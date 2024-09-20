import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const nftAddress = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";
const tokenAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
const merkleRoot2 =
  "0x67ed207195389edeb66a27fe868f6707ee23b6622ef478edf1c7d07552c9e2e7";
  
//redeploy

const MerkleAirdropModule = buildModule("MerkeltreeModule", (m) => {
  const airdrop = m.contract("merkelTreeAirdrop",  [
    nftAddress,
    tokenAddress,
    merkleRoot2,
  ]);

  return { airdrop };
});

export default MerkleAirdropModule;


// MerkeltreeModule#merkelTreeAirdrop - 0x03dBB46C7e02FE8B188E0C254Cb9e00e7a0982B3
// nft#SafeToken - 0x625996DC3bd75dac2939cfdA7fD0Fe75F2a3Da1f
