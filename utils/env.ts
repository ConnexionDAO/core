import "dotenv/config";

const toNum = (str: string | undefined, num: number) => {
  if (str === undefined) return num;
  try {
    return parseInt(str, 10);
  } catch (error) {
    return num;
  }
};

// CORE CONSTANTS
export const DEV_CHAINS = ["localhost", "hardhat"];
// eslint-disable-next-line
export const ZERO_ADDRESS =
  process.env.ZERO_ADDRESS || "0x0000000000000000000000000000000000000000";
export const BLOCK_TIME = toNum(process.env.BLOCK_TIME, 13.2);

// GOVERNANCE
export const QUORUM_PERCENTAGE = toNum(process.env.QUORUM_PERCENTAGE, 4);
export const VOTING_PERIOD = toNum(process.env.VOTING_PERIOD, 10);
export const VOTING_DELAY = toNum(process.env.VOTING_DELAY, 5);
export const MIN_DELAY = toNum(process.env.MIN_DELAY, 1);
export const BLOCK_BUFFER = toNum(process.env.BLOCK_BUFFER, 3);
