import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545", // Localhost for Hardhat node or other local blockchain
    },
    polygon: {
      url: "https://rpc.ankr.com/polygon", // Polygon RPC endpoint
      // accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [], // Ensure your private key is loaded
    },
  },
};

export default config;
