@isTest 
public class SafeChargePaymentController_Test  
{
   @TestSetup
     static void tstSetup(){
        
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true);
        insert wpb;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true);
		insert vr;
		ServiceCredential__c srvYaad = new ServiceCredential__c(Name = 'SafeCharge', Endpoint__c = 'https://test.testsafecharge.com', FormMethod__c = 'POST', Password__c = 'PasswordTest',Key__c = '' + Crypto.getRandomInteger(),AdditionalData__c = 'key, merchant_id, currency, total_amount, item_Lst, user_token_id, time_stamp' );
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
    private static void SafeChargePaymentController_test() {
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
		update new Order(Id=ord.Id,Status = 'Ready to Process'); 
        SafeChargePaymentController.getOrderData(ord.Id,'credit');
        
    }

   @isTest
    private static void SafeChargeResponseCtrl_test() {
        
        
        Order ord = [Select Id,OrderNumber FROM Order limit 1][0];
        //PaymentYaadCtrl.getOrderData(ord.Id,'cash');
		update new Order(Id=ord.Id,Status = 'Ready to Process'); 
        PageReference pageRef = Page.SafeChargeResponseSuccess;
        Test.setCurrentPage(pageRef);
        Map<String,String> pageMap =  ApexPages.currentPage().getParameters();
        pageMap.put('customField1',ord.Id);
       
        List<FieldMapping__mdt> resMapping = [Select FieldApiName__c,MappingName__c From FieldMapping__mdt where isUpdateOnSuccess__c = true And MappingName__c != null And ObjectMapping__r.MasterLabel = 'SC_Order'] ;
        Map<String,String> resMap = new Map<String,String>();
        for(FieldMapping__mdt fm  :resMapping){
            resMap.put(fm.MappingName__c,'val');
        }
       
        Test.startTest();
            SafeChargeResponseCtrl ctrl = new SafeChargeResponseSuccessCtrl();
            ctrl.setSuccess();
            ctrl.init();
            ctrl.handleResponse();
            pageMap.put('Status','Declined');
            ctrl = new SafeChargeResponseErrorCtrl();
            ctrl.setFailure();
            ctrl.init();
            ctrl.handleResponse();
             pageMap.put('Status','Pending');
            ctrl = new SafeChargeResponsePendingCtrl();
            ctrl.setPending();
            ctrl.init();
            ctrl.handleResponse();
        Test.stopTest();
        
    }
    
}