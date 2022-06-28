public class SafeChargeResponseSuccessCtrl extends SafeChargeResponseCtrl {

    public SafeChargeResponseSuccessCtrl(){
       system.debug('Success Page ');
       setSuccess();
    }
    /*
    public override void init()
    {
       super.init();
       
    }
    */
    public override void handleResponse()
    {
      System.debug('in handleResponse');
	   boolean isMatch = super.verifyCheckSum();
      if(!isMatch){
		  this.orderToUpdate.put('SC_Error_Message__c','Error in Checksum calculation');
      }
    }

}