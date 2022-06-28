public with sharing class UpdateLeadLastSMSClickedDate_Batch implements Database.Batchable<AggregateResult> {

    private integer counter;

    public Integer MAX_COUNT = 200;

    

    public UpdateLeadLastSMSClickedDate_Batch () {
        this(0);
    }

    public UpdateLeadLastSMSClickedDate_Batch (integer counter) {
        this.counter = counter;
    }

    public Iterable<AggregateResult> start(Database.BatchableContext bc) {
        String query = 'SELECT MAX(CreatedDate) maxDate, Lead__c' +
            ' FROM MC_SMS_History__c' +
            ' WHERE Number_of_Clicks__c > 0' +
            ' AND Lead__c != null' +
            ' AND Lead__r.Last_SMS_Clicked_Date__c = null' +
            ' GROUP BY Lead__c LIMIT 10000';
        return new AggregateResultIterable(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Lead> leads = new List<Lead>();
        for(sObject sObj : scope) {
            AggregateResult result = (AggregateResult) sObj;
            leads.add(
                new Lead(
                    Id = (Id) result.get('Lead__c'),
                    Last_SMS_Clicked_Date__c = Date.valueOf((DateTime) result.get('maxDate'))
                )
            );
        }
        if (!leads.isEmpty()) {
            update leads;
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(this.counter < this.MAX_COUNT) {
            Database.executeBatch(new UpdateLeadLastSMSClickedDate_Batch(this.counter+1));
        }
    }

}