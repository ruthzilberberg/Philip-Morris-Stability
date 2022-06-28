/****************************************************************************************
Name              : OrderTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               12/11/2018                Kirill         [SW-31314]
----------------------------------------------------------------------------------------*/
trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 

    OrderTriggerHandler trgHandler   =    new OrderTriggerHandler(Trigger.new, Trigger.oldMap);
    trgHandler.setNamespace('Order');
    trgHandler.run();
}