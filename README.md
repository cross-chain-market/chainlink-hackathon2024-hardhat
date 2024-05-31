<!-- markdownlint-disable -->

![Merado logo](https://github.com/cross-chain-market/chainlink-hackathon2024-hardhat/blob/main/Merado_logo.svg?raw=true)


![Architecture](https://github.com/cross-chain-market/chainlink-hackathon2024-hardhat/blob/main/architecture.png?raw=true)

<!-- markdownlint-restore -->

# Merado - Smart contracts

> Cross-chain marketplace of Real World Products.

This is the repo that holds all smart contracts that are part of the project called "Merado" that enable buying and selling cross chain of real products. part of chainlink hackathon project at [Chainlink Block Magic](https://chain.link/hackathon).

## Tech Stack

- [hardhat](https://hardhat.org/)
- [chainlink](https://chain.link/)
- [openzeppelin](https://www.openzeppelin.com/)

## Contract information
- All contracts are located under contracts folder.
- Contracts there where developed for the hackathon and not part of chainlink toolkit are:

#

* Marketplace.sol holds the marketplace fee of a given chain, handles the payment for a given product in the origin chain and then handle transfer of erc1155 products between seller and buyer. CCIPBuyListing is the entry point function that is used by buyers

* CollectionFactory.sol contract that is used to deploy new collections, used to listen on events by quicknode

* Collection.sol collection based on erc1155 for holding record of products for a given collection that a seller created

* CCIPConnector.sol used to pass messages between different chains, and in this way support cross chain interactions

* CCIPMapping.sol holds mapping of selectors which is part of chainlink infra and also ccip connector addresses per chainId

* AvalanchePriceConversion.sol holds price conversions from usd to avalanche native token

* PolygonAmoyPriceConversion.sol holds price conversions from usd to polygon native token


## Deployed contracts

### Avalanche Fuji (Testnet)
```bash
Market - 0xb65eFBCb305f8c5Fb13ec3A7c2b1658046E8290d
CollectionFactory - 0x43871555C9291B89E8B3906285047eA59Eb39A92
Collection - 0x8bE0aEEa349aD16F680a6f51681eb14659f89447
Connector - 0x54aE20e6aff19e01842eB33476aaC1253984874E
Mapper - 0xE290A97629ee82b4907D1695b09c5F57c17f5059
priceFeed - 0x099F3073d39c31A12938f296c12a75EEEF30D821
```

### Polygon Amoy (Testnet)
```bash
Market - 0x1866380708C7EeC51C8557E40ba98ECe37f61dF0
CollectionFactory - 0xd0D05446a76be24713dF2F383CfdcAae66A8bf6B
Connector - 0x33D0555cCeaA36fcCDb3Ddc33243538A6FB8C02F
Mapper - 0xFfB60f298947C468A088dAC442cD14bc2b0B6235
priceFeed - 0xdd71E800eaB1FFACe6E9a66d46A3703F5947761e
```

## Getting Started

> **Pre-requisites:**
>
> - Setup Node.js v20+ (recommended via [nvm](https://github.com/nvm-sh/nvm) with `nvm install 20`)
> - Install [yarn](https://yarnpkg.com/getting-started/install) (recommended via [Node.js Corepack](https://nodejs.org/api/corepack.html))
> - Clone this repository

```bash
# Install dependencies
yarn install

# Compile all smart contracts
yarn compile

# test all smart contracts
yarn test
```

## Contributors

<!-- markdownlint-disable -->

<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="20%"><a href="https://github.com/talwaserman"><img src="https://avatars.githubusercontent.com/talwaserman?v=3?s=100" width="100px;" alt="Tal Waserman"/><br /><sub><b>Tal Waserman</b></sub></a></td>
      <td align="center" valign="top" width="20%"><a href="http://wisdom-umanah.super.site/"><img src="https://media.licdn.com/dms/image/D4D03AQHYoWLAkfiVEg/profile-displayphoto-shrink_200_200/0/1705060796514?e=1722470400&v=beta&t=mlRRiJCMbpF3gjz3eiFMLaVWfjFJ6MYoqVIBL1Dt_9A" width="100px;" alt="Wisdom Umanah"/><br /><sub><b>Wisdom Umanah</b></sub></a></td>
      <td align="center" valign="top" width="20%"><a href="https://github.com/maxipaz"><img src="https://avatars.githubusercontent.com/maxipaz?v=3?s=100" width="100px;" alt="Maxi Paz"/><br /><sub><b>Maxi Paz</b></sub></a></td>
      <td align="center" valign="top" width="20%"><a href="https://github.com/diegosano"><img src="https://avatars.githubusercontent.com/diegosano?v=3?s=100" width="100px;" alt="Diego Sano"/><br /><sub><b>Diego Sano</b></sub></a></td>
      <td align="center" valign="top" width="20%"><a href="https://github.com/SimonAyo1"><img src="https://avatars.githubusercontent.com/SimonAyo1?v=3?s=100" width="100px;" alt="Simon Ayo"/><br /><sub><b>Simon Ayo</b></sub></a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->

## License

Distributed under the MIT License. See [MIT License](https://github.com/cross-chain-market/chainlink-hackathon2024-web/blob/main/LICENSE) for more information.
