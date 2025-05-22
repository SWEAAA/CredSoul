// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoulboundNFT is ERC721, Ownable {
    struct CreditScore {
        uint256 score;
        uint256 lastUpdated;
        string metadataURI;
    }

    mapping(address => CreditScore) public creditScores;
    mapping(address => uint256) public tokenIds;
    uint256 private _nextTokenId;

    event CreditScoreUpdated(address indexed user, uint256 score, uint256 timestamp);

    constructor() ERC721("CredSoul", "CRED") Ownable(msg.sender) {}

    function mint(address to, string memory uri, uint256 score) external onlyOwner {
        require(tokenIds[to] == 0, "User already has a credit score NFT");
        
        uint256 tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);
        
        creditScores[to] = CreditScore({
            score: score,
            lastUpdated: block.timestamp,
            metadataURI: uri
        });
        
        tokenIds[to] = tokenId;
        
        emit CreditScoreUpdated(to, score, block.timestamp);
    }

    function updateCreditScore(address user, uint256 newScore, string memory newUri) external onlyOwner {
        require(tokenIds[user] != 0, "User does not have a credit score NFT");
        
        creditScores[user].score = newScore;
        creditScores[user].lastUpdated = block.timestamp;
        creditScores[user].metadataURI = newUri;
        
        emit CreditScoreUpdated(user, newScore, block.timestamp);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        address owner = ownerOf(tokenId);
        return creditScores[owner].metadataURI;
    }

    // Prevent transfers - make the NFT soulbound
    function _transfer(address from, address to, uint256 tokenId) internal pure override {
        revert("Credit Score NFTs are non-transferable");
    }
}