// SPDX-License-Identifier: MIT
// Fund
// Withdraw

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// This script is for funding the FundMe contract
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.2 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        console.log(
            "msg sender in fundFundMe interaction script: %s",
            msg.sender
        );
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithDrawFundMe is Script {
    function withDrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withDrawFundMe(mostRecentlyDeployed);
    }
}
