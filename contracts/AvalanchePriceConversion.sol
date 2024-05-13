// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AvalanchePriceConversion {
    AggregatorV3Interface internal ethUsdDataFeed;
    AggregatorV3Interface internal linkUsdDataFeed;
    AggregatorV3Interface internal avaxUsdDataFeed;
    AggregatorV3Interface internal maticUsdDataFeed;
    AggregatorV3Interface internal btcUsdDataFeed;

    constructor(
        AggregatorV3Interface _ethUsdDataFeed,
        AggregatorV3Interface _linkUsdDataFeed,
        AggregatorV3Interface _avaxUsdDataFeed,
        AggregatorV3Interface _maticUsdDataFeed,
        AggregatorV3Interface _btcUsdDataFeed
    ) {
        ethUsdDataFeed = _ethUsdDataFeed;
        linkUsdDataFeed = _linkUsdDataFeed;
        avaxUsdDataFeed = _avaxUsdDataFeed;
        maticUsdDataFeed = _maticUsdDataFeed;
        btcUsdDataFeed = _btcUsdDataFeed;
    }

    function getETHUSD() public view returns (int256) {
        (, int256 answer, , , ) = ethUsdDataFeed.latestRoundData();
        return answer / (10 ** 8);
    }

    function getMATICUSD() public view returns (int256) {
        (, int256 answer, , , ) = maticUsdDataFeed.latestRoundData();
        return answer / (10 ** 8);
    }

    function getAVAXUSD() public view returns (int256) {
        (, int256 answer, , , ) = avaxUsdDataFeed.latestRoundData();
        return answer / (10 ** 8);
    }

    function getBTCUSD() public view returns (int256) {
        (, int256 answer, , , ) = btcUsdDataFeed.latestRoundData();
        return answer / (10 ** 8);
    }
}