// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EthereumPriceConversion {
    AggregatorV3Interface internal ethUsddataFeed;
    AggregatorV3Interface internal linkUsddataFeed;

    constructor(
        AggregatorV3Interface _ethUsddataFeed,
        AggregatorV3Interface _linkUsddataFeed
    ) {
        ethUsddataFeed = AggregatorV3Interface(_ethUsddataFeed);
        linkUsddataFeed = AggregatorV3Interface(_linkUsddataFeed);
    }

    function getETHUSD() public view returns (uint256) {
        (, int256 answer, , , ) = ethUsddataFeed.latestRoundData();
        return (uint256(answer) * 100) / (10 ** 8);
    }

    function getLINKUSD() public view returns (uint256) {
        (, int256 answer, , , ) = linkUsddataFeed.latestRoundData();
        return (uint256(answer) * 100) / (10 ** 8);
    }

    function getDecimals() public pure returns (uint256) {
        return 2;
    }
}
