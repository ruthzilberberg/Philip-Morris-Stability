global class SchedualUpdateDevices implements Schedulable{
    global void execute(SchedulableContext sc) {
        updateDevicesCountBatch b = new updateDevicesCountBatch(); 
        Database.executebatch(b);
     }
}