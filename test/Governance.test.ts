import { ethers } from "hardhat";
import { expect } from "chai";

const MIN_DELAY = 1;

describe("Governance", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Token = await ethers.getContractFactory("GovernanceToken");
    const token = await Token.deploy();
    await token.deployed();

    console.log("Token DEPLOYED" + token.address);

    const GovernorTimelock = await ethers.getContractFactory(
      "GovernorTimelock"
    );
    const governorTimelock = await GovernorTimelock.deploy(MIN_DELAY, [], []);
    await governorTimelock.deployed();

    console.log("GovernorTimelock DEPLOYED" + governorTimelock.address);

    const Governor = await ethers.getContractFactory("GovernorContract");
    const governor = await Governor.deploy(
      token.address,
      governorTimelock.address,
      { gasLimit: 30000000 }
    );
    await governor.deployed();

    console.log("Governor DEPLOYED" + governor.address);
  });
});
