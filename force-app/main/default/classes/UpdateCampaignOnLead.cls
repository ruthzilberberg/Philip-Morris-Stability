public with sharing class UpdateCampaignOnLead extends SynronizableOperation implements Schedulable{
    private List<Id> leadIds;
    private map<Id, lead> leads;

    public UpdateCampaignOnLead(List<Id> leadIds) {
        super('UpdateCampaignOnLead');
		this.leads = new map<Id, lead>();
        this.leadIds = leadIds;
    }

    public UpdateCampaignOnLead() {
        super('UpdateCampaignOnLead');
    }

    public override void syncPreperationForAsync(){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Id leadId: leadIds) {
            leadsToUpdate.add(new Lead(Id=leadId, Require_Update_Campign__c=true));
        }
        update leadsToUpdate;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Updated_Campaign_Population_MC__c, Updated_Campaign__r.Campaign_Population__c FROM Lead WHERE Require_Update_Campign__c = TRUE');
     }

    public void execute(Database.BatchableContext info, List<Lead> scope){
        this.leadIds = new List<Id>(new Map<Id,Lead>(scope).keySet());
		this.leads = new map<Id, lead>(scope);
        runSync();
    }

    public override void runSync() {
        Map<Id, Lead> leadsToUpdateById = new Map<Id, Lead>();
        //for(Id leadId: leadIds) {
        for(Id leadId: leads.keySet()) {
            //leadsToUpdateById.put(leadId, new Lead(Id = leadId, Require_Update_Campign__c=false));
            Lead currLead = leads.get(leadId);
            currLead.Require_Update_Campign__c=false;
            leadsToUpdateById.put(leadId, currLead);
        }
        List<Lead> leadsToUpdateMC = new List<Lead>();
        Map<Id,DateTime> mapLeadIdToUpdateCampaignDate = new Map<Id,DateTime>();
        for(CampaignMember iteradtedCampaignMember: [
            SELECT CampaignId, LeadId , Campaign.Campaign_Population__c, CreatedDate
            FROM CampaignMember 
            WHERE LeadId IN :leadsToUpdateById.keySet() AND Campaign.Bypass_update_on_Lead__c = false
            ORDER BY CreatedDate DESC 
        ]) {
            Lead currentLead = leadsToUpdateById.get(iteradtedCampaignMember.LeadId);
            DateTime lastCreatedDate = mapLeadIdToUpdateCampaignDate.get(iteradtedCampaignMember.LeadId);
            if(currentLead.Updated_Campaign__c == null || lastCreatedDate == null || iteradtedCampaignMember.CreatedDate > lastCreatedDate) {
                currentLead.Updated_Campaign__c = iteradtedCampaignMember.CampaignId;	
                currentLead.Updated_Campaign__r = iteradtedCampaignMember.Campaign;
                mapLeadIdToUpdateCampaignDate.put(iteradtedCampaignMember.LeadId,iteradtedCampaignMember.CreatedDate);
                leadsToUpdateMC.add(currentLead);
            }
           
        }
        //update the MC field on leads that change Campaign
        for(Lead currentLead : leadsToUpdateMC){
            UpdateCampaignPopulationOnLeadBatch.UpdateCampaignPopulationMCOnLead(currentLead);
        }

        //update all the leads that the field Require_Update_Campign__c changed
        update leadsToUpdateById.values();
    }

}