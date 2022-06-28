@isTest
public with sharing class ObjectHistoryHandler_Test {
   

    @isTest
    private static void createCampaignHistory()
    {
        Contact c= new Contact(LastName='test_contact');
        insert c;

        Contact c2= new Contact(LastName='test_contact_2');
        insert c2;

        Lead lead= new Lead(LastName='test Lead',Status='New',MobilePhone='0504490718');
        insert lead;

        Campaign camp= new Campaign(Name='test Campaign',Status='Planned');
        insert camp;

        CampaignMember camp_mem= new CampaignMember(CampaignId=camp.Id,ContactId=c.Id,LeadId=lead.Id,Status='Sent',Event__c='Ahituv');
        System.debug('camp_mem.Status:'+camp_mem.Status);
       
        

        insert camp_mem;
        System.debug('after camp_mem.Status:'+camp_mem.Status);

        // To Update Any Other Type Of Status for CampaignMember need first to add it(the status value) to CampaignMemberStatus


         camp_mem.Status='Responded';
         update camp_mem;

         List<ObjectHistory__c> objHistoryLst = [Select Id From ObjectHistory__c];

        System.debug('objHistoryLst:'+objHistoryLst);

        // system.assertEquals(3,objHistoryLst.size());    

        



        
    }


}