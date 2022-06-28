/**
 * Created by sam on 10/14/2018.
 */

trigger LeadToConvertTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    LeadToConvertTriggerHandler trgHandler   =    new LeadToConvertTriggerHandler(Trigger.new, Trigger.old);
    trgHandler.setNamespace('LeadToConvert');
    trgHandler.run();
}