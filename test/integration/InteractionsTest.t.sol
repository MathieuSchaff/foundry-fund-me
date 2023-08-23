// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithDrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_BALANCE = 2 ether;

    function setUp() external {
        // Deploy FundMe contract with script and fund it
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    //
    function testUserCanFundInteractions() public {
        // FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        // fundFundMe.fundFundMe(address(fundMe));
        // address funder = fundMe.getFunder(0);
        // assertEq(funder, USER);
        FundFundMe fundFundMe = new FundFundMe();

        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        console.log("USER: %s", USER);
        console.log("Funder: %s", funder);
        console.log("msg sender test: %s", msg.sender);
        assertEq(funder, msg.sender);
    }

    //
    function testUserCanWithDrawInteractions() public {
        // console.log("user balande before: %s", USER.balance);
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        fundFundMe.fundFundMe(address(fundMe));
        WithDrawFundMe withdrawFundMe = new WithDrawFundMe();
        withdrawFundMe.withDrawFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}
