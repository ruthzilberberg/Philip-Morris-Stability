/****************************************************************************************
Name              : AccountTriggerHelper_Test
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Yoella Bourshan           23/06/2019               Ella Bernachik     [SW-33815] QA-001770 Set Relate promotion to false + QA-001799 Not preventing more than one personal code
2. Ori                       10/10/2019               Ella Bernachik     [SW-34817]
3. Dor Malka                   09/06/2020            Aya  Toledano           [SW-37610]
----------------------------------------------------------------------------------------*/

@isTest
private class AccountTriggerHelper_Test {

    @TestSetup
    static void mySetup(){
        insert new List<Promotion__c>{
            new Promotion__c(status__c = 'Open', Promotion_Code__c ='5511', Type__c = 'Personal Code'),
            new Promotion__c(status__c = 'Open', Promotion_Code__c ='1234', Type__c = 'Personal Code'),
            new Promotion__c(status__c = 'Open', Promotion_Code__c ='12345', Type__c = 'Personal Code')
        };
    //Here is the problem
		Lead ld = new Lead(LastName='Test', DCS_ID__c = 'DCS Test 1234', Email = 'MyEmai@GMAIL.COM' ,
         ID__c ='051317576',
         Zip_Postal_Code__c='ABC' );
		Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Order_Product__c = true,Account__c = true);
        insert vr;
        //Lead ld2 = new Lead(LastName='Test2', DCS_ID__c = 'DCS Test 123', Email = null , ID__c ='020007969' );
        //insert ld2;

        Lead ld3 = new Lead(LastName='Test3', DCS_ID__c = 'DCS Test 12', Email = 'MyEmai@GMAIL.COM' , ID__c ='051067049' );
        insert new List<Lead>{ld,ld3};
                
        Account acc = new Account(lastName = 'acc Test2',  PersonBirthdate=Date.newInstance(1989, 9, 28), PersonEmail = 'MyEmai@GMAIL.COM', Terms_and_Conditions__pc=true, Personal_Promotion_Code__pc='5511');
        acc.ID__pc = '051317576';
        Account acc2 = new Account(LastName='AccountTest2',PersonBirthdate=Date.newInstance(1999, 9, 28),Id__pc='051067049');
        insert new List<Account>{acc,acc2};


