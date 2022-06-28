public with sharing  class CampaignMemberTriggerHandler extends TriggerHandler {
   

   public List<CampaignMember> CampaignMemberNew;
   public Map<Id, CampaignMember> oldMApCampaignMember;

    //constructor
public CampaignMemberTriggerHandler(List<CampaignMember> CampaignMemberNew,  map<Id, CampaignMember> oldMApCampaignMember){

System.debug('>>> CampaignMemberNew:'+CampaignMemberNew);

        this.CampaignMemberNew = CampaignMemberNew;
        this.oldMApCampaignMember = oldMApCampaignMember;

        System.debug('>>> this.CampaignMemberNew:'+this.CampaignMemberNew);

        
    }


 CampaignMemberTriggerHelper helper = new CampaignMemberTriggerHelper();

//classification
///////////////////////////////////////////////////////////////////
    // public override void beforeupdate () {
    //     system.debug( 'in before update' );
    //     if(this.isActionAllowed('update_objectHistoryGetData')){
    //         helper.update_objectHistoryGetData(this.CampaignMemberNew,this.oldMApCampaignMember);
    //     }
    // }  
     
     
     public override void afterUpdate (){
       
       if(this.isactionallowed('update_objectHistory')){
            helper.update_objectHistory(CampaignMemberNew, oldMApCampaignMember,'Update','CampaignMember');
        }
    }
     public override void afterInsert (){
       
       if(this.isactionallowed('updateCampignOnLead')){
            helper.updateCampignOnLead(CampaignMemberNew);
        }
    }


}