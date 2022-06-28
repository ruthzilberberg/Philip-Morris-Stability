/****************************************************************************************
Name              : PaymentYaadCtrl  
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Hanit                                             Kiril              [SW-32135]
----------------------------------------------------------------------------------------*/
public class PaymentYaadCtrl  
{
  
  

  
  public class OrderWrapper
  {
    
        @AuraEnabled
        public String endpoint {get; set;}
        @AuraEnabled
        public String frmMethod {get; set;}
        @AuraEnabled
        public Map<String,String> attMap{get; set;}
        @AuraEnabled
        public Boolean openInIframe {get;set;}
        @AuraEnabled
        public String responseMessage {get; set;}
        @AuraEnabled
        public boolean isSuccess{get; set;}
            

    
        public OrderWrapper(Map<String,String> attMap, String endpoint, String frmMethod,boolean openInIframe,boolean isSuccess,String responseMessage)
        {
            this.attMap = attMap;
            this.endpoint = endpoint;
            this.frmMethod = frmMethod;
            this.openInIframe = openInIframe;
            this.isSuccess = isSuccess;
            this.responseMessage =  responseMessage;
        }

        public OrderWrapper(String responseMessage,boolean isSuccess)
        {
            this.isSuccess = isSuccess;
            this.responseMessage =  responseMessage;
        }

  }
  private static ServiceCredential__c x_Settings;
  private static ServiceCredential__c getPaymentSettings(){
     if(x_Settings == null){
        x_Settings =  [Select Endpoint__c,OpenInIframe__c,Key__c,Password__c,FormMethod__c,Cash_FormMethod__c,Default_UserId__c From ServiceCredential__c where Name= 'Yaad'][0];
     }
     return x_Settings;
  }


  
  public static Map<String,String> getAttMap(Id OrderId,String Method)
  {
        ServiceCredential__c settings = getPaymentSettings();
        User currentUser = [Select Id,Yaad_Sarig_Terminal_Number__c From User where Id=: UserInfo.getUserId() Limit 1][0];
        System.debug('currentUser = ' + currentUser);
        System.debug('OrderId = ' + OrderId);
        if(Method == 'isPay__c'){
            update new Order(Id = OrderId, Yaad_Sarig_Terminal_Number__c = currentUser.Yaad_Sarig_Terminal_Number__c);
        }
        Map<String,String> attMap =  FieldMappingHandler.getAttributeMap(OrderId,'YaadPayment',Method);
        if(Method == 'isCash__c'){
          attMap.put('Masof',currentUser.Yaad_Sarig_Terminal_Number__c);
          if(String.isBlank(attMap.get('UserId'))){
            attMap.put('UserId',settings.Default_UserId__c);
          }
          
        }
        String productsParam = BuildProductsParam(OrderId);
        system.debug('productsParam = ' + productsParam);
        attMap.put('heshDesc',productsParam);
        //ServiceCredential__c settings = getPaymentSettings();
        if(Method == 'isPay__c'){
            String res = SignParamsRequest(attMap,settings.Key__c);
            attMap.put('Signature',res);
        }
        return attMap;
  }
  
  @AuraEnabled
  public static OrderWrapper getOrderData(Id OrderId, String Method){
        Order ord = [Select Id,Status,Payment_Method__c,RecordType.DeveloperName From Order where Id=:OrderId][0];
        system.debug('ord status = ' + ord.Status);
        OrderWrapper ordWrapperToReturn;
        if(ord.Status != 'Ready to Process'){
          
            //return new OrderWrapper('',true);
            ordWrapperToReturn = new OrderWrapper('',true); 
        }
        else{
                String payMethodAction;
                System.debug('Method =  ' + Method);
                if(String.isNotBlank(ord.Payment_Method__c)) {
                    if(ord.Payment_Method__c.equalsIgnoreCase('cash'))
                    {   
                       payMethodAction = 'isCash__c';
                    }else if(ord.Payment_Method__c.equalsIgnoreCase('Credit Card')){
                        payMethodAction = 'isPay__c';
                    }
            
                }
                System.debug('payMethodAction =  ' + payMethodAction);
                System.debug('OrderId = ' + OrderId); 
                if(String.isNotBlank(payMethodAction)){
                    ordWrapperToReturn = PerformAction(OrderId,payMethodAction,ord.RecordType.DeveloperName);
                    ordWrapperToReturn =  ordWrapperToReturn == null ? new OrderWrapper('',true) : ordWrapperToReturn;
                }
                else{
                  ordWrapperToReturn = new OrderWrapper('',true); 
                }
                
        }
        return ordWrapperToReturn;
        /*switch on Method {
            when 'cash' {       
                payMethodAction = 'isCash__c';
            }   
            when 'credit' {     
                payMethodAction = 'isPay__c';
            }
            
        }*/

        
        
  }

