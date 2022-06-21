import { ethers } from "hardhat";
import {
  propose,
  vote,
  queue,
  execute,
  readProposalId,
  sampleFunction,
  readBoxValue,
} from "../utils/governance";

async function main() {
  const [BoxAddr, encodedFuncCall, description, descriptionHash] =
    await sampleFunction(ethers);

  console.log(`Box value: ${await readBoxValue(ethers)}`);

  // PROPOSE
  await propose(ethers, [BoxAddr], [0], [encodedFuncCall], description);

  // VOTE
  const proposalId = await readProposalId();
  if (proposalId === undefined) throw new Error("invalid Proposal ID");
  await vote(ethers, proposalId, 1, "reason");

  // QUEUE and EXECUTE
  await queue(ethers, [BoxAddr], [0], [encodedFuncCall], descriptionHash);
  await execute(ethers, [BoxAddr], [0], [encodedFuncCall], descriptionHash);
  console.log(`Box value: ${await readBoxValue(ethers)}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
