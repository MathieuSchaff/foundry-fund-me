// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testFundMeMinimumUSD() public {
        uint256 minimumUSD = 5 * 10 ** 18;
        assertEq(
            fundMe.MINIMUM_USD(),
            minimumUSD,
            "minimumUSD should be 5 * 10 ** 18"
        );
    }

    function testOwnerIsMsgSender() public {
        console.log("msg.sender: %s", msg.sender);
        // console.log("fundMe.i_owner(): %s", fundMe.i_owner());
        console.log("address(this): %s", address(this));
        assertEq(fundMe.getOwner(), msg.sender, "owner should be msg.sender");
        // assertEq(fundMe.i_owner(), address(this), "owner should be msg.sender");
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4, "version should be 4");
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(
            amountFunded,
            SEND_VALUE,
            "amountFunded and SEND_VALUE should be equal"
        );
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "fundersTest should be USER");
    }

    function testAddsFunderToArrayOfFundersLength() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // I want to retrive all the funders in the array of address called s_funders
        address[] memory fundersTest = fundMe.getAddresses();
        // fundersTest should be equal superior to 0
        assertGt(fundersTest.length, 0, "fundersTest should be superior to 0");
    }

    function testOnlyOwnerCanWithDraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 0, "amountFunded should be 0");
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("gasUsed: %s", gasUsed);
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        // Assert
        assertEq(
            endingFundMeBalance,
            0,
            "startingFundMeBalance should be equal to 0"
        );
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance,
            "endingOwnerBalance should be equal to startingOwnerBalance + startingFundMeBalance"
        );
    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(makeAddr(i));
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
