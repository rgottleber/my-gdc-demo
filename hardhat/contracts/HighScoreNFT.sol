// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract HighScoreNFT is ERC721, ERC721URIStorage, VRFConsumerBaseV2 {
    using Counters for Counters.Counter;
    // Mapping to store the NFT's name, image URL, and score
    mapping(address => uint256) public addressToTokenId;
    mapping(uint256 => string) public name;
    mapping(uint256 => string) public imageURL;
    mapping(uint256 => uint256) public score;
    VRFCoordinatorV2Interface COORDINATOR;

    // public multiplier
    uint256 public multiplier = 1;
    // Your subscription ID.
    uint64 s_subscriptionId;

    // Event to emit when the score is updated
    event ScoreChanged(uint256 id, uint256 newScore);

    // Mapping to store the NFT's owner
    mapping(uint256 => address) public tokenOwner;
    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash =
        0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    constructor(
        uint64 subscriptionId
    )
        ERC721("FlapOnChain", "fc")
        VRFConsumerBaseV2(0x2eD832Ba664535e5886b75D64C46EB9a228C2610)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x2eD832Ba664535e5886b75D64C46EB9a228C2610
        );
        s_subscriptionId = subscriptionId;
        _tokenIdCounter.increment();
    }

    Counters.Counter private _tokenIdCounter;

    // Function to mint a new NFT
    function mint() public {
        // Require that the sender does not already have an NFT
        require(addressToTokenId[msg.sender] == 0, "Only Mint One");
        // Get the current token ID
        uint256 id = _tokenIdCounter.current();
        // Increment the token ID counter
        _tokenIdCounter.increment();
        _safeMint(msg.sender, id);
        // Mint the NFT to the sender
        tokenOwner[id] = msg.sender;
        // Set the NFT's name, image URL, and score
        name[id] = "New Player";
        imageURL[
            id
        ] = "ipfs://QmSsiyNVEZuzTpM7AX9ehngymCCMQxAuZo93wo8TExFQZW/egg_nobg.png";
        score[id] = 0;
        addressToTokenId[msg.sender] = id;
    }

    // Function to update the score
    function updateScore(uint256 id, uint256 _score) public {
        require(msg.sender == tokenOwner[id]);

        // Update the score and emit the event
        score[id] = _score;
        emit ScoreChanged(id, _score);

        // Update the name and image URL based on the new score
        if (score[id] > 15) {
            name[id] = "High Score Achiever";
            imageURL[
                id
            ] = "ipfs://QmSsiyNVEZuzTpM7AX9ehngymCCMQxAuZo93wo8TExFQZW/eagle_nobg.png";
        } else if (score[id] > 0) {
            name[id] = "Regular Player";
            imageURL[
                id
            ] = "ipfs://QmSsiyNVEZuzTpM7AX9ehngymCCMQxAuZo93wo8TExFQZW/chick_nobg.png";
        } else {
            name[id] = "New Player";
            imageURL[
                id
            ] = "ipfs://QmSsiyNVEZuzTpM7AX9ehngymCCMQxAuZo93wo8TExFQZW/egg_nobg.png";
        }
    }

    function tokenURI(
        uint256 id
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        string memory _imageURL;
        if (score[id] > 15) {
            _imageURL = "ipfs://QmWo4YbkFwzeFer2rF6wLS5GiGHmYCNASwJxcLXFV8zCjp/eagle_nobg.png";
        } else if (score[id] > 0) {
            _imageURL = "ipfs://QmWo4YbkFwzeFer2rF6wLS5GiGHmYCNASwJxcLXFV8zCjp/chick_nobg.png";
        } else {
            _imageURL = "ipfs://QmWo4YbkFwzeFer2rF6wLS5GiGHmYCNASwJxcLXFV8zCjp/egg_nobg.png";
        }
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Your Flapper", ',
                        '"description": "Flapping to a new high score", "image": "',
                        _imageURL,
                        '", ',
                        '"attributes": [',
                        '{"trait_type": "Score", "value": ',
                        Strings.toString(score[id]),
                        "}] ",
                        "}"
                    )
                )
            )
        );
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return finalTokenURI;
    }

    function requestNewMultiplier() external returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    // Function to update the multiplier
    function fulfillRandomWords(
        uint256,
        uint256[] memory _rawWords
    ) internal override {
        // generate a new multiplier under between 1 and 10
        uint256 _multiplier = (_rawWords[0] % 10) + 1;
        // set multiplier
        multiplier = _multiplier;
    }

    // The following functions is an override required by Solidity.
    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
