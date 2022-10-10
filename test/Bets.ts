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

  const addBet = async (
    bets: Bets,
    player1: SignerWithAddress,
    player2: SignerWithAddress,
    validator: SignerWithAddress
  ): Promise<{tx: ContractTransaction, createdBetId: any}> => {
    const tx = await bets.add(
      [player1.address, player2.address],
      validator.address,
      "Pepe apuesta 2000 a que gana el barcelona el siguiente partido",
      200
    );

    const receipt = await tx.wait();
    const createdBetId = receipt.events?.[0].args?.betId;

    return {tx, createdBetId}
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

      const {tx} = await addBet(bets, player1, player2, validator);
      expect(tx).to.emit(bets, "BetAdded").withArgs(1, "Bet Added Succesfully");
    });
  });

  describe("Update Bets", async () => {
    it("Should validate a bet by given id", async function () {
      const { bets, player1, player2, validator } = await loadFixture(
        deployBetsContract
      );

      const {createdBetId} = await addBet(bets, player1, player2, validator);

      await bets.connect(validator).validate(createdBetId);
      const bet = await bets.betsMap(createdBetId);
      expect(bet.state).to.equals(1);
    });
  });

  describe("Get players", async () => {
    it("Should return a single player", async function () {
      const { bets, player1, player2, validator } = await loadFixture(
        deployBetsContract
      );

      const {createdBetId} = await addBet(bets, player1, player2, validator);

      expect((await bets.getPlayer(createdBetId, player1.address)).playerAddress).to.equals(player1.address);
    });

    it("Should return all players in a bet", async function () {
      const { bets, player1, player2, validator } = await loadFixture(
        deployBetsContract
      );

      const {createdBetId} = await addBet(bets, player1, player2, validator);

      const expectedResponse = [
        [
          player1.address,
          false
        ],
        [
          player2.address,
          false
        ]
      ]

      expect((JSON.parse(JSON.stringify(await bets.getPlayers(createdBetId))))).to.deep.equal(expectedResponse);
    });
  });
});
