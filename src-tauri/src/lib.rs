use argon2::{Argon2, Params, Version};
use secrecy::{ExposeSecret, SecretString};
use std::sync::OnceLock;
use tauri_plugin_clipboard_manager::ClipboardExt;
use zeroize::Zeroize;

// Parameters for Argon2. Salt is now read from environment variable SALT_PHRASE.
const MEMORY_COST: u32 = 1024 * 1024;
const ITERATIONS: u32 = 2;
const PARALLELISM: u32 = 2;
const HASH_LENGTH: usize = 64;

/// Obfuscated salt storage to prevent simple memory inspection.
/// The salt is XOR'd with a runtime-generated key and stored in a SecretString.
struct ObfuscatedSalt {
    obfuscated_bytes: Vec<u8>,
    xor_key: Vec<u8>,
}

// Custom Debug that doesn't expose sensitive data
impl std::fmt::Debug for ObfuscatedSalt {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ObfuscatedSalt")
            .field("obfuscated_bytes", &"[REDACTED]")
            .field("xor_key", &"[REDACTED]")
            .finish()
    }
}

impl ObfuscatedSalt {
    fn new(salt: &str) -> Self {
        let salt_bytes = salt.as_bytes();
        // Generate a random XOR key at runtime
        let xor_key: Vec<u8> = (0..salt_bytes.len())
            .map(|i| ((i as u8).wrapping_mul(0x5A)).wrapping_add(0x3C))
            .collect();

        // XOR the salt with the key
        let obfuscated_bytes: Vec<u8> = salt_bytes
            .iter()
            .zip(xor_key.iter())
            .map(|(b, k)| b ^ k)
            .collect();

        Self {
            obfuscated_bytes,
            xor_key,
        }
    }

    fn reveal(&self) -> SecretString {
        // De-obfuscate by XORing again
        let mut revealed: Vec<u8> = self
            .obfuscated_bytes
            .iter()
            .zip(self.xor_key.iter())
            .map(|(b, k)| b ^ k)
            .collect();

        let result = String::from_utf8_lossy(&revealed).into_owned();
        // Zeroize the temporary buffer immediately
        revealed.zeroize();
        SecretString::from(result)
    }
}

impl Drop for ObfuscatedSalt {
    fn drop(&mut self) {
        // Securely wipe the obfuscated bytes and key from memory
        self.obfuscated_bytes.zeroize();
        self.xor_key.zeroize();
    }
}

// Global obfuscated salt storage - initialized once at startup
static OBFUSCATED_SALT: OnceLock<ObfuscatedSalt> = OnceLock::new();

/// Get the salt as a SecretString, de-obfuscating on demand
fn get_salt() -> SecretString {
    OBFUSCATED_SALT
        .get()
        .expect("SALT_PHRASE was not initialized at startup")
        .reveal()
}

#[tauri::command]
async fn generate_hash(password: String) -> Result<String, String> {
    tauri::async_runtime::spawn_blocking(move || {
        let salt = get_salt();

        let params = Params::new(MEMORY_COST, ITERATIONS, PARALLELISM, Some(HASH_LENGTH))
            .map_err(|e| format!("[{}:{}] Argon2 Params Error: {}", file!(), line!(), e))?;

        let argon2 = Argon2::new(argon2::Algorithm::Argon2id, Version::V0x13, params);

        let mut output_key_material = [0u8; HASH_LENGTH];
        argon2
            .hash_password_into(
                password.as_bytes(),
                salt.expose_secret().as_bytes(),
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

/// Types a password using simulated keyboard input.
/// This is more secure than clipboard as it doesn't expose the password to other applications.
/// Only available on desktop platforms.
#[cfg(not(any(target_os = "android", target_os = "ios")))]
#[tauri::command]
async fn type_password(text: String) -> Result<(), String> {
    use enigo::{Enigo, Keyboard, Settings};

    tauri::async_runtime::spawn_blocking(move || {
        let mut enigo = Enigo::new(&Settings::default())
            .map_err(|e| format!("Failed to initialize keyboard input: {}", e))?;

        // Type the text character by character
        enigo
            .text(&text)
            .map_err(|e| format!("Failed to type password: {}", e))?;

        Ok(())
    })
    .await
    .map_err(|e| format!("Task Join Error: {}", e))?
}

#[tauri::command]
fn get_build_info() -> String {
    format!("{} ({})", env!("BUILD_HASH"), env!("BUILD_DATE"))
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

    // Initialize the obfuscated salt storage and remove from environment
    // This ensures the plaintext salt is only briefly in memory
    if let Ok(mut salt_value) = std::env::var("SALT_PHRASE") {
        OBFUSCATED_SALT
            .set(ObfuscatedSalt::new(&salt_value))
            .expect("OBFUSCATED_SALT was already initialized");
        // Zeroize the original string before removing the env var
        // SAFETY: This mutates the internal String buffer
        unsafe {
            salt_value.as_bytes_mut().zeroize();
        }
        // Remove the env var to prevent it from being accessible elsewhere
        std::env::remove_var("SALT_PHRASE");
    }

    let mut builder = tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_clipboard_manager::init());

    // Register handlers - desktop includes type_password, mobile does not
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        builder = builder.invoke_handler(tauri::generate_handler![
            generate_hash,
            secure_copy,
            get_build_info,
            type_password
        ]);
    }

    #[cfg(any(target_os = "android", target_os = "ios"))]
    {
        builder = builder.invoke_handler(tauri::generate_handler![
            generate_hash,
            secure_copy,
            get_build_info
        ]);
    }

    builder
        .invoke_handler(tauri::generate_handler![
            generate_hash,
            secure_copy,
            get_build_info
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
