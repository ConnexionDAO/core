// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/nft/ERC721Random.sol";

contract EventDeployer is Ownable {
  constructor() {}

  // function deployNFT(
  //   address factory,
  //   address token0,
  //   address token1,
  //   uint24 fee,
  //   int24 tickSpacing
  // ) internal returns (address pool) {
  //   parameters = Parameters({factory: factory, token0: token0, token1: token1, fee: fee, tickSpacing: tickSpacing});
  //   pool = address(new ERC721Random{salt: keccak256(abi.encode(token0, token1, fee))}());
  //   delete parameters;
  // }
}