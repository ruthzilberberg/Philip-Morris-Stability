/****************************************************************************************
Name              : AccountTriggerHelper
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-30196]
2. Nevo Harari               17/06/2019                Gal Regev          [SW-33815]
3. Yoella Bourshan           23/06/2019                Ella Bernachik     [SW-33815] QA-001770 Set Relate promotion to false + QA-001799 Not preventing more than one personal code
4. Dor Malka                 03/10/2019                Ella Bernachik     [SW-34972] 
5. Ori                       10/10/2019                Ella Bernachik     [SW-34817]
6. Nevo Harari               12/03/2020                Aya                [SW-36926]
7. Dor Malka                   09/06/2020            Aya  Toledano           [SW-37610]

----------------------------------------------------------------------------------------*/
public class AccountTriggerHelper  {
    
    //public static boolean runFindAndConvertLeads = false;
    //public static boolean runValidateIdNumber = false;
    public static List<Id> processedaccsFindAndConvertLead = new List<Id>();
    public static List<String> processedaccsValidateIdNumber = new List<String>();
    public static List<Id> processedaccsRelatePromotion = new List<Id>();
    public static List<Id> processedaccsFindAndConvertLeadIds = new List<Id>();
    public static set<string> promotionCodes = new set<string>();
    
    public void findAndConvertLeads( List<Account> accList,Map<Id,Account> newAcc, Map<Id,Account>oldMap ){
        if(processedaccsFindAndConvertLead.contains(accList[0].Id)) return;
        
        List<Account> accListTmp= new List<Account>(); 
        System.debug('Trigger.isUpdate ' + Trigger.isUpdate);
        System.debug('Trigger.isInsert ' + Trigger.isInsert);
        if( Trigger.isUpdate ){ // If is update
            
            for(Account acc: accList){
                if( acc.Convert__c && oldMap.get(acc.Id).Convert__c == false){   
                    accListTmp.add(acc);
                    acc.Convert__c = false;
                }
            }
        }else{  
            accListTmp=accList;
        }
        processedaccsFindAndConvertLead.addAll(newAcc.keySet());
        if( accListTmp.size() > 0 ) {
            Map<String, Id> DCS_Id_Map = new Map<String,Id>();
            Map<String, Id> prsId_accIdMap = new Map<String,Id>();
            for (account acc : accListTmp) {
                if (String.isNotBlank(acc.DCS_ID__c)) {
                    DCS_Id_Map.put(acc.DCS_ID__c, acc.id);
                }if (String.isNotBlank(acc.ID__pc)) {
                    prsId_accIdMap.put(acc.ID__pc, acc.Id);
                }
            }
            if (!prsId_accIdMap.isEmpty() || !DCS_Id_Map.isEmpty()){
                findAndConvertLeads_Future(DCS_Id_Map,prsId_accIdMap);
            }
        }

     }
 public static final LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
     @Future
     public static void findAndConvertLeads_Future( Map<String, Id>  DCS_Id_Map, Map<String, Id> prsId_accIdMap){
         //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
         Map<String, Account> accMapToUpdate = new Map<String, Account>();
         Map<String, Account> accMapByDcs = new Map<String, Account>();
         Map<String, Account> accMapByPersonId = new Map<String, Account>();         
         
         Map<Id,Account> accsMap = new Map<Id,Account>(
                [Select Id,DCS_ID__c,Primary_Brand__pc,CreatedById,OwnerId,PersonEmail,
                Primary_Brand_Family__pc,Secondary_Brand__pc,Secondary_Brand_Family__pc,ID__pc
                From Account Where Id in : DCS_Id_Map.values() Or Id in : prsId_accIdMap.values()]);
         System.debug('DCS_Id_Map.values()----->'+DCS_Id_Map.values());
         
         for(Account acc: accsMap.values()){
             if(String.isNotBlank(acc.DCS_ID__c)){
                 accMapByDcs.put(acc.DCS_ID__c,acc);
             }
             if(String.isNotBlank(acc.ID__pc)){
                 accMapByPersonId.put(acc.ID__pc,acc);
             }
         }         
         List<Lead> leadList = new List<Lead>();
         Map<Id,Lead> leadsToUpdateBeforeConvert = new Map<Id,Lead>();
         Map<Id,Id> leadId_accId = new Map<Id,Id>();
         for(Lead myLead : [ SELECT  id, DCS_ID__c,ID__c,Email,OwnerId,
                                    Primary_Brand__c, Primary_Brand_Family__c,
                                    Secondary_Brand__c, Secondary_Brand_Family__c 
                                    ,GGID_Verified__c,GGID_Verified_By__c,GGID_Verified_Date__c
                                    FROM Lead
                                     WHERE   ( DCS_ID__c IN: DCS_Id_Map.keySet()
                                     AND DCS_ID__c != null )
                                     OR  ID__c IN: prsId_accIdMap.keySet()]){
            
            System.debug('myLead = ' + myLead);

            Account currentAcc = accMapByPersonId.get(myLead.ID__c);
            /*if(accMapByPersonId.containsKey(myLead.ID__c)){
                currentAcc = accMapByPersonId.get(myLead.ID__c);
            }*/ 

            
            if(currentAcc == null){
                currentAcc = accMapByDcs.get(myLead.DCS_ID__c);
            }
            if(currentAcc != null){
                leadId_accId.put(myLead.Id,currentAcc.Id);
                if(myLead.Email == null){
                   leadsToUpdateBeforeConvert.put(myLead.Id,new Lead(Id = myLead.Id,Email = currentAcc.PersonEmail));//,inCovertProcess__c = true)); 
                }
                if(currentAcc.Primary_Brand__pc == null || currentAcc.Primary_Brand_Family__pc == null ||
                currentAcc.Secondary_Brand__pc == null || currentAcc.Secondary_Brand_Family__pc == null){
                    Account newAcc = new Account(Id = currentAcc.Id);
                    if(currentAcc.Primary_Brand__pc == null){
                        newAcc.Primary_Brand__pc = myLead.Primary_Brand__c;   
                    }
                    if(currentAcc.Primary_Brand_Family__pc == null){
                        newAcc.Primary_Brand_Family__pc = myLead.Primary_Brand_Family__c;
                    }
                    if(currentAcc.Secondary_Brand__pc == null){
                        newAcc.Secondary_Brand__pc = myLead.Secondary_Brand__c;
                    }
                    if(currentAcc.Secondary_Brand_Family__pc == null){
                        newAcc.Secondary_Brand_Family__pc = myLead.Secondary_Brand_Family__c;
                    }
                    //sw-36926
                    newAcc.GGID_Verified__c = myLead.GGID_Verified__c;
                    newAcc.GGID_Verified_By__c = myLead.GGID_Verified_By__c ;
                    newAcc.GGID_Verified_Date__c = myLead.GGID_Verified_Date__c; 
                    //36926
                    accMapToUpdate.put(newAcc.Id,newAcc);
                }
            }

            /*
            accMap.get( uniqId ).Primary_Brand__pc = accMap.get( uniqId ).Primary_Brand__pc == null ? myLead.Primary_Brand__c : accMap.get( uniqId ).Primary_Brand__pc;
            accMap.get( uniqId ).Primary_Brand_Family__pc = accMap.get( uniqId ).Primary_Brand_Family__pc == null ? myLead.Primary_Brand_Family__c : accMap.get( uniqId ).Primary_Brand_Family__pc;
            accMap.get( uniqId ).Secondary_Brand__pc = accMap.get( uniqId ).Secondary_Brand__pc== null ? myLead.Secondary_Brand__c: accMap.get( uniqId ).Secondary_Brand__pc;
            accMap.get( uniqId ).Secondary_Brand_Family__pc = accMap.get( uniqId ).Secondary_Brand_Family__pc == null ? myLead.Secondary_Brand_Family__c: accMap.get( uniqId ).Secondary_Brand_Family__pc;
            */
            leadList.add(myLead);

         
            // End SW-34972
            
         }
         system.debug('leadList id = ' + leadList);
         if(leadList.size()>0){
             //update leadList;
          List<Lead> leadsToUpdateLst = leadsToUpdateBeforeConvert.values();   
          List<Id> failedleadsBeforeConvert = new List<Id>();
          if(leadsToUpdateBeforeConvert.size()>0){ 
            Database.SaveResult[] srList = Database.update(leadsToUpdateLst, false);
            List<Error_Log__c>err_list2= new List<Error_Log__c>();
                // Iterate through each returned result
                Integer indx=0;
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors                
                        Error_Log__c err=new Error_Log__c();
                        for(Database.Error e : sr.getErrors()) {
                            err.Error_Description__c = 'Failed before convert: ' +  e.getMessage();
                            err.Object_Name__c= leadsToUpdateLst[indx].Id;
                            failedleadsBeforeConvert.add(leadsToUpdateLst[indx].Id);
                            err_list2.add(err);
                            /*System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());*/
                        }
                    }
                    indx++;
                }
                if(err_list2.size()>0){
                  insert err_list2;
                }
             
            }
            
