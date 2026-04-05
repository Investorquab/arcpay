import * as dotenv from "dotenv";
dotenv.config();
import { ethers } from "ethers";
import { readFileSync } from "fs";
import { join } from "path";

async function main() {
  console.log("\n🚀 Deploying ArcPay to Arc Testnet...\n");

  const provider = new ethers.JsonRpcProvider("https://rpc.testnet.arc.network");
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);

  console.log("Deployer:", wallet.address);

  const artifact = JSON.parse(
    readFileSync(join("artifacts", "contracts", "ArcPay.sol", "ArcPay.json"), "utf-8")
  );

  const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, wallet);
  const contract = await factory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("✓ ArcPay deployed:", address);
  console.log("→ Explorer:", `https://testnet.arcscan.app/address/${address}`);
  console.log("\nSave this address — you need it for the frontend!\n");
}

main().catch(console.error);