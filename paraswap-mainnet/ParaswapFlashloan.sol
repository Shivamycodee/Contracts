// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

interface IParaswap{

    struct SimpleData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address[] callees;
        bytes exchangeData;
        uint256[] startIndexes;
        uint256[] values;
        address payable beneficiary;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }

    function simpleSwap(SimpleData memory data) external payable returns (uint256);
     function simpleBuy(SimpleData memory data) external payable;

}

contract ParaswapFlashloan is FlashLoanSimpleReceiverBase {

      event SwapIn(address indexed fromToken, address indexed toToken,uint inAmt, uint256 outAmt);
      event SwapOut(address indexed fromToken, address indexed toToken,uint inAmt, uint256 outAmt);

  address public owner;
  address public PoolAddressesProviderPolygon = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;

  address public ParaswapAugustusV5 = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;
  address public ParaswapTokenTransferProxy = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae; // Give allowance to this.
  address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; // USDC
  address public AavePoolAddress = 0x0b913A76beFF3887d35073b8e5530755D60F78C7;

    constructor()
     FlashLoanSimpleReceiverBase(IPoolAddressesProvider(PoolAddressesProviderPolygon)) 
    {
    owner = msg.sender;
    }


  function ApproveTokenTransferProxy(address tokenIn,uint amount) public {
    IERC20(tokenIn).approve(ParaswapTokenTransferProxy,amount); // Give allowance to this.
  }

  function Approve(address tokenIn,uint amount,address spender) public {
    IERC20(tokenIn).approve(spender,amount); // Give allowance to this.
    }


    function fn_RequestFlashLoan(address _token, uint256 _amount,IParaswap.SimpleData[] memory _params) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = abi.encode(_params);
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }


function makeArbitrage(bytes memory params) public {

    IParaswap.SimpleData[] memory SwapData = abi.decode(params,(IParaswap.SimpleData[]));
  
    uint amt = SimpleSwap(SwapData[0]);
   emit SwapIn(SwapData[0].fromToken,SwapData[0].toToken,SwapData[0].fromAmount,amt);
    uint amt2 = SimpleSwap(SwapData[1]);
   emit SwapOut(SwapData[1].fromToken,SwapData[1].toToken,SwapData[1].fromAmount,amt2);
      
    }


   
  function SimpleSwap(IParaswap.SimpleData memory params) public payable returns(uint){
   uint bal = IERC20(params.fromToken).balanceOf(address(this));
   params.fromAmount = bal;
   require(bal >= 0,"Insufficient Balance");
   uint amt = IParaswap(ParaswapAugustusV5).simpleSwap(params);
//    IERC20(params.toToken).transfer(msg.sender,IERC20(params.toToken).balanceOf(address(this)));
   return amt;

  }

    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
        IERC20(asset).approve(PoolAddressesProviderPolygon,amount);  // PoolAddress provider...

        makeArbitrage(params);
        
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }


    function withdraw(address token) public {
    require(msg.sender == owner);
    uint amt = IERC20(token).balanceOf(address(this));
    IERC20(token).approve(msg.sender,amt);
    IERC20(token).transfer(msg.sender,amt);
    }

    }