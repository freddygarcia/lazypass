<script lang="ts">
    /**
     * @component ResultArea
     * @description Displays the generated hash and copy actions.
     * @prop {string} hash - The generated hash.
     * @prop {boolean} copying - Whether the hash has been copied.
     * @prop {number} countdown - Countdown timer value for clearing.
     * @prop {() => void} onCopy - Callback when copy button is clicked.
     */
    let { hash, copying, countdown, onCopy } = $props();

    let revealHash = $state(false);

    function toggleReveal() {
        revealHash = !revealHash;
    }
</script>

<div class="result-area">
    <label>Generated Hash</label>
    <div class="hash-container" class:copied={copying}>
        <code class="hash-text" class:masked={!revealHash}>
            {revealHash
                ? `${hash.slice(0, 4)}...${hash.slice(-4)} (${hash.length})`
                : `****...**** (${hash.length})`}
        </code>
        <div class="action-wrapper">
            <button
                class="reveal-btn"
                onclick={toggleReveal}
                aria-label={revealHash
                    ? "Hide hash"
                    : "Reveal hash"}
            >
                {#if revealHash}
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="20"
                        height="20"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        ><path
                            d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"
                        ></path><line
                            x1="1"
                            y1="1"
                            x2="23"
                            y2="23"
                        ></line></svg
                    >
                {:else}
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="20"
                        height="20"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        ><path
                            d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8-11-8z"
                        ></path><circle cx="12" cy="12" r="3"
                        ></circle></svg
                    >
                {/if}
            </button>
            <div class="copy-wrapper">
                {#if copying}
                    <div class="copy-badge">
                        Cleared in {countdown}s
                    </div>
                {/if}
                <button
                    class="copy-btn"
                    onclick={onCopy}
                    aria-label="Copy hash"
                    class:success={copying}
                >
                    {#if copying}
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="20"
                            height="20"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            ><polyline points="20 6 9 17 4 12"
                            ></polyline></svg
                        >
                    {:else}
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="20"
                            height="20"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            ><rect
                                x="9"
                                y="9"
                                width="13"
                                height="13"
                                rx="2"
                                ry="2"
                            ></rect><path
                                d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"
                            ></path></svg
                        >
                    {/if}
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .result-area {
        margin-top: 1rem;
        animation: slideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1);
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    label {
        font-size: 0.8rem;
        font-weight: 700;
        color: var(--text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.5px;
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

    @media (max-width: 600px) {
        .hash-container {
            flex-direction: column;
            align-items: stretch;
            gap: 0.5rem;
        }
    }

    .hash-text {
        flex: 1;
        font-family: "JetBrains Mono", "Fira Code", monospace;
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

    @media (max-width: 600px) {
        .action-wrapper {
            width: 100%;
            justify-content: center;
        }
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
        animation: badgePop 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)
            forwards;
        pointer-events: none;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    }

    .copy-badge::after {
        content: "";
        position: absolute;
        bottom: -6px;
        left: 50%;
        transform: translateX(-50%);
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        border-top: 6px solid var(--success-color);
    }

    @keyframes badgePop {
        0% {
            opacity: 0;
            transform: translate(-50%, 10px);
        }
        100% {
            opacity: 1;
            transform: translate(-50%, 0);
        }
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
</style>
