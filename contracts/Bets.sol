// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Bets {
    enum BetState {
        CREATED,
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

    mapping(uint8 => Bet) public betsMap;
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }
}
