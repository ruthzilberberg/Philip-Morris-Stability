/****************************************************************************************
Name              : AccountTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Sam Boukhobza               16/01/2019            Ella Bernachik          [SW-32039]
----------------------------------------------------------------------------------------*/
trigger AssetTrigger on Asset (before insert, before update, before delete, after insert, after update, after delete) {

    AssetTriggerHandler trgHandler   =    new AssetTriggerHandler(Trigger.new,Trigger.oldMap);
    trgHandler.setNamespace('Asset');
    trgHandler.run();
}