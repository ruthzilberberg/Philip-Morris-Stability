public class YaadResponseSuccessCtrl extends YaadResponseCtrl  {

    public YaadResponseSuccessCtrl(){
       system.debug('Success Page ');
       setSuccess();
    }

    public override void init()
    {
       super.init();
       try{
            getToken();
       }catch(Exception e){
            System.debug('error = ' + e + 'stackTrace = ' + e.getStackTraceString());
            if(this.orderToUpdate != null){
                update new Order(Id= this.orderToUpdate.Id,Integration_Error__c = ' Error during token Request  : ' + e.getMessage());
            }
       }
    }
    /*
    public override void getOrder()
    {
         String ordnumber = pageParams.get('order');
         system.debug('ordnumber = ' + ordnumber);
         //ord = [Select Id,Yaad_Sarig_Last_Request_User__r.Yaad_Sarig_Terminal_Number__c FROM Order WHERE  OrderNumber = :ordnumber Limit 1];
    }*/
    public override void handleResponse()
    {
       String val = 'Error Code : ' + pageParams.get('CCode')+ 
                +'\nConfirmation Code : ' + pageParams.get('ACode') +
                +'\nAmount Charged : ' + pageParams.get('Amount');
       this.orderToUpdate.put('Yaad_Sarig_Transaction_Details__c',val);

       if(pageParams.get('Amount') != null){
               Decimal amount = null;
               amount = Decimal.valueOf(pageParams.get('Amount'));
               Decimal orderAmount = [Select Total_Amount__c From Order where Id=:this.orderToUpdate.Id][0].Total_Amount__c;
               if(orderAmount != amount){
                  this.orderToUpdate.put('Integration_Error__c','Error during Pay Request : order amount is different than payment amount\n Order amount :' + orderAmount + ' payment amount ' + amount);
               }  
        }
         
       
       //this.orderToUpdate.put('Yaad_Sarig_Terminal_Number__c',ord.Yaad_Sarig_Last_Request_User__r.Yaad_Sarig_Terminal_Number__c);
    }  
    public void getToken()
    {
       ServiceCredential__c settings = getPaymentSettings();
       Map<String,String> attMap =  FieldMappingHandler.getAttributeMap(this.orderToUpdate.Id,'YaadPayment','isGetToken__c');
       //convert map to params
       
       String parametersToSend = FieldMappingHandler.ConvertMapToString(attMap,false);//'action=getToken&Masof='+settings.Masof__c+'&PassP=PMI&TransId='+pageParams.get('Id');//+'&Fild3='+pageParams.get('order');
       parametersToSend += '&TransId='+pageParams.get('Id');
       tokenRequest(settings.Endpoint__c,settings.FormMethod__c,parametersToSend,this.orderToUpdate.Id); 
    }
    /*
    public class response
    {
      public String key;
      public String val;
    }*/
    @TestVisible
    @future(callout=true)
    private static void tokenRequest(String endpoint,String method,String params,Id orderId)
    {
         try{
             HttpRequest req = new HttpRequest();
             req.setEndpoint(endpoint);
             req.setMethod(method);
             req.setBody(params);
             Http http = new Http();
             System.debug(' params =' +  params);
             HTTPResponse res = http.send(req);
             System.debug(' ress =' +  res.getBody());
             Map<String,String> resultsMap = FieldMappingHandler.ConvertParamToMap(res.getBody());
             //System.debug(' resultsMap =' +  resultsMap);
             handleTokenResponse(resultsMap,orderId);
         }
         catch(Exception e){
            System.debug('error = ' + e + 'stackTrace = ' + e.getStackTraceString());
            if(orderId != null){
                update new Order(Id= orderId,Integration_Error__c = ' Error during Token Request : ' + e.getMessage());
            }            
         }
    }
    /*
    private static Map<String,String> convertParamToMap(String params)
    {
            List<String> paramsSplited = params.Split('&');
            Map<string, string> paramsMap = new Map<string, string>();
            for(String pr : paramsSplited)
            {
              List<string> keyVal = pr.Split('=');
              paramsMap.put(keyVal[0],keyVal.size()>1? keyVal[1] : '');
            }
            return paramsMap;
    }
    */
    
    private static void handleTokenResponse(Map<String, String> resultsMap,Id orderId){
        
             String code = String.valueOf(resultsMap.get('CCode'));
             Boolean isSuccess = (code == '0');  
             Order orderToUpdate = (Order)(FieldMappingHandler.getObjectToUpdateByMapping(orderId,'YaadPayment',resultsMap,isSuccess,'isGetToken__c'))[0];
             if(!isSuccess){
                orderToUpdate.put('Integration_Error__c',YaadResponseCtrl.getCodeMapping(code));
             }else{
               if(resultsMap.get('Amount') != null){
                   Decimal amount = null;
                   amount = Decimal.valueOf(resultsMap.get('Amount'));
                   Decimal orderAmount = [Select Total_Amount__c From Order where Id=:orderToUpdate.Id][0].Total_Amount__c;
                   if(orderAmount != amount){
                      orderToUpdate.put('Integration_Error__c','Error during Pay Request : order amount is different than payment amount\n Order amount :' + orderAmount + ' payment amount ' + amount);
                   }  
               }
             }
             //Order ord  = new Order(Id= orderId);
             /*
             if(code == '0') // success
             {
                ord.put('Yaad_Sarig_Payment_Token__c',resultsMap.get('Token'));
                ord.put('Yaad_Sarig_CC_Validity_Date__c',resultsMap.get('Tokef'));
             }
             else //failure
             {
                ord.put('Integration_Status__c','Failed');
                ord.put('Integration_Error__c',YaadResponseCtrl.getCodeMapping(code));
             }*/
             update orderToUpdate;
    }
    
}