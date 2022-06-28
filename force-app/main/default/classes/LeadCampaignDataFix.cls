public with sharing class LeadCampaignDataFix implements Database.Batchable<sObject>, schedulable {
    String query = 'SELECT Id FROM Lead WHERE Updated_Campaign_Flag__c = FALSE';

    public Database.QueryLocator start(Database.BatchableContext BC) {
	    return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Id> leadIdsToFix = new List<Id>();
        for(SObject l : scope) {
            leadsToUpdate.add(new Lead(Id=l.Id, Updated_Campaign_Flag__c=true));
            leadIdsToFix.add(l.Id);
        }
        UpdateCampaignOnLead operation = new UpdateCampaignOnLead(new List<Id>(leadIdsToFix));
        operation.run();
        update leadsToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
        
    }

    public void execute(SchedulableContext SC) {
 	    database.executebatch(new LeadCampaignDataFix());
    }
}