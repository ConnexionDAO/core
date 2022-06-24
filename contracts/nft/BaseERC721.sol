// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract BaseERC721 is ERC721, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdCounter;
  Counters.Counter private _randomCounter;

  constructor() ERC721("MyToken", "MTK") {}

  function mintRandom(address to) external {
    _safeMint(to, randomUnset(2**256-1));
  }
    
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

  function randomUnset(uint256 maxNumber) internal returns (uint256) {
    uint256 num = random() % maxNumber;
    if (num % 2 == 0) {
      while (num < maxNumber) {
        if (!_exists(num)) return num;
        unchecked {
          num += 1;
        }
      }
      return maxNumber;
    }
    while (num > 0) {
      if (!_exists(num)) return num;
      unchecked {
        num -= 1;
      }
    }
    return maxNumber;
  }
}
