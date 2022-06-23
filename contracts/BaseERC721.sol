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

  function safeMint(address to) public onlyOwner {
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(to, tokenId);
  }
    
  function random(uint256 maxNumber) internal returns(uint256) {
    _randomCounter.increment();
    return uint256(
      keccak256(
        abi.encodePacked(
          block.timestamp, block.difficulty, _randomCounter.current()
        )
      )
    ) % maxNumber;
  }
}
