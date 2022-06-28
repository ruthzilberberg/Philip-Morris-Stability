@isTest 
private class PromotionTriggerHelper_Test {

	@isTest
	private static void testName() {
	 Test.startTest();
		Promotion__c free = new Promotion__c(status__c = 'Open', Promotion_Code__c ='5556', Type__c = 'Benefit'); //free bbenefit
        Promotion__c prom = new Promotion__c(status__c = 'Open', Promotion_Code__c ='123456', Type__c = 'Benefit'); //record for trigger
		insert new List<Promotion__c>{free, prom};

		prom.Status__c = 'Active';
		update prom;
	    Test.stopTest();
	}
}