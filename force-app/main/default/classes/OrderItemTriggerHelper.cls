/****************************************************************************************
Name              : OrderItemTriggerHelper
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-30196]
2. Kirill Hantayev           15/11/2018                Kirill Hantayev    [SW-30196]
3. Arkadi                    25/11/2018                Aya Toledano       [SW-31441]
----------------------------------------------------------------------------------------*/
/****************************************************************************************
Name              : OrderItemTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-31096]
1. Ori Roda                  02/04/2019                Neta Kopelman​      [SW-32962]
----------------------------------------------------------------------------------------*/
public class OrderItemTriggerHelper {

    public void updateParentOrderOnItemChange(List<OrderItem> OrderItems) {
        System.debug('==============Nevo TEST DESABLE=====');
        List<Order> orders2Update = new List<Order>();
        Map<Id, List<OrderItem>> lineIdToOrder = new Map<Id, List<OrderItem>>();
        Set<id> ordersIdset = new Set<id>();
        for (OrderItem item : OrderItems) {
            ordersIdset.add(item.OrderId);
            if (!lineIdToOrder.containsKey(item.OrderId)) {
                lineIdToOrder.put(item.OrderId, new List<OrderItem>());
            }
            lineIdToOrder.get(item.OrderId).add(item);
        }

        //String errMassg = Label.Order_is_already_processed;
        Set<String> validStatuses = new Set<string>{
                'Draft'
        };
            
        Set<String> validTypes = new Set<string>{
                'Regular Order',
                'Renting Order',
                'Complete Renting Order'

        };
        System.debug('OrderItemTriggerHelper: ordersIdset = '+ordersIdset);
        System.debug('OrderItemTriggerHelper: start to mark the field - Get_Prices__c');

        for (Order myOrder : [
            SELECT id, Status, Type 
            FROM order 
            WHERE id IN:ordersIdset 
            AND Status IN:validStatuses 
            AND Type IN:validTypes 
            AND Get_Prices__c = false 
            AND Skip_Get_Prices__c = false
            AND Order_Channel__c != 'E-Commerce']) {
            System.debug('OrderItemTriggerHelper: setting Get_Prices__c = true for: '+myOrder);
            orders2Update.add(new Order(Id = myOrder.id, Get_Prices__c = true));
        }
        System.debug('OrderItemTriggerHelper: done mark the field - Get_Prices__c');

        if (orders2Update.size() > 0) {
            List<Database.SaveResult> saveRslts = Database.update(orders2Update, false);
            for (Integer i = 0; i < saveRslts.size(); i++) {
                Database.SaveResult saveRslt = saveRslts[i];
                if (!saveRslt.isSuccess()) {
                    id orederID = orders2Update[i].Id;
                    for (OrderItem item : lineIdToOrder.get(orederID)) {
                        for (Database.Error err : saveRslt.getErrors()) {
                            item.addError(err.getMessage()); System.debug('The following error has occurred.'); System.debug(err.getStatusCode() + ': ' + err.getMessage()); System.debug('Order fields that affected this error: ' + err.getFields()); continue;
                        }
                    }
                }
            }
        }
    }

    public void ResetPricebookEntry(List<OrderItem> OrderItems) {

        //create a map of external Keys to SF Id's from pricebook entries
        Map<String, Id> pbMAP = new Map<String, Id>();
        List<PricebookEntry> pbList = [select Id, Product_ID__c from PricebookEntry where Pricebook2.isStandard = true];
        for (PricebookEntry pbe : pbList)
            if (pbe.Product_ID__c != null)
                pbMap.put(pbe.Product_ID__c, pbe.id);

        for (OrderItem item : OrderItems) {
            //If pricebook entry id is not provided but external Id is provided - use the external Id to populate pricebook entry id
            if (item.PricebookEntryId == null && item.PB_Entry_DCS_ID__c != null) {
                item.PricebookEntryId = pbMap.get(item.PB_Entry_DCS_ID__c);
            }
        }
    }

