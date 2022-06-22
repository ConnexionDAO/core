// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEvent {
  enum ProtocolState {
    FUND_RAISING,
    FUND_COLLECTED,
    EVENT_NOW,
    EVENT_ENDED,
    PAUSED
  }
  event EventCreated();
  event EventPaused();
  event EventUnpaused();
  event EventFundCollected();
  event EventStarted();
  event EventEnded();

  function name() external view returns (string memory);
  function state(uint256 eventId) external view returns (ProtocolState);
}