/****************************************************************************************
Name              : OrderItemTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-31096]
----------------------------------------------------------------------------------------*/
public class OrderItemTriggerHandler  extends TriggerHandler{
public List<OrderItem> OrderItemNew;
   public map<Id, OrderItem> oldMApOrderItem;
  
    OrderItemTriggerHelper helper = new OrderItemTriggerHelper();

    public OrderItemTriggerHandler(List<OrderItem> OrderItemNew,  map<Id, OrderItem> oldMApOrderItem){
        this.OrderItemNew = OrderItemNew;
        this.oldMApOrderItem = oldMApOrderItem;
    }


    public override void afterinsert  (){
	   Boolean isactive= this.isActionAllowed('updateParentOrderOnItemChange');
	   System.debug('isactive INSERT====='+isactive);
        if (this.isActionAllowed('updateParentOrderOnItemChange')) {/// && UserInfo.getUserName()!='integration@pmi.com.partial'
            helper.updateParentOrderOnItemChange(OrderItemNew);
//            return;
        }
        if(this.isActionAllowed('RecreateOrderItem')){
            helper.RecreateOrderItem(OrderItemNew);
        }
    }

    public override void afterUpdate (){
	    Boolean isactive= this.isActionAllowed('updateParentOrderOnItemChange');
		System.debug('isactive UPDTAE====='+isactive);
        if (this.isActionAllowed('updateParentOrderOnItemChange') ) {// && UserInfo.getUserName()!='integration@pmi.com.partial'
            helper.updateParentOrderOnItemChange(OrderItemNew);
//            return;
        }
        if(this.isActionAllowed('RecreateOrderItem')){
            helper.RecreateOrderItem(OrderItemNew);
        }
    }


    public override void afterdelete () {
       if (this.isActionAllowed('updateParentOrderOnItemChange') ) {// && UserInfo.getUserName()!='integration@pmi.com.partial'
            helper.updateParentOrderOnItemChange(oldMApOrderItem.values());
//            return;
        }
    }

    public override void afterundelete () {
       if (this.isActionAllowed('updateParentOrderOnItemChange')) {
            helper.updateParentOrderOnItemChange(OrderItemNew);
//            return;
        }  
    }
/*    
    public override void beforeupdate () {
         if (this.isActionAllowed('ResetPricebookEntry')) {
            helper.ResetPricebookEntry(OrderItemNew);
            return;
        }
    }

*/

    public override void beforeinsert () {
       /* if (!this.isactionallowed('method')) {
            return;
        }*/
        if (this.isActionAllowed('ResetPricebookEntry')) {
            helper.ResetPricebookEntry(OrderItemNew);
            return;
        }
    }

/*
    public override void beforedelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }

    */
}