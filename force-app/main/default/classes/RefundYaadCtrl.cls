/****************************************************************************************
Name              : RefundYaadCtrl  
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Hanit                                             Ella              [SW-32182]
----------------------------------------------------------------------------------------*/
public class RefundYaadCtrl  
{
  
  private static ServiceCredential__c x_Settings;
  private static ServiceCredential__c getPaymentSettings(){
     if(x_Settings == null){
        x_Settings =  [Select Endpoint__c,FormMethod__c From ServiceCredential__c where Name= 'Yaad'][0];
     }
     return x_Settings;
  }

  public class OrderResponse extends Response
  {
       @AuraEnabled
       public String year {get; set;}
       @AuraEnabled
       public String month {get; set;}
       @AuraEnabled
       public String custId {get;set;}

       public OrderResponse(String msg,Boolean isSuccess, String year, String month, String custId){
          super(msg,isSuccess);
          this.year = year;
          this.month = month;
          this.custId = custId;
       }
       
  }

  public virtual class Response 
  {
     @AuraEnabled
     public String responseMessage {get; set;}
     @AuraEnabled
     public boolean isSuccess{get; set;}
     
     public Response(String msg,Boolean isSuccess){
        responseMessage = msg;
        this.isSuccess = isSuccess;
     }
      
  }

  @AuraEnabled 
  public static OrderResponse getDefaultValues(Id OrderId){
     OrderResponse ordRes;
     try{
         ordRes = new OrderResponse(null,true,null,null,null);
         Order ord = [Select Id,OriginalOrderId,OriginalOrder.Yaad_Sarig_Credit_Card_Expiration_Date__c,Parent_Order__r.Account.ID__pc,Parent_Order__c,OrderNumber,Parent_Order__r.Yaad_Sarig_Credit_Card_Expiration_Date__c,RecordType.DeveloperName,Type From Order where Id=: OrderId][0];
         if(ord.RecordType.DeveloperName.equalsIgnoreCase('Regular_Order') && String.isNotBlank(ord.Type) && ord.Type.equalsIgnoreCase('Complete Renting Order') && ord.Parent_Order__r != null)
         //if(ord.RecordType.DeveloperName.equalsIgnoreCase('Return_Order') && String.isNotBlank(ord.Type) && !ord.Type.equalsIgnoreCase('Return Renting') && ord.Parent_Order__r != null)
         {
            String expDate = ord.Parent_Order__r.Yaad_Sarig_Credit_Card_Expiration_Date__c;
            if(String.isNotBlank(expDate)){
                ordRes = new OrderResponse(null,true,'20' + expDate.left(2),expDate.right(2),ord.Parent_Order__r.Account.ID__pc);
            }
         }
     }
     catch(Exception ex){
        System.debug('ex = ' + ex + ' stack trace = ' + ex.getStackTraceString());
        ordRes = new OrderResponse(ex.getMessage(),false,null,null,null);
     }
     return ordRes;
  }
  
  private static User currUser = [Select Id,Yaad_Sarig_Terminal_Number__c From User where Id=:UserInfo.getUserId()];
  