            //before updating accounts - check if lead was updated successfully
            for(Id leadId: failedleadsBeforeConvert){
               Id accId = leadId_accId.get(leadId);
               if(accId != null && accMapToUpdate.containsKey(accId)){
                  accMapToUpdate.remove(accId);
               } 
            }
            
             //update accMap.values();
            if(accMapToUpdate.values().size()>0){
               update accMapToUpdate.values();
            } 
             
             List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
                for(Lead myLead : leadList){
                    if(failedleadsBeforeConvert.contains(myLead.Id)){continue;}
                    
                    Account acc = accMapByPersonId.get(myLead.ID__c);
                    if(acc == null){
                        acc = accMapByDcs.get(myLead.DCS_ID__c);
                    }
                    System.debug('------------------' + myLead);
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(myLead.Id);
                    //String Id = myLead.DCS_ID__c != null ? myLead.DCS_ID__c : myLead.ID__c;
                    
                    //lc.setAccountId( accMapByDcsOrId.containsKey(Id) ? accMapByDcsOrId.get(Id).Id : accMapByDcsOrId.get(myLead.ID__c).Id );
                    lc.setAccountId(acc.Id);
                    system.debug('lc = +' + lc);
                    system.debug('lc id = +'  + myLead.Id);
                    //lc.setOwnerId(string.valueOf(myLead.OwnerId).startsWith('00G') ? accMapByDcsOrId.get(Id).CreatedById : myLead.OwnerId);
                    //lc.setOwnerId(string.valueOf(myLead.OwnerId).startsWith('00G') ? acc.CreatedById : myLead.OwnerId);
                    lc.setOwnerId(acc.OwnerId);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    lcList.add(lc);
                }
    
