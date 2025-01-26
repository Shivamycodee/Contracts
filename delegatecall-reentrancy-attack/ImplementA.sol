// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;


contract ImplementationA {

   uint8 public number;

   function setNumber(uint8 num) external {
    number = num;
   }

}