    public void RecreateOrderItem(List<OrderItem> OrderItemsFromTrigger) {
        system.debug('in OrderItemTriggerHelper.RecreateOrderItem');

        //filter the list to save on soql
        List<OrderItem> OrderItems = new List<OrderItem>();
        for(OrderItem item : OrderItemsFromTrigger){
            if(item.Quantity < 0){
                OrderItems.add(item);
            }
        }
        if(OrderItems.isEmpty()) return;

        //get all the related parent orders
        Set<Id> RelatedOrders_Set = new Set<Id>();
        for (OrderItem item : OrderItems) {
            RelatedOrders_Set.add(item.OrderId);
        } system.debug('related orders found: ' + RelatedOrders_Set);

        //get a map of all orderItems to later delete the positive and recreate for the negative
        Map<Id, OrderItem> OrderItemsOfRelatedOrders_Map = new Map<Id, OrderItem>([
                SELECT Id, OrderId, Quantity, Product2Id, PricebookEntryId, UnitPrice, Replacement_Products_Order__c, Return_Products_Order__c, Bypass_VR__c
                FROM OrderItem
                WHERE OrderId IN:RelatedOrders_Set and Order.RecordType.Name = 'Replacement Order'
        ]);

        //a list that holds the list of orderItems to replace with positive quantity
        List<OrderItem> negativeOrderItemsOfTheFoundOrders_List = new List<OrderItem>();
        //a list that holds the list of orderItems to delete - have positive quantity
        List<OrderItem> positiveOrderItemsOfTheFoundOrders_List = new List<OrderItem>();

        for(OrderItem item : OrderItemsOfRelatedOrders_Map.values()){
            if(item.Quantity < 0){
                negativeOrderItemsOfTheFoundOrders_List.add(item);
            } else if(item.Quantity > 0){
                positiveOrderItemsOfTheFoundOrders_List.add(item);
            }
        }
        system.debug('negativeOrderItemsOfTheFoundOrders_List (list OrderItems to replace to positive): ');
        for (OrderItem item : negativeOrderItemsOfTheFoundOrders_List) system.debug(item);
        system.debug('positiveOrderItemsOfTheFoundOrders_List (list OrderItems to delete): ');
        for (OrderItem item : positiveOrderItemsOfTheFoundOrders_List) system.debug(item);

        //delete all the positive orderItems on the relavent orders
        system.Savepoint sp = Database.setSavepoint();
        if (!positiveOrderItemsOfTheFoundOrders_List.isEmpty()) {
            delete positiveOrderItemsOfTheFoundOrders_List;
        }
        //this will now hold the NEW positive orderItems
        positiveOrderItemsOfTheFoundOrders_List.clear();

        //create the replacement positive orderItems
        for (OrderItem item : negativeOrderItemsOfTheFoundOrders_List) {
                positiveOrderItemsOfTheFoundOrders_List.add(
                        new OrderItem(Quantity = Math.abs(item.Quantity),
                                OrderId = item.OrderId,
                                Product2Id = item.Product2Id,
                                PricebookEntryId = item.PricebookEntryId,
                                UnitPrice = item.UnitPrice,
                                Replacement_Products_Order__c = item.OrderId,
                                Return_Products_Order__c = null,
                                Bypass_VR__c = true)
                );
        }
        system.debug('orderItems to insert instead of the negative quantity: ');
        for (OrderItem item : positiveOrderItemsOfTheFoundOrders_List) system.debug(item);

        List<database.SaveResult> saveList = Database.insert(positiveOrderItemsOfTheFoundOrders_List, false);
        Boolean errorInDML = false;
        for (Database.SaveResult sv : saveList) {
            if (!sv.isSuccess()) {
                errorInDML = true; system.debug('saveList res errors:');
                for (Database.Error err : sv.getErrors()) {
                    system.debug('error: ' + err);
                    positiveOrderItemsOfTheFoundOrders_List[saveList.indexOf(sv)].addError(err.message);
                }
            }
        }
        if (errorInDML) {
            system.debug('error on insert of positive orderlines - going to rollback');
            Database.rollback(sp); return;
        }
    }
}