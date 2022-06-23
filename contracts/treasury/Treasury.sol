// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

abstract contract Treasury is AccessControl {
  using Timers for Timers.BlockNumber;
  using Counters for Counters.Counter;
  using SafeCast for uint256;

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant GOVERNOR = keccak256("GOVERNOR_ROLE");
  struct Schedule {
    Timers.BlockNumber release;
    uint64 maxPercent;
    uint256 maxAmount;
  }
  mapping(uint256 => Schedule) private _schedule;
  Counters.Counter private _schedule_count;
  bool private locked;

  constructor() {
    _setupRole(GOVERNOR, _msgSender());
    _setupRole(GOVERNOR, address(this));
  }
  function setSchedule(uint64 offset, uint64 maxPercent, uint256 maxAmount) external {
    _schedule_count.increment();
    Schedule storage schedule = _schedule[_schedule_count.current()];
    require(schedule.release.isUnset(), "Schedule Created");
    
    schedule.release.setDeadline(block.number.toUint64() + offset);
    schedule.maxPercent = maxPercent;
    schedule.maxAmount = maxAmount;
    _schedule[_schedule_count.current()] = schedule;
  }
  function contribute() external payable {}
  function release() external {}
  function lock() external {}
  function unlock() external {}
  function claim() external {}
}