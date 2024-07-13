// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NftMarket} from "../src/nft_market.sol";
import {HotPotToken} from "../src/hotpot_erc20.sol";
import {Sunday721} from "../src/sunday_erc721.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract NftMarketTest is Test {


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

    NftMarket public nftMarket;
    HotPotToken public hotPotToken;
    Sunday721 public sunday721;
    uint tokenId;
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
        function testFuzzListItem(uint _sale_price) public {

        // Approval for NftMarket
        sunday721.approve(address(nftMarket), tokenId);
        // List Sunday721 token with tokenId
        nftMarket.listItem(address(sunday721), tokenId, _sale_price);
        // Check the sale price of Sunday721 token with tokenId
        assertEq(nftMarket.nftList(address(sunday721), tokenId), _sale_price);

    }
    function testListItemNotApproval()public {
        // List Sunday721 token with tokenId without approval
        vm.expectRevert(NftMarket.NftMarketplace_NotApprovedForMarketplace.selector);
        nftMarket.listItem(address(sunday721), tokenId,sale_price);

    }

    function testListItemEvent()public{

        sunday721.approve(address(nftMarket), tokenId);
        nftMarket.listItem(address(sunday721), tokenId, sale_price);
        vm.expectEmit(true, true, false, true);
        emit NftMarketplace_Listed(address(sunday721), tokenId, sale_price);
        nftMarket.listItem(address(sunday721), tokenId, sale_price);

}
    function buynftSetup(address buyer,uint  _pay_price) public returns (address){

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
    
        return buyer;
    } 
        function testBoughtItem() public {
        
        // generate a special buyer
        address buyer = vm.addr(1);
        // Check the owner of Sunday721 token with tokenId not equal to buyer
        assertNotEq(sunday721.ownerOf(tokenId), buyer);

        // buy Sunday721 token with tokenId
        buyer=buynftSetup(buyer,sale_price);

        // Check the owner of Sunday721 token with tokenId
        assertEq(sunday721.ownerOf(tokenId), buyer);
        
    }
        function testFuzzBoughtItem(address buyer) public {

        vm.assume(buyer != address(0));
        vm.assume(buyer != address(this));

        assertNotEq(sunday721.ownerOf(tokenId), buyer);
        // generate Fuzz buyer
        buynftSetup(buyer,sale_price);
        // Check the owner of Sunday721 token with tokenId
        assertEq(sunday721.ownerOf(tokenId), buyer);
        
    }
        // Self-bought  is allowed
        function testSelfBoughtItem() public {

        address buyer = sunday721.ownerOf(tokenId);

        buyer=buynftSetup(buyer,sale_price);

        assertEq(sunday721.ownerOf(tokenId), buyer);
        
    }

    function testRepeatBoughtSameItem() public {

        address buyer = vm.addr(1);
        assertNotEq(sunday721.ownerOf(tokenId), buyer);

        buyer=buynftSetup(buyer,sale_price);

        assertEq(sunday721.ownerOf(tokenId), buyer);

        address buyer2 = vm.addr(2);
        
        // buy agin will revert with not authorized to approve
        vm.expectRevert(bytes("ERC721: approve caller is not owner nor approved for all"));
        buynftSetup(buyer2,sale_price);
        
    }
    // buy with more than sale price will only pay the sale price
    function testBuyNftwithMoreThanSalePrice() public {

        address buyer = vm.addr(1);
        assertNotEq(sunday721.ownerOf(tokenId), buyer);

        // transfer to buyer
        buyer=buynftSetup(buyer,sale_price+1);

        assertEq(sunday721.ownerOf(tokenId), buyer);
        
    }

    function testBuyNftwithLessThanSalePrice() public {

        address buyer = vm.addr(1);
        assertNotEq(sunday721.ownerOf(tokenId), buyer);

        uint _pay_price = sale_price-1;

        // transfer to buyer
        
        sunday721.approve(address(nftMarket), tokenId);
        // List Sunday721 token with tokenId
        nftMarket.listItem(address(sunday721), tokenId, sale_price);
        // transfer to buyer
        hotPotToken.transfer(buyer, sale_price+100);
        // approve for NftMarket to use HotPotToken of buyer
        
        vm.prank(buyer);
        hotPotToken.approve(address(nftMarket), _pay_price);
        // Buy Sunday721 token with tokenId
        vm.expectRevert(NftMarket.NftMarketplace_NotEnoughFunds.selector);
        vm.prank(buyer);
        nftMarket.buynft(address(sunday721), tokenId, _pay_price);
        
        
    }

    function testBoughtEvent() public {

        address buyer = vm.addr(1);
        assertNotEq(sunday721.ownerOf(tokenId), buyer);
        uint _pay_price=sale_price;
        
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
        
        vm.expectEmit(true, true, false, true);
        emit NftMarketplace_Bought(address(sunday721), tokenId, buyer);
        nftMarket.buynft(address(sunday721), tokenId, _pay_price);
        
    }

    function testFuzzlistandBuy(address buyer,uint sale_item_price) public {

        vm.assume( sale_item_price > 0.01 ether); // ether equal 1e18
        vm.assume( sale_item_price < 10000 ether); // ether equal 1e18
        vm.assume(buyer != address(0));
        uint pay_price = sale_item_price;
        assertNotEq(sunday721.ownerOf(tokenId), buyer);

        sunday721.approve(address(nftMarket), tokenId);
        // List Sunday721 token with tokenId
        nftMarket.listItem(address(sunday721), tokenId, sale_item_price);
        // transfer to buyer
        hotPotToken.transfer(buyer, sale_item_price+100);
        // approve for NftMarket to use HotPotToken of buyer
        vm.prank(buyer);
        hotPotToken.approve(address(nftMarket), pay_price);
        // Buy Sunday721 token with tokenId
        vm.prank(buyer);
        nftMarket.buynft(address(sunday721), tokenId, pay_price);
        assertEq(sunday721.ownerOf(tokenId), buyer);
       
    }




}