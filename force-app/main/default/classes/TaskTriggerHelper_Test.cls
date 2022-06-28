@isTest 
private class TaskTriggerHelper_Test {

	@isTest
	private static void populateTemplateWithValues_Test() {
	      Lead myLead = new Lead( LastName='Test', DCS_ID__c = 'DCS Test 1234');
         insert myLead;
		// Account acc = new Account(lastName = 'acc Test ', dcs_Id__c =  'DCS Test 1234');
		// insert acc;
		 SMS_Template__c SMS_Template = new SMS_Template__c();
		 SMS_Template.Name = 'my Test Template Name';
		 SMS_Template.SMS_Template__c = 'Hi {{{Lead.LastName}}}, We Are Haapy to Say That The Lead {{{Account.Name}}} Has Been Deliverd';
		 SMS_Template.Status__c = 'Published';
		 insert SMS_Template;
		 Task myTask  = new Task(whoid = myLead.id, SMS_Template__c = SMS_Template.Id,Subject='my Subject');
		 insert myTask;

		 myTask.SMS_Template__c = null;
		 update myTask;

		 myTask.SMS_Template__c = SMS_Template.Id;
		 update myTask;
	}
}