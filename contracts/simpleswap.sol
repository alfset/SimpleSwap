// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

address constant SWAP_ROUTER = 0x17AFD0263D6909Ba1F9a8EAC697f76532365Fb95;
address constant WETH = 0x5300000000000000000000000000000000000004;
address constant GHO = 0xD9692f1748aFEe00FACE2da35242417dd05a8615;

contract SimpleSwap {
    ISwapRouter02 private constant router = ISwapRouter02(SWAP_ROUTER);
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant gho = IERC20(GHO);

    function swapExactInputSingleHop(uint256 amountIn, uint256 amountOutMin)
        external
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: GHO,
            fee: 3000,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        router.exactInputSingle(params);
    }

    function swapExactOutputSingleHop(uint256 amountOut, uint256 amountInMax)
        external
    {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02
            .ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: GHO,
            fee: 3000,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 amountIn = router.exactOutputSingle(params);

        if (amountIn < amountInMax) {
            weth.approve(address(router), 0);
            weth.transfer(msg.sender, amountInMax - amountIn);
        }
    }
}

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}
