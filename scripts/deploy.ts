import { ethers } from "hardhat";

async function main() {
  const IterableMapping = await ethers.getContractFactory("IterableMapping");
  const mapping = await IterableMapping.deploy();
  await mapping.deployed();

  const IterableMappingAds = await ethers.getContractFactory(
    "IterableMappingAds"
  );
  const mappingAds = await IterableMappingAds.deploy();
  await mappingAds.deployed();

  const Base64 = await ethers.getContractFactory("Base64");
  const base64 = await Base64.deploy();
  await base64.deployed();

  const Wolon = await ethers.getContractFactory("Wolon", {
    libraries: {
      IterableMapping: mapping.address,
      IterableMappingAds: mappingAds.address,
      Base64: base64.address,
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
