// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFlashloan.sol";

library RouteUtils {
    function getInitialToken(IFlashloan.Route memory route)
        internal
        pure
        returns (address)
    {
        require(route.hops.length > 0, "RouteUtils: No hops in the route");
        require(route.hops[0].path.length > 0, "RouteUtils: No path in the first hop");
        
        return route.hops[0].path[0]; // ["WETH", "USDT", "USDC"]
    }
}
