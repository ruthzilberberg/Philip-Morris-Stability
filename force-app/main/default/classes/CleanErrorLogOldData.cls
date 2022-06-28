/****************************************************************************************
Name              : CleanErrorLogOldData
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Samuel Boukhobza           24/07/2018             Gal Regev          [SW-30196]
----------------------------------------------------------------------------------------
****************************************************************************************/

global class CleanErrorLogOldData implements Schedulable {
    global void execute(SchedulableContext ctx) {

        DeleteErrorLogsBatch deleteBatch = new DeleteErrorLogsBatch();
        Database.executeBatch(deleteBatch,200);

    }

}