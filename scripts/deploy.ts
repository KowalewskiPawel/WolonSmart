import { ethers } from "hardhat";

async function main() {
  const IterableMapping = await ethers.getContractFactory("IterableMapping");

  const mapping = await IterableMapping.deploy();

  await mapping.deployed();

  const Wolon = await ethers.getContractFactory("Wolon", {
    libraries: {
      IterableMapping: mapping.address,
    },
  });
  const wolon = await Wolon.deploy();

  await wolon.deployed();

  console.log("Blog deployed to:", wolon.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
