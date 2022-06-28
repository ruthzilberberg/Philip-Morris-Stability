/****************************************************************************************
Name              : Async_Acc_PromotionLogic
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/06/2019              Ella Bernachik         [SW-33938]
----------------------------------------------------------------------------------------*/
public class Async_Acc_PromotionLogic { //implements Queueable {
    
    public static User currentUser = [Select UserRoleId,UserRole.Name,Profile.Name,LastName,Id From User where Id=:UserInfo.getUserId()][0];
    private list<account> accs;
    private Map<Id,account> accsMap;
    public Async_Acc_PromotionLogic (list<account> accs){
        this.accs = accs;
        //Map<Id,Account> accountMap = new Map<Id,Account>(accs);
        //accsMap = new Map<Id,Account>([Select Id,MGM_PROMO_CODE__c,Customer_Error_Message__c,MGM_FSS_Owner__c From Account where Id in : accountMap.keySet()]);
    }
    public class PromotionException extends Exception{}
    /*
    public void execute(){ //QueueableContext context) {
        
        Map<String, List<Account>> codeToAccs = new Map<String, List<Account>>();
        list<account> accsAddError = new list<account>();
        Set<id> accIdsTrigger = new Set<id>();

        //1. Collect DATA
        List<String> accCodes = new List<String>();
        for(Account acc : accs){
            accIdsTrigger.add(acc.id);
            accCodes.add(acc.MGM_PROMO_CODE__c);// acc.Promotion_Code__pc
            if(codeToAccs.containsKey(acc.MGM_PROMO_CODE__c)){codeToAccs.get(acc.MGM_PROMO_CODE__c).add(acc);// acc.Promotion_Code__pc
            }else {codeToAccs.put(acc.MGM_PROMO_CODE__c,new list<Account>{acc});}// acc.Promotion_Code__pc
        }
        System.debug('codeToAccs = ' + codeToAccs);
        List<Promotion__c> promosPersonal = new List<Promotion__c>();
        List<Promotion__c> Benefits = new List<Promotion__c>();
        List<Promotion__c> promosToUpdate = new List<Promotion__c>();
        List<Account> customersToUpdate = new List<Account>();
        promosPersonal = [select id, Customer__c,Customer__r.Personal_Promotion_Code__pc, Type__c, Status__c, Promotion_Code__c from Promotion__c
                          WHERE Promotion_Code__c IN: accCodes  AND Status__c = 'Active' AND  Type__c = 'Personal Code'];
        Benefits = [select id, Customer__c,Customer__r.Personal_Promotion_Code__pc, Type__c, Status__c, Promotion_Code__c from Promotion__c
                          WHERE Status__c = 'Open' AND  Type__c = 'Benefit'];
        
        System.debug('promosPersonal = ' + promosPersonal);
        System.debug('Benefits = ' + Benefits);
        //2.Find and connect an open benefit to our customers for each Customer/Account(personal)
        Integer i = 0;
        for(Promotion__c promo: promosPersonal){
            for(Account acc : codeToAccs.get(promo.Promotion_Code__c)){
            
                if(Benefits.size() > i){
                    Promotion__c myBenefit = Benefits[i];
                    myBenefit.Customer__c = promo.Customer__c;
                    myBenefit.Referred_By__c = acc.id;
                    myBenefit.Status__c = 'Active';
                    promosToUpdate.add(myBenefit);
                    i++;
                }else{
                    //pop msg missing promotion
                    if(!accIdsTrigger.contains(promo.Customer__c)){
                      Account acc2updtae = new Account(id = promo.Customer__c, Customer_Error_Message__c= label.MGM_Promo_Not_Created, MGM_PROMO_CODE__c = null);
                        customersToUpdate.add(acc2updtae);
                    }
                    /*break;*/
    /*              accsAddError.add(acc);
                    
                }
            }
        }

        if(promosToUpdate.size() > 0){
            update promosToUpdate;
        }
        if(customersToUpdate.size() > 0){
            update customersToUpdate;
        }
        System.debug('accsAddError = ' + accsAddError);
        for(Account acc : accsAddError){
            acc.addError(label.MGM_Personal_Code_Not_Found);
        }
    }
    */

