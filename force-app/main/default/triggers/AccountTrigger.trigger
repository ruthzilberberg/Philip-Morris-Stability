/****************************************************************************************
Name              : AccountTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------*/
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 

    AccountTriggerHandler trgHandler   =    new AccountTriggerHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);
    trgHandler.setNamespace('Account');
    trgHandler.run();
     
    //dlrs.RollupService.triggerHandler();
    
    if(AccountTriggerHandler.runDlrs == false){
      //system.debug('execution dlrs ');
       AccountTriggerHandler.runDlrs = true;
       dlrs.RollupService.triggerHandler();
    }    


}