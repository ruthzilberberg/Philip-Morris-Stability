/**
 * Created by samuel on 03/12/2018.
 */
    @isTest
private class Order_Arvato_test{
    @isTest
    private static void WebService_GetSecurityToken() {

//        schemasDatacontractOrg200407PmgExt.RequestGetSecurityToken  req = new schemasDatacontractOrg200407PmgExt.RequestGetSecurityToken();
//        req.UsesCount = 2;
        ServiceCredential__c srv= new ServiceCredential__c(Name = 'OrderFull', Endpoint__c = 'https://test.arvato-payment.com', Username__c = 'testuser', Password__c = 'PasswordTest');
        insert srv;
        City__c cityName = new City__c(Name='cityTest');
        insert cityName;
        Street_Index__c str = new Street_Index__c(Name='test',Street__c='StreetTest',City__c=cityName.Id);
        insert str;
        Account acc = new Account(Name='TestAcc');
        insert acc;
        Order ord =new Order(Name='test',AccountId=acc.Id,EffectiveDate=System.today(),Shipping_Street__c=str.Id,Shipping_Street_Number__c='12');
        insert ord;
        System.debug('=======in Mock' + srv );

        Test.startTest();
        Test.setMock(WebServiceMock.class, new SW_WebServiceMockForTests());

//        servicesArvatoCom.BasicHttpBinding_SoapTransactionService sw  = new servicesArvatoCom.BasicHttpBinding_SoapTransactionService();
//        sw.GetSecurityToken(new schemasDatacontractOrg200407PmgExt.RequestGetSecurityToken());
//        schemasDatacontractOrg200407PmgExt.ResponseGetSecurityToken response =servicesArvatoCom.GetSecurityToken(req);
        OrderController.getOrderDescription(ord.Id);
        OrderController.getServiceToken();
        OrderController.setAuthoriseError('00000000',ord);
        OrderController.setAuthoriseSuccess('00000000',ord);
        Test.stopTest();

    }
}