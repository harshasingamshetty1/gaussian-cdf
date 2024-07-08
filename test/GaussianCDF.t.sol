// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GaussianCDF.sol";
import "forge-std/console.sol";
// 0.13533528 * 1000000000000000000
// 383101163314249/ 1000000000000000000

contract GaussianCDFTest is Test {
    function testExtremeValue() public pure {
        int256 result1 = GaussianCDF.cdf(1e23, 0, 1e18);
        assertEq(result1, 1e18); // Should be 1

        int256 result2 = GaussianCDF.cdf(-1e23, 0, 1e18);
        assertEq(result2, 0); // Should be 0
    }

    function testBasicCDF() public pure {
        int256 result = GaussianCDF.cdf(0, 0, 1e18);
        assertApproxEqAbs(result, 5e17, 1e10); // Should be close to 0.5
    }

    function testDifferentMeanAndStdDev() public pure {
        int256 result = GaussianCDF.cdf(2e18, 0, 1e18);
        //reference: https://www.danielsoper.com/statcalc/calculator.aspx?id=53
        //Expected value  = 0.97724987 * 1000000000000000000 => 977249870000000000
        assertApproxEqAbs(result, 977249870000000000, 1e15); // Should be close to 0.97724987

        int256 result2 = GaussianCDF.cdf(5e18, 12e18, 5e18);
        //reference: https://www.danielsoper.com/statcalc/calculator.aspx?id=53
        // Expected value = 0.08075666* 1000000000000000000 => 80756660000000000
        assertApproxEqAbs(result2, 80756660000000000, 1e15); // Should be close to 0.08075666
    }

    function testInvalidInputs() public {
        vm.expectRevert("Standard deviation must be positive");
        GaussianCDF.cdf(0, 0, 0);

        vm.expectRevert("Standard deviation must be <= 1e19");
        GaussianCDF.cdf(0, 0, 2e19);

        vm.expectRevert("Invalid mu");
        GaussianCDF.cdf(0, -2e20, 1e18);

        vm.expectRevert("Invalid mu");
        GaussianCDF.cdf(0, 2e20, 1e18);
    }

    function testPower() public pure {
        // just a random testcase for power function
        // int256 base = 744597475021281610;
        // int256 res = GaussianCDF.power(base, 4);
        // int256 res2 = res / 1e15;
        // // 0.364816
        // //    ~ testPCal ~ res: 365013044819096123 365
        // console.logInt(res);
        // console.logInt(res2);
    }
}