    public void execute(){

        
        Map<String, Account> codeToAcc = new Map<String, Account>();
        list<account> accsAddError = new list<account>();

        //1. Collect DATA
        List<String> accCodes = new List<String>();
        for(Account acc : accs){
            accCodes.add(acc.MGM_PROMO_CODE__c);
            codeToAcc.put(acc.MGM_PROMO_CODE__c,acc);
        }
        System.debug('codeToAccs = ' + codeToAcc);
        List<Promotion__c> Benefits = new List<Promotion__c>();
        List<Promotion__c> promosToUpdate = new List<Promotion__c>();
        List<Promotion__c> promosToInsert = new List<Promotion__c>();
        List<Account> customersToUpdate = new List<Account>();
        
        System.debug('accCodes = ' + accCodes);
        List<Promotion__c> promosPersonal = [select id, Customer__c,Customer__r.Contact__c,Customer__r.PersonContactId,Customer__r.Personal_Promotion_Code__pc,Customer__r.MGM_FSS_Owner__c, Type__c, Status__c, Promotion_Code__c from Promotion__c
                          WHERE Promotion_Code__c IN: accCodes  AND Status__c = 'Active' AND  Type__c = 'Personal Code'];
        
        Integer promosSize = promosPersonal.size();
        if(promosSize >0){
            String benefitsQuery = 'Select Id From Promotion__c WHERE Status__c = \'Open\' AND  Type__c = \'Benefit\' Limit ' + promosSize;
            Benefits = Database.query(benefitsQuery);
        }
        Map<String,Promotion__c> promotionMapByCode = new Map<String,Promotion__c>(); 
        for(Promotion__c pr : promosPersonal){
            promotionMapByCode.put(pr.Promotion_Code__c,pr);     
        }
        System.debug('promosPersonal = ' + promosPersonal);
        System.debug('Benefits = ' + Benefits);
        //2.Find and connect an open benefit to our customers for each Customer/Account(personal)
        
        
        for(String code : codeToAcc.keySet()){
            Account acc = codeToAcc.get(code);
            if(!promotionMapByCode.containsKey(code)){
                //customersToUpdate.add(new Account(Id = acc.Id, Customer_Error_Message__c= label.MGM_Promo_Not_Created, MGM_PROMO_CODE__c = null));
                accsAddError.add(acc);
            }
            else{
                /*Promotion__c personalPromotion = promotionMapByCode.get(code);
                Promotion__c myBenefit = Benefits[0];
                myBenefit.Customer__c = personalPromotion.Customer__c;
                myBenefit.Referred_By__c = acc.id;
                myBenefit.Status__c = 'Active';
                myBenefit.Contact__c = personalPromotion.Customer__r.PersonContactId;
                Benefits.remove(0);
                promosToUpdate.add(myBenefit);
                */
                Promotion__c personalPromotion = promotionMapByCode.get(code);
                Promotion__c myBenefit = new Promotion__c();
                myBenefit.Customer__c = personalPromotion.Customer__c;
                myBenefit.Referred_By__c = acc.id;
                myBenefit.Status__c = 'Open';
                //if(!(currentUser.Profile.Name.equalsIgnoreCase('System Adminstrator'))){
                  if(currentUser.LastName == 'Integration'){
                    myBenefit.Referred_Channel__c = 'E-Commerce';
                  }else if(currentUser.UserRole !=null){
                     myBenefit.Referred_Channel__c = currentUser.UserRole.Name.containsIgnoreCase('CSC') ? 'CSC' : currentUser.UserRole.Name; 
                  }
                  myBenefit.Referred_Owner__c = currentUser.Id;
                  myBenefit.Referred_Date__c = system.today();
                //}
                myBenefit.Referred_FSS_Owner__c = acc.MGM_FSS_Owner__c;//personalPromotion.Customer__r.MGM_FSS_Owner__c;               
                myBenefit.Contact__c = personalPromotion.Customer__r.PersonContactId;
                promosToInsert.add(myBenefit);
            }
            
        }
        /*if(promosToUpdate.size() > 0){
            update promosToUpdate;
        }*/
        insert promosToInsert; 
        boolean hasExeptionErr = false;
        String exMessage = '';
        /*if(customersToUpdate.size() > 0){
            try{
                update customersToUpdate;
            }
            catch(Exception ex){
               
               hasExeptionErr = true;
               exMessage = ex.getMessage();
               //customersToUpdate[0].addError(ex.getMessage());
               /*String errorMsg = ex.getMessage();
               system.debug('errorMsg = ' + errorMsg);
               if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
               }
               system.debug('errorMsg = ' + errorMsg);
               throw new PromotionException('Some error',ex);*/
               
        /*  }
        }
        String errMsg = hasExeptionErr ? exMessage : label.MGM_Personal_Code_Not_Found;
        if(errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            errMsg = errMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
        }*/
        String errMsg = label.MGM_Personal_Code_Not_Found;
        System.debug('accsAddError = ' + accsAddError);
        for(Account acc : accsAddError){
            acc.addError(errMsg);
        }
        
        
        
    }
}