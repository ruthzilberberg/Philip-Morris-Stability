public class YaadResponseErrorCtrl extends YaadResponseCtrl 
{
  public YaadResponseErrorCtrl(){
      setFailure();
  }

  public override void handleResponse()
  {
		/*
		String code = pageParams.get('CCode');
		Integer codeNumber;
		List<PaymentResponseCode__mdt> paymentcodeDesc;
		if(String.isNotBlank(code)){
		  codeNumber = Integer.valueOf(code);
		  paymentcodeDesc = [Select Description_in_hebrew__c,Remarks_in_hebrew__c,Code__c,Type__c From PaymentResponseCode__mdt where Code__c =: codeNumber]; //Or MasterLabel = 'GeneralError'];// Order By Code__c NULLS LAST];
		}
		if(paymentcodeDesc == null || paymentcodeDesc.isEmpty()){
			paymentcodeDesc = [Select Description_in_hebrew__c,Remarks_in_hebrew__c,Code__c,Type__c From PaymentResponseCode__mdt where MasterLabel = 'GeneralError'];
		}
		System.debug('paymentcodeDesc = '+ paymentcodeDesc);
		String val = paymentcodeDesc[0].Description_in_hebrew__c + '\n' + paymentcodeDesc[0].Remarks_in_hebrew__c;
		if(paymentcodeDesc[0].Code__c == null){
		  val += '\nCCode val : ' + code;
		}
		*/
		String val = YaadResponseCtrl.getCodeMapping(pageParams.get('CCode'));
		
		this.orderToUpdate.put('Integration_Error__c',val);
   }  
}