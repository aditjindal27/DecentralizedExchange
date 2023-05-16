// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";


interface ClassNFTWrapper {
    function getPopularity() external returns (uint256);
    function getTotalSeats() external returns (uint256);
}


contract Marketplace is ReentrancyGuard {
  using Counters for Counters.Counter;  
  mapping(address => Counters.Counter) _nftCount;
  mapping(address => Counters.Counter) _nftsSold;
  uint256 public LISTING_FEE = 0.0001 ether;
  address payable private _marketOwner;
  address[] private nftContractAddresses;

mapping(address => mapping(uint256 => NFT)) private _idToNFT;

  struct NFT {
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool listed;
  }
  event NFTListed(
    address nftContract,
    uint256 tokenId,
    address seller,
    address owner,
    uint256 price
  );
  event NFTSold(
    address nftContract,
    uint256 tokenId,
    address seller,
    address owner,
    uint256 price
  );

  mapping(address => uint256) popularity;
  mapping(address => Counters.Counter) seatsListed;

  // price = (popularity - ((popularity/totalSeats) * seatsListed)) * 0.01

  constructor(address[] memory _nftContractAddresses) {
    _marketOwner = payable(msg.sender);

    for(uint i = 0; i < _nftContractAddresses.length; i++) {
        popularity[_nftContractAddresses[i]] = ClassNFTWrapper(_nftContractAddresses[i]).getPopularity();
    }
    // popularity = _popularity;
    nftContractAddresses = _nftContractAddresses;
  }

  // List the NFT on the marketplace
  function listNft(address _nftContract, uint256 _tokenId) public payable nonReentrant {
    require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

    IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
    _marketOwner.transfer(LISTING_FEE);
    _nftCount[_nftContract].increment();
    seatsListed[_nftContract].increment();

    // TODO:set price with automated formula
    // do the calcuation price = x * y

    uint256 _price = (popularity[_nftContract]*((ClassNFTWrapper(_nftContract).getTotalSeats()) - seatsListed[_nftContract].current()))*1000000000 / (ClassNFTWrapper(_nftContract).getTotalSeats());


    _idToNFT[_nftContract][_tokenId] = NFT(
      _nftContract,
      _tokenId, 
      payable(msg.sender),
      payable(address(this)),
      _price,
      true
    );

    emit NFTListed(_nftContract, _tokenId, msg.sender, address(this), _price);
  }

  // Buy an NFT
  function buyNft(address _nftContract, uint256 _tokenId) public payable nonReentrant {
    NFT storage nft = _idToNFT[_nftContract][_tokenId];
    require(msg.value >= nft.price, "Not enough ether to cover asking price");

    address payable buyer = payable(msg.sender);
    payable(nft.seller).transfer(msg.value);
    IERC721(_nftContract).transferFrom(address(this), buyer, nft.tokenId);
    nft.owner = buyer;
    nft.listed = false;

    _nftsSold[_nftContract].increment();
    seatsListed[_nftContract].decrement();
    emit NFTSold(_nftContract, nft.tokenId, nft.seller, buyer, msg.value);
  }

  function getListedNfts() public view returns (NFT[] memory) {
    NFT[] memory nfts;

    uint256 unsoldNftsCount = 0;

    for(uint i=0; i < nftContractAddresses.length; i++) {

        address tempAddress = nftContractAddresses[i];
        uint256 nftCount = _nftCount[tempAddress].current();
        unsoldNftsCount += (nftCount - _nftsSold[tempAddress].current());
    }

    nfts = new NFT[](unsoldNftsCount);
    uint nftsIndex = 0;

    for (uint i = 0; i < nftContractAddresses.length; i++) {
        address tempAddress = nftContractAddresses[i];
        uint256 nftCount = _nftCount[tempAddress].current();
        for (uint j = 0; j < nftCount; j++) {
            if(_idToNFT[tempAddress][j].listed) {

                nfts[nftsIndex] = _idToNFT[tempAddress][j];

                nftsIndex++;
            }
        }
    }     

    return nfts;
  }

  function getMyNfts() public view returns (NFT[] memory) {

    NFT[] memory nfts;
    uint nftsIndex = 0;

    uint myNftCount = 0;
    for(uint i=0; i < nftContractAddresses.length; i++) {

        address tempAddress = nftContractAddresses[i];
        uint256 nftCount = _nftCount[tempAddress].current();
        
        for (uint j = 0; j < nftCount; j++) {
            if (_idToNFT[tempAddress][j].seller == msg.sender) {
                myNftCount++;
                
            }
        }

    }

    nfts = new NFT[](myNftCount);

    for(uint i=0; i < nftContractAddresses.length; i++) {

        address tempAddress = nftContractAddresses[i];
        uint256 nftCount = _nftCount[tempAddress].current();
        
        for (uint j = 0; j < nftCount; j++) {
            if (_idToNFT[tempAddress][j].seller == msg.sender) {
                nfts[nftsIndex] = _idToNFT[tempAddress][j];
                nftsIndex++;
            }
        }

    }

    return nfts;
  }

  function getMyListedNfts() public view returns (NFT[] memory) {
    
    NFT[] memory nfts;
    uint nftsIndex = 0;

    uint myNftCount = 0;
    for(uint i=0; i < nftContractAddresses.length; i++) {

        address tempAddress = nftContractAddresses[i];
        uint256 nftCount = _nftCount[tempAddress].current();
        
        for (uint j = 0; j < nftCount; j++) {
            if (_idToNFT[tempAddress][j].seller == msg.sender && _idToNFT[tempAddress][j].listed == true) {
                myNftCount++;
                
            }
        }

    }

    nfts = new NFT[](myNftCount);

    for(uint i=0; i < nftContractAddresses.length; i++) {

        address tempAddress = nftContractAddresses[i];
        uint256 nftCount = _nftCount[tempAddress].current();
        
        for (uint j = 0; j < nftCount; j++) {
            if (_idToNFT[tempAddress][j].seller == msg.sender && _idToNFT[tempAddress][j].listed == true) {
                
                nfts[nftsIndex] = _idToNFT[tempAddress][j];
                nftsIndex++;
            }
        }

    }

    return nfts;
  }

  function getPotentialListingPrice(address _nftContract) public returns (uint256) { 
    uint256 _price = (popularity[_nftContract]*((ClassNFTWrapper(_nftContract).getTotalSeats()) - seatsListed[_nftContract].current()))*1000000000 / (ClassNFTWrapper(_nftContract).getTotalSeats());
    return _price;
  }

  function getPriceOfListedNFT(address _nftContract, uint256 _tokenId) public view returns (uint256) {
    return _idToNFT[_nftContract][_tokenId].price;
  }

}