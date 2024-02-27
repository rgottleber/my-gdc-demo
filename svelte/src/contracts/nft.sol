// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract HighScoreNFT is ERC721 {
    // Mapping to store the NFT's name, image URL, and score
    mapping(uint256 => string) public name;
    mapping(uint256 => string) public imageURL;
    mapping(uint256 => uint256) public score;

    // Event to emit when the score is updated
    event ScoreChanged(uint256 id, uint256 newScore);

    // Mapping to store the NFT's owner
    mapping(uint256 => address) public tokenOwner;

    constructor(uint _interval) ERC721("FlappyChain", "fc") {}
    // Function to mint a new NFT
    function mint(address to, uint256 id, string memory _name, string memory _imageURL, uint256 _score) public {
        require(msg.sender == address(this));
        require(tokenOwner[id] == address(0));
        tokenOwner[id] = to;
        emit Transfer(address(0), to, id);

        // Set the NFT's name, image URL, and score
        name[id] = _name;
        imageURL[id] = _imageURL;
        score[id] = _score;
    }

    // Function to update the score
    function updateScore(uint256 id, uint256 _score) public {
        require(msg.sender == tokenOwner[id]);

        // Update the score and emit the event
        score[id] = _score;
        emit ScoreChanged(id, _score);

        // Update the name and image URL based on the new score
        if (score[id] > 100) {
            name[id] = "High Score Achiever";
            imageURL[id] = "https://example.com/highscore.jpg";
        } else {
            name[id] = "Regular Player";
            imageURL[id] = "https://example.com/regular.jpg";
        }
    }
    // The following functions is an override required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721)
    {
        super._burn(tokenId);
    }
}
