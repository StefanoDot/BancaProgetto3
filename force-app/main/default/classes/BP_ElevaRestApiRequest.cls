public with sharing class BP_ElevaRestApiRequest {
    public static HttpRequest elevaCredentialsReq(String endpoint, String method, String body) {
        
        List<ElevaCredentials__mdt> elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        ElevaCredentials__mdt elevaMoonCredentials = new ElevaCredentials__mdt();
        HttpRequest req = new HttpRequest();
            if (elevaCredentials.size() > 0) {
                elevaMoonCredentials = elevaCredentials.get(0);
                system.debug('*** *** START elevaMoonCredentials ' + elevaMoonCredentials);
                String root = elevaMoonCredentials.root__c;
                String url = '' + root + endpoint;
                String nonce = Utils.generateRandomString(20);
                req.setEndpoint(url);
                req.setMethod(method);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
                req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
                req.setHeader('x-nonce', nonce);
                req.setHeader('x-hmac', Utils.generateSignature('IT', 'EXT', method,nonce));
                req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
                req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
                req.setTimeout(100000);
                req.setBody(body);   
               
  
            }
        return req;
    } 
    public static HttpRequest elevaCredentialsReqDes(String endpoint, String method, String body, String serializedElevaCredentials) {
        List<ElevaCredentials__mdt> elevaCredentials = new List<elevaCredentials__mdt>();
        ElevaCredentials__mdt deserialElevaCredentials = (ElevaCredentials__mdt) JSON.deserialize(serializedElevaCredentials, System.Type.forName('ElevaCredentials__mdt'));
            System.debug('Eleva RestApi Deserial Credential'+ deserialElevaCredentials);
            elevaCredentials.add(deserialElevaCredentials);
            System.debug('List<ElevaCredentials_mdt> : '+ elevaCredentials);
        ElevaCredentials__mdt elevaMoonCredentials = new ElevaCredentials__mdt();
        HttpRequest req = new HttpRequest();
        if (elevaCredentials.size() > 0) {
            elevaMoonCredentials = elevaCredentials.get(0);
            String root = elevaMoonCredentials.root__c;
            String url = '' + root + endpoint;
            String nonce = Utils.generateRandomString(20);

            req.setEndpoint(url);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
            req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
            req.setHeader('x-nonce', nonce);
            req.setHeader('x-hmac', Utils.generateSignature('IT', 'EXT', method,nonce));
            req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
            req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
            req.setTimeout(100000);
            req.setBody(body);
        }
         return req;
    }

public static Utils.FidejussoreResponse elevaCredentialsResponseMap(Map<String, String> params) {
    Utils.FidejussoreResponse response=new Utils.FidejussoreResponse();
    System.debug('elevaCredentialsResponseMap ' + JSON.serialize(params));
    try {
    HttpRequest req = BP_ElevaRestApiRequest.elevaCredentialsReq(params.get('endpoint'),params.get('method'), params.get('body'));
    System.debug('elevaCredentialsResponseMap  req   '+req);
    Http h = new Http();
    HttpResponse res = h.send(req);
    String StatusCode = String.valueOf(res.getStatusCode());
    response.statusCode = String.valueOf(res.getStatusCode());  
    String StrError='';
    if (res.getStatusCode() == 200) {
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String resultStr = JSON.serialize(results.get('result'));
        String totalStr = params.get('nameString') + ' SUCCESS :: ' + resultStr + ' :: ' + UserInfo.getName() + ' :: ' + Datetime.now();
        response.ok=true;
    } else {
    
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String resultStr = JSON.serialize(results.get('result'));
        String totalStr = params.get('nameString') + ' ERROR :: ' + resultStr + ' :: ' + UserInfo.getName() + ' :: ' + Datetime.now();
        
        response.ok=false;
        response.responseMessage = params.get('errorString')+ (results.get('faults'));
        
        if(results.get('faults')!=null){
            String fault=String.valueof( results.get('faults'));
            list<String> split =fault.split(',');
            for(String s: split){
                if(s.contains('faultMessage')){
                    response.responseMessage =s.remove('faultMessage=');
                    StrError= s.remove('faultMessage=');
                }
            }
            response.responseMessage = params.get('errorString') + StrError ;
        }
 
    }
CalloutLoggerService.saveCalloutLogger(req.getEndpoint(),StatusCode,params.get('method'),params.get('recordId'),req.getBody(),res.getBody(),params.get('endpoint'));
System.debug('elevaCredentialsResponseMap response ' + response); 
return response;
   
} catch (Exception e) {
    //   throw ErrorLogEventHandler.standardExceptionLog(e);
    response.ok=false;
    response.responseMessage=e.getMessage();
    System.debug('elevaCredentialsResponseMap response error ' + response);
    return response;
    
}

}
public static Utils.FidejussoreResponse elevaCredentialsRespMapDes(Map<String, String> params) {
    Utils.FidejussoreResponse response=new Utils.FidejussoreResponse();
    
    try {
    HttpRequest req = BP_ElevaRestApiRequest.elevaCredentialsReqDes(params.get('endpoint'),params.get('method'), params.get('body'), params.get('serializedElevaCredentials'));
    Http h = new Http();
    HttpResponse res = h.send(req);
    String StatusCode = String.valueOf(res.getStatusCode());
    response.statusCode = String.valueOf(res.getStatusCode());  
    String StrError='';
    if (res.getStatusCode() == 200) {
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String resultStr = JSON.serialize(results.get('result'));
        String totalStr = params.get('nameString') + ' SUCCESS :: ' + resultStr + ' :: ' + UserInfo.getName() + ' :: ' + Datetime.now();
        response.ok=true;
    } else {
            
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String resultStr = JSON.serialize(results.get('result'));
        String totalStr = params.get('nameString') + ' ERROR :: ' + resultStr + ' :: ' + UserInfo.getName() + ' :: ' + Datetime.now();
        
        response.ok=false;
        response.responseMessage = params.get('errorString')+ (results.get('faults'));
        
        if(results.get('faults')!=null){
            String fault=String.valueof( results.get('faults'));
            list<String> split =fault.split(',');
            for(String s: split){
                if(s.contains('faultMessage')){
                    response.responseMessage =s.remove('faultMessage=');
                    StrError= s.remove('faultMessage=');
                }
            }
            response.responseMessage = params.get('errorString') + StrError ;
        }
 
    }
CalloutLoggerService.saveCalloutLogger(req.getEndpoint(),StatusCode,params.get('method'),params.get('recordId'),req.getBody(),res.getBody(),params.get('endpoint'));
    return response;
   
} catch (Exception e) {
    //   throw ErrorLogEventHandler.standardExceptionLog(e);
    response.ok=false;
    response.responseMessage=e.getMessage();
    return response;
}
}
}