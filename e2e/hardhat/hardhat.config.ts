import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      chainId: 0x7A69,
      gas: 6e6,
      gasPrice: 1e9
    },
  }
};

export default config;
