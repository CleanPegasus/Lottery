// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

contract RNG {
    function generateRandomNumber() external view returns(bytes32) {
        return(blockhash(now));
    }
}