// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";

/**
 * TODO:
 * Access Control
 * Modularisation
 * Parameterisation
 */
abstract contract Treasury is Ownable {
  using Timers for Timers.BlockNumber;
  using Counters for Counters.Counter;
  using SafeCast for uint256;
  using SafeERC20 for IERC20;
  using Math for uint256;

  struct Schedule {
    Timers.BlockNumber release;
    uint256 amount;
    address receipient;
    bool fulfilled;
  }
  mapping(uint256 => Schedule) private _schedule;
  Counters.Counter private _scheduleCount;
  Timers.BlockNumber private _releaseDate;

  IERC20 private _governanceToken;
  IERC20 private _treasuryToken;
  bool private _treasuryCoin;

  uint256 private _minContribution;
  bool private _locked;

  constructor() {}

  modifier lockable {
    require(!_locked);
    _;
  }

  function setSchedule(uint64 offset, uint256 amount, address receipient) external {
    // check valid schedule id
    _scheduleCount.increment();
    uint256 scheduleId = _scheduleCount.current();
    require(
      _schedule[scheduleId].release.isUnset(),
      "Treasury: invalid schedule id"
    );

    // set new schedule
    _schedule[scheduleId] = Schedule({
      release: Timers.BlockNumber({
        _deadline: block.number.toUint64() + offset
      }),
      amount: amount,
      receipient: receipient,
      fulfilled: false
    });
    emit ScheduleSet(_schedule[scheduleId]);
  }

  function receiveToken(uint256 amount) external payable {
    if (_treasuryCoin) {
      require(msg.value >= _minContribution, "Treasury: min contribution not reached");
      _governanceToken.safeTransferFrom(address(this), msg.sender, amount * exchangeRate());
      emit ReceivedToken(msg.sender, msg.value);
      return;
    }
    require(amount >= _minContribution, "Treasury: min contribution not reached");
    _treasuryToken.safeTransferFrom(msg.sender, address(this), amount);
    _governanceToken.safeTransferFrom(address(this), msg.sender, amount * exchangeRate());
    emit ReceivedToken(msg.sender, amount);
  }

  function releaseToken(uint256 scheduleId) external lockable {
    Schedule storage schedule = _schedule[scheduleId];
    require(schedule.release.isExpired(), "Treasury: release date not reached");
    require(!schedule.fulfilled, "Treasury: schedule has been fulfilled");
    // transfer treasury
    _schedule[scheduleId].fulfilled = true;
    transferTreasury(schedule.receipient, schedule.amount.min(treasurySupply()));
    emit ReleaseToken(_schedule[scheduleId]);
  }

  function claim(uint256 amount) external lockable {
    _governanceToken.safeTransferFrom(msg.sender, address(this), amount);
    transferTreasury(msg.sender, amount / exchangeRate());
    emit ClaimToken(msg.sender, amount, exchangeRate());
  }

  function setLock(bool value) external {
    _locked = value;
    emit SetLock(value);
  }

  function transferTreasury(address to, uint256 amount) internal {
    require(amount > 0, "Treasury: cannot transfer zero value");
    require(amount <= treasurySupply(), "Treasury: insufficient treasury supply");
    if (_treasuryCoin) {
      payable(to).transfer(amount);
      return;
    }
    _treasuryToken.safeTransferFrom(address(this), to, amount);
  }

  function exchangeRate() internal view returns (uint256) {
    return (
      _governanceToken.totalSupply() - _governanceToken.balanceOf(address(this))
    ) / treasurySupply();
  }

  function treasurySupply() internal view returns (uint256) {
    if (_treasuryCoin) {
      return address(this).balance;
    }
    return _treasuryToken.balanceOf(address(this));
  }

  event ReceivedToken (address sender, uint256 amount);
  event ScheduleSet (Schedule schedule);
  event ReleaseToken (Schedule schedule);
  event ClaimToken (address sender, uint256 amount, uint256 exchangeRate);
  event SetLock(bool locked);
}