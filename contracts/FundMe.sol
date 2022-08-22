// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 10 ** 18; 

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner; //the owner of the contract

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!");
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
        //require(msg.sender == i_owner, "Your are not the owner of the contract");
        if(msg.sender != i_owner){ revert NotOwner();}
        _;
    }

    //What happens if someone sends this contract ETH without calling the fund function.
    //We will use the following ones:

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }

    //Ether is sent to contract
    //          is msg.data empty?
    //              /    \
    //             yes    no
    //             /        \
    //        receive()?    fallback()
    //          /   \           \
    //        yes   no
    //        /      \
    //    receive()   fallback()    

}