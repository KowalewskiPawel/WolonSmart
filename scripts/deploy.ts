import { ethers } from "hardhat";

async function main() {
  const IterableMappingAds = await ethers.getContractFactory(
    "IterableMappingAds"
  );
  const mappingAds = await IterableMappingAds.deploy();
  await mappingAds.deployed();

  const Wolon = await ethers.getContractFactory("Wolon", {
    libraries: {
      IterableMappingAds: mappingAds.address,
    },
  });
  const wolon = await Wolon.deploy();

  await wolon.deployed();

  console.log("Wolon deployed to:", wolon.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
