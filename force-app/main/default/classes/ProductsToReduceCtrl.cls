public class ProductsToReduceCtrl {
   
   ////////////Wrapper classers///////////
    
    public class returnWrapper {
        @AuraEnabled public List<OrderWrapeer> orderItems {get;set;}
        @AuraEnabled public string errorMessage { get; set; }

        public returnWrapper(string err) {
            errorMessage = err;
            orderItems = new List<OrderWrapeer>();
        }
        public returnWrapper(List<OrderWrapeer> l) {
            orderItems = l;
        }
    }
   
    public class OrderWrapeer {
        @AuraEnabled public OrderItem myOrderItem { get; set; }
        @AuraEnabled public Integer QuantityToReduce { get; set; }
        @AuraEnabled public String ProductName { get; set; }
        @AuraEnabled public Decimal AvailableQuantity { get; set; }
        @AuraEnabled public Decimal UnitPrice { get; set; }

        public OrderWrapeer(OrderItem myOrderItem, Integer QuantityToReduce,  String ProductName, Decimal AvailableQuantity, Decimal UnitPrice) {
            this.myOrderItem = myOrderItem;
            this.QuantityToReduce = QuantityToReduce;
            this.ProductName = ProductName;
            this.UnitPrice = UnitPrice;
        }
    }
      
    /////////////Wrapper classers END/////////////////
      

       
    ///////////////Logic Method//////////

    @AuraEnabled
    public static returnWrapper getOrderItems(id myOrderId) {
        List<OrderWrapeer> OrderItems = new List<OrderWrapeer>();

        System.debug('in getOrderItems for: ' + myOrderId);
        Order myOrder = [SELECT OriginalOrderId,IsReductionOrder,Status  FROM Order WHERE Id = :myOrderId];
        if( !myOrder.IsReductionOrder) {
            return new returnWrapper(Label.Not_Rduction_Message);//'Label for: action not available for NOT REDUCTION ORDER'

        } else if(  myOrder.Status == 'Ready to Process'){
            return new returnWrapper(Label.Step_Message);//'Label for: the user cannot select products on this step - (Status = Ready to Process)');

        }
        Id originalOrderId = myOrder.OriginalOrderId;
        

        for (OrderItem item : [
                SELECT Id, Product2.name,Product2Id, OrderId, ServiceDate,PricebookEntryId,ListPrice , EndDate, UnitPrice, AvailableQuantity, Order.IsReductionOrder, Order.Status
                FROM OrderItem
                where orderId =: originalOrderId AND Product2.Is_Returnable__c = TRUE
                ORDER BY createdDate ASC
        ]) {
            OrderWrapeer wrapper = new OrderWrapeer(item, 0,  item.Product2.name, item.AvailableQuantity, item.UnitPrice);
            OrderItems.add(wrapper);
        }
        if( OrderItems.isEmpty()){
            return new returnWrapper(label.No_order_products_Message);//'Label for: that there are no order products that can be reduced');
        }
        System.debug('OrderItems===' + OrderItems.size());
        return new returnWrapper(OrderItems);
    }

    //save Create Records
    @AuraEnabled
    public static String CreateReduceOrder (string OrderWrapeerJson, string parentId){
        System.debug('INSIDE CreateReduceOrder===' + OrderWrapeerJson);
        
        List<OrderWrapeer> OrderWrapeers = (List<OrderWrapeer>)JSON.deserialize(OrderWrapeerJson,List<OrderWrapeer>.Class);
        List<OrderItem> itemsToInert = new List<OrderItem>();
         List<OrderItem> itemsToUpdate = new List<OrderItem>();
        System.debug('OrderWrapeers===' + OrderWrapeers.size());
        set<id> OriginalOrderIds = new set<id>();
         for(OrderWrapeer wrapper:OrderWrapeers){
            //if(wrapper.QuantityToReduce > 0 && wrapper.myOrderItem.Id != null){
               OriginalOrderIds.add(wrapper.myOrderItem.Id);
          //  }
         }
         map<id, OrderItem> orderItemsMap = new map<id, OrderItem>();
       for(orderItem item : [select id,OriginalOrderItemId,Quantity from orderItem where OriginalOrderItemId IN:  OriginalOrderIds ]){
          //for(orderItem item : myOrder.orderItems){
              orderItemsMap.put(item.OriginalOrderItemId ,item);
          //} 
       }
        
        system.debug('orderItemsMap===' + orderItemsMap);
        for(OrderWrapeer wrapper:OrderWrapeers){
       
          if(wrapper.QuantityToReduce > 0){
                 id originalProdId =  wrapper.myOrderItem.Id;
                System.debug('OriginalOrderItemId ====' + originalProdId);  
                             
                System.debug('Value===' + orderItemsMap.containsKey(originalProdId));
              
               if(!orderItemsMap.containsKey(originalProdId)){
                   OrderItem reducedOrderItem = new OrderItem();  
                   reducedOrderItem.Quantity = (-1)*wrapper.QuantityToReduce;
                   reducedOrderItem.Product2Id = wrapper.myOrderItem.Product2Id;
                   reducedOrderItem.OrderId = parentId;
                   reducedOrderItem.OriginalOrderItemId = wrapper.myOrderItem.Id;
                   reducedOrderItem.PricebookEntryId = wrapper.myOrderItem.PricebookEntryId;
                   reducedOrderItem.UnitPrice = wrapper.myOrderItem.UnitPrice;
                   System.debug('reducedOrderItem===' + reducedOrderItem);
                   itemsToInert.add(reducedOrderItem);
               }else{
                   orderItem itemToUpdate = orderItemsMap.get(originalProdId);
                   itemToUpdate.Quantity -= wrapper.QuantityToReduce;
                   itemsToUpdate.add(itemToUpdate);
               }
               
          }     
        }
        if(itemsToInert.size() > 0){
            insert itemsToInert;
            System.debug('itemsToInert=='+itemsToInert);
        }
        
        if(itemsToUpdate.size() > 0){
            update itemsToUpdate;
            System.debug('itemsToUpdate=='+itemsToUpdate);
        }
        return 'Success';
    } 
}