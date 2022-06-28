/****************************************************************************************
Name              : AccountTriggerHandler
Description       :
Revision History  :
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Sam Boukhobza               16/01/2019            Ella Bernachik          [SW-32039]
2. Dor Malka                   09/06/2020            Aya  Toledano           [SW-37610]
----------------------------------------------------------------------------------------*/
public class AssetTriggerHandler  extends TriggerHandler{

    public List<Asset> newMapAsset;
    public Map<Id,Asset> oldMapAsset;

    AssetTriggerHelper helper = new AssetTriggerHelper();

    public AssetTriggerHandler(List<Asset> newMapAsset,Map<Id,Asset> oldMapAsset){
        this.newMapAsset = newMapAsset;
        this.oldMapAsset = oldMapAsset;
    }


//    public override void afterinsert  (){
//        System.debug( 'in afterUpdate ' );
//    }

    public override void beforeDelete(){

    }

    public override void beforeinsert () {
        system.debug( 'in before insert' );
        system.debug( this.newMapAsset );
		 if(this.isActionAllowed('populate_Origin_Product_Code')){
            helper.populate_Origin_Product_Code(this.newMapAsset,this.oldMapAsset);
        }
        if(this.isActionAllowed('updateProduct')){
            helper.updateProduct(this.newMapAsset,this.oldMapAsset);
        }



    }

    public override void beforeupdate () {
        system.debug( 'in before update' );
		if(this.isActionAllowed('populate_Origin_Product_Code')){
            helper.populate_Origin_Product_Code(this.newMapAsset,this.oldMapAsset);
        }
        if(this.isActionAllowed('updateProduct')){
            helper.updateProduct(this.newMapAsset,this.oldMapAsset);
        }

    }


    public override void afterUpdate(){
        
        if(this.isActionAllowed('updateDeviceCounts')){     
        
            List<Asset> assetsToUpdate = new List<Asset>();
            Set<Id> accIds = new Set<Id>();
            for(Asset ass : this.newMapAsset){
                Asset oldAsset = this.oldMapAsset.get(ass.Id);
                if( ass.Active__c != oldAsset.Active__c || 
                    ass.AccountId != oldAsset.AccountId || 
                    ass.Product2Id != oldAsset.Product2Id ||
                  	ass.Warranty_Due_Date__c != oldAsset.Warranty_Due_Date__c){
                        accIds.add(ass.AccountId);
                        accIds.add(oldAsset.AccountId);
                }
            }  
            System.debug('assetsToUpdate==>'+assetsToUpdate);
            List<Account> accsToUpdate = SharedCustomersDevices.updateDeviceCounts(accIds);
            System.debug('accsToUpdate==>'+accsToUpdate);
            if(accsToUpdate.size() > 0) update accsToUpdate;
        }

    }

    public override void afterDelete(){
        if(this.isActionAllowed('updateDeviceCounts')){       
            helper.updateDeviceCounts(this.oldMapAsset.values());
        }
    }

    public override void afterInsert(){
        if(this.isActionAllowed('updateDeviceCounts')){       
            helper.updateDeviceCounts(this.newMapAsset);
        }
    }

//    public override void beforedelete () {
//        if (!this.isactionallowed('method')) {
//            return;
//        }
//    }
/*
    public override void afterUpdate (){
        if(this.isactionallowed('method')){
        }
    }


    public override void afterdelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }

    public override void afterundelete () {
        if (!this.isactionallowed('method')) {
            return;
        }
    }*/
}