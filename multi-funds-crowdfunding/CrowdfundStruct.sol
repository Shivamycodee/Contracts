// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;
import "./Ownership.sol";

contract CrowdfundStruct is Ownership {

    uint fundCount = 1;
    enum targetStatus {Achieved,InProgress}

    event FundCreated(Fund _fund,address owner,uint timestamp);
    event Contributed(uint fundId,address contributor,uint amount);

    struct Fund{
        address fundRaiser;
        string description;
        uint targetAmount;
        uint collectedAmount;
        bool isTargetAchieved;

        // uint startTime;
        uint endTime;
    }

    mapping (uint=>Fund) public Funds;
    mapping (uint=>targetStatus) public TargetStatus;
    mapping(address=>uint) internal fundIdbyRaiser;
    mapping (uint=>bool) public DeadFund;
    mapping (address=>mapping(uint=>uint)) internal contributionRecord;

}