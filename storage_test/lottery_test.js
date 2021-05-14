const { expect } = require("chai")
const { ethers } = require("hardhat")
const { time, balance } = require("@openzeppelin/test-helpers")

let LotteryC
let lottery
let owner, acc1, acc2

describe("Deploy Lottery", function () {
	beforeEach(async function () {
		LotteryC = await ethers.getContractFactory("Lottery")
	})

	it("Simple test", async function () {
		lottery = await LotteryC.deploy()
		await lottery.deployed()

		await lottery.startLottery(100, 10000)
		await lottery.pickWinners(2000)

		const winners = await lottery.getWinners()
		expect(winners.length).to.equal(100)
	})
})
