// Integer totalMinutes = Datetime.now().minute() + Integer.valueOf(configuration.delay_in_minutes__c);
// String hour = String.valueOf(Datetime.now().hour()+totalMinutes/60);
// String min = String.valueOf(Math.mod(totalMinutes, 60)); 
// String seconds = String.valueOf(Datetime.now().second());
public with sharing abstract class SynronizableOperation implements Schedulable, Database.Batchable<sObject> {
    private static final Integer DEFAULT_DELAY = 3;
    private static final Integer DEFAULT_NUMBER_OF_RECORDS = 200;
    private static final Boolean DEFAULT_RUN_ASYNC = false;

    private Synchronize_Configuration__mdt configuration;
    private String jobId;
    private String name;

    
    public SynronizableOperation(String name) {
        this.name = name;
        System.debug('SynronizableOperation: start constructor, name = '+name);
        configuration = [
            SELECT delay_in_minutes__c, Number_of_records_in_batch__c, run_asynchronized__c
            FROM Synchronize_Configuration__mdt
            WHERE DeveloperName = :name
        ];
        if(configuration == null) {
            System.debug(System.LoggingLevel.WARN, 'SynronizableOperation: not found configuration creating default one');
            configuration = getDefaultConfiguration();
        }else {
            completeDefaultConfigurationValues();
        }
        System.debug('SynronizableOperation: configuration = '+configuration);
        System.debug('SynronizableOperation: done constructor');
    }
    public void execute(SchedulableContext SC) {
        
        this.jobId = SC.getTriggerId();
        System.debug('SynronizableOperation: start executing batch with job id'+this.jobId);
        database.executebatch(this, Integer.valueOf(configuration.Number_of_records_in_batch__c));
    }

    public virtual void syncPreperationForAsync(){}

    public abstract void runSync();

    public virtual void onFinishAsync(){}

    public void run(){
        System.debug('SynronizableOperation: start run');
        if(!configuration.run_asynchronized__c) {
            System.debug('SynronizableOperation: start runSync');
            runSync();
            System.debug('SynronizableOperation: done runSync');
        } else {
            System.debug('SynronizableOperation: start syncPreperationForAsync');
            syncPreperationForAsync();
            System.debug('SynronizableOperation: done syncPreperationForAsync');
            if([
                SELECT COUNT() 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE :this.Name+'%'
                AND State IN ('WAITING', 'ACQUIRED')
            ] == 0) {
                System.debug('SynronizableOperation: start schedulToRun');
                schedulToRun();
                System.debug('SynronizableOperation: done schedulToRun');
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        this.onFinishAsync();
        if(this.jobId != null){
          System.abortJob(this.jobId);
        }
    }

    private void schedulToRun() {
        Integer totalMinutes = Datetime.now().minute() + Integer.valueOf(configuration.delay_in_minutes__c);
        String hour = String.valueOf(Datetime.now().hour()+totalMinutes/60);
        String min = String.valueOf(Math.mod(totalMinutes, 60)); 
        String seconds = String.valueOf(Datetime.now().second());

        //parse to cron expression
        String nextFireTime = seconds + ' ' + min + ' ' + hour + ' * * ?';

        this.jobId = System.schedule(this.name+'_'+seconds+'_'+min+'_'+hour , nextFireTime, this);
    }

    private Synchronize_Configuration__mdt getDefaultConfiguration() {
        return new Synchronize_Configuration__mdt(
            delay_in_minutes__c = DEFAULT_DELAY, 
            Number_of_records_in_batch__c=DEFAULT_NUMBER_OF_RECORDS,
            run_asynchronized__c=DEFAULT_RUN_ASYNC
        );
    }

    private void completeDefaultConfigurationValues() {
        if(configuration.delay_in_minutes__c == null) {
            System.debug(System.LoggingLevel.WARN, 'SynronizableOperation: delay_in_minutes__c is null setting it to default of ' +DEFAULT_DELAY );
            configuration.delay_in_minutes__c = DEFAULT_DELAY;
        }
        if(configuration.Number_of_records_in_batch__c == null) {
            System.debug(System.LoggingLevel.WARN, 'SynronizableOperation: Number_of_records_in_batch__c is null setting it to default of ' +DEFAULT_NUMBER_OF_RECORDS );
            configuration.Number_of_records_in_batch__c = DEFAULT_NUMBER_OF_RECORDS;
        }
        if(configuration.run_asynchronized__c == null) {
            System.debug(System.LoggingLevel.WARN, 'SynronizableOperation: run_asynchronized__c is null setting it to default of ' +DEFAULT_RUN_ASYNC );
            configuration.run_asynchronized__c = DEFAULT_RUN_ASYNC;
        }
    }
}