<script lang="ts">
    /**
     * @component ResetButton
     * @description Button to reset the application state.
     * @prop {() => void} onclick - Click handler.
     */
    let { onclick } = $props();
</script>

<button
    class="reset-btn"
    {onclick}
    aria-label="Reset Application"
    title="Reset Everything"
>
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
        ><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"
        ></path><path d="M3 3v5h5"></path></svg
    >
</button>

<style>
    .reset-btn {
        position: absolute;
        top: 1.5rem;
        right: 1.5rem;
        background: transparent;
        border: none;
        color: var(--text-secondary);
        cursor: pointer;
        padding: 8px;
        border-radius: 50%;
        transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 20;
        display: flex;
        align-items: center;
        justify-content: center;
        -webkit-tap-highlight-color: transparent;
        -webkit-touch-callout: none;
        user-select: none;
        outline: none;
    }

    .reset-btn:hover {
        background: rgba(248, 81, 73, 0.1);
        color: var(--error-color);
        transform: rotate(-180deg);
    }

    .reset-btn:focus {
        outline: none;
    }

    .reset-btn:active {
        background: rgba(248, 81, 73, 0.2);
        transform: rotate(-180deg) scale(0.95);
    }
</style>
