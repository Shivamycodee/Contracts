// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

// 0xfdC8ef8FcbeaF210A9B2407Fd413744Ac9ab6F50 -- contract address on Polygon

interface Quoter{

 function quoteExactInputSingle(address tokenIn,address tokenOut,uint24 fee,uint256 amountIn,uint160 sqrtPriceLimitX96) external returns (uint256 amountOut);

}

interface SwapRouter is IUniswapV3SwapCallback{

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


}


contract SimpleFlashloan is FlashLoanSimpleReceiverBase {

         event ArbitrageAmount(uint);
         event Premium(uint loanAmount,uint premium);


    address payable owner;

    address public PoolAddressesProviderPolygon = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;
    address public QuoterAddress = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address public uniswapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564; // V3 Router...

    address public tokenIn;
    address public tokenOut;

    // ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564); 

    // pool fee to 0.01%.
    uint24 public poolFee = 100;


    constructor()
     FlashLoanSimpleReceiverBase(IPoolAddressesProvider(PoolAddressesProviderPolygon))
    {}

    function changeQuoterAddress(address _quoterAddress) public {
        QuoterAddress = _quoterAddress;
    }

    function fn_RequestFlashLoan(address _tokenIn,address _tokenOut, uint256 _amount,uint24 _poolFee) public {
        address receiverAddress = address(this);
        address asset = _tokenIn;
        uint256 amount = _amount;
        poolFee = _poolFee;
        tokenIn = _tokenIn;
        tokenOut = _tokenOut;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }


      function makeArbitrage(uint _amt) public {

      uint256 quoteA = getQuote(tokenIn,tokenOut, _amt);

    require(quoteA > 0,"quoteA is less than zero...");

        uint256 amountOut = _swap(tokenIn,tokenOut,_amt,quoteA);

    require(amountOut > 0,"Didn't get any tokenOut (1)");

      uint256 quoteB = getQuote(tokenOut,tokenIn, amountOut);
        
      uint arbiAmt =  _swap(tokenOut, tokenIn,amountOut,quoteB);

      require(arbiAmt > 0, "didn't get any arbiAmount (2)");
      emit ArbitrageAmount(arbiAmt);
       
 }


    function _swap(
        address _tokenIn,
        address _tokenOut,
        uint256 amountIn,
        uint256 quote
) public returns (uint256) {

        IERC20(_tokenIn).approve(uniswapRouterAddress, amountIn);
        SwapRouter swapRouter = SwapRouter(uniswapRouterAddress);
        uint timeStamp = block.timestamp + 2000;

           SwapRouter.ExactInputSingleParams memory params = SwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: poolFee,
            recipient: address(this),
            deadline:timeStamp,
            amountIn: amountIn,
            amountOutMinimum: quote,
            sqrtPriceLimitX96: 0
        });

        uint amountOut = swapRouter.exactInputSingle(params);
        return amountOut;
    }

  function getQuote(address _tokenIn,address _tokenOut,uint256 amountIn) public returns (uint256) {
        Quoter quoter = Quoter(QuoterAddress);
        uint256 amountOut = quoter.quoteExactInputSingle(_tokenIn, _tokenOut, poolFee, amountIn, 0);
        return amountOut;
    }
    

 

    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
       makeArbitrage(amount); 
        
        uint256 totalAmount = amount + premium;
        emit Premium(amount, premium);
        IERC20(asset).approve(address(POOL), totalAmount);
        return true;
    }



    function getERC20Balance(address _erc20Address)
        public
        view
        returns (uint256)
    {
        return IERC20(_erc20Address).balanceOf(address(this));
    }

    }