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

    uint256 latestBetId;

    mapping(uint8 => Bet) public betsMap;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        latestBetId = 0;
    }

    function add(
        address[] players,
        address validator,
        string description,
        uint256 amount
    ) public {
        uint newBetId= latestBetId + 1;
        betAdd = Bet({
            betId: newBetId,
            players: players,
            validator: validator,
            description: description,
            amount: amount,
            owner:msg.sender
        });
        betsMap[newBetId] = betAdd;
        latestBetId=newBetId;
    }
}
