// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;
import "./CrowdfundStruct.sol";

struct Fund {
    address fundRaiser;
    string description;
    uint256 targetAmount;
    uint256 collectedAmount;
    bool isAchieved;
    // uint startTime;
    uint256 endTime;
}

contract Crowdfund is CrowdfundStruct {

    modifier canContribute(uint256 id) {
        bool flag = Funds[id].collectedAmount < Funds[id].targetAmount;
        if (!flag) {
            Funds[id].isTargetAchieved = true;
            TargetStatus[id] = targetStatus.Achieved;
            }
        require(flag, "Target already achieved");
        _;
    }

    modifier contributionOpen(uint256 id) {
        require(
            Funds[id].endTime > block.timestamp,
            "Cannot contribute now, time over."
        );
        _;
    }

    modifier isFundRaiser(uint256 id) {
        require(
            Funds[id].fundRaiser == msg.sender,
            "Only FundRaiser can withdraw"
        );
        _;
    }

    modifier notDeadFund(uint256 id) {
        require(!DeadFund[id], "Dead fund.");
        _;
    }

    function raiserAllowed() public view returns(bool){
        uint id = getFundId(msg.sender);
        if(id == 0 || DeadFund[id]) return true;
        else return false;
    }

    function getFundId(address raiser) public view returns (uint256) {
        require(notZeroAddress(raiser), "0x0 Detected.");
        return fundIdbyRaiser[raiser];
    }
    
    function getContribution(uint id) public view returns(uint){
        require(id != 0 && id <= fundCount, "0x0 Detected.");
        return contributionRecord[msg.sender][id];
    }

    function createCrowdFunding(Fund memory _fund) public returns (bool) {
        require(raiserAllowed(),"Raiser already have 1 fund running.");
        require(notZeroAddress(_fund.fundRaiser), "0x0 Detected.");
        require(_fund.endTime > block.timestamp, "Increase Fund timespan.");
        require(_fund.targetAmount > 0, "Requested amount is 0.");
        require(!_fund.isTargetAchieved, "false data.");

        TargetStatus[fundCount] = targetStatus.InProgress;
        DeadFund[fundCount] = false;
        fundIdbyRaiser[_fund.fundRaiser] = fundCount;
        Funds[fundCount] = _fund;
        fundCount += 1;
        emit FundCreated(_fund, owner, block.timestamp);
        return true;
    }

    function contribute(uint256 fundId)
        public
        payable
        canContribute(fundId)
        contributionOpen(fundId)
        notDeadFund(fundId)
        returns (bool)
    {
        require(
            msg.value > 0,
            "No ethers provided.please contribute some ethers for this fund"
        );
        Funds[fundId].collectedAmount += msg.value;
        contributionRecord[msg.sender][fundId] += msg.value;
        emit Contributed(fundId,msg.sender,msg.value);
        return true;
    }

    function withdrawFunds(uint256 fundId)
        public
        isFundRaiser(fundId)
        notDeadFund(fundId)
        returns (bool)
    {
        require(Funds[fundId].isTargetAchieved, "Target Not Achieved.");
        DeadFund[fundId] = true;
        bool success = payable(msg.sender).send(Funds[fundId].collectedAmount);
        return success;
    }

    function withdrawContribution(uint fundId) public returns(bool){
        require(DeadFund[fundId],"Fund is still live.");
        require(TargetStatus[fundId] != targetStatus.InProgress && TargetStatus[fundId] != targetStatus.Achieved,"Cannot refund.");
        require(contributionRecord[msg.sender][fundId]>0,"No contribution made by you.");

        (bool success) = payable(msg.sender).send(contributionRecord[msg.sender][fundId]);
        contributionRecord[msg.sender][fundId] = 0;
        return success;
    }

}
