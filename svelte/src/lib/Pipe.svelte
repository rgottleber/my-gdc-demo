<script lang="ts">
	import type { PipePair } from '$lib/Game';
	export let pipe: PipePair;
</script>

{#if pipe.show}
	<section
		style="left: {pipe.left}px; top: {pipe.topPipe.top}px; width: {pipe.width}px; height: {pipe
			.topPipe.height}px;"
		class="top-pipe pipe-top"
	/>
	<section
		style="left: {pipe.left}px; top: {pipe.bottomPipe.top}px; width: {pipe.width}px; height: {pipe
			.bottomPipe.height}px;"
		class="top-bottom pipe-bottom"
	/>
{/if}

<style>
	.pipe-top {
		position: absolute;
		/* background color of teal and pink gradient */
		background: linear-gradient(180deg, rgba(0, 255, 255, 1) 0%, rgba(255, 0, 255, 1) 100%);
		/* background-color: palegreen; */
	}
	.pipe-bottom {
		position: absolute;
		/* background color of teal and pink gradient */
		background: linear-gradient(360deg, rgba(0, 255, 255, 1) 0%, rgba(255, 0, 255, 1) 100%);
		/* background-color: palegreen; */
	}
</style>