  @AuraEnabled
  public static Response getOrderData(Id OrderId,String Cvv,String ExpMonth,String ExpYear, String CustomerId,String SuccessVal,String FailureVal){
        
        boolean isSuccess = true;
        string requestType= '';
        try{
            System.debug('OrderId = ' + OrderId);
            Order ord = [Select Id,OriginalOrderId,Parent_Order__c,Parent_Order__r.Yaad_Sarig_Terminal_Number__c,OrderNumber,Total_Amount__c,Total_Amount_Abs__c,RecordType.DeveloperName,Type From Order where Id=: OrderId][0]; 
            Map<String,String> attMap = new Map<String,String>();
            Id parentId = ord.OriginalOrderId;
            requestType = 'Refund';
            //FROM UAT - NOT NEEDED -- CHECK!!//
            if(ord.RecordType.DeveloperName.equalsIgnoreCase('Regular_Order') && String.isNotBlank(ord.Type) && ord.Type.equalsIgnoreCase('Complete Renting Order')){
                parentId = ord.Parent_Order__c;
                requestType = 'Token Based Charge';
            }
                                
            if(Test.isRunningTest() == false){
                attMap =  FieldMappingHandler.getAttributeMap(parentId,'YaadPayment','isRefund__c');
            }
            if(!requestType.equalsIgnoreCase('Refund'))
            {
               attMap.remove('zPass');
               attMap.put('Masof',currUser.Yaad_Sarig_Terminal_Number__c);
            }
            attMap.put('cvv',Cvv);
            //attMap.put('Tyear','20' + Tokef.right(2));
            //attMap.put('Tmonth',Tokef.left(2));
            attMap.put('Tyear',ExpYear);
            attMap.put('Tmonth',ExpMonth);
            attMap.put('Order',ord.OrderNumber);
            attMap.put('Info',ord.OrderNumber);
            attMap.put('Amount',String.valueOf(ord.Total_Amount_Abs__c));
            if(String.isNotBlank(CustomerId)){
              attMap.put('UserId',CustomerId); 
            }
            System.debug('attMap = ' + JSON.serialize(attMap)); 
            String productsParam = PaymentYaadCtrl.BuildProductsParam(OrderId);
            attMap.put('heshDesc',productsParam);
            System.debug('heshDesc = ' + productsParam);
            String paramsToSend = FieldMappingHandler.ConvertMapToString(attMap,false);
            ServiceCredential__c settings = getPaymentSettings();
            isSuccess = sendPostReq(settings.Endpoint__c,paramsToSend,settings.FormMethod__c,ord.Id,SuccessVal,FailureVal);
            System.debug('paramsToSend = ' + paramsToSend);
        }catch(Exception e){
           isSuccess = false;
           update new Order(Id= OrderId,Bypass_VR__c = true,Integration_Status__c = 'Failed',Integration_Error__c = 'Error during ' + (String.isNotBlank(requestType) ? requestType : '') + ' request : ' + e.getMessage());
           update new Order(Id = OrderId,Bypass_VR__c = false);
        }
        
        return new Response(isSuccess ? 'Success' : 'Error',isSuccess); 

  }

  public static boolean sendPostReq(String endPoint,String bodyParams,String method,Id ordId,String successVal,String failureVal)
  {
        Boolean isSuccess = true;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        req.setEndpoint(endPoint);
        req.setBody(bodyParams);
        req.setMethod(method);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'text/html,application/xhtml+xml,application/xml');
     
        
        try 
        {
           System.debug('req = ' + req.getBody());
           resp = http.send(req);
           System.debug('resp = ' + resp.getBody());
           isSuccess = handleResponse(resp.getBody(),ordId,successVal,failureVal);
        }
        catch(System.CalloutException e) 
        {
           isSuccess = false;
           update new Order(Id= ordId,Bypass_VR__c = true,Integration_Error__c = ' Error during Refund Request : ' + e.getMessage());
           update new Order(Id = ordId,Bypass_VR__c = false);
        }
        
        return  isSuccess;            
  }
   @TestVisible
  private static boolean handleResponse(String responseParams,Id ordId,String successVal,String failureVal)
  { 
     Boolean isSuccess = true;
     try{
         Map<String,String> resultsMap = FieldMappingHandler.ConvertParamToMap(responseParams);
         String code = String.valueOf(resultsMap.get('CCode'));
         isSuccess = (code == '0');  
         Order orderToUpdate = (Order)(FieldMappingHandler.getObjectToUpdateByMapping(ordId,'YaadPayment',resultsMap,isSuccess,'isRefund__c'))[0];
         if(!isSuccess){
            orderToUpdate.put('Integration_Error__c',YaadResponseCtrl.getCodeMapping(code));
         }else{
            if(resultsMap.get('Amount') != null){
               Decimal amount = null;
               amount = Math.abs(Decimal.valueOf(resultsMap.get('Amount')));
               Decimal orderAmount = Math.abs([Select Total_Amount__c From Order where Id=:ordId][0].Total_Amount__c);
               if(orderAmount != amount){
               
                  orderToUpdate.put('Integration_Error__c','Error during Refund Request : order amount is different than payment amount\n Order amount :' + orderAmount + ' payment amount ' + amount);
                  isSuccess = false;
               }  
            }
         }
         orderToUpdate.put('Bypass_VR__c',true);
         if(isSuccess && String.isNotBlank(successVal)){
            orderToUpdate.put('Status',successVal);
         }
         else if(!isSuccess && String.isNotBlank(failureVal)){
            orderToUpdate.put('Status',failureVal);
         }
         update orderToUpdate;
         
     }catch(Exception e){
         isSuccess = false;
          update new Order(Id= ordId,Bypass_VR__c = true,Integration_Error__c = ' Error during Refund Request : ' + e.getMessage());
     }
     update new Order(Id = ordId,Bypass_VR__c = false);
     return  isSuccess;
     
  }
}