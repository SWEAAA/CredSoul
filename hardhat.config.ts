import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    xdcTestnet: {
      url: "https://rpc.apothem.network",
      chainId: 51,
    }
  }
};

export default config;