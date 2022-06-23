// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";

abstract contract Treasury is AccessControl {
  using Timers for Timers.BlockNumber;
  using Counters for Counters.Counter;
  using SafeCast for uint256;
  using SafeERC20 for IERC20;
  using Math for uint256;

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant GOVERNOR = keccak256("GOVERNOR_ROLE");

  struct Schedule {
    Timers.BlockNumber release;
    uint256 amount;
    address receipient;
    bool fulfilled;
  }
  mapping(uint256 => Schedule) private _schedule;
  Counters.Counter private _schedule_count;
  Timers.BlockNumber private releaseDate;

  IERC20 private governanceToken;
  IERC20 private treasuryToken;
  bool private treasuryCoin;
  uint256 private minContribution;
  bool private locked;

  constructor() {
    _setupRole(GOVERNOR, _msgSender());
    _setupRole(GOVERNOR, address(this));
  }

  function setSchedule(uint64 offset, uint256 amount, address receipient) external {
    _schedule_count.increment();
    Schedule storage schedule = _schedule[_schedule_count.current()];
    require(schedule.release.isUnset(), "Error: Release schedule has been created at id");

    schedule.release.setDeadline(block.number.toUint64() + offset);
    schedule.amount = amount;
    schedule.receipient = receipient;
    schedule.fulfilled = false;
    _schedule[_schedule_count.current()] = schedule;
  }
  
  receive() external payable {
    require(treasuryCoin, "treasury token - use the receiveToken function instead");
    require(msg.value >= minContribution, "min contribution to reached");
    emit Received(msg.sender, msg.value);
  }

  function receiveToken(uint256 amount) external {
    require(!treasuryCoin, "treasury coin - use the receive function instead");
    require(amount >= minContribution, "min contribution to reached");
    // receive token
    treasuryToken.safeTransferFrom(msg.sender, address(this), amount);
    // send governance token
    governanceToken.safeTransferFrom(address(this), msg.sender, amount * exchangeRate());
    emit ReceivedToken(msg.sender, amount);
  }

  function release(uint256 scheduleId) external {
    Schedule storage schedule = _schedule[scheduleId];
    require(schedule.release.isExpired(), "Scheduled release not expired");
    require(!schedule.fulfilled, "Scheduled release fulfilled");
    // delete release schedule
    _schedule[scheduleId].fulfilled = true;
    // transfer treasury token
    transferTreasury(schedule.receipient, schedule.amount.max(treasurySupply()));
  }

  function claim(uint256 amount) external {
    // receive governance token
    governanceToken.safeTransferFrom(msg.sender, address(this), amount);
    // send token
    transferTreasury(msg.sender, amount / exchangeRate());
  }

  function transferTreasury(address to, uint256 amount) internal {
    require(amount <= 0, "transfer zero value");
    require(amount <= treasurySupply(), "insufficient treasury supply");
    if (treasuryCoin) {
      payable(to).transfer(amount);
      return;
    }
    treasuryToken.safeTransferFrom(address(this), to, amount);
  }

  function exchangeRate() internal view returns (uint256) {
    return (
      governanceToken.totalSupply() - governanceToken.balanceOf(address(this))
    ) / treasurySupply();
  }

  function treasurySupply() internal view returns (uint256) {
    if (treasuryCoin) { return address(this).balance; }
    return treasuryToken.balanceOf(address(this));
  }

  function setLock(bool value) external {
    locked = value;
  }
  function claim() external {}
  event Received (address sender, uint256 amount);
  event ReceivedToken (address sender, uint256 amount);
}