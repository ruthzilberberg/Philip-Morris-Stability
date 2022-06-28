/****************************************************************************************
Name              : OrderTriggerHelper
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               12/11/2018                Kirill         [SW-31314]
1. Nevo Harari               17/12/2018                Kirill         [SW-31674]
----------------------------------------------------------------------------------------*/
public class OrderTriggerHelper  {
    
    //SW-37471
    public void setDraftIfFixed(List<Order> orders){        
        for(Order ord : orders)if(ord.Data_Fix__c && UserInfo.getName() == 'Integration') ord.Status = 'Draft';
    }

    //SW-31314
    public void preventDraftValidation( List<Order> Orders ){
        for(Order ord: Orders)
        { 
         
         if(ord.Status != 'Draft')
            ord.status = 'Draft';
            
        }

     }
    //END SW-31314

     //SW-31674
      public void previousStatusRemains( List<Order> Orders, Map<Id, Order> ordersOldMap ){
         for(Order ord: Orders)
        { 
         Order oldOrder = ordersOldMap.get(ord.id);
         if(oldOrder.Status == 'Delivered' && ord.Status != oldOrder.Status ){
          ord.Status = 'Delivered';
          //ord.Status.addError('Status can\'t be changed when status already "Delivered".' );
         }
            
        }
      }
     //END SW-31674
    
    //sw-33972
    public void Call_Async_PromotionLogic(List<Order> Orders, Map<Id, Order> ordersOldMap){
        List<Order> relevOrders = new List<Order>();
        for(Order myOrder : Orders){
        system.debug('myOrder.Status - '+ myOrder.Status);
            if(myOrder.Status != ordersOldMap.get(myOrder.id).Status && String.isNotBlank(myOrder.Status) || myOrder.Create_Promotion__c == true){
                /*system.debug('myOrder.Status - '+ myOrder.Status);
                system.debug('myOrder.old Status - '+ ordersOldMap.get(myOrder.id).Status);
                system.debug('myOrder.myOrder.Processed__c- '+ myOrder.Processed__c);
                system.debug('myOrder.Shipped__c - '+ myOrder.Shipped__c);
                system.debug('myOrder.Order_Channel__c - '+ myOrder.Order_Channel__c);
                system.debug('is shipped  - ' + myOrder.Status.equalsIgnoreCase('Shipped'));
                */
                if((myOrder.Status.equalsIgnoreCase('Delivered') && myOrder.Processed__c==false && myOrder.Shipped__c==false && (myOrder.Order_Channel__c == 'E-Commerce' || myOrder.Order_Channel__c == 'CSC') )
                   ||
                   (myOrder.Status.equalsIgnoreCase('Delivered') && (myOrder.Order_Channel__c != 'E-Commerce' && myOrder.Order_Channel__c != 'CSC'))
                   ||
                   (myOrder.Create_Promotion__c == true) //SW-40034
                   /*|| 
                   (myOrder.Status.equalsIgnoreCase('Processed') && myOrder.Processed__c==true && (myOrder.Order_Channel__c == 'E-Commerce' || myOrder.Order_Channel__c == 'CSC'))
                   ||
                   (myOrder.Status.equalsIgnoreCase('Shipped') && myOrder.Processed__c==false && myOrder.Shipped__c==true && (myOrder.Order_Channel__c == 'E-Commerce' || myOrder.Order_Channel__c == 'CSC'))*/
                   )
                   {
                        relevOrders.add(myOrder);
                   }
            }else if((myOrder.Status.equalsIgnoreCase('Processed') && myOrder.Processed__c==true && ordersOldMap.get(myOrder.id).Processed__c == false && (myOrder.Order_Channel__c == 'E-Commerce' || myOrder.Order_Channel__c == 'CSC'))
                   ||
                   (myOrder.Status.equalsIgnoreCase('Shipped') && myOrder.Processed__c==false && myOrder.Shipped__c==true && ordersOldMap.get(myOrder.id).Shipped__c == false && (myOrder.Order_Channel__c == 'E-Commerce' || myOrder.Order_Channel__c == 'CSC')) )
            {
                relevOrders.add(myOrder);
            
            }
        }
        if(relevOrders.size() > 0){
          Async_PromotionLogic promotionLogic = new Async_PromotionLogic(relevOrders);
          ID jobID = System.enqueueJob(promotionLogic);
        }
    }
}