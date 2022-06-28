/****************************************************************************************
Name              : LeadTrigger
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               15/04/2019               Ella              [SW-31813]
----------------------------------------------------------------------------------------*/
/////////////TEST //////////////////
//////////RUN TEST AccountTriggerHelper_Test/////////////

trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
LeadTriggerHandler trgHandler   =    new LeadTriggerHandler(Trigger.new, Trigger.oldMap);
    trgHandler.setNamespace('Lead');
    trgHandler.run();
}