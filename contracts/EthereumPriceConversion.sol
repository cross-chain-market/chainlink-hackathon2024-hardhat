// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConversion {
    AggregatorV3Interface internal ethUsddataFeed;
    AggregatorV3Interface internal linkUsddataFeed;

    constructor(
        AggregatorV3Interface _ethUsddataFeed,
        AggregatorV3Interface _linkUsddataFeed
    ) {
        ethUsddataFeed = AggregatorV3Interface(_ethUsddataFeed);
        linkUsddataFeed = AggregatorV3Interface(_linkUsddataFeed);
    }

    function getETHUSD() public view returns (int256) {
        (, int256 answer, , , ) = ethUsddataFeed.latestRoundData();
        return answer / (10 ** 8);
    }

    function getLINKUSD() public view returns (int256) {
        (, int256 answer, , , ) = linkUsddataFeed.latestRoundData();
        return answer / (10 ** 8);
    }
}
