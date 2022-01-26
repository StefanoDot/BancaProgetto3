@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    
    public String accIds;  

  	global MockHttpResponseGenerator (String aa){
      this.accIds=aa;
  }

    
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        
        if(accIds=='error'){  
        res.setStatusCode(400);
        res.setBody('{"timeStamp":"2021-01-12T11:26:01.743563Z","environment":{"label":"TEST","node":"546a710d17df"},"faults":[{"faultLevel":"TEST","faultCode":"test","faultDescription":"test","faultMessage":"test","service":"test","origin":"test","fields":[]}]}');
        }
            if(accIds=='success')
        res.setStatusCode(200);
        
        return res;
    }
  
     
}