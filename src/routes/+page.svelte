<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";
  import { onMount } from "svelte";

  let password = $state("");
  let hash = $state("");
  let error = $state("");
  let loading = $state(false);
  let revealHash = $state(false);
  let copying = $state(false);
  let showPassword = $state(false);

  async function generateHash() {
    if (!password || loading) {
      if (!password) error = "Please enter a password";
      return;
    }
    error = "";
    hash = "";
    loading = true;

    try {
      hash = await invoke("generate_hash", { password });
    } catch (e) {
      error = String(e);
      console.error(e);
    } finally {
      loading = false;
    }
  }

  let countdown = $state(0);
  let timer: ReturnType<typeof setInterval>;

  function startCountdown() {
    if (timer) clearInterval(timer);
    countdown = 5;
    timer = setInterval(() => {
      countdown--;
      if (countdown <= 0) {
        clearInterval(timer);
        copying = false;
        hash = "";
      }
    }, 1000);
  }

  async function copyToClipboard() {
    if (!hash) return;
    try {
      // Use our new secure Rust command to handle copying and background clearing
      await invoke("secure_copy", { text: hash });
      copying = true;
      password = "";
      startCountdown();
    } catch (err) {
      console.error("Failed to copy using secure_copy!", err);
      // Fallback to standard method if the command fails
      try {
        await navigator.clipboard.writeText(hash);
        copying = true;
        password = "";
        startCountdown();
      } catch (e) {
        console.error("Fallback copy failed too.", e);
      }
    }
  }
</script>

