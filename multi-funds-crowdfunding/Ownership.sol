// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

contract Ownership{

    event TransferOwnership(address _previousOwner,address _newOwner);

   address public owner;

   constructor(){
    owner = msg.sender;
   }

   modifier onlyOwner(){
    require(msg.sender == owner,"UnAuthorized.");
    _;
   }

   function notZeroAddress(address user) public pure returns(bool){
    return user != address(0);
   }

   function transferOwnership(address _newOwner) public onlyOwner returns(bool){
         require(notZeroAddress(_newOwner),"0x0 detected.");
         owner = _newOwner;
         emit TransferOwnership(owner, _newOwner);
         return true;
   }

   function renounceOwnership() public onlyOwner returns(bool){
      owner = address(0);
      emit TransferOwnership(owner, address(0));
      return true;
   }

}