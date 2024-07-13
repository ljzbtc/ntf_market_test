// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/// @title NFT Market
/// @author liujingze
/// @dev This contract is a simple NFT market contract

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NftMarket {
    error NftMarketplace_NotApprovedForMarketplace();
    error NftMarketplace_NotListed(address nftAddress, uint256 tokenId);
    error NftMarketplace_NotEnoughFunds();
    event NftMarketplace_Listed(
        address indexed token_address,
        uint256 indexed tokenId,
        uint256 sale_price
    );
    event NftMarketplace_Bought(
        address indexed token_address,
        uint256 indexed tokenId,
        address indexed buyer
    );
    // The address of the ERC20 token used for trading
    address public immutable IEC20_TOKEN_ADDRESS;
    // The list of NFTs on the market
    mapping(address => mapping(uint256 => uint256)) public nftList;

    constructor(address _IEC20_TOKEN) {
        IEC20_TOKEN_ADDRESS = _IEC20_TOKEN;
    }

    function listItem(
        address token_address,
        uint256 tokenId,
        uint sale_price
    ) public {
        IERC721 nft = IERC721(token_address);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketplace_NotApprovedForMarketplace();
        }
        nftList[token_address][tokenId] = sale_price;
        emit NftMarketplace_Listed(token_address, tokenId, sale_price);
    }
    
    function buynft(
        address token_address,
        uint256 tokenId,
        uint buy_token_amount
    ) public {
        if (nftList[token_address][tokenId] <= 0) {
            revert NftMarketplace_NotListed(token_address, tokenId);
        }

        if (buy_token_amount < nftList[token_address][tokenId]) {
            revert NftMarketplace_NotEnoughFunds();
        }

        IERC20(IEC20_TOKEN_ADDRESS).transferFrom(
            msg.sender,
            address(this),
            nftList[token_address][tokenId]
        );
        IERC721 nft = IERC721(token_address);
        nft.safeTransferFrom(nft.ownerOf(tokenId), msg.sender, tokenId);
        emit NftMarketplace_Bought(token_address, tokenId, msg.sender);
    }
}
