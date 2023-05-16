// SPDX-License-Identifier: GPL-3.0
//Contract to register your class seat and receive NFT

pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

interface ClassNFTWrapper {
    function mint(address to) external;
    function getPopularityPerSeat() external returns (uint256);
    function getClassID() external returns (uint256);
}

contract Registration {

    mapping(uint256 => address) private _idToNFT;

    constructor(address[] memory _nftContractAddresses) {
        for(uint i = 0; i < _nftContractAddresses.length; i++) {
            address NFT = _nftContractAddresses[i];
            uint id = ClassNFTWrapper(NFT).getClassID();
            _idToNFT[id] = NFT;
        }
    }

    function verifySeat(uint classID) internal view returns(bool) {
        //Call to some verification agent; for this project, we assume the person is not lying
        require(bytes20(_idToNFT[classID]).length > 0, "Invalid classID");
        return true;
    }

    function giveNFT(uint classID) public returns (string memory){
        require(verifySeat(classID), "You do not have a seat in the class");
        address NFT = _idToNFT[classID];
        ClassNFTWrapper(NFT).mint(msg.sender);      
        return "Succesfully given NFT";
    }
}