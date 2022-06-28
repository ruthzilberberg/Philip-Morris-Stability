/****************************************************************************************
Name              : OrderItemTrigger
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------*/
trigger OrderItemTrigger on OrderItem(before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
OrderItemTriggerHandler trgHandler   =    new OrderItemTriggerHandler(Trigger.new, Trigger.oldMap);
    trgHandler.setNamespace('OrderItem');
    trgHandler.run();
}