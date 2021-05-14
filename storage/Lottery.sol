// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase {
	//a ticket can be winner only once
	struct Set {
		uint256[] values;
		mapping(uint256 => bool) is_in;
	}

	Set winningNumbers; //winners structure
	uint256 totalWinners; //how many people can participate
	uint256 totalTickets; //total tickets

	/**
	 *------ RANDOM RELATED FUNCTIONS -------
	 */
	bytes32 internal keyHash;
	uint256 internal fee;
	uint256 public randomResult; //chainlink puts it's random number here
	event RequestedRandomness(bytes32 requestId);

	/**
	 * Constructor inherits VRFConsumerBase.
	 *
	 * Network: Rinkeby
	 * Fee: 0.1 LINK
	 * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
	 * LINK token address:                0x01be23585060835e02b77ef475b0cc51aa1e0709
	 * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
	 */
	constructor()
		public
		VRFConsumerBase(
			0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
			0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK Token
		)
	{
		keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
		fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
	}

	/**
	 * Requests randomness from a user-provided seed
	 */
	function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
		requestId = requestRandomness(keyHash, fee, userProvidedSeed);
		emit RequestedRandomness(requestId);
	}

	/**
	 * Callback function used by VRF Coordinator. Note: If your fulfillRandomness function uses more than 200k gas, the transaction will fail.
	 */
	function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
		randomResult = randomness;
	}

	/**
	 * Withdraw LINK from this contract
	 */
	function withdrawLink() external {
		require(msg.sender == 0x00000004Af22764bb04ddf4402Fd35F6e3011123, "only owner"); //change to modifer
		require(LINK.transfer(msg.sender, LINK.balanceOf(address(this))), "Unable to transfer");
	}

	/**
	 *------ END RANDOM RELATED FUNCTIONS -------
	 */

	//lottery start is initialized with totalWinners & totalTickets
	//modifier: called by some admin role
	function startLottery(uint256 _totalWinners, uint256 _totalTickets) external {
		require(totalWinners <= totalTickets, "more winners than tickets");
		totalWinners = _totalWinners;
		totalTickets = _totalTickets;
	}

	/**
	@dev
		gas intesive function! carefull. requires LINK tokens (100 winners with 1000 tickets = ~ 4,726,134 gas!!!)
	 and the chainlink fee
	 modifier: called by some admin role or non-reentrant after some condition, by public
	 limit parameter is used if you have many winners and potentially it would go over some gas limits
	 */

	function pickWinners(uint256 limit) external {
		require(winningNumbers.values.length < totalWinners, "you have enough winners");

		getRandomNumber(block.timestamp);
		for (uint256 i = 0; i < limit; i++) {
			if (winningNumbers.values.length >= totalWinners) {
				return;
			}
			addToSet((uint256(keccak256(abi.encode(randomResult, i))) % totalTickets) + 1);
		}
	}

	//returns the winners
	function getWinners() public view returns (uint256[] memory) {
		return winningNumbers.values;
	}

	//used with the set to check for uniqueness
	function addToSet(uint256 a) public {
		if (!winningNumbers.is_in[a]) {
			winningNumbers.values.push(a);
			winningNumbers.is_in[a] = true;
		}
	}
}
