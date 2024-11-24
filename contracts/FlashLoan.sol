// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ایمپورت‌های مورد نیاز
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IFlashloan.sol";
import "./base/DodoBase.sol";
import "./base/FlashloanValidation.sol";
import "./base/Withdraw.sol";
import "./libraries/RouteUtils.sol";
import "./libraries/Part.sol";
import "hardhat/console.sol";
contract Flashloan is IFlashloan, DodoBase, FlashloanValidation, Withdraw {
    // رویدادهای مرتبط
    event SentProfit(address recipient, uint256 profit);
    event SwapFinished(address token, uint256 amount);

    function executeFlashloan(
        FlashParams memory params
    ) external checkParams(params) {
        // آماده‌سازی داده‌ها
        bytes memory data = abi.encode(
            FlashParams({
                flashLoanPool: params.flashLoanPool,
                loadAmount: params.loadAmount,
                routes: params.routes
            })
        );

        // توکن اولیه را دریافت کنید
        address loanToken = RouteUtils.getInitialToken(params.routes[0]);

        // بررسی موجودی قرارداد قبل از وام
        console.log(
            "Contract balance before borrow:",
            IERC20(loanToken).balanceOf(address(this))
        );

        // توکن پایه را از DODO دریافت کنید
        address btoken = IDODO(params.flashLoanPool)._BASE_TOKEN_();
        console.log(btoken, "Base Token");

        uint256 baseAmount = IDODO(params.flashLoanPool)._BASE_TOKEN_() ==
            loanToken
            ? params.loadAmount
            : 0;

        uint256 quoteAmount = IDODO(params.flashLoanPool)._BASE_TOKEN_() ==
            loanToken
            ? 0
            : params.loadAmount;

        // درخواست وام از DODO
        IDODO(params.flashLoanPool).flashLoan(
            baseAmount,
            quoteAmount,
            address(this),
            data
        );

        // بررسی موجودی قرارداد بعد از وام
        console.log(
            "Contract balance after borrow:",
            IERC20(loanToken).balanceOf(address(this))
        );
    }

    // Placeholder functions
    function _flashLoanCallBack(
        address, // Placeholder for sender address, unused
        uint256, // Placeholder for loan amount, unused
        uint256, // Placeholder for fee, unused
        bytes calldata data
    ) internal override {
        // Decode the passed data to retrieve flash loan parameters
        FlashParams memory decoded = abi.decode(data, (FlashParams));

        // Determine the loan token from the routes
        address loanToken = RouteUtils.getInitialToken(decoded.routes[0]);

        // Ensure the contract has received the expected loan amount
        require(
            IERC20(loanToken).balanceOf(address(this)) >= decoded.loadAmount,
            "Insufficient loan token balance"
        );

        // Log the loan token and contract balance for debugging
        IERC20 token = IERC20(loanToken);
        console.log(
            address(token),
            token.balanceOf(address(this)),
            "Contract balance after borrow"
        );

        routeLoop(decoded.routes, decoded.loadAmount);
    }

    function routeLoop(
        Route[] memory routes,
        uint256 totalAmount
    ) internal checkTotalRoutePart(routes) {
        for (uint256 i = 0; i < routes.length; i++) {
            uint256 amountIn = Part.partToAmount(routes[i].part, totalAmount);
            hopLoop(routes[i], amountIn);
        }
    }

    function hopLoop(Route memory route, uint256 totalAmount) internal {
        uint256 amountIn = totalAmount;
        for (uint256 i = 0; i < route.hops.length; i++) {
            amountIn = pickProtocol(route.hops[i], amountIn);
        }
    }

    function pickProtocol(
        Hop memory hop,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        if (hop.protocolId == 0) {
            amountOut = uniswapV3(hop.data, amountIn, hop.path);
            console.log(
                amountOut,
                "Amount OUT Recive From Protocol",
                hop.protocolId
            );
        } else if (hop.protocolId < 8) {
            amountOut = uniswapV2(hop.data, amountIn, hop.path);
            console.log(
                amountOut,
                "Amount OUT Recive From Protocol",
                hop.protocolId
            );
        } else {
            amountOut = dodoV2Swap(hop.data, amountIn, hop.path);
            console.log(
                amountOut,
                "Amount OUT Recive From Protocol",
                hop.protocolId
            );
        }
    }

    function uniswapV3() internal returns (uint256 amountOut) {
        revert("Not implemented");
    }

    function uniswapV2() internal returns (uint256 amountOut) {
        revert("Not implemented");
    }

    function dodoV2Swap() internal returns (uint256 amountOut) {
        revert("Not implemented");
    }

    // توکن‌ها را تأیید کنید
    function approveToken(
        address token,
        address to,
        uint256 amountIn
    ) internal {
        require(IERC20(token).approve(to, amountIn), "Approve failed");
    }
}
