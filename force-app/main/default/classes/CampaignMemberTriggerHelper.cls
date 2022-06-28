public with sharing class CampaignMemberTriggerHelper {
    
    List<CampaignMember> newList;
    Map<Id,CampaignMember> oldMap;

    public CampaignMemberTriggerHelper(){

    }

    // public CampaignMemberTriggerHelper( List<CampaignMember> newList,Map<Id,CampaignMember> oldMap,String dmlType,String objectName) {
    //     this.newList=newList;
    //     this.oldMap=oldMap;
    // }

   
    
    public void  update_objectHistory(List<CampaignMember> newList,Map<Id,CampaignMember> oldMap,String dmlType,String objectName){

        ObjectHistoryHandler history_handler = new ObjectHistoryHandler(newList, oldMap,dmlType,objectName);
        
        System.debug('>>>>> In Trigger Helper newList:'+newList);
        
        history_handler.create_related_record();


    }

    public void  updateCampignOnLead(List<CampaignMember> newList){

        Set<Id> allLeadIds = new Set<id>();
        
        for(CampaignMember iteratedCampignMember: newList) {
            if(iteratedCampignMember.LeadId != null) {
                allLeadIds.add(iteratedCampignMember.LeadId);
            }
        }
        UpdateCampaignOnLead operation = new UpdateCampaignOnLead(new List<Id>(allLeadIds));
        operation.run();
    }

}