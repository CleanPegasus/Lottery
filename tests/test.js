const { expect } = require("chai");
const { ethers } = require("hardhat");

function randNumber() {
     return str(Math.floor(Math.random() * 100));
} 

const skipTime = async(time) => {
    await ethers.provider.send("evm_increaseTime", [time]);
}

describe("Lottery", function () {
  it("deploy and start", async function () {

    // deploy RNG contract
    const RNG = await ethers.getContractFactory("RNG");
    const rng = await RNG.deploy();
    await rng.deployed();

    const [owner] = await ethers.getSigners();
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(rng.address);
    await lottery.deployed();
    console.log('Lottery deployed at:'+ lottery.address);

    // start lottery
    await lottery.connect(owner).setLottery(`${60 * 60 * 24 * 7}`) // set lottery duration to 1 week
    this.lottery = lottery;

  });

  it("should be able to accept ETH for the lottery", async function () {

    for (let i = 0; i < 10; i++) {
        const signer = await ethers.getSigners()[i];
        await this.lottery.connect(signer).depositETH({value: ethers.utils.parseEther(randNumber())});
    }

  });

  it("should be able to choose a winner for the lottery", async function () {

    skipTime(60 * 60 * 24 * 7); // skip 1 week
    const winner = await this.lottery.connect(owner).randomlyDrawUser();

  });

});


