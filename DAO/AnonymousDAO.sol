// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;
import "./AnonymousStore.sol";


contract AnonymousDAO is AnonymousStore{

    modifier proposalExist(){
        require(isDAOBusy,"Their is No Proposal currently.");
        _;
    }

    modifier validVoter(){
        require(IERC20(anonymousToken).balanceOf(msg.sender)>0,"Not a token holder.");
        _;
    }

    modifier validVotingPeriod(){
         uint proposedTime = Proposals[proposalCount].proposedTime;
         require(block.timestamp<= proposedTime+proposalVotingPeriod,"can't vote");
         _;
    }

    modifier votingEnded(){
           uint proposedTime = Proposals[proposalCount].proposedTime;
         require(block.timestamp >= proposedTime+proposalVotingPeriod,"can still vote");
         _;
    }

      function updateProposalVotingPeriod(uint _newPeriod) public {

        require(_newPeriod > 1 days,"Mininmum Period requriement is 1 day.");
        require(_newPeriod < 100 days,"Maximum Period possible is 100 days.");
        proposalVotingPeriod = _newPeriod;

      }


      function ceateProposal(Proposal memory _proposol) public returns(bool){

        proposalCount += 1;
        isDAOBusy = true;
        status[proposalCount] = Judgement.Pending;

        Proposals[proposalCount] = _proposol;
        CollateralToken memory _collateralToken = _proposol.colletral;

        require(_proposol.investment <= IERC20(anonymousToken).balanceOf(address(this)),"DAO lacks the investment amount");

        // check weather proposal provide any colleatral or not.
        if(_collateralToken.isBlockchainBased && _collateralToken.haveProjectToken && _collateralToken.colletralProjectToken>0){
            require(IERC20(_collateralToken.projectToken).allowance(address(this)) >= _collateralToken.colletralProjectToken,"Allowance To DAO is not provided.");
            require(IERC20(_collateralToken.projectToken).transferFrom(msg.sender,address(this),_collateralToken.colletralProjectToken),"Token Transfer Failed.");
        }

        return true;

      }


      function vote(bool response,uint amount) public proposalExist validVoter validVotingPeriod{

        require(IERC20(anonymousToken).balanceOf(msg.sender)>= amount,"Voting amount not valid,please vote on the basis of you token balance.");

          if(response){
            Proposals[proposalCount].voteFor += amount;
          }else{
            Proposals[proposalCount].voteAgainst -= amount;
          }

      }


      function passJudgement() public proposalExist votingEnded{

        isDAOBusy = false;
        CollateralToken memory _collateralToken = Proposals[proposalCount].colletral;
        if(Proposals[proposalCount].voteFor > Proposals[proposalCount].voteAgainst) {
            status[proposalCount] = Judgement.Approved;
            IERC20(anonymousToken).transfer(Proposals[proposalCount].receiver,Proposals[proposalCount].investment);
        }
        else {
            status[proposalCount] = Judgement.Rejected;
            if(_collateralToken.isBlockchainBased && _collateralToken.haveProjectToken){
                IERC20(_collateralToken.projectToken).transfer(Proposals[proposalCount].receiver,_collateralToken.colletralProjectToken);
            }
        }

      }


}


