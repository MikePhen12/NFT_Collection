// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers} = require("hardhat");
require("dotenv").config({path: ".env"});
const {WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");


async function main() {
 //Address of the whitelist that you deployed in the previous module 
 const whitelistContract = WHITELIST_CONTRACT_ADDRESS;

 //URL where we can extract the metadata for a CD NFT
 const metadataURL = METADATA_URL;

 // Deploying new smart contracts where cryptoDevsContract here is a factory for instances of our CD contract
 const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs");

 //Deploying the contract 
 const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
  metadataURL,
  whitelistContract
 );

  console.log("Cryptodevs contract address:", deployedCryptoDevsContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