                System.debug('lcList----->'+lcList);
                if(lcList.size() > 0){
    
                   
                    List<Database.LeadConvertResult> lcr = Database.convertLead(lcList,false); 
                    List<Error_Log__c>err_list= new List<Error_Log__c>(); 
                    for (Database.LeadConvertResult res : lcr){
    
                            System.debug('res----->'+res);
        
    
                            if (!res.isSuccess()){
                             System.debug('error size: '+res.getErrors().size());
                                Error_Log__c err=new Error_Log__c();
                                for (Database.Error e : res.getErrors()){
                                        //err.Object_Name__c=
                                        err.Error_Description__c =e.getMessage();
    
                                        if(res.getLeadID()!=null) err.Object_Name__c=res.getLeadID();
                                       
                                        System.debug('The following error has occurred.');                    
                                        System.debug(e.getStatusCode() + ': ' + e.getMessage());
                                        System.debug('Fields that affected this error: ' + e.getFields());
                                     //e.getMessage();
                                    err_list.add(err);
    
                                    }
                            }
    
                        }
    
                        insert err_list;
                        System.debug('err_list----->'+err_list);
    
                }
                List<lead> leadLstUpdateConvertField = new List<Lead>();
             /*try{
                 for(Lead ld : leadsToUpdateLst){
                    leadLstUpdateConvertField.add(new Lead(Id=ld.Id,inCovertProcess__c = false)); 
                 }
                 update leadLstUpdateConvertField;
             }*/
             }   
     }
     
    // 
    public void Validate_IdNumber( List<SObject> sObjList, String Id_field ){
       
        system.debug('=----------------------=');
        List<SObject> objsToError = new List<SObject>();
        
        try{          
            for(SObject sobj: sObjList){
               if(Id_field != null && Id_field != '' && sobj.get(Id_field) != null){
                    String theId = String.valueOf(sobj.get(Id_field));//acc.ID__pc;
                    if(theId.length() > 9){
                        objsToError.add(sobj);
                    }else{
                        //make the id exactly 9 chars long
                        while (theId.length()<9){
                            theId='0'+theId;
                        }
                        system.debug('the id length 9: '+theId);
                
                        //create an int array from the 9char Id
                        List<integer> charList = theId.getChars();
                        List<integer> idsToCheck = new List<integer>();
                        for(Integer i: charList){
                            //system.debug(i-48);
                            idsToCheck.add(i-48);
                        }               
                        system.debug('id list: '+idsToCheck);
                
                        //implemet the logic behind the format of the id
                        integer counter =0;
                        integer i = 0;
                        for(integer digit : idsToCheck){
                            integer step = digit*((math.mod(i++, 2))+1);
                            counter+= step > 9 ? step-9 : step;
                        }
                        //the counter%10 needs to be equal to 0 in order for the ID to be valid
                        system.debug('result=0? '+math.mod(counter, 10));
                        if (math.mod(counter, 10) > 0){
                            objsToError.add(sobj);
                        }else{
                            sobj.put(Id_field,theId);
                        }
                    }//else
                
                  }
                }//for

                if (objsToError.size() > 0){
                    for(SObject errSobj : objsToError){
                        errSobj.addError('Please enter a valid ID'); 
                    }
                }
            }catch(Exception e){           
                  system.debug('error: '+e);
            }
        
    
    }
    
    
     public static void Validate_IdNumber2( List<Account> accNew, Map<Id,Account>oldMap ){
        if(processedaccsFindAndConvertLeadIds.contains(accNew[0].Id)) return;
        
        system.debug('=----------------------=');
        List<Account> objsToError = new List<Account>();
        
        try{          
            for(Account acc : accNew){
               if(processedaccsValidateIdNumber.contains(acc.ID__pc)) continue;
               if(Trigger.isInsert || (acc.ID__pc != oldMap.get(acc.Id).ID__pc)){
                    String theId =acc.ID__pc;//= String.valueOf(acc.ID__pc);//acc.ID__pc;
                    if(theId.length() > 9){
                        objsToError.add(acc);
                    }else{
                        //make the id exactly 9 chars long
                        while (theId.length()<9){
                            theId='0'+theId;
                        }
                        system.debug('the id length 9: '+theId);
                
                        //create an int array from the 9char Id
                        List<integer> charList = theId.getChars();
                        List<integer> idsToCheck = new List<integer>();
                        for(Integer i: charList){
                            //system.debug(i-48);
                            idsToCheck.add(i-48);
                        }               
                        system.debug('id list: '+idsToCheck);
                
                        //implemet the logic behind the format of the id
                        integer counter =0;
                        integer i = 0;
                        for(integer digit : idsToCheck){
                            integer step = digit*((math.mod(i++, 2))+1);
                            counter+= step > 9 ? step-9 : step;
                        }
                        //the counter%10 needs to be equal to 0 in order for the ID to be valid
                        system.debug('result=0? '+math.mod(counter, 10));
                        if (math.mod(counter, 10) > 0){
                            objsToError.add(acc);
                        }else{
                            acc.ID__pc = theId;
                            //obj.put(Id_field,theId);
                        }
                    }//else
                
                  }
                }//for
                if(oldMap != null){
                   processedaccsFindAndConvertLeadIds.addAll(oldMap.keySet());
                }
                
                if (objsToError.size() > 0){
                    for(Account errSobj : objsToError){
                        errSobj.addError('Please enter a valid ID'); 
                    }
                }
            }catch(Exception e){           
                  system.debug('error: '+e);
            }
        
    
    }
    
    // before insert Mark Promotion SW-33815
    public void MarkPromotion( List<Account> accList ){
        for(Account acc : accList){
            System.debug('MarkPromotion====='+acc);
            acc.Relate_Promotion__pc = true;
        }
    }

    // After Insert & Update find+connect Promotion[only one allowed] SW-33815 
    public void FindAndReltePromotion( List<Account> accList, map<Id, Account> oldMApAcc,map<Id,Account> newAcc){
        if(processedaccsRelatePromotion.contains(accList[0].Id)) return;
        Map<Id,Account> relevAccsMap = new Map<Id,Account>();
        for(Account acc : accList){
            
            if(acc.Relate_Promotion__pc == true && acc.Personal_Code__pc == null){
                 if (Trigger.isUpdate){
                    if(acc.Relate_Promotion__pc == true && (acc.Relate_Promotion__pc != oldMApAcc.get(acc.id).Relate_Promotion__pc)) { //Check change to true Not anyChange - Yoella
                        relevAccsMap.put(acc.Id, acc);
                    }
                }
                else{
                     relevAccsMap.put(acc.Id,acc);
                }
            
            }
        }
        processedaccsRelatePromotion.addAll(newAcc.keySet());

        if(relevAccsMap.size() > 0){
            
            //DelayController(2000);
            //find Promotion
            //List<Promotion__c> freePromotionsList = new List<Promotion__c>([select id, Promotion_Code__c, Customer__c  from Promotion__c WHERE Type__c = 'Personal Code' AND Status__c = 'Open' And Customer__c = null Limit 200 For Update]);
            //Integer randomNumber = Integer.valueof((Math.random() * 50));
            Integer numOfLimit = relevAccsMap.size();
            String promotionQuery = 'select id, Promotion_Code__c, Customer__c  from Promotion__c WHERE Type__c = \'Personal Code\' AND Status__c = \'Open\' And Customer__c = null Limit ' + numOfLimit;
            List<Promotion__c> freePromotionsList = database.query(promotionQuery);
            List<Promotion__c> existPersonalPromRelatedToRelevAcc = new List<Promotion__c>([select id, Promotion_Code__c, Customer__c  from Promotion__c WHERE Type__c = 'Personal Code' /*AND Status__c = 'Active'*/ AND Customer__c IN :relevAccsMap.keySet()]); //QA-001799//2nd select replace select of felated list in Account to bring the Personal Code type Promotion
            List<Promotion__c> promotionsToUpdate = new List<Promotion__c>();
            List<Account> accToUpdate = new List<Account>();
            System.debug('freePromotionsList'+freePromotionsList.size());
            System.debug('existPersonalPromRelatedToRelevAcc'+existPersonalPromRelatedToRelevAcc.size());
            System.debug('relevAccsMap'+relevAccsMap.size());
            
            System.debug('freePromotionsList = '+freePromotionsList);
            System.debug('existPersonalPromRelatedToRelevAcc  = '+existPersonalPromRelatedToRelevAcc);
            System.debug('relevAccsMap = '+ relevAccsMap);

            for(Promotion__c prom :existPersonalPromRelatedToRelevAcc) {
                account copyAcc = new account(id = prom.Customer__c);
                copyAcc.Relate_Promotion__pc = false;//[SW-33815] QA-001770
                accToUpdate.add(copyAcc);
                relevAccsMap.remove(prom.Customer__c); //QA-001799
            }

            //Deal with integration upsert balk of insert+update by removing used promotion from the selected list
            Integer index = 0;
            System.debug('ALL free ===='+freePromotionsList);

            /*if(cache.Session.contains('codes')){
              promotionCodes.addAll((List<string>)cache.Session.get('codes'));
            }*/

            for(Promotion__c myPromotion : freePromotionsList){
                
                System.debug('free code ===='+freePromotionsList[index]);
                if(promotionCodes.contains(myPromotion.Promotion_Code__c)) {
                    System.debug('free code ===='+freePromotionsList[index]);
                    System.debug('111 free size===='+freePromotionsList.size());
                   freePromotionsList.remove(index);
                   System.debug('====Code==='+myPromotion.Promotion_Code__c);
                    System.debug('222 free size===='+freePromotionsList.size());
                
                }
                index++;
            }

            //connect Promotion
            Integer count = 0;
            System.debug('promotionCodes======'+promotionCodes.size());
            System.debug('promotionCodes======'+promotionCodes);
            for(Account acc : relevAccsMap.values()){
                account copyAcc = new account(id = acc.id);
                if(count < freePromotionsList.size()){

                   promotionCodes.add(freePromotionsList[count].Promotion_Code__c);
                   
                    freePromotionsList[count].Customer__c = acc.Id;
                    freePromotionsList[count].Status__c = 'Active';
                    promotionsToUpdate.add(freePromotionsList[count]);
                    copyAcc.Personal_Promotion_Code__pc = freePromotionsList[count].Promotion_Code__c;
                    copyAcc.Customer_Error_Message__c = null;
                    System.debug('acc.Id==='+acc.Id);
                    System.debug('copyAcc.Personal_Promotion_Code__pc==='+copyAcc.Personal_Promotion_Code__pc);
                    count++;
                }else{
                    //pop msg missing promotion
                    System.debug('pop msg missing promotion==='+label.MGM_Personal_Code_Not_Found);
                    copyAcc.Customer_Error_Message__c = label.MGM_Personal_Code_Not_Found;
                }
                System.debug('Relate promotion to false===');
                copyAcc.Relate_Promotion__pc = false;//[SW-33815] QA-001770
                accToUpdate.add(copyAcc);
            }
            
            
            /*if(cache.Session.contains('codes')){
              promotionCodes.addAll((List<string>)cache.Session.get('codes'));
            }
            cache.Session.put('codes',promotionCodes);
            */
            system.debug('promotionsToUpdate = ' + Json.serialize(promotionsToUpdate));
            if(promotionsToUpdate.size() > 0) 
                update promotionsToUpdate;
            if(accToUpdate.size() > 0) 
                update accToUpdate;

            promotionsToUpdate.clear();
            accToUpdate.clear();
        }
    }
   //END SW-33815 

   //START SW-33938
   public void Call_Async_PromotionLogic(List<Account> accs, Map<Id, Account> accsOldMap){
        List<Account> relevAccs = new List<Account>();
        for(Account acc : accs){
            //if(acc.Promotion_Code__pc != null && acc.Promotion_Code__pc != accsOldMap.get(acc.id).Promotion_Code__pc ){
            
            if(accsOldMap.get(acc.id).MGM_PROMO_CODE__c == null && acc.MGM_PROMO_CODE__c != null){ //&& acc.MGM_PROMO_CODE__c != accsOldMap.get(acc.id).MGM_PROMO_CODE__c ){
                    relevAccs.add(acc);
              }
            }
        
        if(relevAccs.size() > 0){
          Async_Acc_PromotionLogic promotionLogic = new Async_Acc_PromotionLogic(relevAccs);
          promotionLogic.execute();
         
         // ID jobID = System.enqueueJob(promotionLogic);
        }
    }//START SW-33938


     public void AgeVerificationUpdate( List<SObject> accList, Map<Id,SObject>oldMap ){
        
        //Data collect
        id uId = UserInfo.getUserId();
        user currentUser = [select userrole.name, Contact_Id__c from user WHERE id =: uId limit 1];
        String myrole = currentUser.userrole.name;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        String myUserName = UserInfo.getUserName();
        List<AutoAge__mdt> mdts = [select VerifiedRole__c,VerifiedProfile__c from AutoAge__mdt];
        List<string> roles = AutoAge_Util.getListByName('Role', mdts);
        List<string> profiles = AutoAge_Util.getListByName('Profile', mdts); 
        string getUserName = UserInfo.getUserName();
        string userName = getUserName.containsIgnoreCase('Integration@pmi')?'Integration':getUserName;

        //logic
        AutoAge_Util util = new AutoAge_Util();
        for(SObject acc : accList){
           util.AgeVerification_Update(acc,oldMap.get(acc.id),myrole, profileName, roles, profiles,currentUser.Contact_Id__c,userName );
        }
     }
     
    
     public void AgeVerificationInsert( List<SObject> accList ){
        //Data collect
        id uId = UserInfo.getUserId();
        user currentUser = [select userrole.name ,name, Contact_Id__c from user WHERE id =: uId limit 1];
        String myrole = currentUser.userrole.name;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        String myUserName = UserInfo.getUserName();
        List<AutoAge__mdt> mdts = [select VerifiedRole__c,VerifiedProfile__c from AutoAge__mdt];
        List<string> roles = AutoAge_Util.getListByName('Role', mdts);
        List<string> profiles = AutoAge_Util.getListByName('Profile', mdts); 
        string getUserName = UserInfo.getUserName();
        string userName = getUserName.containsIgnoreCase('Integration@pmi')?'Integration':getUserName;

        //logic
        AutoAge_Util util = new AutoAge_Util();
        for(SObject acc : accList){
           util.AgeVerification_Insert(acc,myrole, profileName, roles, profiles,currentUser.Contact_Id__c,userName );
        }
     }



     public void updatePromotionField(List<Asset> assetList){
        // SharedCustomersDevices.updatePromotionField(assetList);
    }



}