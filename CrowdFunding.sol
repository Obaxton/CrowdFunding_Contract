// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

/*
 *Allows the owner to deploy the contract with a funding goal and five different tiers of donation levels.
 *Supporters are able to donate as much as they want and earn a tier level based on their total amount of donations.
 *The address of each supporter is recorded along with their donation total and tier level.
 *Once the funding goal is met or exceded, the owner is able to withdraw all the funds. 
 */

contract CrowdFunding {

    mapping(address => supporterLevel) public Supporters; //stores all supporters by their address and maps them to their total donation and tier level.

    //state variabls
    address payable Owner;
    uint256 fundingGoal;
    uint256 Tier_One_Requirement;
    uint256 Tier_Two_Requirement;
    uint256 Tier_Three_Requirement;
    uint256 Tier_Four_Requirement;
    uint256 Tier_Five_Requirement;

    //initial setup for contract
    //requires the funding goal and each tier level minimum requirement.
    constructor(uint256 goal, uint256 one, uint256 two, uint256 three, uint256 four, uint256 five) {
        Owner = payable(msg.sender);
        fundingGoal = goal;
        Tier_One_Requirement = one;
        Tier_Two_Requirement = two;
        Tier_Three_Requirement = three;
        Tier_Four_Requirement = four;
        Tier_Five_Requirement = five;
    }

    //contract settings
    modifier onlyOwner() {
        require(msg.sender == Owner, "Only the owner can call this.");
        _;
    }
    modifier onlySupporter() {
        require(msg.sender != Owner, "Only a supporter can call this."); //anyone but the owner can interact
        require(msg.sender.balance >= msg.value, "You do not have enough available funds."); //only makes a donation if supporter has the funds available
        _;
    }

    //tier levels for the current total donation amount
    //might not be needed as the tier can simply be saved as a string or int and serve the same purpose.
    enum donationTiers {
        Tier_One, //0
        Tier_Two, //1
        Tier_Three, //2
        Tier_Four, //3
        Tier_Five //4
    }

    //supporter's current total donations and 
    struct supporterLevel {
        uint256 totalDonation; //stores the total amount of all donations made by the supporter
        donationTiers tier; //indicates supporter's donation tier level
    }

    //accepts and collects donations and calls to update supporter info
    function makeDonation() public onlySupporter payable {
        //call updateSupporter
        updateSupporter();
    }

    //update the supporter's total donation and tier level based on thier total donation
    function updateSupporter() private {
        //add to supporter's total donation
        Supporters[msg.sender].totalDonation += msg.value;

        //assign tier level
        if (Supporters[msg.sender].totalDonation >= Tier_Five_Requirement) {
            Supporters[msg.sender].tier = donationTiers.Tier_Five;
        }
        else if (Supporters[msg.sender].totalDonation >= Tier_Four_Requirement) {
            Supporters[msg.sender].tier = donationTiers.Tier_Four;
        }
        else if (Supporters[msg.sender].totalDonation >= Tier_Three_Requirement) {
            Supporters[msg.sender].tier = donationTiers.Tier_One;
        }
        else if (Supporters[msg.sender].totalDonation >= Tier_Two_Requirement) {
            Supporters[msg.sender].tier = donationTiers.Tier_Two;
        }
        else if (Supporters[msg.sender].totalDonation >= Tier_One_Requirement) {
            Supporters[msg.sender].tier = donationTiers.Tier_One;
        }
        else {
            //no tier
        }
    }

    //view current funding
    function viewBalance() public view returns(uint256) {
        return address(this).balance;
    }

    //payout funds
    function payoutFunds() public onlyOwner {
        //payout current funds to the owner if the goal is met
        require(address(this).balance >= fundingGoal, "The goal has not been reached.");
        Owner.transfer(address(this).balance);
    }
}