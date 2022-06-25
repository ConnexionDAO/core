// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract BaseERC721 is ERC721, Ownable {
  using Counters for Counters.Counter;
  using Timers for Timers.BlockNumber;

  Counters.Counter private _randomCounter;

  constructor() ERC721("MyToken", "MTK") {}

  function mintRandom(address to, uint256 start, uint256 end) external {}

  function createCollection(uint256 number) external {}

  function random() internal returns(uint256) {
    _randomCounter.increment();
    return uint256(
      keccak256(
        abi.encodePacked(
          block.timestamp, block.difficulty, _randomCounter.current()
        )
      )
    );
  }
}
