const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const ProductRegistry = await ethers.getContractFactory("ProductRegistry");
  const contract = await ProductRegistry.deploy();
  await contract.deployed();

  console.log("Contract deployed at:", contract.address);
  // Save this address in frontend/src/utils/constants.js
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
