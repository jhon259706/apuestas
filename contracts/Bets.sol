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
        Player[] players;
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

    modifier betExist(uint8 betId) {
        Bet memory bet = betsMap[betId];
        require(bet.betId == betId, "This bet does not exist");
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

            bet.players.push(player);
        }

        latestBetId = newBetId;
        emit BetAdded(latestBetId, "Bet added successfully");
    }

    function validate(uint8 betId) public onlyValidator(betId) betExist(betId) {
        betsMap[betId].state = BetState.VALIDATED;
    }


    //to do 
    // cómo reutilizar la función del player
    // agregar testing a la función pay
    // agregar lógica de las notificaciones cuando el último player pague
    function pay(uint8 betId) public payable betExist(betId) {
        Bet storage bet = betsMap[betId];
        require(
            msg.value == bet.amount,
            "The amount transfered must match the bet amount"
        );
        address playerPaid = msg.sender;
        bool found = false;
        for (uint256 index = 0; index < bet.players.length; index++) {
            Player storage playerItem = bet.players[index];
            if (playerItem.playerAddress == playerPaid) {
                found = true;
                require(
                    playerItem.paidBet == false,
                    "The bet is already paid by this user"
                );
                playerItem.paidBet = true;
            }
        }
        require(found, "The player does not belong to this bet");
    }

    function getPlayer(uint8 betId, address playerAddress)
        public
        view
        betExist(betId)
        returns (Player memory player)
    {
        Player[] memory players = betsMap[betId].players;

        for (uint256 index = 0; index < players.length; index++) {
            if (players[index].playerAddress == playerAddress) {
                player = players[index];
            }
        }

        require(
            player.playerAddress != address(0),
            "This player is not part of this bet"
        );

        return player;
    }

    function getPlayers(uint8 betId)
        public
        view
        betExist(betId)
        returns (Player[] memory players)
    {
        return betsMap[betId].players;
    }
}
