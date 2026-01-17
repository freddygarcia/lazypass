<script lang="ts">
    /**
     * @component AppHeader
     * @description Displays the application title, subtitle, and build version.
     */
    let { buildHash } = $props();
</script>

<header>
    <h1>LazyPass</h1>
    <p class="subtitle">Personal Token Generator</p>
    {#if buildHash}
        <span class="build-version">Build: {buildHash}</span>
    {/if}
</header>

<style>
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

    .build-version {
        display: block;
        font-size: 0.65rem;
        color: var(--text-secondary);
        opacity: 0.5;
        margin-top: 0.5rem;
        font-family: "SF Mono", "Fira Code", monospace;
        letter-spacing: 0.5px;
    }
</style>
