/****************************************************************************************
Name              : PromotionTriggerHelper
Created/Modified by       Created/Modified Date     Requested by      Related Task/Issue
----------------------------------------------------------------------------------------
1. Nevo                     29/01/2020            Ella Bernachik          [SW-36249]
----------------------------------------------------------------------------------------*/
public class PromotionTriggerHelper  {

  public static void findBenefitPromotion(List<Promotion__c> promotions,Map<Id,Promotion__c> oldMap){
	List<Promotion__c> promotions_Activated = new List<Promotion__c>();
	for(Promotion__c prom : promotions){
	    
		if(prom.Type__c == 'Benefit' && oldMap.get(prom.id).Status__c != prom.Status__c && prom.Status__c == 'Active')
			promotions_Activated.add(prom);
	}
	if(promotions_Activated.size() > 0){
			List<Promotion__c> promsToUpdate = new List<Promotion__c>();
			List<Promotion__c> BenefitPromotions = new List<Promotion__c>([select Promotion_Code__c from Promotion__c where Type__c='Benefit' AND Status__c = 'Open' AND Promotion_Code__c != null limit 1000]);
			Integer i = 0;
			for(Promotion__c prom : promotions_Activated){
				if(BenefitPromotions.size() >= i+1){
					String code = BenefitPromotions[i].Promotion_Code__c;
					//prom.Promotion_Code__c = code;
					BenefitPromotions[i].Status__c = 'Used';
					BenefitPromotions[i].Promotion_Code__c = code+' - Used';
					promsToUpdate.add(new Promotion__c(id = prom.Id, Promotion_Code__c = code));
					promsToUpdate.add(BenefitPromotions[i]);
					i++;
				}else{Break;}
			}
			if(promsToUpdate.size() > 0) 
			  update promsToUpdate;
	}
  }
}