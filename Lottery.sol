// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./UniformRandomNumber.sol";
import "./SumTree.sol";


interface IRNG {
    function generateRandomNumber() external view returns(bytes32);
}

contract Lottery is Ownable, Pausable  {

    bytes32 constant private TREE_KEY = keccak256("Senken-Code-Challenge");
    uint256 constant private MAX_TREE_LEAVES = 5;
    uint256 private lotteryEnd;
    
    IRNG RNG;

    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;
    using SafeMath for uint256;

    SortitionSumTreeFactory.SortitionSumTrees sumTreeFactory;

    constructor (address _RNG) public {
        sumTreeFactory.createTree(TREE_KEY, MAX_TREE_LEAVES);
        RNG = IRNG(_RNG);
        _pause();
    }

    modifier isActive {
        require(now < lotteryEnd, "The Lottery time has ended");
        _;
    }

    function setRNG(address _RNG) public onlyOwner {
        RNG = IRNG(_RNG);
    }

    function setLottery(uint256 _timeInSecs) public onlyOwner whenPaused {
        lotteryEnd = now.add(_timeInSecs);
        _unpause();
    }

    function depositETH() public payable isActive whenNotPaused {
        sumTreeFactory.set(TREE_KEY, msg.value, bytes32(uint256(msg.sender)));
    }

    function chanceOf(address user) external view returns (uint256) {
        return sumTreeFactory.stakeOf(TREE_KEY, bytes32(uint256(user)));
    }

    function randomlyDrawUser() public onlyOwner whenNotPaused returns (address) {

        // Pause contract
        require(now > lotteryEnd, "The lottery has not ended yet");

        bytes32 entropy = RNG.generateRandomNumber();
        uint256 bound = address(this).balance;
        uint256 token = UniformRandomNumber.uniform(uint256(entropy), bound);

        address payable winner = address(uint256(sumTreeFactory.draw(TREE_KEY, token)));

        winner.transfer(address(this).balance);
        _pause();
        return winner;
    }


}
