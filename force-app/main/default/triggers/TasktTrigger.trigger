/****************************************************************************************
Name              : TasktTrigger.Trigger
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               25/11/2018             Kirill Hantayev          [SW-31407]
----------------------------------------------------------------------------------------*/
trigger TasktTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 

	TaskTriggerHandler trgHandler   =    new TaskTriggerHandler(Trigger.new, Trigger.oldMap);
    trgHandler.setNamespace('Task');
    trgHandler.run();
}