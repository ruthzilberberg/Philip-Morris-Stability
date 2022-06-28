@isTest 
private class FieldMappingHandler_Test {

	@TestSetup
	 static void tstSetup(){
		Workflows_and_PB__c sc = new Workflows_and_PB__c(Order__c = true);
		insert sc;
	}
	
	@isTest 
	private static void fieldMappingHandler_test1() {
	    Account acc = new Account(LastName = 'test lastName',PersonBirthdate = System.today().addYears(-222),Terms_and_Conditions__pc = true,ID__pc = '111111118');
		insert acc;
		id stndPB = Test.getStandardPricebookId();
		Order myOrder = new Order(AccountId = acc.Id, Status= 'Draft', EffectiveDate = System.today(), Pricebook2Id = stndPB);
		insert myOrder;
		Map<String,String> attMap = FieldMappingHandler.getAttributeMap(myOrder.Id,'YaadPayment','isPay__c');
		//where isUpdateOnSuccess__c = true And 
		List<FieldMapping__mdt> resMapping = [Select FieldApiName__c,MappingName__c,AdditionalRelationship__c From FieldMapping__mdt where MappingName__c != null And ObjectMapping__r.MasterLabel = 'YaadPayment'];
		Map<String,String> resMap = new Map<String,String>();
		for(FieldMapping__mdt fm  :resMapping){
		   resMap.put(fm.MappingName__c,'val');
		}
		FieldMappingHandler.getObjectToUpdateByMapping(myOrder.Id,'YaadPayment',resMap,true,'isPay__c');
		FieldMappingHandler.SettingWrapper sw = new FieldMappingHandler.SettingWrapper('','','cs');
		sw.isCustomSetting();
		FieldMappingHandler.getObjectToUpdateByMappingByReturnType(myOrder.Id,'YaadPayment',resMap,'success','isPay__c');
		FieldMappingHandler.getUpdateType('success');
		FieldMappingHandler.getUpdateType('failure');
		FieldMappingHandler.getUpdateType('pending');
		FieldMappingHandler.getObjApi('currentuser');
		FieldMappingHandler.getObjApi('non');
		FieldMappingHandler.ConvertMapToString(resMap,true);
		FieldMappingHandler.ConvertParamToMap('x=1&y=2');
		resMapping = [Select FieldApiName__c,MappingName__c,AdditionalRelationship__c From FieldMapping__mdt where AdditionalRelationship__c != null And MappingName__c != null And ObjectMapping__r.MasterLabel = 'YaadPayment'];
		for(FieldMapping__mdt fm  :resMapping){
		   resMap.put(fm.MappingName__c,'val');
		}
		FieldMappingHandler.getAdditionalRelationShips(resMap);
	}
}