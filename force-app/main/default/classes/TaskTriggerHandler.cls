/****************************************************************************************
Name              : TastTriggerHelper
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               25/11/2018             Kirill Hantayev          [SW-31407]
----------------------------------------------------------------------------------------*/
public class TaskTriggerHandler  extends TriggerHandler{
  
  
   public List<Task> TaskNew;
   public map<Id, Task> oldMApTask;
  
    TaskTriggerHelper helper = new TaskTriggerHelper();

    public TaskTriggerHandler(List<Task> TaskNew,  map<Id, Task> oldMApTask){
        this.TaskNew = TaskNew;
        this.oldMApTask = oldMApTask;
    }

/*
    public override void beforeinsert  (){
        System.debug( 'in afterUpdate ' );
        if (this.isActionAllowed('findAndConvertLeads')) {
            
            return;
        }

    }
*/
    public override void afterinsert () {
        system.debug( 'in after insert' );
        if (this.isactionallowed('populateTemplateWithValues')) {
			helper.populateTemplateWithValues(TaskNew,oldMApTask);
			return;
        }
    }

    public override void beforeupdate () {
         system.debug( 'in before update' );
        if (this.isactionallowed('populateTemplateWithValues')) {
			helper.populateTemplateWithValues(TaskNew,oldMApTask); 
            return;
        }
    }

/*
    public override void beforedelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }

    public override void afterUpdate (){
        if(this.isactionallowed('method')){
        }
    }


    public override void afterdelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }

    public override void afterundelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }*/
}