// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.0;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable{    
    enum supplyChainState{Created, Paid, Delivered}
    
    struct S_item {
        string itemName;
        Item _item;
        supplyChainState state;
    } 
    
    mapping(uint => S_item) public items;
    uint itemIndex;
    
    event supplyChainStep(uint _itemIndex, uint _step, address _address);
    
    function createItem(string memory _itemName, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex].itemName = _itemName;
        items[itemIndex]._item = item;
        items[itemIndex].state = supplyChainState.Created;
        emit supplyChainStep(itemIndex, uint(items[itemIndex].state), address(item));
        itemIndex++;
        
    }
    
    function triggerPayment(uint _itemIndex) public payable{
        Item item = items[_itemIndex]._item;
        require(address(item) == msg.sender, "Only items are allowed to update themselves");
        require(item.priceInWei() == msg.value, "Not fully paid yet" );
        require(items[_itemIndex].state == supplyChainState.Created, "Item is further in the supply chain");
        items[_itemIndex].state = supplyChainState.Paid;
        emit supplyChainStep(_itemIndex, uint(items[_itemIndex].state), address(item));
    }
    
    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex].state == supplyChainState.Created, "Item is further in the Chain");
        items[_itemIndex].state = supplyChainState.Delivered;
        
        emit supplyChainStep(_itemIndex, uint(items[_itemIndex].state), address(items[_itemIndex]._item));
     }
}