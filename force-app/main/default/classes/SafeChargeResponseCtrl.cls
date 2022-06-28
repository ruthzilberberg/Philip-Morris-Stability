public abstract class SafeChargeResponseCtrl  {

  public Map<String,String> pageParams;
  private boolean isSuccess;
  private boolean isPending;
  public Order orderToUpdate;
  public Order ord;
  
  public SafeChargeResponseCtrl()
  {
       pageParams = apexpages.currentpage().getparameters();
       system.debug('pageParams = ' + pageParams);
       isSuccess= false;
       isPending = false;
  }
  
  public void setSuccess()
  {
     isSuccess = true;
  }
  
  public void setFailure()
  {
     isSuccess = false;
  }

  public void setPending()
  {
     isPending = true;
  }

  public virtual void init()
  {
      getsObjectToUpdate();
      
  }
  public virtual void getOrder()
  {
         String ordId = pageParams.get('customField1');
         system.debug('customField1 = ' + ordId);
         ord = [Select Id FROM Order WHERE  Id =:ordId Limit 1]; //verify customField1 is a valid orderId 
  }
  public virtual void getsObjectToUpdate()
  {
     //Order ord;
     try{
         String responseType = isPending ? 'pending' : ( isSuccess ? 'success' : 'failure'); 
         getOrder();
         orderToUpdate = (Order)FieldMappingHandler.getObjectToUpdateByMappingByReturnType(ord.Id,'SC_Order',pageParams,responseType,'isPay__c')[0];
         handleResponse();
         system.debug('orderToUpdate = ' + orderToUpdate);
         update orderToUpdate;
     }catch(Exception e)
     {
        System.debug('error = ' + e + 'stackTrace = ' + e.getStackTraceString());
        if(ord != null){
            update new Order(Id= ord.Id,SC_Error_Message__c = ' Error during Response : ' + e.getMessage());
        } 
     }
  }

  public virtual void handleResponse(){}

 private static ServiceCredential__c x_Settings;
	private static ServiceCredential__c PaymentSettings {
		get {
			if (x_Settings == null) { 
				x_Settings = [Select Endpoint__c, OpenInIframe__c, Key__c, AdditionalData__c,Password__c, FormMethod__c, Default_UserId__c From ServiceCredential__c where Name = 'SafeCharge'] [0];
			}
			return x_Settings;
		}
		set {
		}
	}


  public  Boolean  verifyCheckSum(){
     
      String checkSumAttributes = PaymentSettings.AdditionalData__c;
      List<String> attCheckSum;
      system.debug('checkSumAttributes = ' + checkSumAttributes);
      if(String.isBlank(checkSumAttributes)){
         return false;
      }
      attCheckSum = checkSumAttributes.split(',');
      //List<String> attCheckSum = new List<String>{'Key','totalAmount','Currency','responseTimeStamp','PPP_TransactionID','Status','productId'}; 
      List<String> checkSumLst = new List<String>{PaymentSettings.Key__c};
      for(String att : attCheckSum){
        if(pageParams.containsKey(att)){ //&& att != 'productId'){ 
            //String val = (String)EncodingUtil.urlEncode(pageParams.get(att), 'UTF-8');
            //String val = pageParams.get(att);
            checkSumLst.add(pageParams.get(att));
        }
      }
      
      system.debug('checkSumLst = ' + JSON.serialize(checkSumLst));
      //addItemsToCheckSumCalculation(checkSumLst);
      String checkSumString = String.join(checkSumLst,'');
      system.debug('checkSumString = ' + checkSumString);
      Blob hmacData = Crypto.generateDigest('SHA-256', Blob.valueOf(checkSumString));
      String res = EncodingUtil.convertToHex(hmacData);
      boolean isMatch = (res == pageParams.get('advanceResponseChecksum'));
      system.debug('res = ' + res);
      return isMatch;
  }
  /*
  public void addItemsToCheckSumCalculation(List<String> checkSumLst){

       //    ADD ITEMS PART
      system.debug('pageParams = ' + JSON.serialize(pageParams));
      List<String> attParamsOrdered = new List<String>(pageParams.keySet());
      attParamsOrdered.sort();
      system.debug('attParamsOrdered = ' + JSON.serialize(attParamsOrdered));
      boolean itemLstAdded = false;
      
      for(String attParam : attParamsOrdered){
         if(attParam.startsWithIgnoreCase('item_name_')){
            itemLstAdded = true;
            String val = (String)EncodingUtil.urlEncode(pageParams.get(attParam), 'UTF-8');
            checkSumLst.add(val);
         }else if(itemLstAdded){
            break;
         } 
      }
      system.debug('checkSumLst = ' + JSON.serialize(checkSumLst));
  }*/

  

}