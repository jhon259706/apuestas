// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Bets {
    enum BetState {
        CREATED,
        VALIDATED,
        PAID,
        ACTIVE,
        FINISHED,
        CANCELED
    }

    struct Player {
        address playerAddress;
        bool paidBet;
    }

    struct Bet {
        uint8 betId;
        mapping(address => Player) players;
        address validator;
        address owner;
        uint256 amount;
        string description;
        address winner;
        BetState state;
    }

    uint8 public latestBetId;

    mapping(uint8 => Bet) public betsMap;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        latestBetId = 0;
    }

    event BetAdded(uint8 betId, string message);

    modifier onlyValidator(uint8 betId) {
        require(
            msg.sender == betsMap[betId].validator,
            "You don't have permissions to validate this bet"
        );
        _;
    }

    function add(
        address[] calldata players,
        address validator,
        string calldata description,
        uint256 amount
    ) public {
        uint8 newBetId = latestBetId + 1;

        Bet storage bet = betsMap[newBetId];
        bet.betId = newBetId;
        bet.validator = validator;
        bet.owner = msg.sender;
        bet.amount = amount;
        bet.description = description;
        bet.winner = address(0);
        bet.state = BetState.CREATED;

        for (uint256 index = 0; index < players.length; index++) {
            Player memory player = Player({
                playerAddress: players[index],
                paidBet: false
            });
            bet.players[players[index]] = player;
        }

        latestBetId = newBetId;
        emit BetAdded(latestBetId, "Bet added successfully");
    }

    function validate(uint8 betId) public onlyValidator(betId) {
        betsMap[betId].state = BetState.VALIDATED;
    }

    function pay(uint8 betId) public payable {}

    function getPlayer(uint8 betId, address playerAddress)
        public
        view
        returns (Player memory player)
    {
        player = betsMap[betId].players[playerAddress];
        require(
            player.playerAddress != address(0),
            "This player is not part of this bet"
        );
        return player;
    }

    // TODO Fix the getPlayers method to return an array instead of a mapping
    // function getPlayers(uint8 betId)
    //     public
    //     view
    //     returns (address[] memory players)
    // {
    //     return betsMap[betId].players;
    // }
}
