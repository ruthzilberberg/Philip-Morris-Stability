/**
 * Created by samuel on 18/11/2018.
 */

public with sharing class OrderController {
    @AuraEnabled
    public static Order  getOrderDescription( Id OrderId ){
        return [SELECT Id,Name ,Account.FirstName,Account.LastName,Total_Amount__c,Payment_Token__c FROM Order where id=:OrderId];
    }

    @AuraEnabled
    public static void setAuthoriseError(String errorMsg,Order order){
        System.debug('ErrorMsg: ' + errorMsg );
        System.debug('order: ' + order );
        order.Integration_Error__c = 'Arvato Error: '+ String.valueOf( errorMsg );
        order.Integration_Status__c =   'Failed';
        update order;
    }

    @AuraEnabled
    public static void setAuthoriseSuccess(String token,Order order){
        order.Payment_Token__c  =   token;
        order.Integration_Error__c = '';
        update order;
    }
    
    @AuraEnabled
    public static ServiceCredential__c getSettings(){
        ServiceCredential__c srvCredential  =   ServiceCredential__c.getValues('OrderFull');
        System.debug('srvCredential : ' + srvCredential );
        return srvCredential;
//      return [Select Css__c,Domain__c,Endpoint__c,Password__c,TokenUrl__c,Username__c,CssContent__c From ServiceCredential__c where Name = 'OrderFull'];
    }
    
    @AuraEnabled
    public static String getServiceToken(){
        System.debug('called');

        servicesArvatoCom.BasicHttpBinding_SoapTransactionService sw  = new servicesArvatoCom.BasicHttpBinding_SoapTransactionService();
//        sw.srvCredential = ServiceCredential__c.getValues('OrderFull');
        System.debug('==================' + sw.srvCredential);

//        servicesArvatoCom.BasicHttpBinding_SoapTransactionService sw  =    new servicesArvatoCom.BasicHttpBinding_SoapTransactionService();

        schemasDatacontractOrg200407PmgExt.ResponseGetSecurityToken response =   sw.GetSecurityToken(new schemasDatacontractOrg200407PmgExt.RequestGetSecurityToken());
        System.debug( 'response : ' + response );
        System.debug( 'SecurityToken : ' + response.SecurityToken );
        System.debug( 'RSAPublicKey : ' + response.RSAPublicKey );

        return response.SecurityToken;

    }

//    public static String getAuthorise(){
//        servicesArvatoCom.BasicHttpBinding_SoapTransactionService sw  =    new servicesArvatoCom.BasicHttpBinding_SoapTransactionService();
//
//        schemasDatacontractOrg200407PmgExt.ResponseAuthorize response = sw.Authorize(new schemasDatacontractOrg200407PmgExt.RequestAuthorize());
//    }
    
//    public static string getSoapRequest(String token){
//
//       OasisOpenOrgWssSecuritySecext.UsernameToken usrTkn = new OasisOpenOrgWssSecuritySecext.UsernameToken('Philip_Morris_IL_SF_shop','PM_ilsf_2018!');
//       String soapMsgHeader = '<soapenv:Header>' +
//    '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
//        +'<wsse:UsernameToken wsu:Id="UsernameToken-2E66C7C5CE47F74A5314575223194135">'+
//            +'<wsse:Username>Philip_Morris_IL_SF_shop</wsse:Username>'+
//            +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">PM_ilsf_2018!</wsse:Password>'+
//            +'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'+usrTkn.Nonce+'</wsse:Nonce>'+
//            +'<wsu:Created>' + usrTkn.Created + '</wsu:Created></wsse:UsernameToken></wsse:Security></soapenv:Header>';
//        String soapBody = '<soapenv:Body><ser:Authorize><ser:request>'+
//            +'<pmg:CorrelationId>2</pmg:CorrelationId><pmg1:ClientIp>2</pmg1:ClientIp><pmg1:CountryCode>ca</pmg1:CountryCode><pmg1:Culture>ca</pmg1:Culture>'+
//            +'<pmg1:Currency>usd</pmg1:Currency><pmg1:ExternalId>12</pmg1:ExternalId><pmg1:Order>'+
//            +'<pmg:Amount>3</pmg:Amount><pmg:BillingAddress><pmg:City>1</pmg:City><pmg:Company>a</pmg:Company><pmg:CountryCode>r</pmg:CountryCode><pmg:Email>tst@g.com</pmg:Email>'+
//            +'<pmg:FirstName>h</pmg:FirstName><pmg:LastName>d</pmg:LastName><pmg:Phone>0771234567</pmg:Phone><pmg:State>ca</pmg:State><pmg:Street1>12</pmg:Street1></pmg:BillingAddress>'+
//            +'<pmg:Description>test</pmg:Description></pmg1:Order><pmg1:PaymentMethodName>credit</pmg1:PaymentMethodName><pmg1:PaymentToken>'+token +'</pmg1:PaymentToken>'+
//            +'<pmg1:CustomerId>12</pmg1:CustomerId><pmg1:RegistrationToken>'+ token +'</pmg1:RegistrationToken>'+
//            +'</ser:request></ser:Authorize></soapenv:Body>';
//      String  soapBody2 = '<soapenv:Body><ser:Authorize><ser:request><pmg1:CountryCode>DE</pmg1:CountryCode><pmg1:Culture>EN-US</pmg1:Culture>'+
//            +'<pmg1:Currency>EUR</pmg1:Currency><pmg1:ExternalId>${=org.apache.commons.lang.RandomStringUtils.randomNu-meric(10)}</pmg1:ExternalId><pmg1:Order>'+
//            +'<pmg:Amount>70</pmg:Amount><pmg:OrderItems><pmg:OrderItemInfo><pmg:Currency>EUR</pmg:Currency><pmg:ProductName>testprodukt 1</pmg:ProductName>'+
//            +'<pmg:Quantity>5</pmg:Quantity><pmg:UnitPrice>10.00</pmg:UnitPrice><pmg:ProductCode>0001</pmg:ProductCode><pmg:VAT>10</pmg:VAT>'+
//            +'</pmg:OrderItemInfo><pmg:OrderItemInfo><pmg:Currency>EUR</pmg:Currency><pmg:ProductName>testprodukt 2</pmg:ProductName><pmg:Quantity>4</pmg:Quantity>'+
//            +'<pmg:UnitPrice>5.00</pmg:UnitPrice><pmg:ProductCode>0002</pmg:ProductCode><pmg:VAT>5</pmg:VAT></pmg:OrderItemInfo></pmg:OrderItems></pmg1:Order>'+
//            +'<pmg1:PaymentMethodName>PayPal PayPal(PayPal)</pmg1:PaymentMethodName><pmg1:PaymentToken>282aaa32-fd48-4ac8-bc29-478f70cdfcb2</pmg1:PaymentTo-ken>'+
//            +'<pmg1:ReturnUrl>https://test.arvato-payment.de</pmg1:ReturnUrl><pmg1:RegistrationToken>'+ token +'</pmg1:RegistrationToken></ser:request></ser:Authorize></soapenv:Body>';
//        String soapRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.arvato.com" xmlns:pmg="http://schemas.datacontract.org/2004/07/Pmg.ExternalApi.V2.Model" xmlns:pmg1="http://schemas.datacontract.org/2004/07/Pmg.ExternalApi.V2.Model.Requests" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays">'+
//                            +''+soapMsgHeader+''+soapBody2 + '</soapenv:Envelope>';
//
//         return soapRequest;
//
//    }
//
//    public static string getSoapReq2(String token){
//
//       OasisOpenOrgWssSecuritySecext.UsernameToken usrTkn = new OasisOpenOrgWssSecuritySecext.UsernameToken('Philip_Morris_IL_SF_shop','PM_ilsf_2018!');
//       String soapMsgHeader = '<soapenv:Header>' +
//    '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
//        +'<wsse:UsernameToken wsu:Id="UsernameToken-2E66C7C5CE47F74A5314575223194135">'+
//            +'<wsse:Username>Philip_Morris_IL_SF_shop</wsse:Username>'+
//            +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">PM_ilsf_2018!</wsse:Password>'+
//            +'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">'+usrTkn.Nonce+'</wsse:Nonce>'+
//            +'<wsu:Created>' + usrTkn.Created + '</wsu:Created></wsse:UsernameToken></wsse:Security></soapenv:Header>';
//       String msg = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://services.arvato.com" xmlns:pmg="http://schemas.datacon-tract.org/2004/07/Pmg.ExternalApi.V2.Model" xmlns:pmg1="http://schemas.datacon-tract.org/2004/07/Pmg.ExternalApi.V2.Model.Requests" xmlns:arr="http://schemas.mi-crosoft.com/2003/10/Serialization/Arrays" xmlns:c="http://www.w3.org/2001/XMLSchema" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
//    +soapMsgHeader + '<soapenv:Body>'+
//        +'<ser:Authorize><ser:request><pmg1:CountryCode>DE</pmg1:CountryCode><pmg1:Culture>EN-US</pmg1:Culture><pmg1:Currency>EUR</pmg1:Currency><pmg1:ExternalId>${=org.apache.commons.lang.RandomStringUtils.randomNu-meric(10)}</pmg1:ExternalId>'+
//        +'<pmg1:Order><pmg:Amount>70</pmg:Amount><pmg:OrderItems><pmg:OrderItemInfo><pmg:Currency>EUR</pmg:Currency><pmg:ProductName>testprodukt 1</pmg:ProductName><pmg:Quantity>5</pmg:Quantity><pmg:UnitPrice>10.00</pmg:UnitPrice>'+
//        +'<pmg:VAT>10</pmg:VAT></pmg:OrderItemInfo><pmg:OrderItemInfo><pmg:Currency>EUR</pmg:Currency><pmg:ProductName>testprodukt 2</pmg:ProductName><pmg:Quantity>4</pmg:Quantity><pmg:UnitPrice>5.00</pmg:UnitPrice><pmg:ProductCode>0002</pmg:ProductCode>'+
//        +'<pmg:VAT>5</pmg:VAT></pmg:OrderItemInfo></pmg:OrderItems></pmg1:Order><pmg1:PaymentMethodName>PayPal PayPal(PayPal)</pmg1:PaymentMethodName><pmg1:PaymentToken>282aaa32-fd48-4ac8-bc29-478f70cdfcb2</pmg1:PaymentToken><pmg1:ReturnUrl>https://test.arvato-payment.de</pmg1:ReturnUrl>'+
//        +'<pmg1:RegistrationToken>'+ token +'</pmg1:RegistrationToken></ser:request></ser:Authorize></soapenv:Body></soapenv:Envelope>';
//
//       return msg;
//    }
}