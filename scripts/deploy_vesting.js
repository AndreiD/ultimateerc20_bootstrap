// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")
require("@nomiclabs/hardhat-web3")

// const ERC20_ABI = require("../utils/erc20_abi.js")
// const VESTING_ABI = require("../utils/vesting_abi.js")

const GASPrice = "10" //!important

function sleep(ms) {
	return new Promise((resolve) => {
		setTimeout(resolve, ms)
	})
}

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	await hre.run("compile")

	// We get the contract to deploy
	const Vesting = await hre.ethers.getContractFactory("Vesting")
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
		"ETH/BNB"
	)

	const theTokenAddress = "0x8ea25718053f081992b987fbbf2e60e2e8f5b0c3"
	let deployed = await Vesting.deploy(theTokenAddress)
	let dep = await deployed.deployed()

	let sleepTime = 180000 //3min sleep
	if (network !== "mainnet") {
		sleepTime = 30000 // 30 seconds sleep
	}
	await sleep(sleepTime)
	await hre.run("verify:verify", {
		address: dep.address,
		constructorArguments: [theTokenAddress],
	})

	//---------- The Operations ----------

	// //give allowance for transfering tokens
	// let erc20contract = new ethers.Contract(baseTokenAddress, ERC20_ABI, deployer)
	// let numberOfTokens = ethers.utils.parseUnits("300000.0", 18) //30% is vested in various wallets
	// let options = { gasLimit: 100000, gasPrice: ethers.utils.parseUnits(GASPrice, "gwei") }
	// let tx = await erc20contract.increaseAllowance(dep.address, numberOfTokens, options)
	// console.log("Vested Allowance Set.....", tx.hash)

	// //-------------- TEAM VESTING --------------
	// let wallet = "0x1111117Fe854f5CC8BE01Ff0F74605f4F3860cbD" // team
	// let amount = ethers.utils.parseUnits("100000.0", 18)
	// let duration = 365 //days
	// let cliff = 182 //days
	// let vestingContract = new ethers.Contract(dep.address, VESTING_ABI, deployer)
	// let options = { gasLimit: 100000, gasPrice: ethers.utils.parseUnits(GASPrice, "gwei") }
	// let tx = await erc20contract.addTokenGrant(wallet, amount, duration, cliff)
	// console.log("Vested Grant Created For Team.....", tx.hash)
	// //------------------------------------------

	// //-------------- RESERVES VESTING --------------
	// wallet = "0x11111190553D6177CA22c53fCA807871FAE687Cf" // reserves
	// amount = ethers.utils.parseUnits("100000.0", 18)
	// duration = 365 //days
	// cliff = 182 //days
	// tx = await erc20contract.addTokenGrant(wallet, amount, duration, cliff)
	// console.log("Vested Grant Created For Reserves.....", tx.hash)
	// //------------------------------------------
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
