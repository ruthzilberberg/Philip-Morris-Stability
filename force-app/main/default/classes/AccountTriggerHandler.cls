/****************************************************************************************
Name              : AccountTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo Harari               18/10/2018                Gal Regev          [SW-30196]
2. Dor Malka                   09/06/2020            Aya  Toledano           [SW-37610]

----------------------------------------------------------------------------------------*/
public class AccountTriggerHandler  extends TriggerHandler{
  
   public static boolean runDlrs = false;
   public List<Account> AccNew;
   public map<Id, Account> oldMApAcc;
   public map<Id, Account> newMApAcc;
   
    AccountTriggerHelper helper = new AccountTriggerHelper();

    public AccountTriggerHandler(List<Account> AccNew,  map<Id, Account> oldMApAcc, map<Id, Account> newMApAcc){
        this.AccNew = AccNew;
        this.oldMApAcc = oldMApAcc;
        this.newMApAcc = newMApAcc;
    }

  public static boolean isAfterInsertRun= false;
  public static Set<id> isAfterInsertRunSet= new Set<id>();
  
  public static boolean isBeforeInsertRun = false;
  public static Set<id> isBeforeInsertRunSet = new Set<id>();
  
  //public static boolean isAfterUpdateRun = false;
  public static Set<id> isAfterUpdateRunSet = new Set<id>();

  public static boolean isBeforeUpdateRun = false;
  public static Set<id> isBeforeUpdateRunet = new Set<id>();
  
  
    public override void afterinsert  (){
        System.debug( 'in afterinsert ' );
        //starts SW-37556
        if(isAfterInsertRunSet == null) isAfterInsertRunSet = new Set<id>();
        if(isAfterInsertRunSet.contains(AccNew[0].id)) return;
        isAfterInsertRunSet.addAll(newMApAcc.keySet());
    
       /* please mark this after loading DATA  */
      //if(isAfterInsertRun) return; 
      //  isAfterInsertRun = true;
        //END SW-37556
       /* please mark this after loading DATA  */
       /*  */
        if (!(AccountTriggerHelper.processedaccsFindAndConvertLead.contains(AccNew[0].Id)) && this.isActionAllowed('findAndConvertLeads')) {
            helper.findAndConvertLeads(AccNew,newMApAcc,oldMApAcc);
        }

         System.debug( '=====1 ' );
         //if(!(AccountTriggerHelper.processedaccsRelatePromotion.contains(AccNew[0].Id)) && 
         if(this.isactionallowed('FindAndReltePromotion')){
         System.debug( '=====2 ' );
            helper.FindAndReltePromotion(AccNew,null,newMApAcc);
        }


    }

    public override void beforeinsert () {
        System.debug('beforeinsert==========');
        
        //starts SW-37556
        if(isBeforeInsertRunSet == null) isBeforeInsertRunSet = new Set<id>();
        if(isBeforeInsertRunSet.contains(AccNew[0].id)) return;
        for(Account acc : AccNew){
            isBeforeInsertRunSet.add(acc.id);
        }

         /* please mark this after loading DATA  */
        /**///if(isBeforeInsertRun) return;
        //isBeforeInsertRun = true;
         /* please mark this after loading DATA  */

        //END SW-37556
        system.debug( 'in before insert' );

        if(this.isactionallowed('AgeVerificationInsert')){
            helper.AgeVerificationInsert(AccNew);//SW-36926
        }

        if (this.isactionallowed('Validate_IdNumber')) {
            AccountTriggerHelper.Validate_IdNumber2(AccNew,null);
            //helper.Validate_IdNumber(AccNew,'ID__pc');
        }

         if (this.isactionallowed('MarkPromotion')) {
             helper.MarkPromotion(AccNew);
        }

    }
    

    public override void beforeupdate () {
        
        if(isBeforeUpdateRunet == null) isBeforeUpdateRunet = new Set<id>();
        if(isBeforeUpdateRunet.contains(AccNew[0].id)) return;
        isBeforeUpdateRunet.addAll(newMApAcc.keySet());
        /*if(isBeforeUpdateRun) return;
        isBeforeUpdateRun = true;*/
        system.debug( 'in before update' );
        
        if(this.isactionallowed('AgeVerificationUpdate')){
            helper.AgeVerificationUpdate(AccNew,oldMApAcc);//SW-36926
        }

        if (!(AccountTriggerHelper.processedaccsFindAndConvertLeadIds.contains(AccNew[0].Id)) && this.isactionallowed('Validate_IdNumber')) {
            AccountTriggerHelper.Validate_IdNumber2(AccNew,oldMApAcc);
            //helper.Validate_IdNumber(AccNew,'ID__pc');
        }
        if (!(AccountTriggerHelper.processedaccsFindAndConvertLead.contains(AccNew[0].Id)) && this.isActionAllowed('findAndConvertLeads')) {
            helper.findAndConvertLeads(AccNew,newMApAcc,oldMApAcc);
        }
        if(this.isactionallowed('Call_Async_PromotionLogic')){
            helper.Call_Async_PromotionLogic(AccNew,oldMApAcc);
        }
        
        if(this.isactionallowed('updateDeviceCounts')){
            Set<Id> accsId = new Set<Id>();
            for(Account acc : AccNew){
                Account oldAcc = oldMApAcc.get(acc.Id);
                if(oldAcc.Run_EOW_Process__c == false && acc.Run_EOW_Process__c == true) accsId.add(acc.Id);
            }
            System.debug('accsId-->'+accsId);  
            for(Account acc : SharedCustomersDevices.updateDeviceCounts(accsId)){
                newMApAcc.get(acc.Id).Numbers_of_Devices_EOW__c = acc.Numbers_of_Devices_EOW__c; 
                newMApAcc.get(acc.Id).Run_EOW_Process__c = false; 
                
            }
            
        }
       // return;
    }
    

//    public override void beforedelete () {
//        if (!this.isactionallowed('method')) {
//            return;
//        }
//    }

    public override void afterUpdate (){
        
        if(isAfterUpdateRunSet == null) isAfterUpdateRunSet = new Set<id>();
        if(isAfterUpdateRunSet.contains(AccNew[0].id)) return;
        isAfterUpdateRunSet.addAll(newMApAcc.keySet());
       /* if(isAfterUpdateRun) return;
        isAfterUpdateRun = true;*/
        //if(!(AccountTriggerHelper.processedaccsRelatePromotion.contains(AccNew[0].Id)) && 
        if(this.isactionallowed('FindAndReltePromotion')){
            helper.FindAndReltePromotion(AccNew,oldMApAcc,newMApAcc);
        }

        /*if(this.isactionallowed('Call_Async_PromotionLogic')){
            helper.Call_Async_PromotionLogic(AccNew,oldMApAcc);
        }*/
        //return;
    }

}