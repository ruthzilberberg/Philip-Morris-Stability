@isTest
public with sharing class ProductWizardSaveTest {

    @testSetup static void setup() {
        Workflows_and_PB__c sc = new Workflows_and_PB__c(Order__c = true);
        insert sc;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Account__c =true,On_Off_VRs__c = true,Order_Product__c = true);
        insert vr;
        RecordType accRT = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND sObjectType = 'Account' LIMIT 1];

        Contact contact = new Contact(LastName = 'Test LN', ID__c = '040146680');
        insert contact;

        Account acc = new Account(LastName = 'Test LN', RecordTypeId = accRT.Id, ID__pc = contact.ID__c,PersonBirthdate = system.today().addYears(-20));
        insert acc;

        Pricebook2 priceBook = new Pricebook2(IsActive = true, Name = 'Test PriceBook');
        insert priceBook;

        Product2 product = new Product2(Name = 'Test Product', IsActive = true, Quantity__c = 8);
        insert product;

        Id standardPBId = Test.getStandardPricebookId();

        PricebookEntry pricebookEntry = new PricebookEntry(IsActive = true, UnitPrice = 5, Pricebook2Id = priceBook.Id, Product2Id = product.Id);
        PricebookEntry standardPE = new PricebookEntry(IsActive = true, UnitPrice = 5, Pricebook2Id = standardPBId, Product2Id = product.Id);

        insert new List<PricebookEntry>{
                standardPE, pricebookEntry
        };

        Order order = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Pricebook2Id = priceBook.Id);
        insert order;
    }

    @isTest
    private static void SendWorkatoHtppRequestTest() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        Test.startTest();
        System.assertEquals('{"example":"test"}', ProductWizardSave.SendWorkatoHtppRequest('{}').getBody());
        Test.stopTest();
    }

    @isTest
    private static void UpdateProductsWorkatoTestNegative() {
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        ProductWizardSave.UpdateProductsWorkato(order.Id);
        Test.stopTest();

        order = [SELECT Id, Integration_Status__c, Integration_Error__c FROM Order LIMIT 1];

        System.assertEquals('Failed', order.Integration_Status__c);
    }

    @isTest
    private static void UpdateProductsWorkatoTestPositive() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockErrorImpl());

        Test.startTest();
        ProductWizardSave.UpdateProductsWorkato(order.Id);
        Test.stopTest();

        order = [SELECT Id, Integration_Status__c, Integration_Error__c FROM Order LIMIT 1];

        System.assertEquals('Failed', order.Integration_Status__c);
        System.assertEquals('Error during Products wizard workato getprices request: status code : 400 status = null', order.Integration_Error__c);
    }

    @isTest
    private static void getPriceBookTest() {
        Test.startTest();
        System.assertNotEquals(null, ProductWizardSave.getPriceBook());
        Test.stopTest();
    }

    @isTest
    private static void saveJsonTestNegative() {
        Test.startTest();
        System.assertEquals('{"message":"Id not specified in an update call","isSuccess":false}',
                ProductWizardSave.saveJson('{}'));
        Test.stopTest();
    }

    @isTest
    private static void saveJsonTestPositive() {
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        System.assertEquals('{"message":"success","isSuccess":true}',
                ProductWizardSave.saveJson('{"fssOwner":"","paymentMethod":"", "promotionCode":"", "orderId":"' + order.Id + '", "selectedProducts":[]}'));
        Test.stopTest();
    }

    @isTest
    private static void createOrderProductsTest() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Product2 product2 = [SELECT Id, Quantity__c FROM Product2 LIMIT 1];

        ProductWizardSave.Product product = new ProductWizardSave.Product();
        product.productId = product2.Id;
        product.quantity = product2.Quantity__c;

        Test.startTest();
        ProductWizardSave.createOrderProducts(new List<ProductWizardSave.Product>{
                product
        }, order.Id);
        Test.stopTest();

        System.assertNotEquals(0, [SELECT COUNT() FROM OrderItem]);
    }

    @isTest
    private static void createOrderProductsTestWithChainId() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Product2 product2 = [SELECT Id, Quantity__c, DCS_Chain_ID__c FROM Product2 LIMIT 1];

        ProductWizardSave.Product product = new ProductWizardSave.Product();
        product.productId = product2.Id;
        product.quantity = product2.Quantity__c;
        product.Product_type_Id = product2.Id;
        product.chain_id = product2.Id;

        Test.startTest();
        ProductWizardSave.createOrderProducts(new List<ProductWizardSave.Product>{
                product
        }, order.Id);
        Test.stopTest();

        System.assertNotEquals(0, [SELECT COUNT() FROM OrderItem]);
    }
}