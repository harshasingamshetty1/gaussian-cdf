// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

library GaussianCDF {
    int256 private constant SCALE = 1e18;
    int256 private constant SQRT_2PI = 2506628274631000502;
    int256 private constant P = 327591100000000000;

    function cdf(int256 x, int256 mu, int256 sigma) public pure returns (int256) {
        require(sigma > 0, "Standard deviation must be positive");
        require(sigma <= 1e19, "Standard deviation must be <= 1e19");
        require(mu >= -1e20 && mu <= 1e20, "Invalid mu");
        require(x >= -1e23 && x <= 1e23, "x must be between -1e23 and 1e23");

        // Calculate z-score: z = (x - μ) / σ
        int256 z = ((x - mu) * SCALE) / sigma;

        // Call phi function with the calculated z
        return phi(z);
    }

    function phi(int256 z) private pure returns (int256) {
        // Handle extreme values
        if (z > 8e18) return SCALE; // CDF approaches 1 for large positive z
        if (z < -8e18) return 0; // CDF approaches 0 for large negative z

        // Save the sign of z
        int256 sign = z >= 0 ? SCALE : -SCALE;

        // Take absolute value of z and divide by sqrt(2)
        z = abs(z) * 707106781 / 1000000000; // 1/sqrt(2) ≈ 0.707106781

        // Calculate t
        int256 t = (SCALE * SCALE) / (SCALE + ((P * z) / SCALE));

        // Calculate polynomial
        int256 poly = _poly(t);

        // Calculate exp(-z*z)
        int256 expTerm;
        if (z * z / SCALE > 41e18) {
            expTerm = 0; // exp(-x) approaches 0 for large x
        } else {
            expTerm = exp(-((z * z) / SCALE));
        }

        // Calculate y
        int256 y = SCALE - ((poly * expTerm) / SCALE);

        // Final result
        int256 result = (SCALE + ((sign * y) / SCALE)) / 2;

        return result;
    }
    // Helper function for absolute value

    function abs(int256 x) private pure returns (int256) {
        return x >= 0 ? x : -x;
    }

    // calculatest the polynomial part of the error function
    function _poly(int256 t) private pure returns (int256) {
        // these are constants for the Abramowitz and Stegun approximation
        //references mentioned in readme
        int256[5] memory a = [
            int256(1061405429 * 1e9),
            int256(-1453152027 * 1e9),
            int256(1421413741 * 1e9),
            int256(-284496736 * 1e9),
            int256(254829592 * 1e9)
        ];
        // return SCALE - result;
        // 641261988559325975/ 1000000000000000000
        int256 z = ((a[0] * (power(t, 5))) / SCALE) + ((a[1] * (power(t, 4))) / SCALE)
            + ((a[2] * (power(t, 3))) / SCALE) + ((a[3] * (power(t, 2))) / SCALE) + ((a[4] * (power(t, 1))) / SCALE);

        return z;
    }

    function exp(int256 x) private pure returns (int256) {
        // Used Taylor Approximation
        if (x == 0) return SCALE;

        // Handle negative exponents
        bool isNegative = x < 0;
        if (isNegative) {
            x = -x;
        }

        int256 result = SCALE;
        int256 term = SCALE;

        for (uint256 i = 1; i <= 5; i++) {
            term = (term * x) / (SCALE * int256(i));
            // console.log(" ~ exp ~ term:", term);
            // console.log(" ~ exp ~ res:", result);

            result += term;
        }

        if (isNegative) {
            result = (SCALE * SCALE) / result;
        }

        return result;
    }

    function power(int256 base, int256 exponent) private pure returns (int256) {
        int256 result = SCALE;

        for (int256 i = 0; i < exponent; i++) {
            result = result * base / SCALE;
        }

        return result;
    }
}
// Calculations
//0.364816*1061405429 / 1000000000000000000
// 744597475021281610/1000000000000000000
//365013044819096123 *604163094552370125
//0.6041630946
// 530158730158730159/1000000000000000000
