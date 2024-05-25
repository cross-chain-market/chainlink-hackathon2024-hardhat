import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Apollo", (m) => {
  const marketplace = m.contract("Marketplace", []);
  return { marketplace };
});