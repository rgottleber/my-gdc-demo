<script lang="ts">
	import Game from '$lib/Game.svelte';
	import WalletConnect from '$lib/WalletConnect.svelte';
	import GameAbi from '../contracts/game.json';
	export let web3Props: Web3Props;
	const contractAddr = '0x90E60e1a8DE7dc50d0A915b00c3c3cf3d9c10525';
</script>

{#if web3Props?.account}
	<Game bind:web3Props {contractAddr} />
{:else}
	<WalletConnect bind:web3Props {contractAddr} contractAbi={GameAbi} />
{/if}
