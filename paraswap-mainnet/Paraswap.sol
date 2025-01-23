// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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


contract Paraswap {

  address public owner;

  event Swap(address indexed fromToken, address indexed toToken,uint inAmt, uint256 outAmt);

  address public ParaswapAugustusV5 = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;
  address public ParaswapTokenTransferProxy = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae; // Give allowance to this.

  address public TokenIn = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; // USDC

  constructor() {
    owner = msg.sender;
  }

  function setTokenIn(address _tokenIn) public {
    TokenIn = _tokenIn;
  }

  function ApproveTokenTransferProxy(uint amount) public {
    IERC20(TokenIn).approve(ParaswapTokenTransferProxy,amount); // Give allowance to this.
  }

  function SimpleSwap(IParaswap.SimpleData memory params) public payable returns(uint){
   IERC20(TokenIn).transferFrom(msg.sender,address(this),params.fromAmount);
   uint amt = IParaswap(ParaswapAugustusV5).simpleSwap(params);
   IERC20(params.toToken).transfer(msg.sender,IERC20(params.toToken).balanceOf(address(this)));
   emit Swap(params.fromToken,params.toToken,params.fromAmount,amt);
   
   return 0;

  }

  function SimpleBuy(IParaswap.SimpleData memory params) public payable{
    IERC20(TokenIn).transferFrom(msg.sender,address(this),params.fromAmount);
    IParaswap(ParaswapAugustusV5).simpleBuy(params);
    uint amt = IERC20(params.toToken).balanceOf(address(this));
    IERC20(params.toToken).transfer(msg.sender,amt);

  }

  function withdraw(address token) public {
    require(msg.sender == owner);
    uint amt = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(msg.sender,amt);
  }


}