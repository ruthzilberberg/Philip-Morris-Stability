@istest
public class EmailLeadDatafixTest {
@isTest
    public static void testDatafix(){
        et4ae5__SendDefinition__c sd1 = new et4ae5__SendDefinition__c();
        insert sd1;
        Lead lead1 = new Lead();
        lead1.LastName = 'lead 1';
        lead1.MobilePhone = '0504888989';
        lead1.Email_Hard_Bounce__c = true;
        insert lead1;
        et4ae5__IndividualEmailResult__c email1 = new et4ae5__IndividualEmailResult__c();
        email1.Name = 'Test email 2';
        email1.et4ae5__SendDefinition__c = sd1.Id;
        email1.et4ae5__HardBounce__c = false;
        email1.et4ae5__Lead__c = lead1.Id;
        insert email1;
        Test.startTest();
        EmailLeadDatafixBatch sldf = new EmailLeadDatafixBatch();
        Database.executeBatch(sldf);
        Test.stopTest();
        List<et4ae5__IndividualEmailResult__c> mail_List = [SELECT Id, et4ae5__Lead__c, et4ae5__Lead__r.Email_Hard_Bounce__c, et4ae5__HardBounce__c FROM et4ae5__IndividualEmailResult__c Where Name = 'Test email 2'];
        System.assertEquals(false, mail_List[0].et4ae5__Lead__r.Email_Hard_Bounce__c);
    }
}