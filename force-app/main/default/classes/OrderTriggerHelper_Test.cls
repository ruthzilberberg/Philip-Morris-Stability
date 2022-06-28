@isTest 
private class OrderTriggerHelper_Test {

    @TestSetup
     static void mySetup(){
        Workflows_and_PB__c sc = new Workflows_and_PB__c(Order__c = true);
        insert sc;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Account__c =true,On_Off_VRs__c = true,Order_Product__c = true);
        insert vr;
    }
    @isTest
    private static void preventDraftValidation_Test() {
         Account acc = new Account(FirstName='Name', LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),ID__pc  = '111111118');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Shipped', EffectiveDate = System.today(), Pricebook2Id = stndPB);
        insert myOrder;
    }

    @isTest
    private static void previousStatusRemains_Test() {
         Account acc = new Account(FirstName='Name', LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),ID__pc  = '111111118');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Delivered', EffectiveDate = System.today(), Pricebook2Id = stndPB);
        insert myOrder;
        
        myOrder.Status = 'Draft';
        update myOrder ;
    }

    //SW-33792 START
    @isTest
    private static void Async_Test() {
         Account acc = new Account(FirstName='Name', LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),ID__pc  = '111111118');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        id orderRtId = [select id from recordTYpe where name = 'Lending Order' and sobjectType='Order' limit 1].id;
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Shipped', EffectiveDate = System.today(), Pricebook2Id = stndPB, Promotion_code__c ='5511');
        myOrder.recordTypeId = orderRtId;
        insert myOrder;
        //create product
        Product2 prod = new Product2( Name = 'name',IsActive = true,Device_Product__c=true,Product_Generation__c='0', Sub_Product_Generation__c='0');
        insert prod;
        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = stndPB, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;
        OrderItem item = new OrderItem(orderId = myOrder.Id, QUANTITY = 2 , UNITPrice = 22, PricebookEntryId = customPrice.id);
        insert item;

        //create Promotion__c
        Promotion__c Promotion = new Promotion__c(Status__c = 'Active', Type__c = 'Benefit', Promotion_Code__c ='5511' );
        Promotion__c Promotion1 = new Promotion__c(Status__c = 'Active', Type__c = 'Personal Code', Promotion_Code__c ='8888', Customer__c = acc.id );
        Promotion__c Promotion2 = new Promotion__c(Status__c = 'Open', Type__c = 'Benefit', Promotion_Code__c ='9999');
        insert new List<Promotion__c>{Promotion,Promotion1,Promotion2};
        myOrder.Status = 'Processed';
        myOrder.Order_Channel__c = 'E-Commerce';
        update myOrder;
    }

    @isTest
    private static void Async2_Test() {
         Account acc = new Account(FirstName='Name', LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),ID__pc  = '111111118');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        id orderRtId = [select id from recordTYpe where name = 'Lending Order' and sobjectType='Order' limit 1].id;
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Shipped', EffectiveDate = System.today(), Pricebook2Id = stndPB, Promotion_code__c ='5511');
        myOrder.recordTypeId = orderRtId;
        insert myOrder;
        //create product
        Product2 prod = new Product2( Name = 'name',IsActive = true );
        insert prod;
        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = stndPB, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;
        OrderItem item = new OrderItem(orderId = myOrder.Id, QUANTITY = 2 , UNITPrice = 22, PricebookEntryId = customPrice.id);
        insert item;

        //create Promotion__c
        Promotion__c Promotion = new Promotion__c(Status__c = 'Active', Type__c = 'Benefit', Promotion_Code__c ='0000000' );
        Promotion__c Promotion1 = new Promotion__c(Status__c = 'Active', Type__c = 'Personal Code', Promotion_Code__c ='5511', Customer__c = acc.id );
        Promotion__c Promotion2 = new Promotion__c(Status__c = 'Open', Type__c = 'Benefit', Promotion_Code__c ='9999');
        
        insert new List<Promotion__c>{Promotion,Promotion1,Promotion2};
        myOrder.Status = 'Processed';
        myOrder.Order_Channel__c = 'E-Commerce';
        update myOrder;
    }

    @isTest
    private static void Async3_Test() {
         Account acc = new Account(FirstName='Name', LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),ID__pc  = '111111118');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        id orderRtId = [select id from recordTYpe where name = 'Lending Order' and sobjectType='Order' limit 1].id;
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Shipped', EffectiveDate = System.today(), Pricebook2Id = stndPB, Promotion_code__c ='5511');
        myOrder.recordTypeId = orderRtId;
        insert myOrder;
        //create product
        Product2 prod = new Product2( Name = 'name',IsActive = true );
        insert prod;
        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = stndPB, Product2Id = prod.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;
        OrderItem item = new OrderItem(orderId = myOrder.Id, QUANTITY = 2 , UNITPrice = 22, PricebookEntryId = customPrice.id);
        insert item;

        //create Promotion__c 
        Promotion__c Promotion = new Promotion__c(Status__c = 'Active', Type__c = 'Benefit', Promotion_Code__c ='0000000' );
        Promotion__c Promotion1 = new Promotion__c(Status__c = 'Active', Type__c = 'Personal Code', Promotion_Code__c ='5511', Customer__c = acc.id );
        
        insert new List<Promotion__c>{Promotion,Promotion1};
        myOrder.Status = 'Delivered';
        myOrder.Order_Channel__c = 'CSC';
        update myOrder;
        acc.MGM_PROMO_CODE__c = '12342';
        try{
            update acc;
        }catch(Exception ex){
           System.debug('ex : ' + ex);
        }  
    }   
    //SW-33792 STOP
}