// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // before start broadcast, => not a real tx
        HelperConfig helperConfig = new HelperConfig();
        address ethUsePriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // mock
        FundMe fundMe = new FundMe(ethUsePriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
