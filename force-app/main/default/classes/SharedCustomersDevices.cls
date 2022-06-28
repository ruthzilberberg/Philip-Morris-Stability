public class SharedCustomersDevices {

    public static List<Account> updateDeviceCounts(Set<Id> customersIds) {
        List<AggregateResult> groupedResults = [SELECT AccountId,COUNT(Id)coun FROM Asset   WHERE   AccountId IN: customersIds AND 
                                                                                                Active__c = TRUE AND
                                                                                                EOW_Promotion_flag__c = TRUE AND
                                                                                                Product2Id != null AND 
                                                                                                Product2.EOW_Usage__c = TRUE AND
                                                                                                Account.Name != 'Philip Morris'
                                                                                        GROUP BY AccountId];
         
        List<Account> accsToUpdate = new List<Account>();
        Set<Id> resetCounters = new Set<Id>();
        
        for (AggregateResult ar : groupedResults)  {
            Account acc = new Account();
            acc.Id = (Id)ar.get('AccountId');
            System.debug('accId==>'+ acc.Id);
            System.debug('device_count'+(Double)ar.get('coun'));
            acc.Numbers_of_Devices_EOW__c = (Double)ar.get('coun');
            accsToUpdate.add(acc);
            resetCounters.add(acc.Id);
        }
        System.debug('accId==>'+ customersIds);
        
        for(Id accId : customersIds){
            if(!resetCounters.contains(accId)){   
                Account acc = new Account();
                acc.Id = accId;
            	System.debug('accId==>'+ acc.Id);
                acc.Numbers_of_Devices_EOW__c = 0;
                accsToUpdate.add(acc);
            }
        }
        return accsToUpdate;
    }
}