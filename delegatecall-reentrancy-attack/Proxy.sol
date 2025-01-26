// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;
import "hardhat/console.sol";

contract Proxy{

    error CallDelegationError(uint a);

   uint8 public data;
   address ImplmentaionA;
   struct Message{
    string mess;
    uint8 num;
   }

   function setImpAddress(address add) external {
    ImplmentaionA = add;
   }


   function callcall(uint a) external{

      (bool success,) = ImplmentaionA.call(abi.encodeWithSignature("setNumber(uint8)", a));
      require(success,"delegate call failed.");

   }

   function callDelegate(uint a) external{

    if(a == 2){
        revert CallDelegationError({a:2});
    }

      (bool success,) = ImplmentaionA.delegatecall(abi.encodeWithSignature("setNumber(uint8)", a));
      require(success,"delegate call failed.");

   }

     function callDelegateGetStr() external returns(Message memory){

      (bool success,bytes memory res) = ImplmentaionA.delegatecall(abi.encodeWithSignature("getString()"));
      require(success,"delegate call failed.");
      console.logBytes(res);
      Message memory str = abi.decode(res, (Message));
      console.logString(str.mess);
      console.logUint(str.num);
      return str;

   }

       fallback() external {
        address pLogic = ImplmentaionA;
        require(pLogic != address(0), "Invalid Ox");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), pLogic, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

}