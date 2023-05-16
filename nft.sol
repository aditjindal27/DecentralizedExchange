// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract ClassNFT is ERC721 {

    //ClassNFT - Adresss - Popularity
    //CS 6515 - 0x8FdBAABD91c190E140510A9449a537e4c343CA30 - 80
    //CS 4400 - 0x0B04746B40BeBDDD3DD2515FBb2584A66F267873 - 60
    //CS 2110 - 0x4e87d6e6C4140aa2B5CFd2409da8e440F59D9EE1 - 75
    //CS 7650 - 0xACB4E58C8d058E91ad515024F89Dc4396c9D0Ef8 - 40

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    uint public classID; 
    uint public classPopularity; //between 0 - 100
    uint public maxSupply; //total number of seats
    uint public currentSupply = 0;

    constructor(string memory _name, string memory _symbol, uint ID, uint popularity, uint _maxSupply) ERC721(_name, _symbol) {
        classID = ID;
        classPopularity = popularity;
        maxSupply = _maxSupply;
    }

    function mint(address to) public virtual {
        currentSupply = currentSupply + 1;
        require(currentSupply < maxSupply, "total number of seats have already been filled");
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    function getPopularityPerSeat() public view returns (uint) {
        return classPopularity / maxSupply;
    }

    function getTotalSeats() public view returns (uint) {
        return maxSupply;
    }

    function getOccupiedSeats() public view returns (uint) {
        return currentSupply;
    }

    function getPopularity() public view returns (uint) {
        return classPopularity;
    }

    function getClassID() public view returns (uint) {
        return classID;
    }
}