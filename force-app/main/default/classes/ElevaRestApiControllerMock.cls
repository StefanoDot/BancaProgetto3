global class ElevaRestApiControllerMock implements HttpCalloutMock {
	public ElevaRestApiControllerMock() {   }
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"MOCKSERVICE":"MOCKRES"}');
        res.setStatusCode(200);
        return res;

    }
}