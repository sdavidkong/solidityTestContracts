// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

contract Sample{

    string[] public cities = ['Prague', 'Bucharest'];

    function f_memory() public{
        string[] memory s1 = cities;
        s1[0] = 'Berlin';

    }
       function f_storage() public{
        string[] storage s1 = cities;
        s1[0] = 'Berlin';

    }


}
