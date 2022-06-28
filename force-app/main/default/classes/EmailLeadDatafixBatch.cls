public class EmailLeadDatafixBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator('SELECT Id, et4ae5__Lead__c, et4ae5__Lead__r.Email_Hard_Bounce__c, et4ae5__HardBounce__c, LastModifiedDate FROM et4ae5__IndividualEmailResult__c' + 
                                      ' Where et4ae5__Lead__c != null order by LastModifiedDate desc ');
    }
    public void execute(Database.BatchableContext bc, List<et4ae5__IndividualEmailResult__c> records){
        Map <Id,et4ae5__IndividualEmailResult__c> emailLeadsIdsMap = new Map <Id,et4ae5__IndividualEmailResult__c>();
        for(et4ae5__IndividualEmailResult__c mail : records){
            if(emailLeadsIdsMap.get(mail.et4ae5__Lead__c) == null){
                emailLeadsIdsMap.put(mail.et4ae5__Lead__c, mail);
            }        
        }
        List <Lead> leads = [SELECT Id, Email_Hard_Bounce__c from Lead WHERE Id in : emailLeadsIdsMap.keySet()];
        for(Lead l : leads){
            if(l.Email_Hard_Bounce__c == false && emailLeadsIdsMap.get(l.Id).et4ae5__HardBounce__c == true){
                l.Email_Hard_Bounce__c = true;
            }
            else if(l.Email_Hard_Bounce__c == true && emailLeadsIdsMap.get(l.Id).et4ae5__HardBounce__c == false){
                l.Email_Hard_Bounce__c = false;
            }
        }
        update leads;
        system.debug(leads.size());
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}