  private static OrderWrapper PerformAction(Id OrderId,String Method, String RecordTypeName)
  {
        OrderWrapper orw;
        Boolean isSuccess = true;
        ServiceCredential__c settings = getPaymentSettings();
        Map<String,String> attMap = getAttMap(OrderId,Method);
        system.debug('Method = ' + Method );
        Order ord = [Select Payment_Method__c From Order where Id=:OrderId Limit 1][0];
        if(String.isNotBlank(ord.Payment_Method__c)) {
            if(ord.Payment_Method__c.equalsIgnoreCase('cash'))
            {
               System.debug('in cash ');
               String paramsToSend = FieldMappingHandler.ConvertMapToString(attMap,false);
               isSuccess = SendReq(settings.Endpoint__c,paramsToSend,settings.Cash_FormMethod__c,OrderId,'Cash',Method,attMap.get('Masof'),RecordTypeName);
               orw = new OrderWrapper(isSuccess ? 'Success' : 'Error',isSuccess); 

            }else if(ord.Payment_Method__c.equalsIgnoreCase('Credit Card')){
               System.debug('in credit');
               orw =  new OrderWrapper(attMap,settings.Endpoint__c,settings.FormMethod__c,settings.OpenInIframe__c,isSuccess,null);
            }
        }  
        
        System.debug('orw = ' + orw);
        return orw;
  }
   
   
 

