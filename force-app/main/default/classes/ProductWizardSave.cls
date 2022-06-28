public with sharing class ProductWizardSave {

   public class ProductsException extends Exception {}

    public ProductWizardSave() {

    }

    public class SaveRequest{
      public string fssOwner;
      public string paymentMethod;
      public string promotionCode;
      public string orderId;
      public List<Product> selectedProducts;
    }
    public class OrderData{ 
      public string fssOwner;
      public string paymentMethod;
      public string promotionCode;
      public string orderId;

      public OrderData(string fssOwner,string paymentMethod,string promotionCode,string orderId){
              this.fssOwner = fssOwner;
              this.paymentMethod = paymentMethod;
              this.promotionCode = promotionCode;
              this.orderId = orderId;
      }
    }

    public class Product{
       public string productId;
       public string type;
       public decimal quantity;
       public string parentType;
       public string productBundleId;
       public string chain_id;
       public string DCS_Product_Id;
       public string DCS_Chain_ID;
       public string Product_type_Id;
       public boolean isOneChoose;
       public string codentify;
       public boolean isDevice;

    }
        public class Response{
             public boolean isSuccess;
             public string message;
             public Response(boolean isSuccess, string message){
                     this.isSuccess = isSuccess;
                     this.message = message;
             }  
        }
        

        public static HttpResponse SendWorkatoHtppRequest(String jsonBody){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Workato/getprices');
            req.setMethod('POST');
            req.setTimeout(60000);
            //req.setHeader('Accept', 'application/json');
            req.setHeader('API-TOKEN', '{!$Credential.Password}');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonBody);
            system.debug('req = ' + req + ' body = ' + req.getBody());
            HttpResponse res = h.send(req);
            system.debug('result = ' + res  + ' body = ' + res.getBody());
            return res;
        
        }
        
        public class WorkatoGetPrice{
          public string Type;
          public string UserDCS_Id;
          public string OrderId;
          public string PromotionCode;
          public string PriceBookId;
          
          public WorkatoGetPrice(string Type,string UserDCS_Id,string OrderId, string PromotionCode, string PriceBookId){
            this.Type= Type;
            this.UserDCS_Id = UserDCS_Id;
            this.OrderId = OrderId;
            this.PromotionCode = PromotionCode;
            this.PriceBookId = PriceBookId;
          }
          public WorkatoGetPrice(){}
        }
        
        @AuraEnabled 
        public static void UpdateProductsWorkato(Id ordId){
          Order ordToUpdate = new Order(Id= ordId, skip_get_prices__c = false,Get_Prices__c = false);
          try{
             Order ord = [Select Id,Type,Promotion_code__c,Pricebook2Id,Customer_DCS_Id__c From Order where Id=:ordId];
             WorkatoGetPrice jsonBody = new WorkatoGetPrice(ord.Type,ord.Customer_DCS_Id__c,ord.Id,ord.Promotion_code__c,ord.PriceBook2Id);
             String jsonBodyStr = JSON.serialize(jsonBody);
             system.debug('jsonBodyStr = ' + jsonBodyStr);
             HttpResponse res = SendWorkatoHtppRequest(jsonBodyStr);
             system.debug('result = ' + res  + ' body = ' + res.getBody() + 'res status = ' + res.getStatus() + ' code = ' + res.getStatusCode()); 
             Integer statusCode = res.getStatusCode();
             if(statusCode != 200){
                 ordToUpdate.Integration_Error__c = 'Error during Products wizard workato getprices request: status code : ' + statusCode + ' status = ' + res.getStatus();
                 ordToUpdate.Integration_Status__c = 'Failed';     
             }
          }catch(Exception ex){
            ordToUpdate.Integration_Error__c = 'Error during Products wizard = ' + ex.getMessage();
            ordToUpdate.Integration_Status__c = 'Failed';
          }
          update ordToUpdate;
        
        }
        
        @AuraEnabled
        public static String saveJson(String jsonProducts){

                ProductWizardSave.Response res = new ProductWizardSave.Response(true,'success');
                Id orderId;
                try{
                        System.debug('IN saveJson ----->');
                        System.debug('jsonProducts ------>'+jsonProducts);
                        

                        ProductWizardSave.SaveRequest jsonRes = (ProductWizardSave.SaveRequest)(Json.deserializeStrict(jsonProducts, ProductWizardSave.SaveRequest.class));
                        orderId = jsonRes.orderId;
                        //system.debug('json res = '+ jsonRes.selectedProducts);
                        updateOrder(new OrderData(jsonRes.fssOwner,jsonRes.paymentMethod,jsonRes.promotionCode,jsonRes.orderId));
                        createOrderProducts(jsonRes.selectedProducts,jsonRes.orderId);
                }catch(DmlException ex){
                    res.isSuccess = false;
                    res.message = ex.getdmlMessage(0);  
                }
                catch(Exception ex){
                    res.isSuccess = false;
                    res.message = ex.getMessage(); //add generic message from label    
                }
                //call workato
                //if(res.isSuccess){
                //    UpdateProductsWorkato(orderId);
                //}
                return Json.serialize(res);

        }
        private static PriceBook2 x_PriceBook;
        public static PriceBook2 getPriceBook(){
            if(x_PriceBook == null){
                x_PriceBook = [Select Id From PriceBook2 where isActive = true Limit 1][0];    
            }
            return  x_PriceBook;   
        }
        public static void updateOrder(OrderData orderDetail){
                System.debug('IN update Order----->');
                Order ordToUpdate = new Order(Pricebook2Id = getPriceBook().Id, Id= orderDetail.orderId,Promotion_code__c = orderDetail.promotionCode,Payment_Method__c = orderDetail.paymentMethod,skip_get_prices__c=true);
                
                if(String.isBlank(orderDetail.fssOwner)){
                   ordToUpdate.FSS_Owner__c=null;
                }else{
                  ordToUpdate.FSS_Owner__c = orderDetail.fssOwner;
                }
                System.debug('ordToUpdate ' + ordToUpdate);
                update ordToUpdate;
        }


