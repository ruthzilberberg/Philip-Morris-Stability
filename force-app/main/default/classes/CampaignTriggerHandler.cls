public with sharing class CampaignTriggerHandler extends TriggerHandler {
    
    public List<Campaign> campaignNew;
    public Map<Id,Campaign> campaignOldMap;
    CampaignTriggerHelper helper = new CampaignTriggerHelper();
    public CampaignTriggerHandler(List<Campaign> campaignNew,Map<Id,Campaign> campaignOldMap) {
        System.debug('>>> CampaignNew: '+ campaignNew);
        this.campaignNew = campaignNew;
        this.campaignOldMap = campaignOldMap;
    }

    public override void beforeUpdate (){
        if(this.isactionallowed('updateCampaignPopulationFlag')){
             helper.updateCampaignPopulationFlag(this.campaignNew,this.campaignOldMap);
         }
     }
}