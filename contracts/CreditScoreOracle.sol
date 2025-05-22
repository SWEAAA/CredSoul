// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "./SoulboundNFT.sol";

contract CreditScoreOracle is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    SoulboundNFT public nftContract;
    
    uint256 private fee;
    bytes32 private jobId;
    mapping(bytes32 => address) private requests;

    event RequestCreditScore(bytes32 indexed requestId, address indexed user);
    event CreditScoreReceived(bytes32 indexed requestId, uint256 score);

    constructor(
        address _nftContract,
        address _link,
        address _oracle,
        string memory _jobId
    ) ConfirmedOwner(msg.sender) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        nftContract = SoulboundNFT(_nftContract);
        jobId = bytes32(bytes(_jobId));
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0.1 LINK
    }

    function requestCreditScore(address user) external returns (bytes32) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Add the user address as a parameter
        req.add("userAddress", addressToString(user));

        bytes32 requestId = sendChainlinkRequest(req, fee);
        requests[requestId] = user;
        
        emit RequestCreditScore(requestId, user);
        return requestId;
    }

    function fulfill(bytes32 _requestId, uint256 _score) external recordChainlinkFulfillment(_requestId) {
        address user = requests[_requestId];
        require(user != address(0), "Request not found");

        // Generate metadata URI (in production, this would be IPFS)
        string memory uri = string(abi.encodePacked(
            "https://api.credsoul.xyz/metadata/",
            addressToString(user)
        ));

        // Mint or update the NFT
        if (nftContract.tokenIds(user) == 0) {
            nftContract.mint(user, uri, _score);
        } else {
            nftContract.updateCreditScore(user, _score, uri);
        }

        emit CreditScoreReceived(_requestId, _score);
        delete requests[_requestId];
    }

    function addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}