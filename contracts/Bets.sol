// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Bets {
    enum BetState {
        CREATED,
        VERIFIED,
        PAID,
        ACTIVE,
        FINISHED,
        CANCELED
    }

    struct Bet {
        uint8 betId;
        address[] players;
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

    event BetAdded(uint betId, string message);

    function add(
        address[] calldata players,
        address validator,
        string calldata description,
        uint256 amount
    ) public returns (uint8) {
        uint8 newBetId = latestBetId + 1;
        Bet memory betAdd = Bet({
            betId: newBetId,
            players: players,
            validator: validator,
            owner: msg.sender,
            amount: amount,
            description: description,
            winner: address(0),
            state: BetState.CREATED
        });
        betsMap[newBetId] = betAdd;
        latestBetId = newBetId;
        emit BetAdded(latestBetId, 'Bet added successfully');
    }

    function getPlayers(uint8 betId)
        public
        view
        returns (address[] memory players)
    {
        return betsMap[betId].players;
    }
}
