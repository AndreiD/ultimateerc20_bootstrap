// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ElCheapo is ERC20, Ownable {
	constructor() ERC20("NAME", "SYM") {
		address _owner = 0x4cbB78f5725FFba9A3Dae80F01d308403C4fe2c7;
		_mint(_owner, 1000000000 * (10**uint256(18)));
		transferOwnership(_owner);
	}
}
