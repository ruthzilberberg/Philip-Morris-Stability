public without sharing class CommunicationPreferencesService {
    
    @AuraEnabled(cacheable=true)
    public static List<Communication_Preference__mdt> getCommunicationPreferencesInfo(Id recordId) {
    

        // getting all Comm Prefs 
        List<Communication_Preference__mdt> comPrefs;
        comPrefs = [SELECT Id, Order__c, Field_Name__c, Static_Resource_Name__c, Show_when__c, Help_Text__c
                FROM Communication_Preference__mdt ORDER BY Order__c]; 

        System.debug(comPrefs);

        // creating a list with field names from ComPrefs
        List<String> fieldNames = new List<String>();
        for (Communication_Preference__mdt comPref : comPrefs){
            fieldNames.add(comPref.Field_Name__c);
        }

        System.debug(fieldNames);


        // getting the account with fields specified in comPrefs
        Account account; 
        String accountId = recordId;     
        String soql = 'SELECT Name,' + String.join(fieldNames, ',') + ' FROM Account WHERE Id=:accountId LIMIT 1';
        List<Account> accounts = Database.query(soql);
        
        If (accounts.size()>0){
            account = accounts[0];
        }

        System.debug(account);

        // creating a list of Comm Prefs that have true in them in the account found above
       
        List<Communication_Preference__mdt> comPrefInfo = new List<Communication_Preference__mdt>();

        for (Communication_Preference__mdt comPref : comPrefs) {
            if (account.get(comPref.Field_Name__c)==comPref.Show_when__c) {
                
                comPref.Static_Resource_Name__c = '/resource/'+comPref.Static_Resource_Name__c;
                comPrefInfo.add(comPref);
            }
        }
        
        System.debug(comPrefInfo);

        return comPrefInfo;
    }
}