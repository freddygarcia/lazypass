use argon2::{Argon2, Params, Version};
use tauri_plugin_clipboard_manager::ClipboardExt;

// Parameters for Argon2. Salt is now read from environment variable SALT_PHRASE.
const MEMORY_COST: u32 = 512 * 1024;
const ITERATIONS: u32 = 2;
const PARALLELISM: u32 = 2;
const HASH_LENGTH: usize = 32;

#[tauri::command]
async fn generate_hash(password: String) -> Result<String, String> {
    tauri::async_runtime::spawn_blocking(move || {
        let salt = std::env::var("SALT_PHRASE").expect(
            "SALT_PHRASE environment variable not found (should have been checked at startup)",
        );

        let params = Params::new(MEMORY_COST, ITERATIONS, PARALLELISM, Some(HASH_LENGTH))
            .map_err(|e| format!("[{}:{}] Argon2 Params Error: {}", file!(), line!(), e))?;

        let argon2 = Argon2::new(argon2::Algorithm::Argon2id, Version::V0x13, params);

        let mut output_key_material = [0u8; HASH_LENGTH];
        argon2
            .hash_password_into(
                password.as_bytes(),
                salt.as_bytes(),
                &mut output_key_material,
            )
            .map_err(|e| format!("[{}:{}] Hashing Error: {}", file!(), line!(), e))?;

        Ok(output_key_material
            .iter()
            .map(|b| format!("{:02x}", b))
            .collect())
    })
    .await
    .map_err(|e| format!("Task Join Error: {}", e))?
}

#[tauri::command]
async fn secure_copy(app: tauri::AppHandle, text: String) -> Result<(), String> {
    app.clipboard()
        .write_text(text.clone())
        .map_err(|e| e.to_string())?;

    // Spawn a background task to clear the clipboard after 10 seconds

    // first, create a 10 seconds const
    const CLIPBOARD_CLEAR_DURATION: std::time::Duration = std::time::Duration::from_secs(10);

    tauri::async_runtime::spawn(async move {
        tokio::time::sleep(CLIPBOARD_CLEAR_DURATION).await;
        if let Ok(current) = app.clipboard().read_text() {
            // Only clear if the user hasn't copied something else
            if current == text {
                let _ = app.clipboard().write_text("");
            }
        }
    });

    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    dotenvy::dotenv().ok();

    // Fallback to compile-time env var if runtime is missing (fixes Android .env issue)
    if std::env::var("SALT_PHRASE").is_err() {
        if let Some(salt) = option_env!("SALT_PHRASE") {
            std::env::set_var("SALT_PHRASE", salt);
        } else {
            log::error!(
                "SALT_PHRASE environment variable is not set and no compile-time fallback found."
            );
        }
    }

    let mut builder = tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_clipboard_manager::init());

    #[cfg(mobile)]
    {
        builder = builder.plugin(tauri_plugin_biometric::init());
    }

    builder
        .invoke_handler(tauri::generate_handler![generate_hash, secure_copy])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
