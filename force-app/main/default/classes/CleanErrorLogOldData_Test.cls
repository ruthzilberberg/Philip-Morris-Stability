/****************************************************************************************
Name              : CleanErrorLogOldData_Test
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Samuel Boukhobza           24/07/2018             Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------
****************************************************************************************/

@isTest
public class CleanErrorLogOldData_Test {

    @isTest
    public static  void executeCleanErrorLog_Test() {
        test.startTest();

        Error_Log__c log_test       =   new Error_Log__c(Object_Name__c='test');
        insert log_test;

        CleanErrorLogOldData celod  =   new CleanErrorLogOldData();
        String sch                  =   '0 0 023 * * ?';
        System.schedule('Test executeCleanErrorLog', sch,celod);
        test.stopTest();
    }
}