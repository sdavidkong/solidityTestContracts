// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

contract Auction{
    mapping(address => uint) public bids;

    function bid() payable public{
        bids[msg.sender] = msg.value;
    }
}
