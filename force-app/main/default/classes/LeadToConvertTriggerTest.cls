/**
 * Created by sam on 10/14/2018.
 */

@isTest
public class LeadToConvertTriggerTest {
    @isTest
    static void LeadToConvertTest(){
        Lead ld = new Lead(LastName='Test');
        insert ld;
        System.debug('new lead : ' + ld);
        ld.Customer_Registered__c=true;
        update ld;
        System.debug('updated lead : ' + ld);
    }
}