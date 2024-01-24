// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner();

    enum NFTState {
        HAPPY,
        SAD
    }

    string s_happySvgUri;
    string s_sadSvgUri;
    uint256 s_tokenCounter;

    mapping(uint256 => NFTState) public s_tokenIdToMood;

    constructor(
        string memory happySvgUri,
        string memory sadSvgUri
    ) ERC721("Mood NFT", "MN") {
        s_happySvgUri = happySvgUri;
        s_sadSvgUri = sadSvgUri;
        s_tokenCounter = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        s_tokenIdToMood[s_tokenCounter] = NFTState.HAPPY;
    }

    function flipMood(uint256 tokenId) public {
        if (
            getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender
        ) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToMood[tokenId] == NFTState.HAPPY) {
            s_tokenIdToMood[tokenId] = NFTState.SAD;
        } else {
            s_tokenIdToMood[tokenId] = NFTState.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return ("data:application/json;base64,");
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == NFTState.HAPPY) {
            imageUri = s_happySvgUri;
        } else {
            imageUri = s_sadSvgUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        abi.encodePacked( //abi.encodePacked返回类型为Bytes，可以直接base64编码
                            '{"name": "',
                            name(),
                            '", "description": "An NFT that reflects the mood of the owner, 100% on Chain!","image": "',
                            imageUri,
                            '", "attributes": [{"trait_type": "cuteness","value": 100}]}'
                        )
                    )
                )
            );
    }
}