   public static boolean SendReq(String endPoint,String bodyParams,String method,Id ordId, String reqType, String methodName, String masofNumber,String recordTypeName)
  {
        System.debug('bodyParams = ' + bodyParams);
        Boolean isSuccess = true;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        req.setEndpoint(endPoint);
        req.setBody(bodyParams);
        req.setMethod(method);
        req.setTimeout(15000);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json,application/x-www-form-urlencoded,text/html,application/xhtml+xml,application/xml');
     
        
        try 
        {
           resp = http.send(req);
           System.debug('resp = ' + resp.getBody());
           isSuccess = HandleResponse(resp.getBody(),ordId,reqType,methodName,masofNumber,recordTypeName,req,resp);
        }
        catch(System.CalloutException e) 
        {
           isSuccess = false;
           System.debug('Err = ' + e  + 'StackTrace = ' + e.getStackTraceString());
           update new Order(Id= ordId,Bypass_VR__c = true,Yaad_Sarig_Terminal_Number__c = masofNumber,Integration_Error__c = ' Error during callout ' + reqType + ' Request : ' + e.getMessage());
           update new Order(Id = ordId,Bypass_VR__c = false);
        }
        catch(Exception e){
           isSuccess = false;
           System.debug('Err = ' + e  + 'StackTrace = ' + e.getStackTraceString());
           update new Order(Id= ordId,Bypass_VR__c = true,Yaad_Sarig_Terminal_Number__c = masofNumber,Integration_Error__c = ' Error during ' + reqType + ' Request : ' + e.getMessage());
           update new Order(Id = ordId,Bypass_VR__c = false);
        }
        
        return  isSuccess;            
  }
   @TestVisible
  private static boolean HandleResponse(String responseParams,Id ordId,String reqType,String methodName, String masofNumber,String recordTypeName,HttpRequest req,HttpResponse resp)
  { 
     Boolean isSuccess = true;
     try{
         Map<String,String> resultsMap = FieldMappingHandler.ConvertParamToMap(responseParams);
         system.debug('resultsMap = ' + resultsMap);
         boolean ccodeParamExist = resultsMap.containsKey('CCode');
         String code = String.valueOf(resultsMap.get('CCode'));
         isSuccess = (code == '0');
         if(methodName == 'isCash__c'){
           if(recordTypeName == 'Return_Order'){
             methodName = 'isRefund__c';
           }
         }    
         Order orderToUpdate = (Order)(FieldMappingHandler.getObjectToUpdateByMapping(ordId,'YaadPayment',resultsMap,isSuccess,methodName))[0];
         orderToUpdate.put('Yaad_Sarig_Terminal_Number__c',masofNumber);
         
         if(!isSuccess){
            
            
            String calloutData = '\n Yaad Sarig response - ' + system.now().format()+ ' :\n' + 'status :' + resp.getStatus() + ' status code : ' + resp.getStatusCode() + '\nresponse body :\n\n' + responseParams;
            orderToUpdate.put('Integration_Error__c',YaadResponseCtrl.getCodeMapping(code));
             
            orderToUpdate.put('Integration_Error_Detailed__c',(ccodeParamExist?'':'Missing CCode param\n') + 'Request:\n'+ req.getBody() +'\nResponse:\n' + calloutData);// + '\nParams:\n' + Json.serialize(resultsMap));
            //(ccodeParamExist:''?'Missing CCode param\n') + 
         }else{
            if(resultsMap.get('Amount') != null){
               Decimal amount = null;
               amount = Math.abs(Decimal.valueOf(resultsMap.get('Amount')));
               Decimal orderAmount = Math.abs([Select Total_Amount__c From Order where Id=:ordId][0].Total_Amount__c);
               if(orderAmount != amount){
                  orderToUpdate.put('Integration_Error__c','Error during Pay Request : order amount is different than payment amount\n Order amount :' + orderAmount + ' payment amount ' + amount);
                  isSuccess = false;
               }  
            }
         }
         orderToUpdate.put('Bypass_VR__c',true);
         system.debug('orderToUpdate = ' + orderToUpdate);
         update orderToUpdate;
     }catch(Exception e){
          isSuccess = false;
          update new Order(Id= ordId,Bypass_VR__c = true,Yaad_Sarig_Terminal_Number__c = masofNumber,Integration_Error__c = ' Error during '+ reqType + ' Request : ' + e.getMessage());
     }
     update new Order(Id = ordId,Bypass_VR__c = false);
     return  isSuccess;
     
  }

  public static string BuildProductsParam(Id ordId)
  {
     //String productsParam = '';
     List<String> productsParamLst = new List<String>();
     List<OrderItem> orderItems = [Select Id,Product2.ProductCode,Product2.Name,Quantity,UnitPrice From OrderItem where OrderId =:ordId];
     for(OrderItem ordItm : orderItems){
        productsParamLst.add('[' + ordItm.Product2.ProductCode + '~' + ordItm.Product2.Name + '~' + ordItm.Quantity+ '~' + ordItm.UnitPrice+ ']'); //'~' +
     }
     return String.join(productsParamLst,'');
  }
  private static string SignParamsRequest(Map<String,String> attName_attVal,String key) {
               
        String message = rearrangeMap(attName_attVal,true);
        string signedResult = genrateSignature(message, key);
        System.debug('res = '  +signedResult);
        return signedResult;
  }

  private static string rearrangeMap(Map<string, string> attributesMap,boolean sortList)
  {
        attributesMap.remove('Sign');
        attributesMap.remove('signature');
        return FieldMappingHandler.ConvertMapToString(attributesMap,sortList);
  }
    public static String genrateSignature(String data,String key) {
            String salt = data;
            String secretKey = key;//'secret_key';
            String signature = generateHmacSHA256Signature(salt, secretKey);
            System.debug('Signature : '+signature);
            return signature;
        }

        private static String generateHmacSHA256Signature(String saltValue, String secretKeyValue) {
            String algorithmName = 'HmacSHA256';
            Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(saltValue), Blob.valueOf(secretKeyValue));
            return EncodingUtil.base64Encode(hmacData);
        }


  
  
  
    

}