import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";



const nftModule = buildModule("nft", (m) => {
  

  const erc20 = m.contract("SafeToken");

  return { erc20 };
});

export default nftModule;