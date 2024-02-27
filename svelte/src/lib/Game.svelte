<script lang="ts">
	import { GameController } from './Game';
	import Pipe from '$lib/Pipe.svelte';
	import Bird from '$lib/Bird.svelte';
	const game = new GameController();
	export let web3Props: Web3Props;
	export let contractAddr: string;
	let frame = game.newGame();
	let score: number | null = null;
	let multiplier: number;
	$: imageURL = null;
	let nftID: number;
	let _nftID: number;
	async function loadScore() {
		nftID = await web3Props.contract.addressToTokenId(web3Props.account);
		imageURL = await web3Props.contract.imageURL(nftID);
		score = await web3Props.contract.score(nftID);
		multiplier = await web3Props.contract.multiplier();
		_nftID = nftID.toNumber();
	}
	loadScore();
	setInterval(() => {
		frame = game.nextFrame(multiplier);
	}, 1000 / 60);

	function jump() {
		game.jump();
	}

	async function startGame() {
		await loadScore();
		frame = game.start(multiplier);
	}

	async function updateNFT() {
		const nftID = await web3Props.contract.addressToTokenId(web3Props.account);
		web3Props.contract.updateScore(nftID, frame.score);
	}
	async function resetNFT() {
		const nftID = await web3Props.contract.addressToTokenId(web3Props.account);
		web3Props.contract.updateScore(nftID, 0);
	}
	async function mintNFT() {
		let txn = await web3Props.contract.mint();
		txn.wait();
		await loadScore();
	}
</script>

<main style="width: {frame.width}px; height: {frame.height}px;" class="game">
	<Pipe pipe={frame.firstPipe} />
	<Pipe pipe={frame.secondPipe} />

	{#if _nftID == 0}
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<h1 style="background-color:lightgreen " on:click={mintNFT}>Mint NFT</h1>
	{:else}
		{#if frame.gameOver || !frame.gameStarted}
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<h1 style="background-color:lightgreen " on:click={startGame}>Start Game</h1>
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<h1 style="top: 70%;" on:click={resetNFT}>Reset NFT</h1>
			{#if frame.gameOver}
				<h2>Game Over</h2>
				<h3>Score: {frame.score}</h3>
				{#if frame.score > score}
					<!-- svelte-ignore a11y-click-events-have-key-events -->
					<h3 style="top: 60%; background-color:gold;" on:click={updateNFT}>
						New High Score: Update NFT
					</h3>
				{/if}
				<!-- svelte-ignore a11y-click-events-have-key-events -->
				<h3
					style="top: 65%;"
					on:click={window.open(
						`https://testnets.opensea.io/assets/avalanche-fuji/${contractAddr}/${nftID}`,
						'_blank'
					)}
				>
					View NFT
				</h3>
			{/if}
		{/if}
		<div class="highscore">Previous High Score: {score}</div>
		<div class="multiplier">Current Score Multiplier: {multiplier}</div>
		{#if imageURL}
			<Bird bird={frame.bird} bind:birdImg={imageURL} />
		{/if}
	{/if}
	<section style="height: {frame.ground.height}px;" id="ground" />
	<section id="score">{frame.score}</section>
</main>
<svelte:window on:keydown={jump} on:click={jump} />

<style>
	h1 {
		position: absolute;
		text-align: center;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		background: white;
	}
	/* center h2 horizontally */
	h2 {
		position: absolute;
		text-align: center;
		top: 30%;
		left: 50%;
		background: red;
		transform: translate(-50%, -50%);
	}
	h3 {
		position: absolute;
		text-align: center;
		top: 40%;
		left: 50%;
		background: white;
		transform: translate(-50%, -50%);
	}
	main {
		position: relative;
		border: 1px solid black;
		overflow: hidden;
		/* background-color: lightblue; */
		/* use an image as the background with*/
		background-image: url('/background.png');
		/* change background opacity */
	}
	#ground {
		background-color: brown;
		position: absolute;
		bottom: 0;
		left: 0;
		width: 100%;
	}
	#score {
		position: absolute;
		right: 10px;
		top: 10px;
		font-size: 20px;
		z-index: 10;
		padding: 5px;
		background-color: white;
		user-select: none;
	}
	.multiplier {
		position: absolute;
		left: 10px;
		top: 50px;
		font-size: 20px;
		z-index: 10;
		padding: 5px;
		background-color: white;
		user-select: none;
	}
	.highscore {
		position: absolute;
		left: 10px;
		top: 10px;
		font-size: 20px;
		z-index: 10;
		padding: 5px;
		background-color: white;
		user-select: none;
	}
</style>
