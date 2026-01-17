<script lang="ts">
    /**
     * @component PasswordInput
     * @description Password input field with visibility toggle.
     * @prop {string} value - The password value (bindable).
     * @prop {boolean} disabled - Whether the input is disabled.
     * @prop {() => void} onSubmit - callback when Enter is pressed.
     */
    let { value = $bindable(), disabled = false, onSubmit } = $props();

    let showPassword = $state(false);

    function toggleVisibility() {
        showPassword = !showPassword;
    }

    function handleKeydown(e: KeyboardEvent) {
        if (e.key === "Enter" && onSubmit) {
            onSubmit();
        }
    }
</script>

<div class="input-group">
    <label for="password">Password</label>
    <div class="password-wrapper">
        <input
            id="password"
            type={showPassword ? "text" : "password"}
            placeholder="Type here"
            bind:value
            disabled={disabled}
            onkeydown={handleKeydown}
        />
        <button
            type="button"
            class="toggle-password"
            onclick={toggleVisibility}
            aria-label={showPassword ? "Hide password" : "Show password"}
            tabindex="-1"
        >
            {#if showPassword}
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
                    ></path><line x1="1" y1="1" x2="23" y2="23"
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
    </div>
</div>

<style>
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
        box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2);
        width: 100%;
        padding-right: 3.5rem;
        box-sizing: border-box;
    }

    input:focus {
        border-color: var(--accent-color);
        box-shadow:
            0 0 0 4px rgba(88, 166, 255, 0.15),
            inset 0 2px 4px rgba(0, 0, 0, 0.2);
        background: #010409;
    }

    .password-wrapper {
        position: relative;
        display: flex;
        align-items: center;
        width: 100%;
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
        outline: none;
    }

    .toggle-password:hover {
        color: var(--text-primary);
        background: rgba(255, 255, 255, 0.05);
    }
</style>
