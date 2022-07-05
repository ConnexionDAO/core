import { ethers } from "hardhat";
import {
  saveAddress,
  getAddresses,
  readJson,
  addressName,
  getDeployer,
} from "../utils/main";
import { deploy, receiveToken } from "../utils/treasury";
import { ZERO_ADDRESS } from "../utils/env";

async function main() {
  // TREASURY DEPLOYMENT
  const tokenAddr: string = await readJson(
    "addresses",
    addressName("GovernanceToken")
  );
  const [treasury, testERC20] = await deploy(ethers, {
    releaseDate: 10,
    treasuryCoin: true,
    treasuryToken: ZERO_ADDRESS,
    governanceToken: tokenAddr,
    minContribution: 0,
    locked: false,
    initExchangeRate: 1,
  });
  await saveAddress("Treasury", treasury.address);
  await saveAddress("TestERC20", testERC20.address);
  console.log("DEPLOYED CONTRACTS", await getAddresses());

  // TEST FUNCTONS
  await receiveToken(ethers, 10, true);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
