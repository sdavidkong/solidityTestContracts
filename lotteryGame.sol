// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

contract lottery{
    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender;
    }

    receive() external payable{
        require(msg.value == 11 ether);
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    function randomNum() public view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public{
            require(players.length >= 10);
            uint r = randomNum();
            address payable winner;
            uint index = r % players.length;
            winner = players[index];

            uint managerFee = (getBalance() * 34) / 100;
            uint winnerPrize = (getBalance() * 66) / 100;
            winner.transfer(winnerPrize);
            payable(manager).transfer(managerFee);
            players = new address payable [](0);
           
    }
}
    
