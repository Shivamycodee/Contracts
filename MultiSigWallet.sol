// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract MutliSigWallet{

  event TransactionInserted(address to,uint amount,uint id);
  event TransactionApproved(uint id,address owner);
  event TransactionExecuted(uint id,address to,uint amount);

  address[] public Owners;
  uint private immutable cfmSigns;

  struct Transaction{
    uint amount;
    address to;
    bool isCompleted;
  }

  mapping (address=>bool) private isOwner;
  mapping (uint=> mapping(address=>bool)) isApproved;

  Transaction[] transactions;

  modifier onlyOwner(){
    require(isOwner[msg.sender],"Not Owner");
    _;
  }

  constructor(address[] memory _owner,uint _cfmSigns){

      require(_owner.length>1,"Should be more than 1 owners");
      require(_owner.length>=_cfmSigns,"Invalid Confirm Signature value");
      Owners = _owner;
      cfmSigns = _cfmSigns;
      for(uint8 i=0;i<_owner.length;i++){
        require(_owner[i] != address(0),"Invalid Address");
              isOwner[_owner[i]] = true;
}
  }

  function insertTransaction(address to) public payable onlyOwner{

     require(to != address(0),"Invalid Address.");
     require(msg.value>0,"No ethers transfered.");

     uint transactionId = transactions.length;
     isApproved[transactionId][msg.sender] = true;

     transactions.push(Transaction(
        msg.value,
        to,
       false
     ));
     
     emit TransactionInserted(to, msg.value, transactionId);

  }

  function approveTransaction(uint id) public onlyOwner {

       require(transactions.length>id,"Invalid Id");
       require(isApproved[id][msg.sender],"Tx is already approved by owner.");

       isApproved[id][msg.sender] = true;

       uint cfmCount = 0;
       for(uint8 i=0;i<Owners.length;i++){
           if(isApproved[id][Owners[i]]) cfmCount++;
       }

       if(cfmCount>=cfmSigns) executeTransaction(id);
       emit TransactionApproved(id, msg.sender);

  }

  function executeTransaction(uint id) private onlyOwner{

      require(transactions.length>id,"Invalid Id");
      Transaction memory _tx = transactions[id];
      require(!_tx.isCompleted,"Tx already completed");
      
 
       (bool success,) = payable(_tx.to).call{value:_tx.amount}("");
       require(success,"Transaction Failed.");
       transactions[id].isCompleted = true;
       emit TransactionExecuted(id, _tx.to, _tx.amount);

  }



}