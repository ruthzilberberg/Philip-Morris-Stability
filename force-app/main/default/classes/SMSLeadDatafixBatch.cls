public class SMSLeadDatafixBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Lead__c, Lead__r.Mobile_Hard_bounce__c, Held__c, LastModifiedDate FROM MC_SMS_History__c' + 
                                      ' Where Lead__c != null order by LastModifiedDate desc';
      return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<MC_SMS_History__c> records){
        Map <Id, MC_SMS_History__c> smsLeadsIdsMap = new Map <Id, MC_SMS_History__c>();
        for(MC_SMS_History__c sms : records){
            if(smsLeadsIdsMap.get(sms.Lead__c)== null){
                smsLeadsIdsMap.put(sms.Lead__c, sms);
            }      
        }
        List <Lead> leads = [SELECT Id, Mobile_Hard_bounce__c from Lead WHERE Id in : smsLeadsIdsMap.keySet()];
        System.debug('leads '+ leads);
        for(Lead l : leads){
            if(l.Mobile_Hard_bounce__c == true && smsLeadsIdsMap.get(l.Id).Held__c == false){
                l.Mobile_Hard_bounce__c = false;
            }
             else if(l.Mobile_Hard_bounce__c == false && smsLeadsIdsMap.get(l.Id).Held__c == true){
                l.Mobile_Hard_bounce__c = true;
            }
        }
        update leads;
        System.debug([select Id ,Mobile_Hard_bounce__c from Lead WHERE Id in : leads]);
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}