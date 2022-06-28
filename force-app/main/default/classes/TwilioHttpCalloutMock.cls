@isTest
public class TwilioHttpCalloutMock implements HttpCalloutMock {

    public String status = 'completed';

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(
            '{"sid":"RM0db30e9",' +
            '"unique_name":"RM0db30e9",' +
            '"status":"' + status + '"}'
        );
        response.setStatusCode(200);
        return response;
    }

}