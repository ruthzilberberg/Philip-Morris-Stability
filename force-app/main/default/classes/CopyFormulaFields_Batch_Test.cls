@isTest 
private class CopyFormulaFields_Batch_Test {

	@isTest
	private static void Contact_Test() {
		Contact c= new Contact(LastName='test_contact');
        insert c;
		Database.executeBatch(new CopyFormulaFields_Batch('Contact'));
	}

	@isTest
	private static void Account_Test() {
		Database.executeBatch(new CopyFormulaFields_Batch('Account'));
	}
	@isTest
	private static void Lead_Test() {
		Database.executeBatch(new CopyFormulaFields_Batch('Lead'));
	}

	
}