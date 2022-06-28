/****************************************************************************************
Name              : AssetTrigger_Test
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------*/
@isTest
private class AssetTrigger_Test {


    @TestSetup
    static void setup(){
        Account acc = new Account(LastName='AccountTest',PersonBirthdate=Date.newInstance(1989, 9, 28),Id__pc='020007969');
        //insert acc;



        Account acc2 = new Account(LastName='AccountTest2',PersonBirthdate=Date.newInstance(1999, 9, 28),Id__pc='051067049');
        insert new List<Account>{acc,acc2};

        Product2 prd = new Product2(Name='prdTest',ProductCode='BlaBla',Device_Product__c=true, Product_Generation__c='2.4', Sub_Product_Generation__c='+', EOW_Usage__c = true);
        //insert  prd;
        Product2 prd1 = new Product2(Name='prdTest',ProductCode='BlaBla2',Device_Product__c=true, Product_Generation__c='2.4', Sub_Product_Generation__c='+', EOW_Usage__c = true);
        insert new List<Product2>{prd,prd1};

        Asset ass1 = new Asset(Name = 'Test',PurchaseDate = System.today(), AccountId = acc.Id, Warranty_Due_Date__c = System.today().addDays(3), Product2Id=prd.Id,Active__c = true);
        //insert ass1;
        Asset ass2 = new Asset(Name = 'Test2',PurchaseDate = System.today(), AccountId = acc.Id, Warranty_Due_Date__c = System.today().addDays(3), Product2Id=prd1.Id,Active__c = true);

        Asset ass3 = new Asset(Name = 'Test2',PurchaseDate = System.today(), AccountId = acc.Id);

        Asset ass4 = new Asset(Name = 'Test4',PurchaseDate = System.today(), AccountId = acc.Id);
       
	    Asset ass5 = new Asset(Name = 'Test4',PurchaseDate = System.today(), AccountId = acc.Id, Integration_Error__c = '400:INVALID_CODENTIFYID - Invalid Codentify ID');

        insert new List<Asset>{ass1, ass2, ass3, ass4, ass5};        
    }

    @isTest
    private static void updateProductTest() {
        Account acc2 = [SELECT Id,Numbers_of_Devices_EOW__c FROM Account WHERE LastName = 'AccountTest2' LIMIT 1];

        Asset ass2 = [SELECT Id, AccountId,Product2Id FROM Asset WHERE Name = 'Test2' LIMIT 1];



        Test.startTest();
            ass2.AccountId = acc2.Id;
            ass2.Origin_Product_Code__c = 'Test';
            update ass2;

            acc2 = [select Id,Numbers_of_Devices_EOW__c From Account where Id =: acc2.Id][0];

            delete ass2;

        Test.stopTest();

        acc2 = [select Id,Numbers_of_Devices_EOW__c From Account where Id =: acc2.Id][0];
        
    }
    
}