// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NftMarket} from "../src/nft_market.sol";
import {HotPotToken} from "../src/hotpot_erc20.sol";
import {Sunday721} from "../src/sunday_erc721.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract NftMarketHandler is Test {

    NftMarket public nftMarket;
    HotPotToken public hotPotToken;
    Sunday721 public sunday721;
    uint public tokenId;
    uint sale_price;

    function setUp() public {

        // deploy HotPotToken
        hotPotToken = new HotPotToken(1E25);
        // deploy NftMarket with HotPotToken address
        nftMarket = new NftMarket(address(hotPotToken));
        // deploy Sunday721
        sunday721 = new Sunday721();
        // mínt 1 Sunday721 token with tokenId
        tokenId =0 ;
        sale_price = 100;
        sunday721.mint(address(this), tokenId);

    }

    function testListItem() public {

        // Approval for NftMarket
        sunday721.approve(address(nftMarket), tokenId);
        // List Sunday721 token with tokenId
        nftMarket.listItem(address(sunday721), tokenId, sale_price);
        // Check the sale price of Sunday721 token with tokenId
        assertEq(nftMarket.nftList(address(sunday721), tokenId), sale_price);

    }

    function testBuyItem(address buyer) public {

        vm.assume(buyer!=address(0));

        uint _pay_price = sale_price;
            
        sunday721.approve(address(nftMarket), tokenId);
        // List Sunday721 token with tokenId
        nftMarket.listItem(address(sunday721), tokenId, sale_price);
        // transfer to buyer
        hotPotToken.transfer(buyer, sale_price+100);
        // approve for NftMarket to use HotPotToken of buyer
        vm.prank(buyer);
        hotPotToken.approve(address(nftMarket), _pay_price);
        // Buy Sunday721 token with tokenId
        vm.prank(buyer);
        nftMarket.buynft(address(sunday721), tokenId, _pay_price);
    }

    function returnNFTmarketnftbalance() view public returns(uint){
        return sunday721.balanceOf(address(nftMarket));

    }
    
}

contract NftMarketInvariants is Test {

    NftMarketHandler handler;
 

    function setUp() public {

    handler = new NftMarketHandler();

    targetContract(address(handler));
    // console.log("NftMarketHandler balance: ", NftMarketHandler(address(handler)).returnNFTmarketnftbalance());

    }

    function invariant_ntfmarket_nft_balance_equal_0() public view {
        
    }
}


