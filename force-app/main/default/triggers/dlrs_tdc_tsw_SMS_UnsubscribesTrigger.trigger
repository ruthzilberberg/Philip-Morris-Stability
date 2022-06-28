/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_tdc_tsw_SMS_UnsubscribesTrigger on tdc_tsw__SMS_Unsubscribes__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(tdc_tsw__SMS_Unsubscribes__c.SObjectType);
}