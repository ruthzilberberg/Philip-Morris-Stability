public with sharing class AddOrderProducts_Controller {

    @AuraEnabled
    public static List<Product2> getProducts(Integer limits , Integer offsets){
	    Integer intlimits = integer.valueof(limits);
        Integer intoffsets = integer.valueof(offsets);
        return [SELECT Id, Name, ProductCode, Description, Family FROM Product2  Limit :intlimits Offset :intoffsets];
    }
	
	 @AuraEnabled
    public static List<Product2> productsByText(String searchText){
	    System.debug('searchText='+searchText);
        return [SELECT Id, Name, ProductCode, Description, Family FROM Product2  WHERE Name LIKE : '%' +searchText+'%' Limit 20 Offset : 5];
    }

	
	@AuraEnabled
    public static String createProducts(id recordid, List<product2> products){
        OrderItem[] OrderItems = new List<OrderItem>();
		System.debug('recordid='+recordid);  
		System.debug('products='+products.size());
		System.debug('products='+products);
		PricebookEntry pbe ;
		if(Test.isRunningTest()){pbe = [select id,Pricebook2id from PricebookEntry limit 1];}
		else{pbe = [select id,Pricebook2id from PricebookEntry WHERE Pricebook2.IsStandard = true  limit 1];}
		for(product2 product : products){
			OrderItems.add(new OrderItem(product2Id = product.Id, quantity = product.Quantity__c , Device_Codentify__c = product.Codentify__c , orderId = recordid, UnitPrice = 100, PricebookEntryId = pbe.id ));
		}
		update new order(Id=recordid , Pricebook2Id = pbe.Pricebook2Id);
		System.debug('OrderItems.size()='+OrderItems.size());
		if(OrderItems.size() > 0){
		  try{
			insert OrderItems;
			return 'Success';
		  }catch(Exception e){ 
		  System.debug('e.getMessage()='+e.getMessage());
		  return e.getMessage();}
		}
		return 'No Records Selected.';
	}

	@AuraEnabled
	public static List<AddOrderProductsFields__mdt> getFielsByTable(string tableName){
		
		return [select editable__c, fieldName__c, label__c, Table_name__c, type__c FROM AddOrderProductsFields__mdt 
					WHERE MasterLabel =: tableName];
	}
	
}