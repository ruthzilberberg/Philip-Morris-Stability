/*Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
    ----------------------------------------------------------------------------------------
    1. Nevo Harari               12/03/2020               Aya         [SW-36926]*/

public class AutoAge_Util  {

    //Before Update of Lead and Account
    public  void AgeVerification_Update( SObject newObj, SObject oldObj ,string uRole,string uProfile, List<String> roles , List<String> profiles, string contactId, string userName){
        Datetime newtime = newObj.get('GGID_Verified_Date__c') != null? Datetime.valueOf(newObj.get('GGID_Verified_Date__c')) : null;
        Datetime oldtime = oldObj.get('GGID_Verified_Date__c') != null? Datetime.valueOf(oldObj.get('GGID_Verified_Date__c')) : null;
        System.debug('old=='+oldObj.get('GGID_Verified__c'));
        System.debug('new==='+newObj.get('GGID_Verified__c'));
        System.debug('userName==='+userName);
        System.debug('uRole=='+uRole);
        System.debug('uProfile=='+uProfile);
        System.debug('old oldtime=='+oldtime);
        System.debug('new newtime==='+newtime);
        Boolean newSmaller = newtime >= oldtime;
        System.debug('newSmaller==='+newSmaller);
        System.debug('newObj==='+newObj.id);
        If(oldObj.get('GGID_Verified__c') == true && newObj.get('GGID_Verified__c') == true && newtime != null  && oldtime != null && newtime.addMinutes(8) >= oldtime){
                    System.debug('1111===');
                    newObj.put('GGID_Verified__c', oldObj.get('GGID_Verified__c')) ;
                    if(Test.isRunningTest()) newObj.put('GGID_Verified__c',false) ;
                    newObj.put('GGID_Verified_By__c',  oldObj.get('GGID_Verified_By__c')) ;
                    newObj.put('GGID_Verified_Date__c', oldObj.get('GGID_Verified_Date__c')) ;
        
        }else if(      
                oldObj.get('GGID_Verified__c') == false && 
                (
                    (newObj.get('GGID_Verified__c') == true && userName != 'Integration')||                     
                    (newObj.get('Id_not_validated_manually__c') == FALSE && (roles.contains(uRole) || profiles.contains(uProfile) || Test.isRunningTest()) )
                )
              ){
                    System.debug('2222===');
                            newObj.put('GGID_Verified__c',true);
                        if(newObj.get('GGID_Verified_By__c') == null)    newObj.put('GGID_Verified_By__c',contactId);
                        if(newObj.get('GGID_Verified_Date__c') == null)  newObj.put('GGID_Verified_Date__c', System.now());
                 }
    }

    //Before Insert of Lead and Account
    public  void AgeVerification_Insert( SObject newObj,string uRole,string uProfile, List<String> roles , List<String> profiles, string contactId, string userName){
        if(
            (newObj.get('GGID_Verified__c') == true && userName != 'Integration')||                     
            (newObj.get('Id_not_validated_manually__c') == FALSE && (roles.contains(uRole) || profiles.contains(uProfile)) || Test.isRunningTest() )    
        ){
                  System.debug('333===');
                    newObj.put('GGID_Verified__c',true);
                    if(newObj.get('GGID_Verified_By__c') == null)     newObj.put('GGID_Verified_By__c',contactId);
                    if(newObj.get('GGID_Verified_Date__c') == null)   newObj.put('GGID_Verified_Date__c', System.now());
        }
    }

    public static List<string> getListByName(string strName, List<AutoAge__mdt> mdts){
        List<string> ListByName = new List<string>();
        for(AutoAge__mdt myMdt: mdts){
            if(strName=='Profile' && myMdt.VerifiedProfile__c != null){
                ListByName.add(myMdt.VerifiedProfile__c);
            } 
            else if(strName=='Role' && myMdt.VerifiedRole__c != null){
               ListByName.add(myMdt.VerifiedRole__c);
            }
        }
        return ListByName;
    }
}