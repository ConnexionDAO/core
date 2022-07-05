import { HardhatEthersHelpers } from "@nomiclabs/hardhat-ethers/types";
import { getDeployer, getContract, readJson, addressName } from "./main";
import { BLOCK_BUFFER } from "./env";

export interface TreasuryParameters {
  releaseDate: number;
  treasuryCoin: boolean;
  treasuryToken: string;
  governanceToken: string;
  minContribution: number;
  locked: boolean;
  initExchangeRate: number;
}

export const deploy = async (
  ethers: HardhatEthersHelpers,
  params: TreasuryParameters
) => {
  const deployer = await getDeployer(ethers);
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(...Object.values(params));
  await treasury.deployed();

  const TestERC20 = await ethers.getContractFactory("TestERC20");
  const testERC20 = await TestERC20.deploy();
  await testERC20.deployed();
  return [treasury, testERC20];
};

export const receiveToken = async (
  ethers: HardhatEthersHelpers,
  amount: number,
  isEth: boolean
) => {
  const treasuryContract = await getContract(ethers, "Treasury");
  const governanceToken = await getContract(ethers, "GovernanceToken");
  const testERC20 = await getContract(ethers, "TestERC20");
  // transferERC20("TestERC20", treasuryContract.address, 1000*(10**18));
  transferERC20(
    ethers,
    "GovernanceToken",
    treasuryContract.address,
    1000 * 10 ** 18
  );
  if (isEth) {
    const receiveTokenTx = await treasuryContract.receiveToken(amount);
    await receiveTokenTx.wait(BLOCK_BUFFER);
  } else {
    const treasuryAddr: string = await readJson(
      "addresses",
      addressName("Treasury")
    );
    const approvalTx = await governanceToken.approve(treasuryAddr, amount);
    await approvalTx.wait(BLOCK_BUFFER);
    const receiveTokenTx = await treasuryContract.receiveToken(amount);
    await receiveTokenTx.wait(BLOCK_BUFFER);
  }
};

export const transferERC20 = async (
  ethers: HardhatEthersHelpers,
  contractName: string,
  receipientAddr: string,
  amount: number
) => {
  const testERC20 = await getContract(ethers, contractName);
  const transferTx = await testERC20.transfer(receipientAddr, amount);
  await transferTx.wait(BLOCK_BUFFER);
};
