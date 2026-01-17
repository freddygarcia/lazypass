<script lang="ts">
    /**
     * @component AuthCard
     * @description Displays the authentication lock screen.
     * @prop {string} authError - Error message to display if authentication fails.
     * @prop {() => void} onAuthenticate - Callback function to trigger authentication.
     */
    let { authError, onAuthenticate } = $props();
</script>

<div class="card auth-card">
    <div class="auth-icon">
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="64"
            height="64"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
            ><rect x="3" y="11" width="18" height="11" rx="2" ry="2"
            ></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg
        >
    </div>
    <h2>LazyPass Locked</h2>
    <p class="subtitle">Authenticate to access</p>

    <button class="generate-btn" onclick={onAuthenticate}>
        Authenticate
    </button>
    {#if authError}
        <p class="error">{authError}</p>
    {/if}
</div>

<style>
    .auth-card {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
    }

    .auth-icon {
        color: var(--accent-color);
        margin-bottom: 1.5rem;
        padding: 1rem;
        background: rgba(88, 166, 255, 0.1);
        border-radius: 50%;
        animation: pulse 2s infinite;
    }

    h2 {
        margin: 0;
        margin-bottom: 0.5rem;
        color: var(--text-primary);
    }

    .subtitle {
        color: var(--text-secondary);
        font-size: 0.9rem;
        margin-bottom: 2rem;
    }

    .generate-btn {
        width: 100%;
        padding: 1.1rem;
        border-radius: 14px;
        border: none;
        background: linear-gradient(
            135deg,
            var(--accent-color),
            var(--accent-hover)
        );
        color: white;
        font-size: 1.1rem;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 4px 15px rgba(88, 166, 255, 0.3);
    }

    .generate-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(88, 166, 255, 0.4);
    }

    .error {
        color: var(--error-color);
        margin-top: 1rem;
    }

    @keyframes pulse {
        0% {
            box-shadow: 0 0 0 0 rgba(88, 166, 255, 0.4);
        }
        70% {
            box-shadow: 0 0 0 10px rgba(88, 166, 255, 0);
        }
        100% {
            box-shadow: 0 0 0 0 rgba(88, 166, 255, 0);
        }
    }
</style>
