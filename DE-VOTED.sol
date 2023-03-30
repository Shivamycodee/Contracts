// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;


contract Ownable{
    address _owner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor(){
        _owner = msg.sender;
        emit OwnershipTransferred(address(0),_owner);
    }

    modifier onlyOwner(){
        require(msg.sender == _owner,"only owner can access");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
       _owner = _newOwner;
       emit OwnershipTransferred(msg.sender,_owner);
    }

     function renounceOwnership() public onlyOwner{
        _owner = address(0);
        emit OwnershipTransferred(_owner,address(0));
    }

}


contract devote is Ownable{


    event electionCreated(uint electionId,uint startDate,uint endDate);
    event candidateAdded(address indexed,uint enrollNo);
    event subAdminAdded(uint id,uint enrNo);
    event voterAdded(address indexed, uint enrNo,uint sem);
    event voted(uint,address,address);


    uint fiveMonths = 13149000;

    struct subAdmin{
        uint id;
        address subAdminAddress;
        string name;
        uint enrollNo;
        string department;
        bool isAllowed;
    }

    struct voter{
        address voterAddress;
        uint  enrollNo;
        uint year;
        uint sem;    
    }

    struct candidate{
        address add;
        string name;
        uint enrollNo;
        bool isStanding;
        string email;
    }

    struct election{
        uint electionId;
        uint start;
        uint end;
        uint strength;
        string department;
        string position;
        string description;
        uint voteCount;
    }



    mapping(uint => election) public elections;
    mapping(address => subAdmin) public subAdmins;
    mapping(address => candidate) public candidates;
    mapping(address => voter) public voters;
    mapping(uint => mapping(uint => address)) public myVote;
    mapping(address => mapping(uint => uint)) public ballotCount;
    mapping(uint =>mapping(address=>bool)) public hasVoted;
    mapping(address => uint) public access;

    mapping(uint =>mapping(uint => voter)) public voterList;

    modifier onlySubAdmin(){
        require(subAdmins[msg.sender].isAllowed,"Only allowed sub-admins can access...");
        _;
    }

    modifier isElectionAlive(election memory elc){
        require(block.timestamp < elc.end && block.timestamp > elc.start);
        _;
    }

    modifier isVoter(){
        require(voters[msg.sender].voterAddress == msg.sender,"please register first");
        _;
    }

    modifier isAuthorized(){
        require(access[msg.sender] > block.timestamp,"Your access has been revoked");
        _;
    }

    modifier candidateExist(address _cad){
        require(candidates[_cad].add == msg.sender,"Candidate does not exist");
        _;
    }

    modifier isEnded(uint id){
        require(elections[id].end < block.timestamp,"Election is still going on...");
        _;
    }


    function createSubAdmin(uint _id,
    string memory _name,
    uint _enrollNo,
    string memory _department) public onlyOwner{

  subAdmins[msg.sender] = subAdmin(_id,msg.sender ,_name, _enrollNo, _department, true);
  emit subAdminAdded(_id, _enrollNo);

}

    function createElection(uint id,
    uint _start,
    uint _end,
    uint _strength,
    string memory _dept,
    string memory _position,
    string memory _data) public onlyOwner onlySubAdmin{
      require(_start < _end,"please configure dates of election");
      elections[id] = election(id,_start,_end,_strength,_dept,_position,_data,0);
      emit electionCreated(id,_start,_end);  

    }

    function createCandidate(
        string memory _name,
        uint _enrollNo,
        bool _isStanding,
        string memory _email
    ) public onlyOwner onlySubAdmin{

        candidates[msg.sender] = candidate(msg.sender,_name,_enrollNo,_isStanding,_email);
        emit candidateAdded(msg.sender,_enrollNo);
    }

   function createVoter(uint _enroll,uint _year,uint _sem) public onlyOwner onlySubAdmin{
       voters[msg.sender] = voter(msg.sender,_enroll,_year,_sem);
       grantAccess(_year,_sem);
       emit voterAdded(msg.sender,_enroll,_sem);
   }

   function grantAccess(uint _year,uint _sem) public {
       uint totalSem = 2*_year;
       uint remain = totalSem - _sem + 1;
       uint remainSec = remain*fiveMonths;
       access[msg.sender] = block.timestamp + remainSec;
   }



   function vote(uint _electionId,address _candidate) public isElectionAlive(elections[_electionId]) isAuthorized() candidateExist(_candidate){
       require(!hasVoted[_electionId][_candidate],"you have already voted...");

         uint enr = voters[msg.sender].enrollNo;

         myVote[_electionId][enr] = _candidate;

         ballotCount[_candidate][_electionId] += 1;
         elections[_electionId].voteCount += 1;

         hasVoted[_electionId][_candidate] = true;

         uint voterId = elections[_electionId].voteCount;
         voterList[_electionId][voterId] = voters[msg.sender];

         emit voted(_electionId,msg.sender,_candidate);
   }

   function getElectionData(uint _id) public view isEnded(_id) returns(uint,uint,string memory,string memory,string memory,uint,voter[] memory){
       election memory elc = elections[_id];
       uint totalVotes = elc.voteCount;

       voter[] memory vt = new voter[](totalVotes);
       for(uint i=1; i <= totalVotes ;i++){
           vt[i] = voterList[_id][i];         
       }
       return (elc.start,elc.end,elc.department,elc.position,elc.description,elc.voteCount,vt);
   }


}
