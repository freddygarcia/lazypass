fn main() {
    let _ = dotenvy::dotenv();
    if let Ok(salt) = std::env::var("SALT_PHRASE") {
        println!("cargo:rustc-env=SALT_PHRASE={}", salt);
    }
    println!("cargo:rerun-if-changed=.env");
    tauri_build::build()
}
