<script lang="ts">
	import { ethers } from 'ethers';
	export let web3Props: Web3Props;
	export let contractAddr: string;
	export let contractAbi: any;

	async function connectWallet() {
		let provider = new ethers.providers.Web3Provider(window.ethereum, 'any');
		await provider.send('eth_requestAccounts', []);
		const signer = provider.getSigner();
		const chainId = await signer.getChainId();
		if (chainId != 43113) {
			await window.ethereum.request({
				method: 'wallet_addEthereumChain',
				params: [
					{
						chainId: '0xa869',
						rpcUrls: ['https://api.avax-test.network/ext/bc/C/rpc'],
						chainName: 'Avalanche Fuji Testnet',
						nativeCurrency: {
							name: 'AVAX',
							symbol: 'AVAX',
							decimals: 18
						},
						blockExplorerUrls: ['https://testnet.snowtrace.io']
					}
				]
			});
		}
		const account = await signer.getAddress();
		const contract = new ethers.Contract(contractAddr, contractAbi.abi, signer);
		web3Props = { signer, provider, chainId, account, contract };
	}
</script>

{#if !web3Props?.account}
	<button class="btn" on:click={connectWallet}>Attach Wallet</button>
{/if}

<style>
	.btn {
		display: inline-flex;
		flex-shrink: 0;
		cursor: pointer;
		-webkit-user-select: none;
		-moz-user-select: none;
		user-select: none;
		flex-wrap: wrap;
		align-items: center;
		justify-content: center;
		border-color: transparent;
		border-color: hsl(var(--n) / var(--tw-border-opacity));
		text-align: center;
		transition-property: color, background-color, border-color, fill, stroke, opacity, box-shadow,
			transform, filter, -webkit-text-decoration-color, -webkit-backdrop-filter;
		transition-property: color, background-color, border-color, text-decoration-color, fill, stroke,
			opacity, box-shadow, transform, filter, backdrop-filter;
		transition-property: color, background-color, border-color, text-decoration-color, fill, stroke,
			opacity, box-shadow, transform, filter, backdrop-filter, -webkit-text-decoration-color,
			-webkit-backdrop-filter;
		transition-duration: 0.2s;
		transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
		border-radius: var(--rounded-btn, 0.5rem);
		height: 3rem;
		padding-left: 1rem;
		padding-right: 1rem;
		font-size: 0.875rem;
		line-height: 1.25rem;
		line-height: 1em;
		min-height: 3rem;
		font-weight: 600;
		text-transform: uppercase;
		text-transform: var(--btn-text-case, uppercase);
		-webkit-text-decoration-line: none;
		text-decoration-line: none;
		border-width: var(--border-btn, 1px);
		-webkit-animation: button-pop var(--animation-btn, 0.25s) ease-out;
		animation: button-pop var(--animation-btn, 0.25s) ease-out;
		--tw-border-opacity: 1;
		--tw-bg-opacity: 1;
		background-color: hsl(var(--n) / var(--tw-bg-opacity));
		--tw-text-opacity: 1;
		color: hsl(var(--nc) / var(--tw-text-opacity));

		--nc: 238 99% 83%;
		--n: 238 43% 17%;
		--tw-border-opacity: 1;
		--rounded-btn: 1rem;
		--btn-text-case: uppercase;
		--border-btn: 1px;
		--animation-btn: 0.25s;
		--tw-bg-opacity: 1;
		--tw-text-opacity: 1;
	}
</style>
