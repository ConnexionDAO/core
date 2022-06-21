import { HardhatEthersHelpers } from "@nomiclabs/hardhat-ethers/types";
import { utils } from "ethers";
import {
  getDeployer,
  getContract,
  isDevChain,
  moveBlocks,
  readJson,
  saveJson,
  getChainId,
  moveTime,
} from "./main";
import {
  VOTING_PERIOD,
  VOTING_DELAY,
  MIN_DELAY,
  BLOCK_BUFFER,
  ZERO_ADDRESS,
} from "./env";

export const propose = async (
  ethers: HardhatEthersHelpers,
  targets: [string],
  values: [number],
  calldatas: [string],
  description: string
) => {
  // SEND PROPOSAL
  const GovernorContract = await getContract(ethers, "GovernorContract");
  const proposalTx = await GovernorContract.propose(
    targets,
    values,
    calldatas,
    description
  );
  const proposalReceipt = await proposalTx.wait(BLOCK_BUFFER);

  // SAVE PROPOSAL ID
  const proposalId = proposalReceipt.events[0].args.proposalId;
  await saveProposalId(proposalId, description);
  if (isDevChain()) await moveBlocks(VOTING_DELAY + 1);
};

// 0 = Against, 1 = For, 2 = Abstain for this example
export const vote = async (
  ethers: HardhatEthersHelpers,
  proposalId: string,
  voteWay: number,
  reason: string
) => {
  const GovernorContract = await getContract(ethers, "GovernorContract");
  const voteTx = await GovernorContract.castVoteWithReason(
    proposalId,
    voteWay,
    reason
  );
  const voteTxReceipt = await voteTx.wait(BLOCK_BUFFER);
  if (isDevChain()) await moveBlocks(VOTING_PERIOD + 1);
};

export const queue = async (
  ethers: HardhatEthersHelpers,
  targets: [string],
  values: [number],
  calldatas: [string],
  descriptionHash: string
) => {
  const GovernorContract = await getContract(ethers, "GovernorContract");
  const queueTx = await GovernorContract.queue(
    targets,
    values,
    calldatas,
    descriptionHash
  );
  await queueTx.wait(BLOCK_BUFFER);
  if (isDevChain()) {
    await moveTime(MIN_DELAY + 1);
    await moveBlocks(1);
  }
};

export const execute = async (
  ethers: HardhatEthersHelpers,
  targets: [string],
  values: [number],
  calldatas: [string],
  descriptionHash: string
) => {
  const GovernorContract = await getContract(ethers, "GovernorContract");
  const executeTx = await GovernorContract.execute(
    targets,
    values,
    calldatas,
    descriptionHash
  );
  await executeTx.wait(BLOCK_BUFFER);
};

export const sampleFunction = async (ethers: HardhatEthersHelpers) => {
  const Box = await getContract(ethers, "Box");
  const encodedFuncCall = Box.interface.encodeFunctionData("store", [15]);
  const description = "Proposal Description";
  const descriptionHash = utils.keccak256(utils.toUtf8Bytes(description));
  return [Box.address, encodedFuncCall, description, descriptionHash];
};

export const readBoxValue = async (ethers: HardhatEthersHelpers) => {
  const Box = await getContract(ethers, "Box");
  return await Box.retrieve();
};

export const saveProposalId = async (
  proposalId: string,
  description?: string
) => {
  const descriptionvalue = description || "";
  await saveJson(
    getChainId(),
    proposalId.toString(),
    descriptionvalue,
    "json/proposals.json"
  );
};

export const readProposalId = async () => {
  const proposals = await readProposalsId();
  if (proposals.length < 1) return undefined;
  return proposals[proposals.length - 1];
};

export const readProposalsId = async () => {
  return Object.keys(
    await readJson(getChainId(), undefined, "json/proposals.json")
  );
};

export const deployGovernance = async (
  ethers: HardhatEthersHelpers,
  MIN_DELAY: number,
  QUORUM_PERCENTAGE: number,
  VOTING_PERIOD: number,
  VOTING_DELAY: number
) => {
  const deployer = await getDeployer(ethers);

  const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy();
  await governanceToken.deployed();
  const transactionResponse = await governanceToken.delegate(deployer.address);
  await transactionResponse.wait(1);

  const GovernorTimelock = await ethers.getContractFactory("GovernorTimelock");
  const governorTimelock = await GovernorTimelock.deploy(MIN_DELAY, [], []);
  await governorTimelock.deployed();

  const GovernorContract = await ethers.getContractFactory("GovernorContract");
  const governorContract = await GovernorContract.deploy(
    governanceToken.address,
    governorTimelock.address,
    QUORUM_PERCENTAGE,
    VOTING_PERIOD,
    VOTING_DELAY
  );
  await governorContract.deployed();

  const Box = await ethers.getContractFactory("Box");
  const box = await Box.deploy();
  await box.deployed();
  const transferTx = await box.transferOwnership(governorTimelock.address);
  await transferTx.wait(1);

  const proposerRole = await governorTimelock.PROPOSER_ROLE();
  const executorRole = await governorTimelock.EXECUTOR_ROLE();
  const adminRole = await governorTimelock.TIMELOCK_ADMIN_ROLE();

  const proposerTx = await governorTimelock.grantRole(
    proposerRole,
    governorContract.address
  );
  await proposerTx.wait(1);
  const executorTx = await governorTimelock.grantRole(
    executorRole,
    ZERO_ADDRESS
  );
  await executorTx.wait(1);
  const revokeTx = await governorTimelock.revokeRole(
    adminRole,
    deployer.address
  );
  await revokeTx.wait(1);

  return [governanceToken, governorTimelock, governorContract, box];
};
