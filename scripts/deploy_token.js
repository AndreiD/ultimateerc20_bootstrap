// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { time } = require("@openzeppelin/test-helpers")
const hre = require("hardhat")
require("@nomiclabs/hardhat-web3")

function sleep(ms) {
	return new Promise((resolve) => {
		setTimeout(resolve, ms)
	})
}

async function main() {
	console.log("REMEMBER TO DELETE ARTIFACTS & CACHE BEFORE DOING THIS!")
	await sleep(5000)
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	await hre.run("compile")

	// We get the contract to deploy
	const TheToken = await hre.ethers.getContractFactory("Links")
	console.log("Deploying Contract...")

	let network = process.env.NETWORK ? process.env.NETWORK : "rinkeby"

	console.log(">-> Network is set to " + network)

	// ethers is avaialble in the global scope
	const [deployer] = await ethers.getSigners()
	const deployerAddress = await deployer.getAddress()
	const account = await web3.utils.toChecksumAddress(deployerAddress)
	const balance = await web3.eth.getBalance(account)

	console.log(
		"Deployer Account " + deployerAddress + " has balance: " + web3.utils.fromWei(balance, "ether"),
		"ETH"
	)

	const deployed = await TheToken.deploy()
	let dep = await deployed.deployed()

	console.log("Contract deployed to:", dep.address)

	let sleepTime = 180000 //3min sleep
	if (network !== "mainnet") {
		sleepTime = 60000 //1 min sleep
	}
	await sleep(sleepTime)
	await hre.run("verify:verify", {
		address: "dep.address",
		constructorArguments: [],
	})
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
