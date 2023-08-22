// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface AavePoolv3{

   function supply(address asset,uint amount,address onBehalfOf,uint16 referalCode) external;
   function withdraw(address asset,uint amount,address to) external returns(uint256);
   function borrow(address asset,uint256 amount,uint256 interestRateCode,uint16 referalCode,address onBehalfOf) external;
   function repay(address asset,uint256 amount,uint256 interestRateCode,address onBehalfOf) external;

   function getUserAccountData(address user) external returns(uint,uint,uint,uint,uint,uint);
   // totalCollateralBase totalDebtBase availableBorrowsBase currentLiquidationThreshold ltv healthFactor  

}


interface AaveProtocolDataProvider{
    function getUserReserveData(address asset,address user) external returns(uint,uint,uint,uint,uint,uint,uint,uint40,bool);
}

interface XStaker{
        function Stake(uint amount) external returns(uint);
        function RemoveStake() external returns(uint);
}


contract CompoundYeild{

    address public AavePoolAddress = 0x0b913A76beFF3887d35073b8e5530755D60F78C7;
    address public AaveProtocolData = 0xacB5aDd3029C5004f726e8411033E6202Bc3dd01;

    address public usdt = 0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0; // USDT Address.
    address public USDC = 0xe9DcE89B076BA6107Bb64EF30678efec11939234; // USDC Address.

    address public AGEUR = 0x1870299d37aa5992850156516DD81DcBf98f2b1C; // AGEUR Address.
    address public AGEURX = 0x6bF2BC4BD4277737bd50cF377851eCF81B62e320; // JEUR Address.


    mapping(address=>uint) public Deposit;
    mapping(address=>uint) public TotalDeposit;
    mapping(address=>uint) public aTokenHold;

    uint8 StableInterestRateCode = 1;


    function Supply(address asset,uint amount) public {
        require(IERC20(asset).approve(AavePoolAddress,amount),"allowance failed");
        require(IERC20(asset).balanceOf(msg.sender) > amount,"insufficient balance...");
        require(IERC20(asset).transferFrom(msg.sender,address(this),amount),"token transfer fails");
        Deposit[msg.sender] += amount;
        TotalDeposit[asset] += amount;
        AavePoolv3(AavePoolAddress).supply(asset,amount,address(this),0);
    }


    function Withdraw(address asset,uint decimal,uint _amount) public {
        uint amount = _amount*10**decimal; 
        uint finalAmount = amount;
        AavePoolv3(AavePoolAddress).withdraw(asset, finalAmount, address(this));
    }

    function Borrow(address asset,uint _amount,uint8 decimal,uint256 InterestRateCode) public {
        uint amount = _amount*10**decimal; 
        AavePoolv3(AavePoolAddress).borrow(asset,amount,InterestRateCode,0,address(this));
    }

    function BorrowMaxAmount(address asset,uint256 InterestRateCode) public returns(uint){
        uint GetMaxBorrowValue = getMaxBorrowValue(address(this),asset);
        AavePoolv3(AavePoolAddress).borrow(asset,GetMaxBorrowValue,InterestRateCode,0,address(this));
        return GetMaxBorrowValue;

    }

    function Repay(address asset,uint _amount,uint256 decimal,uint256 InterestRateCode) public {
        uint amount = _amount*10**decimal;
        require(IERC20(asset).approve(AavePoolAddress,amount),"allowance failed");
        AavePoolv3(AavePoolAddress).repay(asset,amount,InterestRateCode,address(this));
    }


    function getCurrentBalance(address asset,address user) public returns(uint){
      (uint aToken, , , , , , , ,) = AaveProtocolDataProvider(AaveProtocolData).getUserReserveData(asset, user);
       return aToken;
    }

    function getMaxBorrowValue(address user,address asset) public returns(uint){
        (,,,,uint _ltv,) = AavePoolv3(AavePoolAddress).getUserAccountData(user);
        uint ltv = (_ltv/100) - 1;
         uint currentBal = getCurrentBalance(asset, user);
         uint maxVal = currentBal*ltv/10000;
        return maxVal;
    }

    function CompoundYieldFarming(address xstaker,uint amount,uint InterestRateCode) public {

      require(IERC20(usdt).approve(AavePoolAddress,amount*1e6),"usdt allowance failed");
      require(IERC20(AGEUR).approve(AavePoolAddress,amount*1e18),"matic allowance failed");

      require(IERC20(AGEUR).approve(xstaker,amount*1e18),"matic allowance failed");
      require(IERC20(AGEURX).approve(AavePoolAddress,amount*1e18),"maticX allowance failed");

      require(IERC20(usdt).transferFrom(msg.sender,address(this),amount*1e6),"token transfer fails");
      Supply(usdt,amount*1e6);

      uint Amount = amount*1e18;

    while(Amount > 1 ether){
      uint borrowedAmount = BorrowMaxAmount(AGEUR,InterestRateCode);
      Amount = borrowedAmount;
      uint xToken = XStaker(xstaker).Stake(Amount);
      Supply(AGEURX,xToken);
    }

    }


}
