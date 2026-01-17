<script lang="ts">
    import { invoke } from "@tauri-apps/api/core";
    import { authenticate } from "@tauri-apps/plugin-biometric";
    import { onMount } from "svelte";

    import AppHeader from "$lib/components/AppHeader.svelte";
    import AuthCard from "$lib/components/AuthCard.svelte";
    import PasswordInput from "$lib/components/PasswordInput.svelte";
    import GenerateButton from "$lib/components/GenerateButton.svelte";
    import ProcessingOverlay from "$lib/components/ProcessingOverlay.svelte";
    import ResetButton from "$lib/components/ResetButton.svelte";
    import ResultArea from "$lib/components/ResultArea.svelte";

    // Authentication State
    let isAuthenticated = $state(false);
    let authError = $state("");

    // Application State
    let password = $state("");
    let hash = $state("");
    let error = $state("");
    let loading = $state(false);
    let copying = $state(false);
    let buildHash = $state("");
    let countdown = $state(0);
    let timer: ReturnType<typeof setInterval>;

    /**
     * Resets the application to its initial state.
     */
    function resetApp() {
        password = "";
        hash = "";
        error = "";
        loading = false;
        copying = false;
        if (timer) clearInterval(timer);
        countdown = 0;
    }

    /**
     * Generates a secure Argon2id hash from the password.
     */
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

    /**
     * Starts the countdown timer for clipboard clearing.
     */
    function startCountdown() {
        if (timer) clearInterval(timer);
        countdown = 10;
        timer = setInterval(() => {
            countdown--;
            if (countdown <= 0) {
                resetApp();
            }
        }, 1000);
    }

    /**
     * Copies the generated hash to clipboard securely.
     */
    async function copyToClipboard() {
        if (!hash) return;
        try {
            // Use secure Rust command to handle copying and background clearing
            await invoke("secure_copy", { text: hash });
            copying = true;
            password = "";
            startCountdown();
        } catch (err) {
            console.error("Failed to copy using secure_copy!", err);
            // Fallback to standard method
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

    /**
     * Checks biometric authentication.
     */
    async function checkAuth() {
        // Check if we're on a mobile platform
        const isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);

        if (!isMobile) {
            isAuthenticated = true;
            return;
        }

        try {
            await authenticate("Unlock LazyPass");
            isAuthenticated = true;
            authError = "";
        } catch (e) {
            console.error(e);
            authError = "Authentication failed. Please try again.";
        }
    }

    /**
     * Fetches build information on mount.
     */
    async function fetchBuildInfo() {
        try {
            buildHash = await invoke("get_build_info");
        } catch (e) {
            console.error("Failed to fetch build info:", e);
            buildHash = "unknown";
        }
    }

    onMount(() => {
        checkAuth();
        fetchBuildInfo();
    });
</script>

{#if isAuthenticated}
    <main class="container">
        <div class="card">
            <ResetButton onclick={resetApp} />

            <AppHeader {buildHash} />

            <PasswordInput
                bind:value={password}
                disabled={loading}
                onSubmit={generateHash}
            />

            <GenerateButton
                {loading}
                disabled={!password || loading}
                onclick={generateHash}
            />

            {#if loading}
                <ProcessingOverlay />
            {/if}

            {#if hash && !loading}
                <ResultArea
                    {hash}
                    {copying}
                    {countdown}
                    onCopy={copyToClipboard}
                />
            {/if}

            {#if error}
                <p class="error">{error}</p>
            {/if}
        </div>
    </main>
{:else}
    <main class="container">
        <AuthCard {authError} onAuthenticate={checkAuth} />
    </main>
{/if}