<main class="container">
  <div class="card">
    <header>
      <h1>LazyPass</h1>
      <p class="subtitle">Proprietary Argon2id Token Generator</p>
    </header>

    <div class="input-group">
      <label for="password">Password</label>
      <div class="password-wrapper">
        <input
          id="password"
          type={showPassword ? "text" : "password"}
          placeholder="Enter your secret password..."
          bind:value={password}
          disabled={loading}
          onkeydown={(e) => e.key === 'Enter' && generateHash()}
        />
        <button
          type="button"
          class="toggle-password"
          onclick={() => showPassword = !showPassword}
          aria-label={showPassword ? "Hide password" : "Show password"}
          tabindex="-1"
        >
          {#if showPassword}
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
          {:else}
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
          {/if}
        </button>
      </div>
    </div>

    <button class="generate-btn" onclick={generateHash} disabled={loading}>
      {#if loading}
        <span class="loader"></span>
        Processing Token...
      {:else}
        Generate Secure Token
      {/if}
    </button>

    {#if loading}
      <div class="processing-overlay">
        <div class="scan-line"></div>
        <div class="shield-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
        </div>
        <p class="status-text">Hardening Memory...</p>
        <div class="pulse-container">
          <div class="pulse-ring"></div>
        </div>
      </div>
    {/if}

    {#if hash && !loading}
      <div class="result-area">
        <label>Generated Hash</label>
        <div class="hash-container" class:copied={copying}>
          <code class="hash-text" class:masked={!revealHash}>
            {revealHash ? `${hash.slice(0, 4)}...${hash.slice(-4)} (${hash.length})` : hash.replace(/./g, '•')}
          </code>
          <div class="action-wrapper">
            <button class="reveal-btn" onclick={() => revealHash = !revealHash} aria-label={revealHash ? "Hide hash" : "Reveal hash"}>
              {#if revealHash}
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
              {:else}
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
              {/if}
            </button>
            <div class="copy-wrapper">
              {#if copying}
                <div class="copy-badge">
                   Cleared in {countdown}s
                </div>
              {/if}
              <button class="copy-btn" onclick={copyToClipboard} aria-label="Copy hash" class:success={copying}>
                {#if copying}
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                {:else}
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                {/if}
              </button>
            </div>
          </div>
        </div>
      </div>
    {/if}

    {#if error}
      <p class="error">{error}</p>
    {/if}
  </div>
</main>

<style>
  :root {
    --bg-color: #0d1117;
    --card-bg: rgba(22, 27, 34, 0.9);
    --text-primary: #f0f6fc;
    --text-secondary: #8b949e;
    --accent-color: #58a6ff;
    --accent-hover: #1f6feb;
    --border-color: #30363d;
    --error-color: #f85149;
    --success-color: #3fb950;

    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    background-color: var(--bg-color);
    color: var(--text-primary);
  }

  :global(body) {
    margin: 0;
    padding: 0;
    background-color: var(--bg-color);
    overflow: hidden;
  }

  .container {
    height: 100vh;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: 1.5rem 1.5rem 1.5rem;
    background: radial-gradient(circle at top right, rgba(88, 166, 255, 0.15), transparent),
                radial-gradient(circle at bottom left, rgba(188, 140, 255, 0.1), transparent),
                #0d1117;
  }

  .card {
    width: 100%;
    max-width: 480px;
    padding: 2.5rem;
    background: var(--card-bg);
    backdrop-filter: blur(20px);
    border: 1px solid var(--border-color);
    border-radius: 24px;
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6);
    position: relative;
    overflow: hidden;
    animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
  }

  .card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--accent-color), transparent);
    opacity: 0.5;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px) scale(0.98); }
    to { opacity: 1; transform: translateY(0) scale(1); }
  }

  header {
    text-align: center;
    margin-bottom: 2.5rem;
  }

  h1 {
    font-size: 3rem;
    font-weight: 800;
    margin: 0;
    background: linear-gradient(135deg, #58a6ff 0%, #bc8cff 100%);
    -webkit-background-clip: text;
    background-clip: text;
    -webkit-text-fill-color: transparent;
    letter-spacing: -1.5px;
  }

  .subtitle {
    color: var(--text-secondary);
    font-size: 0.8rem;
    margin-top: 0.5rem;
    text-transform: uppercase;
    letter-spacing: 2px;
    font-weight: 600;
  }

  .input-group {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
  }

  label {
    font-size: 0.8rem;
    font-weight: 700;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  input {
    background: rgba(1, 4, 9, 0.8);
    border: 1px solid var(--border-color);
    border-radius: 14px;
    padding: 1rem 1.2rem;
    color: var(--text-primary);
    font-size: 1.1rem;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    outline: none;
    box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
  }

  input:focus {
    border-color: var(--accent-color);
    box-shadow: 0 0 0 4px rgba(88, 166, 255, 0.15), inset 0 2px 4px rgba(0,0,0,0.2);
    background: #010409;
  }

  .password-wrapper {
    position: relative;
    display: flex;
    align-items: center;
  }

  .password-wrapper input {
    width: 100%;
    padding-right: 3.5rem;
  }

  .toggle-password {
    position: absolute;
    right: 12px;
    background: transparent;
    border: none;
    color: var(--text-secondary);
    cursor: pointer;
    padding: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: color 0.2s;
    border-radius: 8px;
  }

  .toggle-password:hover {
    color: var(--text-primary);
    background: rgba(255, 255, 255, 0.05);
  }

  .generate-btn {
    width: 100%;
    padding: 1.1rem;
    border-radius: 14px;
    border: none;
    background: linear-gradient(135deg, var(--accent-color), var(--accent-hover));
    color: white;
    font-size: 1.1rem;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    margin-bottom: 1.5rem;
    box-shadow: 0 4px 15px rgba(88, 166, 255, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
  }

  .generate-btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(88, 166, 255, 0.4);
    filter: brightness(1.1);
  }

  .generate-btn:disabled {
    background: var(--border-color);
    cursor: not-allowed;
    box-shadow: none;
    opacity: 0.7;
  }

  /* Enhanced Processing Animation */
  .processing-overlay {
    position: relative;
    padding: 2rem 0;
    text-align: center;
    background: rgba(88, 166, 255, 0.05);
    border-radius: 16px;
    border: 1px dashed rgba(88, 166, 255, 0.3);
    margin-top: 1rem;
    overflow: hidden;
    animation: pulseBg 2s infinite ease-in-out;
  }

  @keyframes pulseBg {
    0%, 100% { background: rgba(88, 166, 255, 0.05); }
    50% { background: rgba(88, 166, 255, 0.1); }
  }

  .scan-line {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 4px;
    background: linear-gradient(90deg, transparent, var(--accent-color), transparent);
    box-shadow: 0 0 15px var(--accent-color);
    animation: scan 1.5s infinite linear;
    z-index: 10;
  }

  @keyframes scan {
    0% { top: -10%; opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; }
    100% { top: 110%; opacity: 0; }
  }

  .shield-icon {
    color: var(--accent-color);
    margin-bottom: 1rem;
    animation: float 2s infinite ease-in-out;
  }

  @keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-10px); }
  }

  .status-text {
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--accent-color);
    text-transform: uppercase;
    letter-spacing: 1px;
    margin: 0;
  }

  .pulse-container {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 100px;
    height: 100px;
    pointer-events: none;
  }

  .pulse-ring {
    width: 100%;
    height: 100%;
    border: 2px solid var(--accent-color);
    border-radius: 50%;
    animation: ringPulse 2s infinite;
    opacity: 0;
  }

  @keyframes ringPulse {
    0% { transform: scale(0.5); opacity: 0.5; }
    100% { transform: scale(2); opacity: 0; }
  }

  .result-area {
    margin-top: 1rem;
    animation: slideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  }

  @keyframes slideUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .hash-container {
    margin-top: 0.75rem;
    background: #010409;
    border: 1px solid var(--accent-color);
    border-radius: 14px;
    padding: 1.2rem;
    display: flex;
    align-items: center;
    gap: 1rem;
    box-shadow: 0 0 20px rgba(88, 166, 255, 0.1);
  }

  .hash-text {
    flex: 1;
    font-family: 'JetBrains Mono', 'Fira Code', monospace;
    font-size: 0.9rem;
    word-break: break-all;
    color: var(--text-primary);
    max-height: 120px;
    overflow-y: auto;
    line-height: 1.5;
  }

  .hash-text.masked {
    letter-spacing: 0.25rem;
    color: var(--text-secondary);
    filter: blur(1px);
    opacity: 0.6;
    user-select: none;
  }

  .action-wrapper {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .reveal-btn {
    background: rgba(240, 246, 252, 0.05);
    border: 1px solid var(--border-color);
    color: var(--text-secondary);
    width: 44px;
    height: 44px;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .reveal-btn:hover {
    background: rgba(240, 246, 252, 0.1);
    color: var(--text-primary);
    border-color: var(--accent-color);
  }

  .hash-container.copied {
    border-color: var(--success-color);
    box-shadow: 0 0 15px rgba(63, 185, 80, 0.2);
    transition: all 0.3s ease;
  }

  .copy-wrapper {
    position: relative;
    display: flex;
    align-items: center;
  }

  .copy-badge {
    position: absolute;
    top: -45px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--success-color);
    color: white;
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 0.75rem;
    font-weight: 700;
    white-space: nowrap;
    animation: badgePop 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
    pointer-events: none;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  }

  .copy-badge::after {
    content: '';
    position: absolute;
    bottom: -6px;
    left: 50%;
    transform: translateX(-50%);
    border-left: 6px solid transparent;
    border-right: 6px solid transparent;
    border-top: 6px solid var(--success-color);
  }

  @keyframes badgePop {
    0% { opacity: 0; transform: translate(-50%, 10px); }
    100% { opacity: 1; transform: translate(-50%, 0); }
  }

  .copy-btn {
    background: rgba(240, 246, 252, 0.05);
    border: 1px solid var(--border-color);
    color: var(--text-secondary);
    width: 44px;
    height: 44px;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .copy-btn.success {
    background: var(--success-color);
    border-color: var(--success-color);
    color: white;
  }

  .copy-btn:hover {
    background: var(--accent-color);
    color: white;
    border-color: var(--accent-color);
    transform: scale(1.05);
  }

  .error {
    color: var(--error-color);
    text-align: center;
    font-size: 0.9rem;
    font-weight: 600;
    margin-top: 1.5rem;
    padding: 0.8rem;
    background: rgba(248, 81, 73, 0.1);
    border-radius: 10px;
    border: 1px solid rgba(248, 81, 73, 0.2);
  }

  .loader {
    width: 20px;
    height: 20px;
    border: 3px solid rgba(255,255,255,0.3);
    border-top: 3px solid white;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
