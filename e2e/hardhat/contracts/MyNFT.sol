// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MyNFT {
    address payable owner;
    
    constructor() {
        owner = payable(msg.sender);
    }
    
    function mint(
    ) payable public {
        require(msg.value == 100 ether, "This NFT costs 100 ether");
    }
}
