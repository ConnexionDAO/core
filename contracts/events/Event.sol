// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEvent.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

abstract contract Event is IEvent {
  using Timers for Timers.BlockNumber;
  using SafeCast for uint256;

  struct EventStruct {
    Timers.BlockNumber fundingEnd;
    uint256 raise;
    bool paused;
    bool eventNow;
    bool eventEnded;
  }

  string private _name;
  mapping(uint256 => EventStruct) private _events;

  function state(uint256 eventId) public view virtual returns (EventState) {
    EventStruct memory eventStruct = _events[eventId];
    if (eventStruct.eventEnded) return EventState.EVENT_ENDED;
    if (eventStruct.paused) return EventState.PAUSED;
    if (eventStruct.eventNow) return EventState.EVENT_NOW;
    return EventState.FUND_RAISING;
  }

  function hashEvent(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  ) public pure virtual returns (uint256) {
    return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
  }

  function createEvent(
    
  ) public virtual {
    EventStruct storage eventStruct = _events[1];
    uint64 snapshot = block.number.toUint64() + 10;
    eventStruct.fundingEnd.setDeadline(snapshot);
  }
}