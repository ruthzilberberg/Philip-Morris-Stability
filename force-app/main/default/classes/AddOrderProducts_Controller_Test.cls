@isTest 
private class AddOrderProducts_Controller_Test {
		
	 @testSetup static void setup() {
       //Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true,Account__c = true);
        //insert vr;
        Workflows_and_PB__c wpb = new Workflows_and_PB__c(Order__c = true,Order_Product__c = true);
        insert wpb;
        Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222), ID__pc='020007969');
        insert acc;
        id stndPB = Test.getStandardPricebookId();
        Order myOrder = new Order(AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB);
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
    }
  
	@isTest
	private static void getProducts() {
	  AddOrderProducts_Controller.getProducts(2,2);
	}

	@isTest
	private static void productsByText() {
	  AddOrderProducts_Controller.productsByText('dfg');
	}
	@isTest
	private static void createProducts() {
		id m = Test.getStandardPricebookId();
		id orderId = [select id from Order limit 1][0].id;
		List<product2> products = [select id,Quantity__c, Codentify__c from product2 ];
		AddOrderProducts_Controller.createProducts(orderId, products);
	}

	@isTest
	private static void getFielsByTable() {
		AddOrderProducts_Controller.getFielsByTable('product2');
	}
}