@isTest
public with sharing class CommunicationPreferencesServiceTest {

    
    @isTest static void getCommunicationPreferencesInfoTest() {
        Account acc = new Account(lastName = 'acc Test2',  PersonBirthdate=Date.newInstance(1989, 9, 28), PersonEmail = 'MyEmai@GMAIL.COM', Terms_and_Conditions__pc=true, Personal_Promotion_Code__pc='5511');
        acc.ID__pc = '051317576';
        insert acc;

        List<Communication_Preference__mdt> names = CommunicationPreferencesService.getCommunicationPreferencesInfo(acc.id);

        List<Communication_Preference__mdt> namesTest = new List<Communication_Preference__mdt>();
        
        System.assertEquals(namesTest,names);
    }

}