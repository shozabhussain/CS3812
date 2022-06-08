// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract asset
{
    

    // DECLARATIONS
    struct bid
    {
        address addr;
        uint value;
    }

    address private constant registerAddress = 0xe5f0332CA42459333149b67aF2d0E486D03F8a83; //just a dummy address for now, feel free to change this

    //DO NOT CHANGE ANY FUNCTION HEADERS
s
    constructor(string memory dataHash)
    {
        // Code here
    }

    function getHistoryOfOwners() public view returns(address[] memory)
    {
        // Code here
        address[] memory temp; //Feel free to delete this
        return temp;
    }

    function getOwner() public view returns(address)
    {
        // Code here
        address temp;
        return temp;
    }

    function getDataHash() public view returns(string memory)
    {
        // Code here
        return "";
    }

    function getMinimumPrice() public view returns(uint)
    {
        // Code here
        return 0;
    }

    
    function setMinimumPrice(uint price) public 
    {
        //Only the owner may call this function

        // Code here
        return;
    }

    function sell() public
    {
        //Only the owner may call this function
        //This function may only be called by the owner if there is at least one bid

        // Code here
        return;
    }

    function viewBid(uint index) public view returns(bid memory)
    {
        //Only the owner may call this function
        //This function should revert with an error "That bid number does not exist" if you try to access a bid number that does not exist.
        
        // Code here
        bid memory temp;
        return temp;
    }

    function getNumberOfBids() public view returns(uint)
    {
        //Only the owner may call this function

        // Code here
        return 0;
    }

    function submitBid() public payable 
    {
        //The owner may not call this function
        //In addition, the bid must be higher than the minimum price defined by set minimum price as defined in the handout.
        // Code here
        return;
    }

    function getOwnBidAmount() public view returns (uint)
    {
        // Code here
        return 0;
    }


}


//DO NOT CHANGE ANYTHING IN THIS
contract Register
{
    struct submission
    {
        string rollNumber;
        uint Value;
    }

    function getHistory(uint index) public view returns (submission memory) {}
    
    function submit(string memory rollNumber, uint Value) public {}
}
