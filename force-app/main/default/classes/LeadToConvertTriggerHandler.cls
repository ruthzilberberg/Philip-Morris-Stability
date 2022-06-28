/**
 * Created by sam on 10/14/2018.
 */

public class LeadToConvertTriggerHandler extends TriggerHandler{
    public Lead newLead;
    public Lead oldLead;

    public LeadToConvertTriggerHandler(List<Lead> newLead, List<Lead> oldLead){
        System.debug('oldLead   === ' + oldLead);
        this.newLead = newLead != null && newLead.size() > 0 ? newLead.get(0) : new Lead();
        this.oldLead = oldLead != null && oldLead.size() > 0 ? oldLead.get(0) : new Lead();
    }

    LeadToConvertTriggerHelper helper = new LeadToConvertTriggerHelper();
/*
//    public override void beforeInsert () {
//
//        System.debug( 'in Before insert' );
////        if (!this.isActionAllowed('method')) {
////            return;
////        }
//    }
//
//    public override void beforeUpdate () {
//
//        System.debug( 'in Before update' );
////        if (this.isActionAllowed('leadToAccount')) {
////            helper.leadToAccount(newLead,oldLead);
////            return;
////        }
//    }

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