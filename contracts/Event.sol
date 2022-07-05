// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

abstract contract Event {
  using Timers for Timers.BlockNumber;
  using SafeCast for uint256;
  
  enum EventState {
    FUND_RAISING,
    FUND_RAISED,
    EVENT_NOW,
    EVENT_ENDED,
    PAUSED
  }

  struct EventStruct {
    address governor;
    address treasury;
    address nft;
    Timers.BlockNumber fundingDeadline;
    uint256 raise;
    EventState state;
  }

  string private _name;
  mapping(uint256 => EventStruct) private _events;

  function create() external {}
  function setPaused(bool value) external {}
  function setFundRaising() external {}
  function setFundRaised() external {}
  function setEventNow() external {}
  function setEventEnded() external {}
  function state(uint256 eventId) internal pure returns (EventState) {
    return EventState.EVENT_NOW;
  }

  function hashEvent() internal pure returns (uint256) {
    return uint256(keccak256(abi.encode()));
  }

  event EventCreated();
  event EventPaused();
  event EventUnpaused();
  event EventFundCollected();
  event EventStarted();
  event EventEnded();
}