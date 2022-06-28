/****************************************************************************************
Name              : DeleteErrorLogsBatch
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Samuel Boukhobza           24/07/2018             Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------
****************************************************************************************/

global class DeleteErrorLogsBatch implements Database.batchable<sObject> {

    String query;

    global DeleteErrorLogsBatch(){
        query = ErrorLogManager.getDeleteLogQuery();
    }

    global Database.QueryLocator start(Database.BatchableContext info){
        system.debug('DeleteErrorLogsBatch: '+query);
        system.debug(Database.getQueryLocator(query));

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<Error_Log__c> scope){
        delete scope;
    }

    global void finish(Database.BatchableContext info){

    }

}