// SPDX-License-Identifier: GPL-3.0
// 90c6f6a8861d510a6c0e0c0d8d0d387652e9247b29367a821cba5e4ae8bdb497

pragma solidity >=0.7.0 <0.9.0;

contract asset
{
    string private hash ;
    address private owner  ;
    address[] private history_owners  = new address[](50);
    uint private minPrice ;

    // DECLARATIONS
    struct bid
    {
        address addr;
        uint value;
    }

    // mapping (address => bid) private bidsMapping ;
    bid [] private bids ;


    address private constant registerAddress = 0x5801bd1Be6e6093745FCafA18De4b11217dDD0CE; //just a dummy address for now, feel free to change this

    //DO NOT CHANGE ANY FUNCTION HEADERS

    constructor(string memory dataHash)
    {
        hash = dataHash ;
        owner = tx.origin ;
        history_owners.push(tx.origin) ;
        minPrice = 2 ;
    }

    function getHistoryOfOwners() public view returns(address[] memory)
    {
        // Code here
        return history_owners;
    }

    function getOwner() public view returns(address)
    {
        // Code here
        return owner;
    }

    function getDataHash() public view returns(string memory)
    {
        // Code here
        return hash;
    }

    function getMinimumPrice() public view returns(uint)
    {
        // Code here
        return minPrice;
    }


    function setMinimumPrice(uint price) public
    {
        //Only the owner may call this function

        if (owner != tx.origin) {
        revert("Only owner can call this function") ;
        }

        minPrice = price ;

        for(uint i=0; i<bids.length; i++)
        {
            if(bids[i].value < minPrice && bids[i].value != 0)
            {
                payable(bids[i].addr).transfer(bids[i].value) ;
                bids[i].value = 0;
            }
        }
        return;
    }

    function sell() public
    {
        //Only the owner may call this function
        //This function may only be called by the owner if there is at least one bid

        if (owner != tx.origin) {
            revert("Only owner can call this function") ;
        }

        if(bids.length < 1)
        {
            revert("There should be at least 1 bid") ;
        }

        uint maxBid = 0 ;
        uint maxIndex = 0 ;

        for(uint i=0; i<bids.length; i++)
        {
            if(bids[i].value > maxBid)
            {
                maxBid = bids[i].value ;
                maxIndex = i ;
            }
        }

        if(maxBid == 0)
        {
            revert("There should be at least 1 bid") ;
        }

        owner = bids[maxIndex].addr ;
        history_owners.push(bids[maxIndex].addr) ;

        for(uint i=0; i<bids.length; i++)
        {
            if(i != maxIndex)
            {
                payable(bids[i].addr).transfer(bids[i].value) ;
            }

            bids[i].value = 0;
        }

        payable(tx.origin).transfer(maxBid) ;

        Register reg = Register(registerAddress) ;
        reg.submit("23100174", maxBid) ;

        return ;
    }

    function viewBid(uint index) public view returns(bid memory)
    {
        //Only the owner may call this function
        //This function should revert with an error "That bid number does not exist" if you try to access a bid number that does not exist.

        // Code here
        if (owner != tx.origin) {
            revert("Only owner can call this function") ;
        }

        if(index < 0 || index >= bids.length)
        {
            revert("That bid number does not exist")   ;
        }

        if(bids[index].value == 0)
        {
            revert("That bid number does not exist")  ;
        }

        return bids[index];
    }

    function getNumberOfBids() public view returns(uint)
    {
        //Only the owner may call this function

        if (owner != tx.origin) {
            revert("Only the owner can call this function") ;
        }

        uint number = 0 ;

        for(uint i=0; i<bids.length; i++)
        {
            if(bids[i].value != 0)
            {
                number++ ;
            }
        }

        return number;
    }

    function submitBid() public payable
    {
        //The owner may not call this function
        //In addition, the bid must be higher than the minimum price defined by set minimum price as defined in the handout.

        if (owner == tx.origin) {
            revert("Owner can't call this function") ;
        }

        for(uint i=0; i<bids.length; i++)
        {
            if(bids[i].addr == tx.origin)
            {
                if(bids[i].value > 0)
                {
                    bids[i].value = bids[i].value + msg.value ;
                    return ;
                }
                else
                {
                    if(msg.value < minPrice)
                    {
                        revert("Bids must offer more than minimumPrice") ;
                    }
                    else
                    {
                        bids[i].value = msg.value ;
                        return ;
                    }
                }
            }
        }

        if(msg.value < minPrice)
        {
            revert("Bids must offer more than minimumPrice") ;
        }
        else
        {
            bid memory temp ;
            temp.addr = tx.origin ;
            temp.value = msg.value ;
            bids.push(temp) ;
            return ;
        }


    }

    function getOwnBidAmount() public view returns (uint)
    {
        for(uint i=0; i<bids.length; i++)
        {
            if(bids[i].addr == tx.origin)
            {
                return bids[i].value ;
            }
        }
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