        Product2 prd = new Product2(Name='prdTest',ProductCode='BlaBla',Device_Product__c=true, Product_Generation__c='2.4', Sub_Product_Generation__c='+');
        //insert  prd;
        Product2 prd1 = new Product2(Name='prdTest',ProductCode='BlaBla2',Device_Product__c=true, Product_Generation__c='2.4', Sub_Product_Generation__c='+');
        insert new List<Product2>{prd,prd1};

        
        Asset ass1 = new Asset(Name = 'Test',PurchaseDate = System.today(), AccountId = acc2.Id, Product2Id=prd.Id);
        //insert ass1;
        Asset ass2 = new Asset(Name = 'Test2',PurchaseDate = System.today(), AccountId = acc2.Id, Product2Id=prd1.Id);
        insert new List<Asset>{ass1,ass2};       
    }
 
    @isTest
    private static void update_Test() {
        Account acc = [SELECT Id,DCS_ID__c,LastName,ID__pc,Convert__c  FROM Account WHERE LastName = 'acc Test2' LIMIT 1];

        acc.ID__pc='020007969';
        acc.dcs_Id__c =  'DCS Test 123';
        acc.Convert__c =true;
        acc.Relate_Promotion__pc = true; //QA-001799
        update acc;
    }
    


    @isTest
    private static void IdInvalide_Test() {
        Test.startTest();
        try {
            Account acc = new Account(lastName = 'acc Test2 ',ID__pc='0513175', PersonBirthdate = system.today().addYears(-22), PersonEmail = 'MyEmai@GMAIL.COM', Terms_and_Conditions__pc=true,Personal_Promotion_Code__pc='5511' );
            insert acc;
        }catch (Exception e){
           System.debug( 'e.getMessage()  ' + e.getMessage() );
           System.assertEquals(e.getMessage().contains('Please enter a valid ID'),true);
        }
        try {
            Account acc = new Account(lastName = 'acc Test2 ',ID__pc='051317585446', PersonBirthdate = system.today().addYears(-22), PersonEmail = 'MyEmai@GMAIL.COM', Terms_and_Conditions__pc=true,Personal_Promotion_Code__pc='5511' );
            insert acc;
        }catch (Exception e){
            System.debug( 'e.getMessage()  ' + e.getMessage() );
            //System.assertEquals(e.getMessage().contains('Please enter a valid ID'),true);
        }
        Test.stopTest();
    }
	
	 @isTest
    private static void AsynqAcc_Test() {
        Test.startTest();
      insert new Promotion__c(status__c = 'Open', Promotion_Code__c ='5555', Type__c = 'Benefit');
            Account acc = [select id FROM Account WHERE PersonEmail = 'MyEmai@GMAIL.COM' limit 1];
			//acc.Promotion_Code__pc=null;
			//acc.MGM_PROMO_CODE__c=null;

			
			//update acc;
			//acc.Promotion_Code__pc='5511';
			acc.MGM_PROMO_CODE__c='5555';
			acc.Personal_Promotion_Code__pc='5555';
			try{
				update acc;
			}catch(Exception e){}
       
        
        Test.stopTest();
    }
	 @isTest
    private static void AsynqAcc_Test2() {
        Test.startTest();
		insert new Promotion__c(status__c = 'Open', Promotion_Code__c ='5556', Type__c = 'Benefit');
        insert new Promotion__c(status__c = 'Active', Promotion_Code__c ='123456', Type__c = 'Personal Code');
        Account acc2 = new Account(lastName = 'acc1 Test2', PersonBirthdate = system.today().addYears(-22), PersonEmail = 'My2Emai@GMAIL.COM', Terms_and_Conditions__pc=true, Personal_Promotion_Code__pc='55115');
        acc2.ID__pc = '020007969';
 		acc2.MGM_PROMO_CODE__c = null;
        insert acc2;
        acc2.MGM_PROMO_CODE__c='123456';
        update acc2;
        Async_Acc_PromotionLogic promotionLogic = new Async_Acc_PromotionLogic(new List<Account>{acc2});
        promotionLogic.execute();
        /*Account acc = [select id FROM Account WHERE PersonEmail = 'MyEmai@GMAIL.COM' limit 1];
			//acc.Promotion_Code__pc=null;
			acc.MGM_PROMO_CODE__c=null;
			update acc;
			//acc.Promotion_Code__pc='5511';
			acc.MGM_PROMO_CODE__c='123456';
			//acc.Personal_Promotion_Code__pc='12345';
			update acc;
            */
        
        Test.stopTest();
    }

    @IsTest
    private static void CreateErrorForLeadConvertPartialFailed(){
         Account acc = [select id,lastName,PersonBirthdate,PersonEmail,Terms_and_Conditions__pc,Personal_Promotion_Code__pc FROM Account WHERE PersonEmail = 'MyEmai@GMAIL.COM' limit 1];
        //AccountTriggerHelper hepler=new AccountTriggerHelper();
       // helper.findAndConvertLeads_Future();

        System.debug('acc----->'+acc);
        acc.PersonEmail='MyEmai22@GMAIL.COM';
        update acc;

        
     
        
    }

	 @IsTest
    private static void verify_Test(){
         Account acc = [select id,lastName,PersonBirthdate,PersonEmail,Terms_and_Conditions__pc,Personal_Promotion_Code__pc FROM Account WHERE PersonEmail = 'MyEmai@GMAIL.COM' limit 1];

        System.debug('acc----->'+acc);
        
	    acc.GGID_Verified__c=false;
        update acc;
		 acc.GGID_Verified_Date__c =  system.now().addDays(400);
		 acc.GGID_Verified__c=true;
        update acc;
        
    }
    
    
    @IsTest
    static void testSchedualDeviceCount(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP,  new SchedualUpdateDevices());        
  
        Test.stopTest();
        
        updateDevicesCountBatch b = new updateDevicesCountBatch(); 
        Database.executebatch(b); 
    }

}