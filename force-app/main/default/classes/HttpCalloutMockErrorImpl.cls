@isTest
global class HttpCalloutMockErrorImpl implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);

        return res;
    }
}