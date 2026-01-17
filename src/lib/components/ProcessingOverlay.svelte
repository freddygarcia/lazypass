<script lang="ts">
    /**
     * @component ProcessingOverlay
     * @description Visual overlay shown while generating the token.
     */
</script>

<div class="processing-overlay">
    <div class="scan-line"></div>
    <div class="shield-icon">
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="48"
            height="48"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
            ><path
                d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
            ></path></svg
        >
    </div>
    <p class="status-text">Hardening Memory...</p>
    <div class="pulse-container">
        <div class="pulse-ring"></div>
    </div>
</div>

<style>
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
        0%,
        100% {
            background: rgba(88, 166, 255, 0.05);
        }
        50% {
            background: rgba(88, 166, 255, 0.1);
        }
    }

    .scan-line {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: linear-gradient(
            90deg,
            transparent,
            var(--accent-color),
            transparent
        );
        box-shadow: 0 0 15px var(--accent-color);
        animation: scan 1.5s infinite linear;
        z-index: 10;
    }

    @keyframes scan {
        0% {
            top: -10%;
            opacity: 0;
        }
        10% {
            opacity: 1;
        }
        90% {
            opacity: 1;
        }
        100% {
            top: 110%;
            opacity: 0;
        }
    }

    .shield-icon {
        color: var(--accent-color);
        margin-bottom: 1rem;
        animation: float 2s infinite ease-in-out;
    }

    @keyframes float {
        0%,
        100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-10px);
        }
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
        0% {
            transform: scale(0.5);
            opacity: 0.5;
        }
        100% {
            transform: scale(2);
            opacity: 0;
        }
    }
</style>
