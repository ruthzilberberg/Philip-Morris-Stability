@isTest
private class UpdateLeadLastSMSClickedDate_BatchTest {

    private static Date MAX_DATE = Date.today().addDays(-15);
    private static Date OLD_DATE = Date.today().addDays(-20);

    @testSetup
    static void setup() {
        Lead lead = new Lead(
            LastName = 'Lead',
            MobilePhone = '054307336'
        );
        insert lead;

        List<MC_SMS_History__c> smsHistories = new List<MC_SMS_History__c>();
        MC_SMS_History__c history1 = new MC_SMS_History__c(
            Name = 'SMS2',
            Lead__c = lead.Id
        );
        smsHistories.add(history1);
        MC_SMS_History__c history2 = new MC_SMS_History__c(
            Name = 'SMS1',
            Lead__c = lead.Id
        );
        smsHistories.add(history2);
        insert smsHistories;
        Test.setCreatedDate(smsHistories[0].Id, MAX_DATE);
        Test.setCreatedDate(smsHistories[1].Id, OLD_DATE);

        List<MC_SMS_Clicked__c> clickers = new List<MC_SMS_Clicked__c>();
        MC_SMS_Clicked__c clicker1 = new MC_SMS_Clicked__c(
            Name = 'Click1',
            MC_SMS_History__c = history1.Id
        );
        clickers.add(clicker1);
        MC_SMS_Clicked__c clicker2 = new MC_SMS_Clicked__c(
            Name = 'Click2',
            MC_SMS_History__c = history2.Id
        );
        clickers.add(clicker2);
        insert clickers;
    }

    @isTest
    public static void updateLeadLastSMSClickedDate_test() {
        Lead lead = [
            SELECT Id, Last_SMS_Clicked_Date__c
            FROM Lead
            LIMIT 1
        ];

        Test.startTest();
        UpdateLeadLastSMSClickedDate_Batch batch = new UpdateLeadLastSMSClickedDate_Batch();
        batch.MAX_COUNT = 0;
        Database.executeBatch(batch);
        Test.stopTest();

        Lead leadResult = [
            SELECT Id, Last_SMS_Clicked_Date__c
            FROM Lead
            LIMIT 1
        ];

        System.assertNotEquals(lead.Last_SMS_Clicked_Date__c, MAX_DATE);
        System.assertEquals(leadResult.Last_SMS_Clicked_Date__c, MAX_DATE);
    }

}