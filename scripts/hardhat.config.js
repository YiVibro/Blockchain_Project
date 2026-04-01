require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.19",
  networks: {
    mumbai: {
      url: process.env.RPC_URL,        // from Alchemy or QuickNode
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
