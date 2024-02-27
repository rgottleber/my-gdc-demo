<script lang="ts">
	import type { Bird } from '$lib/Game';
	export let bird: Bird;
	export let birdImg: string;
</script>

<section
	style="left: {bird.left}px; top: {bird.top}px; width: {bird.size}px; height: {bird.size}px; "
	class="bird"
>
	<!-- Image  -->
	<img src={birdImg} />
</section>

<style>
	.bird {
		position: absolute;
		/* background-image: url('chick_nobg.png'); */
	}
	img {
		width: 100%;
		height: 100%;
	}
</style>
