// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract BankingSystem {
    // DECLARATIONS
    mapping (address => uint) private accountBalance ;
    mapping (address => string) private accountFirstName ;
    mapping (address => string) private accountLastName ;
    mapping (address => uint) private accountLoan ;
    uint private funds = 0 ;
    address private owner = tx.origin ;
    // CODE

    // Constructor
    constructor() {

    }


    // TASK 1
    function openAccount(string memory firstName, string memory lastName) public {
        if (owner == tx.origin) {
            revert("Error, Owner Prohibited") ;
        }

        if(bytes(accountFirstName[tx.origin]).length != 0) {
            revert("Account already exists") ;
        }

        accountFirstName[tx.origin] = firstName ;
        accountLastName[tx.origin] = lastName ;
        accountBalance[tx.origin] = 0 ;
        accountLoan[tx.origin] = 0 ;
    }


    // TASK 2
    function getDetails() public view returns (uint balance, string memory first_name, string memory last_name, uint loanAmount) {

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        return(accountBalance[tx.origin], accountFirstName[tx.origin], accountLastName[tx.origin], accountLoan[tx.origin]) ;
    }


    // TASK 3
    // minimum deposit of 1 ether.
    // 1 ether = 10^18 Wei.
    function depositAmount() public payable {

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        if(bytes(accountLastName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        if (msg.value < 1000000000000000000) {
            revert("Low Deposit") ;
        }

        accountBalance[tx.origin] = accountBalance[tx.origin] + msg.value ;
    }


    // Task 4
    function withDraw(uint withdrawalAmount) public {

        //withdrawalAmount = withdrawalAmount*1000000000000000000 ;
        if (owner == tx.origin) {
            revert("Error, Owner Prohibited") ;
        }

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        if (withdrawalAmount > accountBalance[tx.origin] ) {
            revert("Insufficient Funds") ;
        }

        accountBalance[tx.origin] = accountBalance[tx.origin] - withdrawalAmount ;
        payable(tx.origin).transfer(withdrawalAmount) ;
    }


    // Task 5
    function TransferEth(address payable reciepent, uint transferAmount) public {

        //transferAmount = transferAmount*1000000000000000000 ;

        if (owner == tx.origin) {
            revert("Error, Owner Prohibited") ;
        }

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        if (transferAmount > accountBalance[tx.origin] ) {
            revert("Insufficient Funds") ;
        }

        accountBalance[tx.origin] = accountBalance[tx.origin] - transferAmount ;
        accountBalance[reciepent] = accountBalance[reciepent] + transferAmount ;
    }


    // Task 6.1
    function depositTopUp() public payable {

        if (owner != tx.origin) {
            revert("Only owner can call this function") ;
        }

        funds = funds + msg.value ;
    }


    // Task 6.2
    function TakeLoan(uint loanAmount) public {
        //loanAmount = loanAmount*1000000000000000000 ;

        if (owner == tx.origin) {
            revert("Error,Owner Prohibited") ;
        }

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        if (loanAmount > funds ) {
            revert("Insufficent Loan Funds") ;
        }

        if (loanAmount > (2*accountBalance[tx.origin])) {
            revert("Loan Limit Exceeded") ;
        }

        //accountBalance[tx.origin] = accountBalance[tx.origin] + loanAmount ;

        accountLoan[tx.origin] = accountLoan[tx.origin] + loanAmount ;
        funds = funds - loanAmount ;
        payable(tx.origin).transfer(loanAmount) ;
    }


    // Task 6.3
    function InquireLoan() public view returns (uint loanValue) {

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        return accountLoan[tx.origin] ;
    }


    // Task 7
    function returnLoan() public payable  {

        if(bytes(accountFirstName[tx.origin]).length == 0) {
            revert("No Account") ;
        }

        if(accountLoan[tx.origin] == 0) {
            revert("No Loan") ;
        }

        if (msg.value > accountLoan[tx.origin]) {
            revert("Owed Amount Exceeded") ;
        }

        funds = funds + msg.value ;
        accountLoan[tx.origin] = accountLoan[tx.origin] - msg.value ;
    }


    function AmountInBank() public view returns(uint) {
            // DONT ALTER THIS FUNCTION
            return address(this).balance;
    }



}

