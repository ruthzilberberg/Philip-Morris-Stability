trigger CampaignTrigger on Campaign (before update) {
    CampaignTriggerHandler trgHandler =  new CampaignTriggerHandler(Trigger.new,Trigger.oldMap);
    trgHandler.setNamespace('Campaign');
    trgHandler.run();
}