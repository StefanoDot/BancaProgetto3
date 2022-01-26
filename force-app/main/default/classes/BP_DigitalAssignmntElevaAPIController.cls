public class BP_DigitalAssignmntElevaAPIController {
    
    @future(callout=true)
    public static void interruptRequest(String oppId) {
        
        try {
            List<Opportunity> updatedOppLst = new List<Opportunity>();
            
            List<ElevaCredentials__mdt> elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
            ElevaCredentials__mdt elevaMoonCredentials = new ElevaCredentials__mdt();
            if (elevaCredentials.size() > 0) {
                elevaMoonCredentials = elevaCredentials[0];
            }
            
            String root = elevaMoonCredentials.root__c;                
            String endpoint = 'onboarding/census';
            String url = '' + root + endpoint;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
            req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
            req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
            req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
            req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
            req.setTimeout(100000);
            
            req.setBody('{"opportunityId":"'+oppId+'"}');
            
            Http h = new Http();
            HttpResponse res = h.send(req);
            string StatusCode = String.valueOf(res.getStatusCode());
            String StrError='';
            
            if (res.getStatusCode() == 200) {
                
                updatedOppLst.add( new Opportunity(Id = oppId, StatusOnboarding__c = 'Terminata',StatusVideoconferenza__c = 'Interrotta'));
                
            } else {
                
            }
            
            if(! updatedOppLst.isEmpty()) {
                update updatedOppLst;
            }
            CalloutLoggerService.saveCalloutLogger(url,StatusCode,'DELETE',oppId,req.getBody(),res.getBody(),endpoint);
            
            
        } catch (Exception e) {
            system.debug('getMoreScore Exeption: '+ e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void bookVideoConference(String oppId,String requestStr) {
		
        List<Opportunity> updatedOppLst = new List<Opportunity>();  
        
        List<ElevaCredentials__mdt> elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        ElevaCredentials__mdt elevaMoonCredentials = new ElevaCredentials__mdt();
        if (elevaCredentials.size() > 0) {
            elevaMoonCredentials = elevaCredentials[0];
        }
        String root = elevaMoonCredentials.root__c;                
        String endpoint = 'onboarding/census';
        String url = '' + root + endpoint;
        
        //Making a call to Eleva to send Contract and other information
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        //Serializing the wrapper object and setting up request body
        req.setBody(requestStr);
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        string StatusCode = String.valueOf(res.getStatusCode());
        String StrError='';
        
        
        if (res.getStatusCode() == 200) {
            
            updatedOppLst.add( new Opportunity(Id = oppId, StatusOnboarding__c = 'Richiesta'));
        } 
        else {
            updatedOppLst.add( new Opportunity(Id = oppId, StatusOnboarding__c = 'Richiesta KO per problemi tecnici'));
        }
        
       
        if(! updatedOppLst.isEmpty()) {
            update updatedOppLst;
        }
        CalloutLoggerService.saveCalloutLogger(url,StatusCode,'POST',oppId,req.getBody(),res.getBody(),endpoint);
    }
    
}