const hre = require("hardhat")
require("@nomiclabs/hardhat-web3")
const fs = require("fs-extra")

function sleep(ms) {
	return new Promise((resolve) => {
		setTimeout(resolve, ms)
	})
}
async function main() {
	fs.removeSync("cache")
	fs.removeSync("artifacts")
	await hre.run("compile")

	// We get the contract to deploy
	const TheToken = await hre.ethers.getContractFactory("Lottery")

	let network = process.env.NETWORK ? process.env.NETWORK : "rinkeby"
	console.log("Deploying Contract >-> Network is set to " + network)

	const [deployer] = await ethers.getSigners()
	const deployerAddress = await deployer.getAddress()
	const account = await web3.utils.toChecksumAddress(deployerAddress)
	const balance = await web3.eth.getBalance(account)

	console.log(deployerAddress + " has: " + web3.utils.fromWei(balance, "ether"), "ETH")

	const deployed = await TheToken.deploy()
	let dep = await deployed.deployed()

	console.log("Contract deployed to >-> ", dep.address)

	let sleepTime = 600000 //10min sleep
	if (network !== "mainnet") {
		sleepTime = 60000 //1 min sleep
	}
	await sleep(sleepTime)
	await hre.run("verify:verify", {
		address: dep.address,
		constructorArguments: [],
	})
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
