import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Bets", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployBetsContract() {
    // Contracts are deployed using the first signer/account by default
    const [owner, player1, player2, validator] = await ethers.getSigners();

    const BetsContract = await ethers.getContractFactory("Bets");
    const bets = await BetsContract.deploy();

    return { owner, bets, player1, player2, validator };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { bets, owner } = await loadFixture(deployBetsContract);

      expect(await bets.owner()).to.equal(owner.address);
    });
  });

  describe("Add bets", function () {
    it("Should add a bet to the mapping list", async function () {
      const { bets, player1, player2, validator } = await loadFixture(deployBetsContract);

      const response = await bets.add(
        [player1.address, player2.address],
        validator.address,
        'hola mundo',
        200
      );
      console.log(await (await bets.betsMap(1)));
      expect(await bets.latestBetId()).to.equal(1);
    });
  });
});
