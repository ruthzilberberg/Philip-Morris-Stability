@isTest
public class UpdateCampaignOnLeadTest {
    //@testSetup static void setup() {
        
   // }
    
    @isTest static void updateCampaignOnLeadTest() {
        Lead newLead = new Lead();
        newLead.FirstName = 'Israel';
        newLead.LastName = 'Levy';
        newLead.Phone= '0508887667';
        Insert newLead;
        List<Id> newLeadLst = new List<Id>();
        newLeadLst.add(newLead.Id);
        
        Campaign newCampaign = new Campaign();
        newCampaign.Name = 'TestCampaign';
        Insert newCampaign;
        
        CampaignMember cM = new CampaignMember();
        cM.CampaignId = newCampaign.Id;
        cM.LeadId = newLead.Id;
       
        
        Test.startTest();
        Insert cM;
        UpdateCampaignOnLead updateCamp = new UpdateCampaignOnLead();
        DataBase.executeBatch(updateCamp);
        Test.stopTest();
        Lead afterUpdate = [SELECT Id,Updated_Campaign__c FROM Lead WHERE Id =:newLead.Id];
        System.assertEquals(newCampaign.Id, afterUpdate.Updated_Campaign__c);
    }
    
}