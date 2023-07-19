import { ethers } from "hardhat";

async function main() {
    const [owner, ] = await ethers.getSigners();
    const to = "0x6388a00fd84e9353a33c11991b17ef17954240e6";
    console.log(await ethers.provider.getBalance(to));
    await owner.sendTransaction({
      to: to,
      value: ethers.parseEther("1000.0"),
    });
    console.log(await ethers.provider.getBalance(to));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

