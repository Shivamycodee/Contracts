// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;
import {Ownership} from "./Anonymous.sol";


interface IERC20{
  function allowance(address spender) external returns(uint);
  function transfer(address to,uint amount) external returns(bool);
  function transferFrom(address from,address to,uint amount) external returns(bool);
  function balanceOf(address user) external returns(uint);
}


contract AnonymousStore is Ownership{

    bool public isDAOBusy;
    uint public proposalVotingPeriod = 10 days; // mutable by owner;
    enum Judgement {Approved,Pending,Rejected}
    uint public proposalCount = 0;
    address anonymousToken = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    struct CollateralToken{
      bool isBlockchainBased;
      bool haveProjectToken;
      address projectToken;
      uint colletralProjectToken;
    }


    struct Proposal{ 
      address receiver;
      uint propId;
      uint proposedTime;
      string description;
      uint investment;
      CollateralToken colletral;
      uint voteFor;
      uint voteAgainst;
      bool votingCompleted;
      Judgement communityDecision;

    }

    mapping (uint=>Proposal) public Proposals;
    mapping(uint => Judgement) public status;

}