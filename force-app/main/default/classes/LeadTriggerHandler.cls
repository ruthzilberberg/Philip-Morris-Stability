/****************************************************************************************
Name              : LeadTrigger
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               15/04/2019               Ella              [SW-31813]
----------------------------------------------------------------------------------------*/

/////////////TEST //////////////////
//////////RUN TEST AccountTriggerHelper_Test/////////////

public class LeadTriggerHandler   extends TriggerHandler{
 public List<Lead> newLead;
    public Map<Id, Lead> oldLead;

    public LeadTriggerHandler(List<Lead> newLead, Map<Id, Lead> oldLead){
        System.debug('oldLead   === ' + oldLead);
        this.newLead = newLead;
        this.oldLead = oldLead;
    }

    LeadToConvertTriggerHelper helper = new LeadToConvertTriggerHelper();
    AccountTriggerHelper Accounthelper = new AccountTriggerHelper();

    public override void beforeInsert () {

	 if(this.isactionallowed('AgeVerificationInsert')){
            Accounthelper.AgeVerificationInsert(newLead);//SW-36926
        }

       System.debug( 'in Before insert' );
       if (this.isactionallowed('Validate_IdNumber')) {
            Accounthelper.Validate_IdNumber(newLead,'ID__c');
           return;
        }
  }


   public override void beforeUpdate () {
     
	  if(this.isactionallowed('AgeVerificationUpdate')){
            Accounthelper.AgeVerificationUpdate(newLead,oldLead);//SW-36926
        }
       
	   System.debug( 'in Before update' );
       if (this.isactionallowed('Validate_IdNumber')) {
            Accounthelper.Validate_IdNumber(newLead,'ID__c');
            return;
        }
    }
/*
//    public override void beforeDelete () {
//
//        System.debug( 'in Before delete' );
//        if (!this.isActionAllowed('method')) {
//            return;
//        }
//    }

//    public override void afterInsert (){
//        System.debug( 'in after insert' );
////        if(this.isActionAllowed('method')){
////        }
//
//    }

    public override void afterUpdate (){
        System.debug( 'in after insert' );
        if (this.isActionAllowed('leadToAccount')) {
            helper.leadToAccount(newLead,oldLead);
            return;
        }

    }


//    public override void afterDelete () {
//
//        System.debug( 'in after delete' );
//        if (!this.isActionAllowed('method')) {
//            return;
//        }
//    }

//    public override void afterUndelete () {
//
//        System.debug( 'in after undelete' );
//        if (!this.isActionAllowed('method')) {
//            return;
//        }
//    }*/

}