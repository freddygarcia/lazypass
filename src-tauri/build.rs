fn main() {
    let _ = dotenvy::dotenv();
    match std::env::var("SALT_PHRASE") {
        Ok(salt) if salt.is_empty() => {
            panic!("SALT_PHRASE environment variable is set but empty. Please provide a non-empty salt phrase.");
        }
        Ok(salt) => {
            println!("cargo:rustc-env=SALT_PHRASE={}", salt);
        }
        Err(_) => {
            panic!("SALT_PHRASE environment variable is not set. Please set it in your .env file or environment.");
        }
    }

    // Read build hash from environment variable (set by CI or manually)
    let build_hash = std::env::var("BUILD_HASH").unwrap_or_else(|_| "dev".to_string());
    println!("cargo:rustc-env=BUILD_HASH={}", build_hash);

    // Read build date from environment variable
    let build_date = std::env::var("BUILD_DATE").unwrap_or_else(|_| "unknown".to_string());
    println!("cargo:rustc-env=BUILD_DATE={}", build_date);

    println!("cargo:rerun-if-env-changed=BUILD_HASH");
    println!("cargo:rerun-if-env-changed=BUILD_DATE");
    println!("cargo:rerun-if-changed=.env");
    tauri_build::build()
}
