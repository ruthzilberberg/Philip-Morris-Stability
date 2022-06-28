@isTest 
private class PaymentYaad_Test {

    @TestSetup
     static void tstSetup(){
        
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true);
        insert wpb;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true,Account__c=true);
        insert vr;
        ServiceCredential__c srvYaad = new ServiceCredential__c(Name = 'Yaad', Endpoint__c = 'https://testYaad.tst.com', FormMethod__c = 'POST', Password__c = 'PasswordTest',Key__c = '' + Crypto.getRandomInteger(),Cash_FormMethod__c = 'GET');
        insert srvYaad;
        Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),Terms_and_Conditions__pc = true,ID__pc = '111111118');
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
    private static void PaymentYaadCtrl() {
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
        update new Order(Id=ord.Id,Status = 'Ready to Process'); 
        PaymentYaadCtrl.getOrderData(ord.Id,'credit');
        
    }

    @isTest
    private static void paymentYaad_returnSuccess() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Test());
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
        //PaymentYaadCtrl.getOrderData(ord.Id,'cash');
        update new Order(Id=ord.Id,Status = 'Ready to Process'); 
        PaymentYaadCtrl.getOrderData(ord.Id,'credit');
        PageReference pageRef = Page.YaadResponseSuccess;
        Test.setCurrentPage(pageRef);
        Map<String,String> pageMap =  ApexPages.currentPage().getParameters();
        pageMap.put('order',ord.OrderNumber);
        
        List<FieldMapping__mdt> resMapping = [Select FieldApiName__c,MappingName__c From FieldMapping__mdt where isUpdateOnSuccess__c = true And MappingName__c != null And ObjectMapping__r.MasterLabel = 'YaadPayment'] ;
        Map<String,String> resMap = new Map<String,String>();
        for(FieldMapping__mdt fm  :resMapping){
            pageMap.put(fm.MappingName__c,'val');
        }
        pageMap.put('CCode','0');
        pageMap.put('Amount','3');
        Test.startTest();
            YaadResponseSuccessCtrl ctrl = new YaadResponseSuccessCtrl();
            ctrl.init();
        Test.stopTest();
        try{
          YaadResponseSuccessCtrl.tokenRequest(null,null,null,null); 
        }catch(Exception ex){
          
        }
    }

      @isTest
    private static void paymentYaad_cash() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Test());
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
        update new Order(Id=ord.Id,Status = 'Ready to Process',Payment_Method__c = 'Cash'); 
        Test.startTest();
            PaymentYaadCtrl.getOrderData(ord.Id,'cash');
        Test.stopTest();

    }
    
    @isTest
    private static void paymentYaad_returnSuccess_error() {
        try{
            YaadResponseSuccessCtrl ctrl = new YaadResponseSuccessCtrl();
            ctrl.init();
        }catch(Exception ex){
        }
    }

    @isTest
    private static void paymentYaad_returnError() {
        
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
        PageReference pageRef = Page.YaadResponseError;
        Test.setCurrentPage(pageRef);
        Map<String,String> pageMap =  ApexPages.currentPage().getParameters();
        pageMap.put('order',ord.OrderNumber);

        List<FieldMapping__mdt> resMapping = [Select FieldApiName__c,MappingName__c From FieldMapping__mdt where isUpdateOnFailure__c = true And MappingName__c != null And ObjectMapping__r.MasterLabel = 'YaadPayment'];
        Map<String,String> resMap = new Map<String,String>();
        for(FieldMapping__mdt fm  :resMapping){
            pageMap.put(fm.MappingName__c,'val');
        }
        pageMap.put('CCode','1');
        YaadResponseErrorCtrl ctrl = new YaadResponseErrorCtrl();
        ctrl.init();
    
    }



}