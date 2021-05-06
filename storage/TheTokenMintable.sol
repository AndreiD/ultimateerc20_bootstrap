// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract TheTokenMintable is ERC20Permit, ERC20Burnable, Ownable {
	constructor() ERC20Permit("TheTokenMintable") ERC20("TheTokenMintable Coin", "SYMBOL") {
		_mint(msg.sender, 100000000 * (10**uint256(18)));
	}

	//the mint
	function mint(address to, uint256 amount) public onlyOwner {
		_mint(to, amount);
	}

	// withdraw currency accidentally sent to the smart contract
	function withdraw() public onlyOwner {
		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

	// reclaim accidentally sent tokens
	function reclaimToken(IERC20 token) public onlyOwner {
		require(address(token) != address(0));
		uint256 balance = token.balanceOf(address(this));
		token.transfer(msg.sender, balance);
	}
}
