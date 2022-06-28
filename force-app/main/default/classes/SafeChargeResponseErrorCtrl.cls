public class SafeChargeResponseErrorCtrl  extends SafeChargeResponseCtrl {

    public SafeChargeResponseErrorCtrl(){
       system.debug('Error Page ');
       setFailure();
    }
    /*
    public override void init()
    {
       super.init();
    }
    */
    public override void handleResponse()
    {       
       //SYSTEM.DEBUG('page params = ' + JSON.serializePretty(pageParams));
       if(pageParams.containsKey('Status') && pageParams.get('Status') != null && pageParams.get('Status').equalsIgnoreCase('Declined'))
       {
         boolean isMatch = super.verifyCheckSum();
         if(!isMatch){
            this.orderToUpdate.put('SC_Error_Message__c','Error in Checksum calculation');
         }
       }
       String errVal = 'Error Code : ' + pageParams.get('errCode')+ 
                +'\nexErrCode : ' + pageParams.get('exErrCode') +
                +'\nerror : ' + pageParams.get('error');
       this.orderToUpdate.put('SC_Error_Message__c',errVal);
       String reasonVal =  'Reason Code : ' + pageParams.get('reasonCode')+ 
                +'\nReason : ' + pageParams.get('reason');
       this.orderToUpdate.put('SC_Failure_Reason__c',reasonVal);
    }
}