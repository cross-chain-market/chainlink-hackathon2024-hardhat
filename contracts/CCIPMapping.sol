// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CCIPMapping {
    address owner;
    mapping(uint256 => address) ccipConnectors; //<chainId> -> <CCIP contract address>
    mapping(uint256 => uint64) public chainSelectors; // <chainId> => <chain selector>

    event ConnectorUpdated(uint256 indexed chainId, address connector);
    event SelectorUpdated(uint256 indexed chainId, uint64 chainSelector);

    constructor() {
        owner = msg.sender;
        chainSelectors[43113] = 14767482510784806043; // Avalanch-fuji
        chainSelectors[80002] = 16281711391670634445; // Polygon Amoy
        chainSelectors[421614] = 3478487238524512106; // Arbitrum Sepolia
        chainSelectors[11155111] = 16015286601757825753; // Sepolia
        chainSelectors[11155420] = 5224473277236331295; // Optimism Sepolia
    }

    function updateConnector(uint256 chainId, address connector) onlyOwner external {
        require(chainId > 0, 'number should be bigger then 0');
        require(connector != address(0), "invalid connector address");
        ccipConnectors[chainId] = connector;
        emit ConnectorUpdated(chainId, connector);
    }

    function updateChainSelector(uint256 chainId, uint64 chainSelector) external {
        require(chainId > 0, 'number should be bigger then 0');
        require(chainSelector > 0, "invalid connector address");
        chainSelectors[chainId] = chainSelector;
        emit SelectorUpdated(chainId, chainSelector);
    }

    function getCCIPNavigations(uint256 chainId) external view returns(address, uint64) {
        return (ccipConnectors[chainId], chainSelectors[chainId]);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}