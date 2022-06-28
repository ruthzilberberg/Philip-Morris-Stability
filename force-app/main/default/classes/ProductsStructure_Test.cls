@isTest
public with sharing class ProductsStructure_Test {



    public ProductsStructure_Test() {

    }

    @TestSetup
    static void makeData(){

        Workflows_and_PB__c sc = new Workflows_and_PB__c(Order__c = true);
        insert sc;
        Validation_Rules_Switch__c vr = new Validation_Rules_Switch__c(Order__c = true,Account__c =true,On_Off_VRs__c = true,Order_Product__c = true);
        insert vr;
        
          Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),ID__pc  = '111111118');
          insert acc;
          id stndPB = Test.getStandardPricebookId();
          Order myOrder = new Order(AccountId = acc.Id, Status= 'Shipped', EffectiveDate = System.today(), Pricebook2Id = stndPB);
          insert myOrder;
        
        List<Product2> list_prod= new List<Product2>();
        
        Product2 prod_1 = new Product2(
            Name='Sleeve - Yellow',
            Product_Screen_Type__c='Sleeve',
            Quantity__c=0,
            IsActive=true,
            Color__c='blue',
            DCS_Chain_ID__c='AA11'
        ); 
        Product2 prod_2 = new Product2(
            Name='Sleeve - Blue',
            Product_Screen_Type__c='Sleeve',
            Quantity__c=0,
            IsActive=true,
             Color__c='red'
        ); 
        Product2 prod_3 = new Product2(
            Name='Cap - Green',
            Product_Screen_Type__c='Cap',
            Quantity__c=0,
            IsActive=true,
             Color__c='green'
        ); 
        Product2 prod_4 = new Product2(
            Name='Packet - Green',
            Product_Screen_Type__c='Heets',
            Quantity__c=0,
            IsActive=true,
             Color__c='blue',
            DCS_Chain_ID__c='12345'
        ); 
        Product2 prod_5 = new Product2(
            Name='Packet - Green',
            Product_Screen_Type__c='Kit',
            Quantity__c=0,
            IsActive=true,
             Color__c='green'
        ); 
        Product2 prod_6 = new Product2(
            Name='Cleaning stick - white',
            Product_Screen_Type__c='Cleaning stick',
            Quantity__c=0,
            IsActive=true,
            Color__c='white'
        ); 

        //////////////
        // Chains////
        ////////////
        
        Product2 prod_7 = new Product2(
            Name='IQOS 3 + 1 Packet',
            Product_Screen_Type__c='Chain',
            Quantity__c=1,
            IsActive=true,
            DCS_Chain_ID__c='CCBB11'
            
        ); 
        
        Product2 prod_8 = new Product2(
            Name='IQOS 3 + 5 Packet',
            Product_Screen_Type__c='Chain',
            Quantity__c=1,
            IsActive=true,
             DCS_Chain_ID__c='CCBB22'
            
        ); 

        //// first insert Product

        list_prod.add(prod_1);
        list_prod.add(prod_2);
        list_prod.add(prod_3);
        list_prod.add(prod_4);
        list_prod.add(prod_5);
        list_prod.add(prod_6);
        list_prod.add(prod_7);
        list_prod.add(prod_8);
        
        insert list_prod;

        /// Now insert Chain_Products__c (Level 2)
           Chain_Products__c chain_prod_1= new Chain_Products__c(
            Name='IQOS',
            Display_Name__c='IQOS',
            Repeat_Selection__c=1,
            Chain__c=prod_7.Id,
            Type__c='ProductGroup',
            Quantity__c=1,
            Selection_Attribute__c='Color',
             Active__c=true

        );
           Chain_Products__c chain_prod_2= new Chain_Products__c(
            Name='Heets',
            Display_Name__c='Heets',
            Repeat_Selection__c=3,
            Chain__c=prod_7.Id,
            Type__c='ProductGroup',
            Quantity__c=1,
            Selection_Attribute__c='Color',
            Active__c=true
            
        );
           Chain_Products__c chain_prod_3= new Chain_Products__c(
            Name='Heets',
            Display_Name__c='Heets',
            Repeat_Selection__c=5,
            Chain__c=prod_8.Id,
            Type__c='ProductGroup',
            Quantity__c=1,
            Selection_Attribute__c='Color',
            Active__c=true
            
        );

        insert chain_prod_1;
        insert chain_prod_2;
        insert chain_prod_3;

    /// Now insert Chain_Products_Variants__c (Level 3)


        Chain_Product_Variant__c chain_prod_variant_1 = new Chain_Product_Variant__c(
        Name='IQOS Blue',
        Price__c=100,
        Active__c=true,
        Chain_Product__c=chain_prod_1.Id,
        Chain__c=prod_7.Id
        
        
    );

    
    Chain_Product_Variant__c chain_prod_variant_2 = new Chain_Product_Variant__c(
        Name='Heets Green',
        Price__c=100,
        Active__c=true,
        Chain_Product__c=chain_prod_2.Id,
        Chain__c=prod_7.Id
                
    );
    Chain_Product_Variant__c chain_prod_variant_3 = new Chain_Product_Variant__c(
        Name='Heets Yellow',
        Price__c=100,
        Active__c=true,
        Chain_Product__c=chain_prod_2.Id,
        Chain__c=prod_7.Id
                
    );
    Chain_Product_Variant__c chain_prod_variant_4 = new Chain_Product_Variant__c(
        Name='Heets Pink',
        Price__c=100,
        Active__c=true,
        Chain_Product__c=chain_prod_2.Id,
        Chain__c=prod_7.Id
                
    );
    Chain_Product_Variant__c chain_prod_variant_5 = new Chain_Product_Variant__c(
        Name='Heets Blue',
        Price__c=100,
        Active__c=true,
        Chain_Product__c=chain_prod_2.Id,
        Chain__c=prod_7.Id
                
    );




        Chain_Product_Variant__c chain_prod_variant_6 = new Chain_Product_Variant__c(
        Name='Special',
        Price__c=100,
        Active__c=true,
        Chain_Product__c=chain_prod_3.Id,
        Chain__c=prod_8.Id
        
        
    );


    insert chain_prod_variant_1;
    insert chain_prod_variant_2;
    insert chain_prod_variant_3;
    insert chain_prod_variant_4;
    insert chain_prod_variant_5;
    insert chain_prod_variant_6;
  

    }

    @IsTest
    static void check(){

        
        String productChannelField='';
        List<Order> ords = [Select Id From Order Limit 1];
        String response= ProductsStructure.getJson(ords[0].Id);


     
    }







}