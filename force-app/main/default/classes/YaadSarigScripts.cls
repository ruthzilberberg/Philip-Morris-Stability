public class YaadSarigScripts {

@AuraEnabled
 public static string UpdateYaadSarigToken(String ordNumber, String masofNumber, String yaadTransactionNumber, String successStatus){
 
   try{
   if(String.isBlank(ordNumber) || String.isBlank(masofNumber) || String.isBlank(yaadTransactionNumber) || String.isBlank(successStatus)){
     return 'Required input missing - check order number, masof number, yaad transaction number, success Status';
   }
   String failureStatus = 'Failed';
   Order ord = [Select Id From Order where OrderNumber =:ordNumber][0];
   ServiceCredential__c settings = [Select Endpoint__c,FormMethod__c From ServiceCredential__c where Name= 'Yaad'][0];
    Map<String,String> attMap = FieldMappingHandler.getAttributeMap(ord.Id,'YaadPayment','isGetToken__c');
    //convert map to params
    attMap.put('Masof',masofNumber);
    String parametersToSend = FieldMappingHandler.ConvertMapToString(attMap,false);
    parametersToSend +='&TransId='+yaadTransactionNumber;
    system.debug('parametersToSend = ' + parametersToSend);
    Order orderToUpdate;
    HttpRequest req = new HttpRequest();
    req.setEndpoint(settings.Endpoint__c);
    req.setMethod(settings.FormMethod__c);
    req.setBody(parametersToSend);
    Http http = new Http();
    System.debug(' params =' + parametersToSend);
    HTTPResponse res = http.send(req);
    System.debug(' ress =' + res.getBody());
    System.debug(' req =' + req.toString());
    System.debug(' req body =' + req.getBody());
    Map<String,String> resultsMap = FieldMappingHandler.ConvertParamToMap(res.getBody());
    String code = String.valueOf(resultsMap.get('CCode'));
    Boolean isSuccess = (code == '0'); 
    orderToUpdate = (Order)(FieldMappingHandler.getObjectToUpdateByMapping(ord.Id,'YaadPayment',resultsMap,isSuccess,'isGetToken__c'))[0];
    if(isSuccess){
        orderToUpdate.put('Yaad_Sarig_Transaction__c',yaadTransactionNumber);
        orderToUpdate.put('Yaad_Sarig_Terminal_Number__c',masofNumber);
        orderToUpdate.put('Status',successStatus);
    } 
    if(!isSuccess){
      orderToUpdate.put('Integration_Error__c',YaadResponseCtrl.getCodeMapping(code));
      orderToUpdate.put('Status',failureStatus);
    }else{
    if(resultsMap.get('Amount') != null){
    Decimal amount = null;
    amount = Decimal.valueOf(resultsMap.get('Amount'));
    Decimal orderAmount = [Select Total_Amount__c From Order where Id=:orderToUpdate.Id][0].Total_Amount__c;
    if(orderAmount != amount){
      orderToUpdate.put('Integration_Error__c','Error during Pay Request : order amount is different than payment amount\n Order amount :' + orderAmount + ' payment amount ' + amount);
      orderToUpdate.put('Status',failureStatus);
    } 
    }
    }    
    orderToUpdate.Bypass_VR__c = true;
    System.debug(' orderToUpdate =' + orderToUpdate);
    update orderToUpdate;
    update new Order(Id = orderToUpdate.Id,Bypass_VR__c = false);
    System.debug(' resultsMap =' + resultsMap);
    return 'process complete - check order';
    }catch(Exception ex){
      system.debug('error = ' + ex + ' trace string ' + ex.getStackTraceString());
       return ' error : ' + ex.getMessage();
    }  
 }

}