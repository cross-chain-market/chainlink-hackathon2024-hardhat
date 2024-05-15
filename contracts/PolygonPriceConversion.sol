// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PolygonPriceConversion {
    AggregatorV3Interface internal ethUsdDataFeed;
    AggregatorV3Interface internal linkUsdDataFeed;
    AggregatorV3Interface internal maticUsdDataFeed;

    constructor(
        AggregatorV3Interface _ethUsdDataFeed,
        AggregatorV3Interface _linkUsdDataFeed,
        AggregatorV3Interface _maticUsdDataFeed
    ) {
        ethUsdDataFeed = _ethUsdDataFeed;
        linkUsdDataFeed = _linkUsdDataFeed;
        maticUsdDataFeed = _maticUsdDataFeed;
    }

    function getETHUSD() public view returns (uint256) {
        (, int256 answer, , , ) = ethUsdDataFeed.latestRoundData();
        return (uint256(answer) * 100) / (10 ** 8);
    }

    function getLINKUSD() public view returns (uint256) {
        (, int256 answer, , , ) = linkUsdDataFeed.latestRoundData();
        return (uint256(answer) * 100) / (10 ** 8);
    }

    function getMATICUSD() public view returns (uint256) {
        (, int256 answer, , , ) = maticUsdDataFeed.latestRoundData();
        return (uint256(answer) * 100) / (10 ** 8);
    }

    function getDecimals() public pure returns (uint256) {
        return 2;
    }
}
