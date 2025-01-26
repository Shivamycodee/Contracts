// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;


contract ImplementationB {

   uint8 public number;

   function setNumber(uint8 num) external {
    number = num*2;
   }

   struct Message {
    string message;
    uint8 num;
   }


   function getString() public pure returns(Message memory){
    Message memory mess = Message({message:"FUCK YOU",num:22});
    return mess;
   }

}
