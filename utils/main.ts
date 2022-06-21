import { HardhatEthersHelpers } from "@nomiclabs/hardhat-ethers/types";
import { network, run } from "hardhat";
import { DEV_CHAINS } from "./env";
import fs from "fs";
import path from "path";

/**
 * =====================================
 * HARDHAT FUNCTIONS (json formatting)
 * - getNetwork()
 * - getDevChains()
 * - getDeployer(ethers)
 * - deployContract(ethers, name, args)
 * - getContract(ethers, name)
 * - moveBlocks(amount)
 * =====================================
 */
export const getNetwork = () => network.name;
export const getChainId = () => network.config.chainId!.toString();
export const isDevChain = () => DEV_CHAINS.includes(getNetwork());

export const getDeployer = async (ethers: HardhatEthersHelpers) => {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer Address (#): ", deployer.address);
  console.log(
    "Deployer Balance ($): ",
    (await deployer.getBalance()).toString()
  );
  console.log("======================");
  return deployer;
};

// TODO: deployed contract returns undeployed ContractFactory
export const deployContract = async (
  ethers: HardhatEthersHelpers,
  name: string,
  args: []
) => {
  const Contract = await ethers.getContractFactory(name);
  const contract = await Contract.deploy(...args);
  await contract.deployed();
  return [Contract, contract];
};

export const getContract = async (
  ethers: HardhatEthersHelpers,
  name: string
) => {
  const address = await readJson("addresses", addressName(name));
  if (address === undefined) throw new Error("getContract address not found");
  const contract = await ethers.getContractAt(name, address);
  return contract;
};

export const moveBlocks = async (amount: number) => {
  for (let index = 0; index < amount; index++) {
    await network.provider.request({
      method: "evm_mine",
      params: [],
    });
  }
  console.log(`Moved ${amount} blocks`);
};

export const moveTime = async (amount: number) => {
  await network.provider.send("evm_increaseTime", [amount]);
  console.log(`Moved forward in time ${amount} seconds`);
};

export const verify = async (contractAddress: string, args: any[]) => {
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e: any) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified!");
    } else {
      console.log(e);
    }
  }
};

/**
 * =====================================
 * CONTRACT ADDRESSES (json formatting)
 * - saveAddress(name, value, file?)
 * - getAddresses()
 * - readJson(type?, name?, file?)
 * - saveJson(type, name, value, file?)
 * - filterObj(obj, str)
 * - addressName(name)
 * =====================================
 */
export const saveAddress = async (
  name: string,
  value: string,
  file?: string
) => {
  await saveJson("addresses", addressName(name), value, file);
};

export const getAddresses = async () => {
  const object = await readJson();
  if (!object || !object.addresses) return {};
  return filterObj(object.addresses, getNetwork());
};

export const readJson = async (type?: string, name?: string, file?: string) => {
  const fileName = file || "json/constants.json";
  const rawdata = await fs.promises.readFile(path.resolve(__dirname, fileName));
  let object = undefined;
  try {
    object = JSON.parse(rawdata.toString());
  } catch (e) {}
  if (object === undefined) return undefined;
  if (type === undefined) return object;
  if (name === undefined) return object[type];
  if (object[type]) return object[type][name];
  return undefined;
};

export const saveJson = async (
  type: string,
  name: string,
  value: string,
  file?: string
) => {
  let object = await readJson(undefined, undefined, file);
  if (object === undefined) object = {};
  if (object[type] === undefined) object[type] = {};
  object[type][name] = value;
  const fileName = file || "json/constants.json";
  await fs.promises.writeFile(
    path.resolve(__dirname, fileName),
    JSON.stringify(object)
  );
};

export const filterObj = (obj: Object, str: string) => {
  return Object.fromEntries(
    Object.entries(obj).filter(([key]) => key.includes(str))
  );
};

export const addressName = (name: string) => {
  return `${getNetwork()}-${name}`;
};
