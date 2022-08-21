// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

contract FundMe{
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 10 ** 18; 

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner; //the owner of the contract

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= minimumUsd, "Didn't send enough!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset array
        funders = new address[](0);
        //actually withdraw the funds
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Your are not the owner of the contract");
        _;
    }
}