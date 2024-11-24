// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlashloan {
    struct Hop {
        uint8 protocolId; // Protocol identifier
        bytes data;       // Protocol-specific data
        address[] path;   // Transaction path
    }

    struct Route {
        Hop[] hops;   // List of hops representing steps in the route
        uint16 part;  // Percentage of the total transaction (in basis points, e.g., 10000 = 100%)
    }

    struct FlashParams {
        address flashLoanPool; // Address of the flash loan pool
        uint256 loanAmount;    // Amount of the flash loan
        Route[] routes;        // Routes for the transaction
    }
}
