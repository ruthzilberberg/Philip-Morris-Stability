global class updateDevicesCountBatch implements Database.Batchable<sObject>{
    String query;

    public updateDevicesCountBatch(){
        //this.query = 'SELECT AccountId FROM Asset WHERE AccountId != NULL AND Account.Name != \'Philip Morris\'';
       //if(Test.isRunningTest()) this.query = 'SELECT AccountId FROM Asset';
       this.query = 'SELECT Id,Numbers_of_Devices_EOW__c FROM Account';
    }

    global Database.querylocator start(Database.BatchableContext BC){
                return Database.getQueryLocator(query);}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> accIds = new Set<Id>();

        for (sObject s : scope)  {
            Account acc = (Account)s;
            accIds.add(acc.Id);
        }
        System.debug('accIds==>'+accIds);
        List<Account> accsToUpdate = SharedCustomersDevices.updateDeviceCounts(accIds);
/**
        accIds = new Set<Id>();
        for(Account acc : accsToUpdate){
            accIds.add(acc.Id);
        }
        
        
        for(Account acc : [SELECT Id FROM Account WHERE Id NOT IN: accIds]){
            System.debug('acc==>'+acc.Id);
            acc.Numbers_of_Devices_EOW__c = 0;
        	accsToUpdate.add(acc); 	
        }
   **/    	
        update accsToUpdate;
        
    }
    global void finish(Database.BatchableContext BC){}
}