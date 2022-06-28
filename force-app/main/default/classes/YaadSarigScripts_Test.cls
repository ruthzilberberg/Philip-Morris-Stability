@isTest 
private class YaadSarigScripts_Test {
  @TestSetup
     static void tstSetup(){
        
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true);
        insert wpb;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true);
    insert vr;
    ServiceCredential__c srvYaad = new ServiceCredential__c(Name = 'Yaad', Endpoint__c = 'https://testYaad.tst.com', FormMethod__c = 'POST', Password__c = 'PasswordTest',Key__c = '' + Crypto.getRandomInteger(),Cash_FormMethod__c = 'GET');
        insert srvYaad;
        Account acc = new Account(ID__pc = '111111118',LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),Terms_and_Conditions__pc = true);
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Id regularRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Regular Order').getRecordTypeId();
        Order myOrder = new Order(AccountId = acc.Id,Payment_Method__c = 'Credit Card',Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB, RecordTypeId = regularRecTypeId);
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
    private static void UpdateYaadSarigToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Test());
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
        update new Order(Id=ord.Id,Status = 'Ready to Process'); 
        Test.startTest();
        YaadSarigScripts.UpdateYaadSarigToken(ord.OrderNumber,'0010085112','9767168','Delivered');
        Test.stopTest();
        YaadSarigScripts.UpdateYaadSarigToken(null,'0010085112','9767168','Delivered');
        YaadSarigScripts.UpdateYaadSarigToken(ord.OrderNumber,'0010085112','9767168','Delivered');
    }

}