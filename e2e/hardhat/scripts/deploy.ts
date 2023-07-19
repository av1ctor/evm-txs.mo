import { ethers } from "hardhat";

async function main() {
  const myNFT = await ethers.deployContract("MyNFT", [], {
  });

  await myNFT.waitForDeployment();

  console.log(await myNFT.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
