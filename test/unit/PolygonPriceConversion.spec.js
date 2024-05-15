const { network, ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { developmentChains } = require("../../helper-hardhat-config");
const { assert } = require("chai");

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Polygon Price Consumer Unit Tests", async function () {
          async function deployPriceConsumerFixture() {
              const [deployer] = await ethers.getSigners();

              const DECIMALS = "8";
              const INITIAL_PRICE = "2000000000000";

              const mockV3AggregatorFactory = await ethers.getContractFactory("MockV3Aggregator");
              const mockV3Aggregator = await mockV3AggregatorFactory
                  .connect(deployer)
                  .deploy(DECIMALS, INITIAL_PRICE);

              const polygonPriceConversionFactory = await ethers.getContractFactory(
                  "PolygonPriceConversion"
              );
              const polygonPriceConversion = await polygonPriceConversionFactory
                  .connect(deployer)
                  .deploy(
                      mockV3Aggregator.address,
                      mockV3Aggregator.address,
                      mockV3Aggregator.address
                  );

              return { polygonPriceConversion, mockV3Aggregator };
          }

          describe("get ETH/USD", async function () {
              describe("success", async function () {
                  it("should return the same value as the mock", async () => {
                      const { polygonPriceConversion, mockV3Aggregator } = await loadFixture(
                          deployPriceConsumerFixture
                      );
                      const priceConsumerResult = await polygonPriceConversion.getETHUSD();
                      const priceFeedResult =
                          ((await mockV3Aggregator.latestRoundData()).answer * 100) / 10 ** 8;

                      assert.equal(priceConsumerResult.toString(), priceFeedResult.toString());
                  });
              });
          });

          describe("get LINK/USD", async function () {
              describe("success", async function () {
                  it("should return the same value as the mock", async () => {
                      const { polygonPriceConversion, mockV3Aggregator } = await loadFixture(
                          deployPriceConsumerFixture
                      );
                      const priceConsumerResult = await polygonPriceConversion.getLINKUSD();
                      const priceFeedResult =
                          ((await mockV3Aggregator.latestRoundData()).answer * 100) / 10 ** 8;

                      assert.equal(priceConsumerResult.toString(), priceFeedResult.toString());
                  });
              });
          });

          describe("get MATIC/USD", async function () {
              describe("success", async function () {
                  it("should return the same value as the mock", async () => {
                      const { polygonPriceConversion, mockV3Aggregator } = await loadFixture(
                          deployPriceConsumerFixture
                      );
                      const priceConsumerResult = await polygonPriceConversion.getMATICUSD();
                      const priceFeedResult =
                          ((await mockV3Aggregator.latestRoundData()).answer * 100) / 10 ** 8;

                      assert.equal(priceConsumerResult.toString(), priceFeedResult.toString());
                  });
              });
          });
      });
