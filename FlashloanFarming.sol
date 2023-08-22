// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface AavePoolv3{

   function supply(address asset,uint amount,address onBehalfOf,uint16 referalCode) external;
   function withdraw(address asset,uint amount,address to) external returns(uint256);
   function borrow(address asset,uint256 amount,uint256 interestRateCode,uint16 referalCode,address onBehalfOf) external;
   function repay(address asset,uint256 amount,uint256 interestRateCode,address onBehalfOf) external;

   function getUserAccountData(address user) external returns(uint,uint,uint,uint,uint,uint);
   // totalCollateralBase totalDebtBase availableBorrowsBase currentLiquidationThreshold ltv healthFactor  

}


// interface AaveProtocolDataProvider{
//     function getUserReserveData(address asset,address user) external returns(uint,uint,uint,uint,uint,uint,uint,uint40,bool);
// }

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


contract FlashLoanFarming is FlashLoanSimpleReceiverBase {

    event Supplied(address user,uint amount);


    address payable owner;

    address public USDT = 0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0;
    address public USDC = 0xe9DcE89B076BA6107Bb64EF30678efec11939234; // USDC Address.

    address public AavePoolAddress = 0x0b913A76beFF3887d35073b8e5530755D60F78C7;
    uint public ApprovalAmount = 10000000*10**6;
    // address public AaveProtocolData = 0xacB5aDd3029C5004f726e8411033E6202Bc3dd01;

     //   PoolAddressesProvider-Polygon      │ '0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F' │


    constructor()
     FlashLoanSimpleReceiverBase(IPoolAddressesProvider(0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F))
    {}

    function fn_RequestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
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

  
  function FlashLoanFarm(address asset,uint amount) public {

     uint balance = IERC20(asset).balanceOf(address(this)) - 1e6;
     Supply(asset,balance);
     emit Supplied(address(this),balance);
     Borrow(asset,amount);

  }


  function Supply(address asset,uint amount) public {
        require(IERC20(asset).approve(AavePoolAddress,ApprovalAmount),"allowance failed");
        require(IERC20(asset).balanceOf(address(this)) > amount,"insufficient balance...");
        // require(IERC20(asset).transferFrom(msg.sender,address(this),ApprovalAmount),"token transfer fails");
        AavePoolv3(AavePoolAddress).supply(asset,amount,address(this),0);
    }

    function Borrow(address asset,uint amount) public {
        AavePoolv3(AavePoolAddress).borrow(asset,amount,2,0,address(this));
    }



    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
        IERC20(asset).approve(0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F,ApprovalAmount);
        IERC20(asset).approve(AavePoolAddress,ApprovalAmount);
        FlashLoanFarm(asset,amount);
        
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }


    }
