@IsTest
public with sharing class UpdateCampaignPopulationOnLeadTest {
    @IsTest
    public static void UpdateCampaignPopulationOnLeadTest() {
        Campaign campaign = new Campaign();
        campaign.Name = 'TestCampaign';
        campaign.Campaign_Population__c = 'CC';
        Insert campaign;
        Lead newLead = new Lead();
        newLead.FirstName = 'Israel';
        newLead.LastName = 'Levy';
        newLead.Phone= '0508887667';
        newLead.Updated_Campaign_Population_MC__c = 'CC';
        newLead.Updated_Campaign__c = campaign.Id;
        Insert newLead;
        Test.startTest();
        campaign.Campaign_Population__c = 'IQOS';
        Update campaign;
        UpdateCampaignPopulationOnLeadBatch updateCamp = new UpdateCampaignPopulationOnLeadBatch();
        updateCamp.execute(null);
        updateCamp.finish(null);
        Test.stopTest();
        Lead afterUpdate = [SELECT Id,Updated_Campaign_Population_MC__c FROM Lead WHERE Id =:newLead.Id];
        //System.assertEquals('CC2IQOS', afterUpdate.Updated_Campaign_Population_MC__c);
       //CopyFormulaFields_Batch_Test,UpdateCampaignPopulationOnLeadTest,UpdateCampaignOnLeadTest
    }
}