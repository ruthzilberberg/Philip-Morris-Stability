/****************************************************************************************
Name              : PromotionTrigger
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo                     29/01/2020            Ella Bernachik          [SW-36249]
----------------------------------------------------------------------------------------*/
trigger PromotionTrigger on Promotion__c (before insert, before update, before delete, after insert, after update)  {
    PromotionTriggerHandler trgHandler   =    new PromotionTriggerHandler(Trigger.new,Trigger.oldMap);
    trgHandler.setNamespace('Promotion__c');
    trgHandler.run();

 }