// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./libraries/IterableMapping.sol";
import "./libraries/IterableMappingAds.sol";
import "./libraries/Base64.sol";

contract Wolon is ERC721 {
    struct MemberAttributes {
        uint256 helperTokens;
        uint256 foundHelp;
        uint256 totalSupported;
    }

    struct GiveawayVoting {
        uint256 zero;
        uint256 twentyfive;
        uint256 fifty;
        uint256 seventyfive;
        uint256 hundred;
    }

    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;
    using IterableMappingAds for IterableMappingAds.Map;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    mapping(uint256 => MemberAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;
    mapping(address => bool) private hasAd;
    mapping(address => bool) private hasVoted;
    IterableMapping.Map private helperTokensMap;
    IterableMapping.Map private foundHelpMap;
    IterableMapping.Map private totalSupportedMap;
    IterableMappingAds.Map private helpAds;
    GiveawayVoting public paymentVoting;

    string[] private adsArray;

    event MembershipNFTMinted(address sender, uint256 tokenId);

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

        string memory helperTokens = Strings.toString(memberAttributes.helperTokens);
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
            revert("No membership found");
        }
    }

     function mintMembershipNFT()
        external
    {
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
        require(nftHolders[msg.sender] > 0, "You are not a member");
        _;
    }

    function helperTokensInc(address _helper) internal isMember {
        uint256 idOfMemberNft = nftHolders[_helper];
        MemberAttributes storage member = nftHolderAttributes[idOfMemberNft];
        member.helperTokens = member.helperTokens.add(1);
    }

    function increaseFoundHelp() internal isMember {
        uint256 idOfMemberNft = nftHolders[msg.sender];
        MemberAttributes storage member = nftHolderAttributes[idOfMemberNft];
        member.foundHelp = member.foundHelp.add(1);
    }

    function getBudgetBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function addHelpAd(string memory _helpAd) public isMember {
        require(hasAd[msg.sender] == false, "You already have ad");
        helpAds.set(msg.sender, _helpAd);
        adsArray.push(helpAds.get(msg.sender));
        hasAd[msg.sender] = true;

        delete adsArray;

        for (uint256 i = 0; i < helpAds.size(); i++) {
            address key = helpAds.getKeyAtIndex(i);
            adsArray.push(helpAds.get(key));
        }
    }

    function getUserAd() public isMember view returns (string memory) {
        return helpAds.get(msg.sender);
    }

    function removeUserAd() public isMember {
        require(hasAd[msg.sender] == true, "You don't have have ad");
        helpAds.remove(msg.sender);
        hasAd[msg.sender] = false;

        delete adsArray;

        for (uint256 i = 0; i < helpAds.size(); i++) {
            address key = helpAds.getKeyAtIndex(i);
            adsArray.push(helpAds.get(key));
        }
    }

    function helpFound(address _helper) public isMember {
        require(hasAd[msg.sender] == true, "You don't have have ad");
        require(nftHolders[_helper] > 0, "The user is not a member");
        helpAds.remove(msg.sender);
        hasAd[msg.sender] = false;

        delete adsArray;

        for (uint256 i = 0; i < helpAds.size(); i++) {
            address key = helpAds.getKeyAtIndex(i);
            adsArray.push(helpAds.get(key));
        }

        increaseFoundHelp();
        helperTokensInc(_helper);
    }

    function getAds() public view returns (string[] memory) {
        return adsArray;
    }

    function voteForPayment(uint _vote) public isMember {
        require(hasVoted[msg.sender] == false, "You have already voted");
        if (_vote == 0) {
            paymentVoting.zero = paymentVoting.zero.add(1);
        }
        else if (_vote == 1) {
            paymentVoting.twentyfive = paymentVoting.twentyfive.add(1);
        }
        else if (_vote == 2) {
            paymentVoting.fifty = paymentVoting.fifty.add(1);
        }
        else if (_vote == 3) {
            paymentVoting.seventyfive = paymentVoting.seventyfive.add(1);
        }
        else if (_vote == 4) {
            paymentVoting.hundred = paymentVoting.hundred.add(1);
        } else {
            revert("Incorrect voting number");
        }
        hasVoted[msg.sender] = true;
    }
}
