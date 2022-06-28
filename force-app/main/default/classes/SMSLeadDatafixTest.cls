@istest
public class SMSLeadDatafixTest {
    @isTest
    public static void testDatafix(){
        Lead lead1 = new Lead();
        lead1.LastName = 'lead 1';
        lead1.MobilePhone = '0504888989';
        lead1.Mobile_Hard_bounce__c = true;
        insert lead1;
        MC_SMS_History__c sms = new MC_SMS_History__c();
        sms.Name = 'SMS 1';
        sms.Lead__c = lead1.Id;
        sms.Held__c = false;        
        insert sms;
        Test.startTest();
        SMSLeadDatafixBatch sldf = new SMSLeadDatafixBatch();
        Database.executeBatch(sldf);
        Test.stopTest();
        List<MC_SMS_History__c > sms_List = [SELECT Id, Lead__c, Held__c, Lead__r.Mobile_Hard_bounce__c  FROM MC_SMS_History__c Where Name = 'SMS 1'];
        System.assertEquals(false, sms_List[0].Lead__r.Mobile_Hard_bounce__c);
    }
}