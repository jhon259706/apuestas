import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config();

const projectId: string = process.env.INFURA_PROJECT_ID ?? '';
const privateKey: string = process.env.DEPLOYER_SIGNER_PRIVATE_KEY ?? '';

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${projectId}`,
      accounts: [
        privateKey
      ],
    },
  },
};

export default config;
