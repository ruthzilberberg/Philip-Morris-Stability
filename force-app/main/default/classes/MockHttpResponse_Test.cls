@isTest 
global class MockHttpResponse_Test implements HttpCalloutMock{

	    // Implement this interface method
		global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
		
		if(req.getEndpoint().containsIgnoreCase('testYaad.tst.com')){	
			res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			res.setBody('Token=123&Tokef=123&CCode=0&Amount=3');
		}
		res.setStatusCode(200);
		return res;
    }
}