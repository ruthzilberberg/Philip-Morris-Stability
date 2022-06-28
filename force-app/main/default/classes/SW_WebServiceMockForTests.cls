/**
 * Created by samuel on 03/12/2018.
 */

@isTest
global class SW_WebServiceMockForTests implements WebServiceMock {

    global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
        System.debug('=======in Mock' );

        //servicesarvatocom.basichttpbinding_soaptransactionservice sw  = new servicesarvatocom.basichttpbinding_soaptransactionservice();
        //system.debug('=======' + sw.srvcredential);
        schemasDatacontractOrg200407PmgExt.ResponseGetSecurityToken response_x = new schemasDatacontractOrg200407PmgExt.ResponseGetSecurityToken();
		servicesArvatoCom.GetSecurityTokenResponse_element response_1x = new servicesArvatoCom.GetSecurityTokenResponse_element();
        response_1x.GetSecurityTokenResult = response_x;
        response_x.SecurityToken ='';
        response_x.RSAPublicKey = 'test';
		response_x.Error = new schemasDatacontractOrg200407PmgExt.Error();
		response_x.Error.Message ='errorTest';
        response_x.Error.Details='detailTest';
        response_x.Error.ErrorCode='ErrorCodeTest';
        response_x.Error.InnerErrors = new schemasDatacontractOrg200407PmgExt.ArrayOfErrorAuthorisation();
        schemasDatacontractOrg200407PmgExt.ErrorAuthorisation errAuth = new schemasDatacontractOrg200407PmgExt.ErrorAuthorisation();
        errAuth.ErrorCode='ErrorCode';
//        response_x.Error.InnerErrors.
        response_x.Error.PspErrorCode='PspErrorCode';
        response_x.Error.PspErrorMessage='PspErrorMessage';
		response_x.ShopAction = new schemasDatacontractOrg200407PmgExt.ShopAction();
        response_x.ShopActionRequired =true;
        response_x.Success =true;
        response.put('response_x', response_1x);


    }


}