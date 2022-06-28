@isTest 
public class RefundYaadCtrl_Test  
{
    
     @TestSetup
     static void tstSetup(){
        
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true);
        insert wpb;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true, Account__c = true);
        insert vr;
        ServiceCredential__c srvYaad = new ServiceCredential__c(Name = 'Yaad', Endpoint__c = 'https://testYaad.tst.com', FormMethod__c = 'POST', Password__c = 'PasswordTest',Key__c = '' + Crypto.getRandomInteger(),Cash_FormMethod__c = 'GET');
        insert srvYaad;
        Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),Terms_and_Conditions__pc = true);
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Id regularRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Regular Order').getRecordTypeId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB, RecordTypeId = regularRecTypeId);
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
        //item.Quantity = 3;
        //update item;
        Test.stopTest();
    }


        @isTest
    private static void refundYaad() {
    
       Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Test());
       Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
       Test.startTest();
       RefundYaadCtrl.getDefaultValues(ord.Id);
       RefundYaadCtrl.getOrderData(ord.Id,'1234','12','2021','111111118','success','failure');
       Test.stopTest();
    /*
        
        Order myOrder = [Select Id,OrderNumber,Status,AccountId,EffectiveDate,Pricebook2Id,( SELECT
                        Id,QUANTITY,UNITPrice,PricebookEntryId
                        FROM OrderItems )
                    FROM Order limit 1][0];
        
        List<OrderItem> ordItems = [SELECT
                        Id,QUANTITY,UNITPrice,PricebookEntryId
                        FROM OrderItems Limit 1];
        System.assertNotEquals(ordItems.size(), 0);                  
        myOrder.Status = 'Processed';
        update myOrder;
        Id refundRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Return Order').getRecordTypeId();
        Order refundOrder = myOrder.clone();
        refundOrder.OriginalOrderId = myOrder.Id;
        refundOrder.RecordTypeId = refundRecTypeId;
        refundOrder.IsReductionOrder = true;
        refundOrder.Status = 'Ready to Process';
        insert refundOrder;
        OrderItem itemRefund = myOrder.OrderItems[0].clone();
        itemRefund.OriginalOrderItemId = myOrder.OrderItems[0].Id;
        itemRefund.OrderId = refundOrder.Id;
        itemRefund.Quantity = -1;
        insert itemRefund;
         
        Test.startTest();
            RefundYaadCtrl.getOrderData(refundOrder.Id,'1234','12','2021','111111118');
            try{
                RefundYaadCtrl.handleResponse(null,null);
            }catch(Exception ex){}
        Test.stopTest();
    */
    }

    @isTest
    private static void RefundYaad2() {

    /*
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Test());
        Order myOrder = [Select Id,OrderNumber,Status,AccountId,EffectiveDate,Pricebook2Id,( SELECT
                        Id,QUANTITY,UNITPrice,PricebookEntryId
                        FROM OrderItems )
                    FROM Order limit 1][0];


        update new Order(Id=myOrder.Id,Status = 'Ready to Process');
        Test.startTest();
            RefundYaadCtrl.getOrderData(myOrder.Id,null,null,null,null);
            try{
                RefundYaadCtrl.handleResponse(null,null);
            }catch(Exception ex){}
        Test.stopTest();
    */
    }
    @isTest
    private static void refundYaad_Error(){
        try{
            RefundYaadCtrl.getDefaultValues(null);
            RefundYaadCtrl.sendPostReq(null,null,'',null,null,null);
        }catch(Exception ex){}
    }
        
}