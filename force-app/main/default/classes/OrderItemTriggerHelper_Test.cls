/****************************************************************************************
Name              : OrderItemTriggerHelper_Test
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-30196]
2. Arkadi                    25/11/2018                Aya Toledano       [SW-31441]
----------------------------------------------------------------------------------------*/
@isTest 
private class OrderItemTriggerHelper_Test {

    @isTest
    private static void updateParentOrderOnItemChange_Test() {
        //Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true,Account__c = true);
        //insert vr;
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true,Order_Product__c = true);
        insert wpb;
        Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222), ID__pc='020007969');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB, Type = 'Regular Order');
        insert myOrder;
        Product2 prod = new Product2( Name = 'name',IsActive = true );
        insert prod;

        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = stndPB, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;

        OrderItem item = new OrderItem(orderId = myOrder.Id, QUANTITY = 2 , UNITPrice = 22, PricebookEntryId = customPrice.id);
        Test.startTest();
        insert item;
        item.Quantity = 3;
        update item;
        delete item;
        Test.stopTest();

    }

    @isTest
    private static void updateParentOrderOnItemChange_ValidStatus_Test() {
        //Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true,Account__c = true);
        //insert vr;
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true,Order_Product__c = true);
        insert wpb;
        Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222), ID__pc='020007969');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB );
        insert myOrder;
        Product2 prod = new Product2( Name = 'name',IsActive = true );
        insert prod;

        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = stndPB, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;

        OrderItem item = new OrderItem(orderId = myOrder.Id, QUANTITY = 2 , UNITPrice = 22, PricebookEntryId = customPrice.id);
        try{
             Test.startTest();
            insert item;
            item.Quantity = 3;
            update item;
            delete item;
            Test.stopTest();
        }catch(Exception e){}

    }

    @isTest
    private static void RecreateOrderItem_Test(){
        //Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true,Account__c = true);
        //insert vr;
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true,Order_Product__c = true);
        insert wpb;
        Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222), ID__pc='020007969');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB ,RecordTypeId=[SELECT Id FROM RecordType WHERE Name ='Replacement Order' limit 1].Id);
        insert myOrder;
        Order myOrder1 = new Order(Parent_Order__c=myOrder.Id ,AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB ,RecordTypeId=[SELECT Id FROM RecordType WHERE Name ='Replacement Order' limit 1].Id);
        insert myOrder1;

        Product2 prod = new Product2( Name = 'name',IsActive = true );
        insert prod;
        Test.startTest();
        PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = stndPB, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
        insert customPrice;

        OrderItem item = new OrderItem(orderId = myOrder1.Id, QUANTITY = -2 , UNITPrice = 22, PricebookEntryId = customPrice.id);
        insert item;
        Test.stopTest();
    }
}