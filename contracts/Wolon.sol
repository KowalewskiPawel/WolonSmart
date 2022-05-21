// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./libraries/IterableMapping.sol";
import "./libraries/Base64.sol";

contract Wolon is ERC721 {
    struct MemberAttributes {
        uint256 helperTokens;
        uint256 foundHelp;
        uint256 totalSupported;
    }

    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    mapping(uint256 => MemberAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;
    IterableMapping.Map private helperTokensMap;
    IterableMapping.Map private foundHelpMap;
    IterableMapping.Map private totalSupportedMap;

    event MembershipNFTMinted(address sender, uint256 tokenId);

    uint256 private budget;

    constructor() payable ERC721("Wolon3.0", "WLN") {
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        MemberAttributes memory memberAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory helperTokens = Strings.toString(
            memberAttributes.helperTokens
        );
        string memory foundHelp = Strings.toString(memberAttributes.foundHelp);
        string memory totalSupported = Strings.toString(
            memberAttributes.totalSupported
        );
        string
            memory logo = "ipfs://QmczzwSXHQM8scabG6Renv2ZMUzb6Bujyx76Fv23bQSoj4";

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "'
                        "Wolon 3.0 Member"
                        '", "description": "Wolon 3.0 Membership NFT", "image": "',
                        logo,
                        '","attributes": [ { "trait_type": "Helper Tokens", "value": ',
                        helperTokens,
                        '}, { "trait_type": "Found Help", "value": ',
                        foundHelp,
                        '}, { "trait_type": "Total Supported", "value": ',
                        totalSupported,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function checkIfUserHasNFT() public view returns (MemberAttributes memory) {
        uint256 userNftTokenId = nftHolders[msg.sender];
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            MemberAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function mintMembershipNFT() external {
        require(
            nftHolders[msg.sender] == 0,
            "Only one nft per address allowed"
        );
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = MemberAttributes({
            helperTokens: 0,
            foundHelp: 0,
            totalSupported: 0
        });

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();

        emit MembershipNFTMinted(msg.sender, newItemId);
    }

    modifier isMember() {
        require(
            nftHolders[msg.sender] > 0,
            "You are not a member of Wolon 3.0"
        );
        _;
    }

    function helperTokensInc() internal isMember {
        uint256 idOfMemberNft = nftHolders[msg.sender];
        MemberAttributes storage member = nftHolderAttributes[idOfMemberNft];
        member.helperTokens = member.helperTokens.add(1);
    }

    function increaseFoundHelp() internal isMember {
        uint256 idOfMemberNft = nftHolders[msg.sender];
        MemberAttributes storage member = nftHolderAttributes[idOfMemberNft];
        member.foundHelp = member.foundHelp.add(1);
    }
}
