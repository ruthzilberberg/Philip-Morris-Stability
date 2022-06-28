trigger CampaignMemberTrigger on CampaignMember (after insert,after update,before update) {

 
    
    System.debug('Trigger.isAfter----->'+Trigger.isAfter);
    System.debug('Trigger.isAfter----->'+Trigger.isUpdate);
    CampaignMemberTriggerHandler trgHandler =  new CampaignMemberTriggerHandler(Trigger.new,Trigger.oldMap);
    trgHandler.setNamespace('CampaignMember');
    trgHandler.run();



}