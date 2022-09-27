import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import type { Bets } from "../typechain-types/Bets";
import type { ContractTransaction } from "@ethersproject/contracts/src.ts/index";

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

  const addBet = (
    bets: Bets,
    player1: SignerWithAddress,
    player2: SignerWithAddress,
    validator: SignerWithAddress
  ): Promise<ContractTransaction> => {
    return bets.add(
      [player1.address, player2.address],
      validator.address,
      "Pepe apuesta 2000 a que gana el barcelona el siguiente partido",
      200
    );
  };

  describe("Deployment", () => {
    it("Should set the right owner", async function () {
      const { bets, owner } = await loadFixture(deployBetsContract);

      expect(await bets.owner()).to.equal(owner.address);
    });
  });

  describe("Add bets", async () => {
    it("Should add a bet to the mapping list", async function () {
      const { bets, player1, player2, validator } = await loadFixture(
        deployBetsContract
      );

      const tx = await addBet(bets, player1, player2, validator);
      expect(tx).to.emit(bets, "BetAdded").withArgs(1, "Bet Added Succesfully");
    });
  });

  describe("Update Bets", async () => {
    it("Should validate a bet by given id", async function () {
      const { bets, player1, player2, validator } = await loadFixture(
        deployBetsContract
      );

      const addBetTx = await addBet(bets, player1, player2, validator);
      const receipt = await addBetTx.wait();

      const createdBetId = receipt.events?.[0].args?.betId;
      await bets.connect(validator).validateBet(createdBetId);
      const bet = await bets.betsMap(createdBetId);
      expect(bet.state).to.equals(1);
    });
  });
});
