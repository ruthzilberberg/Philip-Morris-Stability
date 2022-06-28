/****************************************************************************************
Name              : ErrorLogManager
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Samuel Boukhobza           24/07/2018             Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------
****************************************************************************************/

public with sharing class ErrorLogManager {

    private static Error_Log_Configuration__mdt getErrorLogConfig(){
        Error_Log_Configuration__mdt config =   [SELECT Expired_date__c FROM Error_Log_Configuration__mdt WHERE MasterLabel= 'Default' LIMIT 1];
        return config;
    }

    public static String getDeleteLogQuery(){
        Error_Log_Configuration__mdt config = getErrorLogConfig();
        String days             =   '-' + config.Expired_date__c;
        if(Test.isRunningTest()) {
            days                =   '1';
        }
        Datetime last2month     =   System.now().addDays( Integer.valueOf(days) );

        Q query = new Q(Error_Log__c.SObjectType)
                .selectFields(new Set<String>{'Name', 'OwnerId', 'CreatedDate'})
                .add(Q.condition('CreatedDate').isLessOrEquals(last2month));
        System.debug( '------- In ErrorLogManager ---------' +  query );
        return query.build();

    }


}