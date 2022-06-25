// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Timers.sol";

abstract contract BaseERC721 is ERC721, Ownable {
  using Counters for Counters.Counter;
  using Timers for Timers.BlockNumber;

  struct Collection {
    uint256 start;
    uint256 end;
  }
  Counters.Counter private _randomCounter;
  Counters.Counter private _collectionsCounter;
  uint256 private _tokenCounter;
  mapping(uint256 => Collection) private _collections;
  mapping(uint256 => uint256) private _collectionBalance;

  constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

  function getCollection(uint256 collectionId) external view returns (Collection memory) {
    return _collections[collectionId];
  }

  function getCollectionBalance(uint256 collectionId) external view returns (uint256) {
    return _collectionBalance[collectionId];
  }

  function createCollection(uint256 number) external {
    uint256 _collectionId = _collectionsCounter.current();
    _collections[_collectionId] = Collection({
      start: _tokenCounter,
      end: _tokenCounter + number - 1
    });
    _collectionsCounter.increment();
    _collectionBalance[_collectionId] = number;
    _tokenCounter += number;
  }

  function mintRandom(address to, uint256 collectionId) external {
    require(
      _collectionsCounter.current() > collectionId,
      "ERC721Random: mint random (request mint of invalid collection)"
    );
    Collection memory range = _collections[collectionId];
    _collectionBalance[collectionId] -= 1;
    _safeMint(to, range.start + random() % (range.end - range.start + 1));
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
}
