<script lang="ts">
    /**
     * @component GenerateButton
     * @description Button to trigger hash generation.
     * @prop {boolean} loading - Loading state.
     * @prop {boolean} disabled - Disabled state.
     * @prop {() => void} onclick - Click handler.
     */
    let { loading = false, disabled = false, onclick } = $props();
</script>

<button
    class="generate-btn"
    {onclick}
    disabled={disabled || loading}
>
    {#if loading}
        <span class="loader"></span>
        Processing Token...
    {:else}
        Generate Secure Token
    {/if}
</button>

<style>
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

    .loader {
        width: 20px;
        height: 20px;
        border: 3px solid rgba(255, 255, 255, 0.3);
        border-top: 3px solid white;
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
    }

    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
</style>
