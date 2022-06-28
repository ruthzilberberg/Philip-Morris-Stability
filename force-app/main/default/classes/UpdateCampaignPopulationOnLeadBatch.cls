public with sharing class UpdateCampaignPopulationOnLeadBatch implements Schedulable, Database.Batchable<SObject>, Database.Stateful{
    private List<Lead> leadsToUpdate;
    private String timeStamp;
    public UpdateCampaignPopulationOnLeadBatch(){
        this.timeStamp = String.valueOf(System.currentTimeMillis());
        
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('UpdateCampaignPopulaytionOnLeadBatch - Start');
        return Database.getQueryLocator(
            'SELECT Id,Updated_Campaign_Population_MC__c,Updated_Campaign__r.Campaign_Population__c, Updated_Campaign__c'
            +' FROM Lead' 
            +' WHERE Updated_Campaign__r.CampaignPopulationChangedFlag__c = TRUE'
            +' AND UpdateCampaignTime__c != \''+this.timeStamp+'\''
        );
    }  

    public void execute(Database.BatchableContext info, List<Lead> scope){
        System.debug('UpdateCampaignPopulationOnLeadBatch-Execute ScopeSize: '+scope.size());
        List<Id> campaignIds = new List<Id>();
        for(Lead lead : scope){
            if(lead.Updated_Campaign__c != null) {
                UpdateCampaignPopulationMCOnLead(lead);
                campaignIds.add(lead.Updated_Campaign__c);
            }
            lead.UpdateCampaignTime__c = this.timeStamp;
        }
        update scope;
        List<Campaign> camps = [
                SELECT (SELECT Id FROM Leads1__r WHERE UpdateCampaignTime__c != :this.timeStamp LIMIT 1) 
                FROM Campaign WHERE Id IN: campaignIds
        ];
        List<Campaign> campToUpdate = new List<Campaign>();
        for(Campaign camp: camps) {
            if(camp.Leads1__r.size() == 0) {
                camp.CampaignPopulationChangedFlag__c = false;
                campToUpdate.add(camp);
            } 
        }
        if(campToUpdate.size()>0){  
            update campToUpdate;
        }
  
    }

    public static Boolean isAllowedLeadUpdateCampaignPopulationMC(Lead lead) {
        return !(lead.Updated_Campaign_Population_MC__c == 'CC2IQOS'
            || lead.Updated_Campaign_Population_MC__c == 'IQOS');
    }

    public static void  UpdateCampaignPopulationMCOnLead(Lead lead){
        if (isAllowedLeadUpdateCampaignPopulationMC(lead)) {
            String leadPopulation = lead.Updated_Campaign_Population_MC__c;
            String campaign_Population = (leadPopulation == 'CC' && lead.Updated_Campaign__r.Campaign_Population__c == 'IQOS')
                ? 'CC2IQOS'
                : lead.Updated_Campaign__r.Campaign_Population__c;
            lead.Updated_Campaign_Population_MC__c = campaign_Population;
            System.debug('UpdateCampaignPopulationOnLead- updateLead: '+ lead);
        }
    }

    public void finish(Database.BatchableContext info){
        
		List<CopyFormulaFields_Batch_Time__c> csTimes = new List<CopyFormulaFields_Batch_Time__c>([select Id, Current_Time__c,Prev_Time__c  from CopyFormulaFields_Batch_Time__c limit 1]);
        CopyFormulaFields_Batch_Time__c csTime = new CopyFormulaFields_Batch_Time__c();
		if(csTimes.isEmpty()){ insert csTime;}
		else{csTime = csTimes[0];}
        if(csTime.Current_Time__c == null) {
            csTime.Prev_Time__c = system.now().addYears(-7);
        }else{
            
            csTime.Prev_Time__c = csTime.Current_Time__c;        
        }
        csTime.Current_Time__c = system.now();
        update csTime;
        Database.executeBatch(new CopyFormulaFields_Batch('Account'));
        
    } 
    
    
    public void  execute(SchedulableContext SC) {
        Database.executeBatch(this);
     }
}