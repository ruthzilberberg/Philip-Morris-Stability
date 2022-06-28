public abstract class YaadResponseCtrl {

  public Map<String,String> pageParams;
  private boolean isSuccess;
  public Order orderToUpdate;
  public Order ord;
  
  public YaadResponseCtrl()
  {
       pageParams = apexpages.currentpage().getparameters();
       system.debug('pageParams = ' + pageParams);
	   isSuccess= false;
  }
  
  public void setSuccess()
  {
     isSuccess = true;
  }
  
  public void setFailure()
  {
     isSuccess = false;
  }

  public virtual void init()
  {
      getsObjectToUpdate();
  }
  public virtual void getOrder()
  {
         String ordnumber = pageParams.get('order');
		 system.debug('ordnumber = ' + ordnumber);
		 ord = [Select Id FROM Order WHERE  OrderNumber = :ordnumber Limit 1];
  }
  public virtual void getsObjectToUpdate()
  {
     //Order ord;
	 try{
		 getOrder();
		 orderToUpdate = (Order)FieldMappingHandler.getObjectToUpdateByMapping(ord.Id,'YaadPayment',pageParams,isSuccess,'isPay__c')[0];
		 handleResponse();
		 system.debug('orderToUpdate = ' + orderToUpdate);
		 update orderToUpdate;
	 }catch(Exception e)
	 {
	    System.debug('error = ' + e + 'stackTrace = ' + e.getStackTraceString());
		if(ord != null){
			update new Order(Id= ord.Id,Integration_Error__c = ' Error during Response : ' + e.getMessage());
		}
		
	 }
  }

  public abstract void handleResponse();

  private ServiceCredential__c x_Settings;
  public ServiceCredential__c getPaymentSettings(){
     if(x_Settings == null){
        x_Settings =  [Select Endpoint__c,FormMethod__c From ServiceCredential__c where Name= 'Yaad'][0];
     }
     return x_Settings;
  }

  public static String getCodeMapping(String code)
  {
		//String code = pageParams.get('CCode');
		Integer codeNumber;
		List<PaymentResponseCode__mdt> paymentcodeDesc;
		
		if(String.isNotBlank(code)){
		  codeNumber = Integer.valueOf(code);
		  paymentcodeDesc = [Select Description__c,Remarks__c,Description_in_hebrew__c,Remarks_in_hebrew__c,Code__c,Type__c From PaymentResponseCode__mdt where Code__c =: codeNumber]; //Or MasterLabel = 'GeneralError'];// Order By Code__c NULLS LAST];
		}
		if(paymentcodeDesc == null || paymentcodeDesc.isEmpty()){
			paymentcodeDesc = [Select Description__c,Remarks__c,Description_in_hebrew__c,Remarks_in_hebrew__c,Code__c,Type__c From PaymentResponseCode__mdt where MasterLabel = 'GeneralError'];
		}
		//2 SOQL because of sf error when trying together
		System.debug('paymentcodeDesc = '+ paymentcodeDesc);
		String val;
		if(String.isNotBlank(paymentcodeDesc[0].Description__c) || String.isNotBlank(paymentcodeDesc[0].Remarks__c)){
			val = paymentcodeDesc[0].Description__c + '\n' +  (String.isNotBlank(paymentcodeDesc[0].Remarks__c) ? paymentcodeDesc[0].Remarks__c : '');
		}
		else{
			val = paymentcodeDesc[0].Description_in_hebrew__c + '\n' + (String.isNotBlank(paymentcodeDesc[0].Remarks_in_hebrew__c)? paymentcodeDesc[0].Remarks_in_hebrew__c : '');
		}
		if(paymentcodeDesc[0].Code__c == null){
		  val += '\nCCode val : ' + code;
		}
		return val;
  }



  
   


   
    
}