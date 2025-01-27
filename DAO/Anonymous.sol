// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;


contract Ownership{

   event OwnershipTransfer(address _oldOwner,address _newOwner,uint timestamp);

   address owner;


   constructor(){
    owner = msg.sender;
    emit OwnershipTransfer(address(0), msg.sender, block.timestamp);
   }
   
   modifier onlyOwner(){
    require(msg.sender == owner,"Only owner can call this function.");
    _;
   }

   function transferOwnership(address _newOwner) public onlyOwner{
          require(_newOwner != address(0),"Can't transfer ownership to zero address.");
          owner = _newOwner;
          emit OwnershipTransfer(msg.sender,_newOwner, block.timestamp);

   }


}



contract Voter is Ownership{

 event Transfer(address sender,address receiver,uint amount);
 event Approval(address owner,address spender,uint amount);

 string _name;
 string _symbol;
 uint8 _decimal;
 uint _totalSupply;

 mapping(address => uint) private _balance;
 mapping(address => mapping(address => uint)) private _allowance;

 constructor(uint8 __decimal,string memory __name,string memory __symbol){

    _name = __name;
    _decimal = __decimal;
    _symbol = __symbol;

 }

 function name() public view returns(string memory){
    return _name;
 }

 function symbol() public view returns(string memory){
    return _symbol;
 }

 function decimal() public view returns(uint8){
    return _decimal;
 }

 function totalSupply() public view returns(uint){
    return _totalSupply;
 }

 function balanceOf(address user) public view returns(uint){
    return _balance[user];
 }

 function _handler(address sender,address receiver,uint amount) private {

    if(sender == address(0)){

       unchecked {
       _totalSupply += amount;   
       _balance[receiver] += amount;
        }

    }
    if(receiver == address(0)){

       unchecked {
       _totalSupply -= amount;   
        }

    }

    if(sender != address(0) && receiver != address(0) && msg.sender == sender){
  
      unchecked{  _balance[sender] -= amount;
        _balance[receiver] += amount;
}
    }else{
      
     unchecked {
      _allowance[sender][msg.sender] -= amount;
      _balance[sender] -= amount;
      _balance[receiver] += amount;

}
    }


    emit Transfer(sender,receiver,amount);
 
 }

 function mint(address receiver,uint amount) public onlyOwner{

    require(amount>0,"Amount should be more than 0");
    _handler(address(0),receiver,amount);

 }

 function burn(uint amount) public onlyOwner{
        require(amount>0,"Amount should be more than 0");
        require(amount<=_totalSupply,"amount is more than totalsupply");
        _handler(msg.sender, address(0), amount);

 }

 function approve(address spender,uint amount) public {

    require(spender != address(0),"zero address detected.");
    _allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender,spender,amount);


 }

 function allowance(address spender) public view returns(uint){
    return _allowance[msg.sender][spender];
 }

 function transfer(address receiver,uint amount) public {

   require(receiver != address(0),"receiving address is a zero address");
   require(_balance[msg.sender] >= amount,"not enough balance");
   _handler(msg.sender, receiver, amount);

 }

 function transferFrom(address sender,address receiver,uint amount) public {

  require(_allowance[sender][msg.sender] >= amount,"Not enough allowance.");
  require(balanceOf(sender)>=amount,"not enough balance.");
  _handler(sender, receiver, amount);

 }


}