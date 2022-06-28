@isTest
public with sharing class LeadCampaignDataFixTest {
    @isTest
    public static void testBatch() {
        insert new Lead(lastName='test1');
        Test.startTest();
        new LeadCampaignDataFix().execute(null);
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Lead WHERE Updated_Campaign_Flag__c=TRUE]);
    }
}