// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Ekyc{

    // Address of the central bank RBI
    address RBI; 

    constructor(){
      // Assigning of address to RBI variable
      RBI  = msg.sender;  
    }

    modifier onlyRBI(){
        // condition for functions, can only be called by RBI
        require(msg.sender == RBI,"only RBI can call!");  
        _;
    }

    modifier onlyBank(string memory _custName){
        // condition make sure that a bank can do kyc of only there own customers.
        require(Customer[_custName].CustBank == msg.sender,"Customer account does not exist.");
        _;
    }

     // This modifier checks that the address passed in is not the zero address.
    modifier validAddress(address _address) {
        require(_address != address(0), "Not valid address");
        _;
    }

    // General bank structure
    struct bank{               
        string BankName;
        address BankAddress;
        uint    KycCount;
        bool CanAddCust;
        bool CanDoKyc;
    }

    // General bank structure
    struct customer {      
        string CustName;
        string CustData;
        address CustBank;
        bool KycStatus;
    }

    // Relation between customer name and customer structure
    mapping (string => customer) Customer;
    // Relation between bank  address and bank  structure         
    mapping (address => bank) Banks;               

 //Function to add new bank which can only be called by RBI
 function AddNewBank(string memory _name,address _address) public onlyRBI validAddress(_address) {
      // require condition will make sure that no 2 or more banks are added of similar address.
       require(keccak256(abi.encodePacked(_address)) != keccak256(abi.encodePacked(Banks[_address].BankAddress)),"Bank already exist");
       Banks[_address] = bank(_name,_address,0,true,true);
   }

 // Function to add new customers 
 function AddNewCustomer(string memory _name,string memory _custData) public { 
     /*
     * require condition will make sure that no 2 or more customers are added of similar name.
     * Another require condition checks whether the  bank is allowed by RBI to add customer or not.
     */
     require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(Customer[_name].CustName)),"Customer already exist"); 
     require(Banks[msg.sender].CanAddCust,"Bank is not allowed to add customers.");
       Customer[_name] = customer(_name,_custData,msg.sender,false); 
}

 // Function  to allow banks to add new customer
 function AllowBankFromAddingNewCustomers(address _address) public onlyRBI validAddress(_address){
     // require condition checks whether Bank with this address exist or not.
     require(keccak256(abi.encodePacked(Banks[_address].BankName)) != keccak256(abi.encodePacked("")),"Bank with given address is not found");          
     Banks[_address].CanAddCust = true;
 }

  // Function to allow banks to do kyc
  function AllowBankFromKYC(address _address) public onlyRBI validAddress(_address){
     // require condition checks whether Bank with this address exist or not.
      require(keccak256(abi.encodePacked(Banks[_address].BankName)) != keccak256(abi.encodePacked("")),"Bank with given address is not found");         
      Banks[_address].CanDoKyc = true;
  }

  // Function  to block banks from  adding new customer
  function BlockBankFromAddingNewCustomers(address _address) public onlyRBI validAddress(_address){
     // require condition checks whether Bank with this address exist or not.
      require(keccak256(abi.encodePacked(Banks[_address].BankName)) != keccak256(abi.encodePacked("")),"Bank with given address is not found");         
      Banks[_address].CanAddCust = false;
  }
 
   // Function  to block banks from  doing kyc 
  function BlockBankFromKYC(address _address) public onlyRBI validAddress(_address){
     // require condition checks whether Bank with this address exist or not.
        require(keccak256(abi.encodePacked(Banks[_address].BankName)) != keccak256(abi.encodePacked("")),"Bank with given address is not found");        
        Banks[_address].CanDoKyc = false;
   }

   // function  to  update customer kyc status
   function  UpdateCustomerKycStatus(string memory _custName) public onlyBank(_custName){
    /*
     * require condition checks whether bank have a customer of this particular name(_custName) or not.
     * Another condition checks whether the bank is permitted to do kyc or not.
     */
       require(keccak256(abi.encodePacked(Customer[_custName].CustName)) != keccak256(abi.encodePacked("")),"Customer does not exist");     
       require(Banks[msg.sender].CanDoKyc,"Bank is not permitted to do kyc.");
       Customer[_custName].KycStatus = true;
       Banks[msg.sender].KycCount++;

   }

   // Function to view customer details
   function ViewCustomerDetails(string memory _custName) public view returns(string memory CustomerData,string memory BankOfCusotmer,bool kycStatus){  
      /*
      * By naming the return parameters (CustomerData,BankOfCustomer,etc), when the function is called,
       rather than returning only values with data type it returns values with title in deployed contracts section of remix ide.
      */
      require(keccak256(abi.encodePacked(Customer[_custName].CustName)) != keccak256(abi.encodePacked("")),"Customer does not exist");
       CustomerData = Customer[_custName].CustData;                         
       BankOfCusotmer = Banks[Customer[_custName].CustBank].BankName;
       kycStatus = Customer[_custName].KycStatus;
   }

   // Function to view bank details
   function ViewBankDetails(address _address) public view validAddress(_address) returns(string memory BankName,uint BankKycCount,bool CanAddCust,bool CanDoKyc){  
     /*
       By naming the return parameters(BankName,BankKycCount,etc), when the function is excuted,
       rather than returning only values with data type it returns values with title in deployed contracts section of remix ide.
     */
    require(keccak256(abi.encodePacked(Banks[_address].BankName)) != keccak256(abi.encodePacked("")),"Bank does not exist");
    BankName = Banks[_address].BankName;
    BankKycCount = Banks[_address].KycCount;
    CanAddCust = Banks[_address].CanAddCust;
    CanDoKyc = Banks[_address].CanDoKyc;
}

}
