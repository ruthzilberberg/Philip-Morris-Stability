/****************************************************************************************
Name              : OrderTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               12/11/2018                Kirill         [SW-31314]
----------------------------------------------------------------------------------------*/
public class OrderTriggerHandler  extends TriggerHandler{
  
  
   public List<Order> OrderNew;
   public map<Id, Order> oldMApOrder;
  
    OrderTriggerHelper helper = new OrderTriggerHelper();

    public OrderTriggerHandler(List<Order> OrderNew,  map<Id, Order> oldMApOrder){
        this.OrderNew = OrderNew;
        this.oldMApOrder = oldMApOrder;
    }

    public override void beforeinsert () {
        system.debug( 'in before insert' );
        if (this.isActionAllowed('preventDraftValidation')) {
            helper.preventDraftValidation(OrderNew);
            return;
        }
    }
/*
    public override void afterinsert  (){
        System.debug( 'in afterUpdate ' );
         if (!this.isactionallowed('method')) {
            return;
        }
    }

   
   */
    public override void beforeupdate () {
         System.debug( 'in beforeupdate ' );
         if (this.isactionallowed('previousStatusRemains')) {
			 helper.previousStatusRemains(OrderNew, oldMApOrder);
            return;
        }
    }
    public override void afterUpdate (){
       if(this.isactionallowed('Call_Async_PromotionLogic')){
            helper.Call_Async_PromotionLogic(OrderNew, oldMApOrder);
        }
    }
	/*
    public override void beforedelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }
    */


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