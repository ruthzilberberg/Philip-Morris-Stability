public with sharing class CampaignTriggerHelper {
    public CampaignTriggerHelper() {

    }

    public void updateCampaignPopulationFlag(List<Campaign> campaignNew, Map<Id,Campaign> CampaignOldMap){
        List<Campaign> campaignIdsForUpdate = new List<Campaign>();
        for(Campaign campaign : campaignNew){
            if(campaign.Campaign_Population__c != CampaignOldMap.get(campaign.Id).Campaign_Population__c){
                campaign.CampaignPopulationChangedFlag__c = true;
                campaignIdsForUpdate.add(campaign);
            }
        }
    }
}