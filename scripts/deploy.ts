import { ethers } from "hardhat";
import {
  QUORUM_PERCENTAGE,
  VOTING_PERIOD,
  VOTING_DELAY,
  MIN_DELAY,
} from "../utils/env";
import { deployGovernance } from "../utils/governance";
import { getNetwork, saveAddress, getAddresses } from "../utils/main";

async function main() {
  const NETWORK = getNetwork();
  console.log(`NETWORK: ${NETWORK}`);

  const [token, timelock, governor, box] = await deployGovernance(
    ethers,
    MIN_DELAY,
    QUORUM_PERCENTAGE,
    VOTING_PERIOD,
    VOTING_DELAY
  );
  await saveAddress("GovernanceToken", token.address);
  await saveAddress("GovernorTimelock", timelock.address);
  await saveAddress("GovernorContract", governor.address);
  await saveAddress("Box", box.address);

  console.log("DEPLOYED CONTRACTS", await getAddresses());
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
