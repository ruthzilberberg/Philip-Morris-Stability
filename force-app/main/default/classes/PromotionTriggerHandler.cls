/****************************************************************************************
Name              : PromotionTriggerHandler
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo                     29/01/2020            Ella Bernachik          [SW-36249]
----------------------------------------------------------------------------------------*/
public class PromotionTriggerHandler  extends TriggerHandler{

 public List<Promotion__c> promotions;
    public Map<Id,Promotion__c> oldMap;

    PromotionTriggerHelper helper = new PromotionTriggerHelper();

    public PromotionTriggerHandler(List<Promotion__c> promotions,Map<Id,Promotion__c> oldMap){
        this.promotions = promotions;
        this.oldMap = oldMap;
    }


//    public override void afterinsert  (){
//        System.debug( 'in afterUpdate ' );
//    }
/*
    public override void beforeinsert () {
        system.debug( 'in before insert' );
        if(this.isActionAllowed('xxxx')){
           // helper
        }
    }

    public override void beforeupdate () {
        system.debug( 'in before update' );
        
    }*/

//    public override void beforedelete () {
//        if (!this.isactionallowed('method')) {
//            return;
//        }
//    }

    public override void afterUpdate (){
        if(this.isactionallowed('findBenefitPromotion')){
		  PromotionTriggerHelper.findBenefitPromotion(promotions, oldMap);
        }
    }

/*
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