public static void createOrderProducts(List<Product> selectedProducts, Id orderId){

            Set<id> ProdIds = new Set<id>();
          

            for(Product curSelectedProduct : selectedProducts){
                    System.debug('SelectProduct: '+curSelectedProduct);
                                        
                 if(!String.isBlank(curSelectedProduct.Product_type_Id)){
                          // for Intro Kit variants products  
                         if(!ProdIds.contains(curSelectedProduct.Product_type_Id)){
                             ProdIds.add(curSelectedProduct.Product_type_Id);
                           }
                           //insert the bundle(chain) id to the set
                           if(!ProdIds.contains(curSelectedProduct.chain_id)){
                                ProdIds.add(curSelectedProduct.chain_id);    
                           }
                 }
                 //for regular products(Heets Kits Accesso... )
                 else{
                         if(!ProdIds.contains(curSelectedProduct.ProductId)){
                             ProdIds.add(curSelectedProduct.ProductId);
                           }  
                 }   

                    
                     
            }
            System.debug('ProdIds  ----->'+ProdIds);
            System.debug('ProdIds size ----->'+ProdIds.size()); 

              

        Map<String,PricebookEntry> productId_PricebookEntry_map= new Map<String,PricebookEntry>();
        Id pbId = getPriceBook().Id;
        Map<Id,PricebookEntry> PBE_map = new  Map<Id,PricebookEntry>([SELECT id,Product2Id, UnitPrice, 
         ProductCode,Product_ID__c FROM PricebookEntry WHERE Product2Id IN : ProdIds And PriceBook2Id =:pbId And IsActive = true]); //add isActive 

        System.debug('PBE_map----->'+PBE_map);

        for(PricebookEntry pbe :PBE_map.values()){

                String productId=pbe.Product2Id;
                productId_PricebookEntry_map.put(productId,pbe);

        }

        System.debug('productId_PricebookEntry_map----->'+Json.serialize(productId_PricebookEntry_map));




        List<OrderItem> mainProducts = new List<OrderItem>();
        Set<String> chains_created= new Set<String>();
        Map<String,OrderItem> parentChain = new Map<String,OrderItem>();
        List<OrderItem> variants_to_insert = new List<OrderItem>();
        Map<Integer,String> variantIndx_parentChainId = new Map<Integer,String>();
        Integer variantIndx=0;
        for(Product curSelectedProduct : selectedProducts){
               
                //if the product isn't chain_variant
                String currentChainId = curSelectedProduct.chain_id;
                if (String.isBlank(currentChainId)){
                        OrderItem item = new OrderItem();
                         item.OrderId=orderId;  
                         if(!String.isBlank(curSelectedProduct.codentify)){
                           item.Device_Codentify__c=curSelectedProduct.codentify;
                         }
                         //fetch relevant data from pricebook -- in this case by curSelectedProduct.productId    
                          try{
                              PricebookEntry PBE= productId_PricebookEntry_map.get(curSelectedProduct.productId);
                              //add the pricebook data to the orderItem record;
                              item.PricebookEntryId=PBE.Id;
                              item.UnitPrice=PBE.UnitPrice;
                          }catch(Exception ex){
                             throw new ProductsException('Missing active pricebook entry for ' + curSelectedProduct.productId); 
                          }
                          
                          //item.Required_Product_Quantity_DSC__c=curSelectedProduct.quantity;
                          item.Quantity=curSelectedProduct.quantity;    
                          mainProducts.add(item);
                
                }else{
                    //get paretns to create
                    //create another list for the child with the parent index
                    
                    //create parent
                    if(!parentChain.containsKey(currentChainId)){
                               
                          OrderItem item = new OrderItem();
                          item.OrderId=orderId;   
                          item.DCS_Chain_ID__c=curSelectedProduct.DCS_Chain_ID;  
                          //fetch relevant data from pricebook -- in this case by curSelectedProduct.Product_type_Id       
                          try{
                              PricebookEntry PBE= productId_PricebookEntry_map.get(currentChainId);
                              item.PricebookEntryId=PBE.Id;
                              item.UnitPrice=PBE.UnitPrice;
                          }catch(Exception ex){
                            throw new ProductsException('Missing active pricebook entry for ' + currentChainId); 
                          }
                          //add the pricebook data to the orderItem record;
                          
                          
                           //Quantity one because always one parent kit      
                          //item.Required_Product_Quantity_DSC__c=1; 
                          item.Quantity=1;      
                          mainProducts.add(item);
                          parentChain.put(currentChainId,item) ;  
                    }
                    //create the child object (without id yet)
                        OrderItem parentItem =  parentChain.get(currentChainId);
                        OrderItem variantItem = new OrderItem();
                        variantItem.OrderId=orderId;        
                        variantItem.DCS_Chain_ID__c=curSelectedProduct.DCS_Chain_ID; 
                        
                        //this line emit the order item child to its parent.       
                        variantItem.ParentChainOrderProduct__c=parentItem.Id;
                        variantIndx_parentChainId.put(variantIndx,currentChainId);
                        //fetch relevant data from pricebook -- in this case by curSelectedProduct.productId    
                        try{    
                            PricebookEntry PBE= productId_PricebookEntry_map.get(curSelectedProduct.Product_type_Id);
                            //add the pricebook data to the orderItem record;
    
                            variantItem.PricebookEntryId=PBE.Id;
                            variantItem.UnitPrice=PBE.UnitPrice;
                        }catch(Exception ex){
                            throw new ProductsException('Missing active pricebook entry for ' + curSelectedProduct.Product_type_Id); 
                        }
                        

                        //Quantity one because always one variant of each type(door,heets etc... radio btn)     
                        //variantItem.Required_Product_Quantity_DSC__c=1; 
                        //SW-42210
                        if(curSelectedProduct.quantity != null)
                        //variantItem.Quantity=1;
                        variantItem.Quantity=curSelectedProduct.quantity;
                        else{
                          variantItem.Quantity=1;
                        }
                        //SW-42210 - End
                        // Codentify Addon 
                        if(curSelectedProduct.isDevice==true) variantItem.Device_Codentify__c=curSelectedProduct.codentify;
                        ///
                
                        variants_to_insert.add(variantItem);
                        variantIndx++;   

                }   
        }

       insert mainProducts;
       for(integer i=0;i<variants_to_insert.size();i++){
               String chainId = variantIndx_parentChainId.get(i);
               OrderItem pOrd = parentChain.get(chainId);
               system.debug('pOrd = ' + pOrd); 
               variants_to_insert[i].ParentChainOrderProduct__c = pOrd.Id;
       }
       insert variants_to_insert;

}

}