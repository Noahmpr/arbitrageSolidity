// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFlashloan.sol";
import "../libraries/RouteUtils.sol";
import "../interfaces/IDODO.sol";

contract DodoBase is IFlashloan {
    // تابع‌های مربوط به فلش وام
    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function DSPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function _flashLoanCallBack(
        address,
        uint256,
        uint256,
        bytes calldata data
    ) internal virtual {}

    // چک کردن پارامترها
    modifier checkParams(FlashParams memory params) {
        address loanToken = RouteUtils.getInitialToken(params.routes[0]);

        // استفاده صحیح از _BASE_TOKEN_ به عنوان address
        address baseToken = IDODO(params.flashLoanPool)._BASE_TOKEN_();
        address quoteToken = IDODO(params.flashLoanPool)._QUOTE_TOKEN_();

        // مقایسه توکن قرضی با توکن‌های پایه یا نقل‌قول
        bool loanEqBase = (loanToken == baseToken);
        bool loanEqQuote = (loanToken == quoteToken);

        require(loanEqBase || loanEqQuote, "Loan token is not equal to base or quote token");
        _;
    }
}
