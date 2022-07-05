// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
  constructor() ERC20("TestERC20", "TET") {
    _mint(msg.sender, 10000 * 10 ** decimals());
  }
}
