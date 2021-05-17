const hre = require("hardhat")
require("@nomiclabs/hardhat-web3")
const fs = require("fs-extra")

async function main() {
	fs.removeSync("cache")
	fs.removeSync("artifacts")
	await hre.run("compile")

	// We get the contract to deploy
	const TheToken = await hre.ethers.getContractFactory("Rave")

	let network = process.env.NETWORK ? process.env.NETWORK : "rinkeby"
	console.log("Deploying Contract >-> Network is set to " + network)

	const [deployer] = await ethers.getSigners()
	const deployerAddress = await deployer.getAddress()
	const account = await web3.utils.toChecksumAddress(deployerAddress)
	const balance = await web3.eth.getBalance(account)

	console.log(deployerAddress + " has: " + web3.utils.fromWei(balance, "ether"), "ETH")

	let quickSwapRouterAddress = "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff" //matic
	if (network === "matic_test") {
		quickSwapRouterAddress = "0xA062fBeab8Da0644bbFAD914F9280912f1A0B333" //?
	}

	const deployed = await TheToken.deploy(quickSwapRouterAddress)
	let dep = await deployed.deployed()

	console.log("Contract deployed to >-> ", dep.address)
	console.log("on matic..verify contracts manually")
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
