import { HardhatEthersHelpers } from "@nomiclabs/hardhat-ethers/types";
import { getDeployer } from "./main";

export const deploy = async (ethers: HardhatEthersHelpers) => {
  await getDeployer(ethers);

  const TokenTimelock = await ethers.getContractFactory("TokenTimelock");
  const tokenTimelock = await TokenTimelock.deploy();
  await tokenTimelock.deployed();
};
