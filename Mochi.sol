// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract Ownership{

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner,"Only Owner can call");
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner returns(bool){
     require(_newOwner != address(0),"0x detected.");
     owner = _newOwner;
     return true;
  }

}

contract Mochi is Ownership{

     string public name;
     string public symbol;

     event Transfer(address sender,address receiver,uint tokenId);
     event Approval(address owner,address spender,uint tokenId);
     event ApprovalForAll(address owner,address spender,bool isApproved);
 
     constructor(string memory _name,string memory _symbol){
        name = _name;
        symbol = _symbol;
     }

    mapping (uint=>address) private _owner;
    mapping (address=>uint) private _balance;
    mapping (uint=>address) private _spenderApprove;
    mapping (address=>mapping(address=>bool)) private _operatorApprove;
    mapping (uint=>string) private _tokenURI;

    
    function tokenURI(uint _id) public view returns(string memory){
        return _tokenURI[_id];
    }

    function balanceOf(address _user) public view returns(uint){
        require(address(0) != _user,"0x invalid.");
        return _balance[_user];
    }

    function ownerOf(uint _id) public view returns(address){
        require(_owner[_id] != address(0),"invalid address");
        return _owner[_id];
    }

    function isApprovedOrOwner(address from,uint id) internal view returns(bool){
        return _spenderApprove[id] == msg.sender || _operatorApprove[from][msg.sender] || _owner[id] == msg.sender;
    }

    function approve(address spender,uint id) public returns(bool){

        require(isApprovedOrOwner(msg.sender, id),"UnAuthorized.");
        _spenderApprove[id] = spender;
        emit Approval(msg.sender,spender,id);
        return true;

    }

    function setApproveForAll(address spender,bool isApprove) public returns(bool){
        require(address(0) != spender,"0x Address detected.");
        _operatorApprove[msg.sender][spender] = isApprove;
        emit ApprovalForAll(msg.sender, spender, isApprove);
        return true;        
    }

    function transferFrom(address from,address to,uint id) public returns(bool){

        require(isApprovedOrOwner(from, id),"UnAuthorized.");
        require(_owner[id] == from,"from not owner");
        require(to != address(0),"0x address detected.");

        _balance[from] -= 1;
        _balance[to] += 1;
        _owner[id] = to;

        emit Transfer(from, to, id);
        return true;


    }

    function mint(address receiver,uint id,string memory uri) public onlyOwner returns(bool){
         
         require(_owner[id] == address(0),"Already exist.");
         require(receiver != address(0),"0 address detected.");

         _owner[id] = receiver;
         _balance[receiver] += 1;
         _tokenURI[id] = uri;
         emit Transfer(address(0),receiver,id); 
         return true;

    }

    function getApproved(uint id) public view returns(address){
        return _spenderApprove[id];
    }
    
    function isApprovedForAll(address owner,address spender) public view returns(bool){
           require(owner != address(0) || spender != address(0),"0x address detected.");
           return _operatorApprove[owner][spender];
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
    return interfaceId == 0x80ac58cd; // ERC-721 interface ID
}



}