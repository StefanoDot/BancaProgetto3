/**
 * Created by ACAPUTO00 on 10/02/2020.
 */

public with sharing class CalloutLoggerService {

    public static void saveCalloutLogger(String endpoint, String errorMessage, String httpMethod, String recordId, String request, String response, String service){
        System.debug('CalloutLoggerService saveCalloutLogger --Start endpoint: '+endpoint+' errorMessage: '+errorMessage+
        ' httpMethod: '+httpMethod+' recordId: '+recordId+' request: '+request+' response: '+response+' service: '+service);

        Callout_Logger__c cl = new Callout_Logger__c();
        Datetime now = Datetime.now();
        String unReq = request.unescapeHtml4();
        String unRes = response.unescapeHtml4();

        cl.Endpoint__c = endpoint;
        cl.ErrorMessage__c = errorMessage;
        cl.HTTPMethod__c = httpMethod;
        cl.RecordID__c = recordId;
        cl.Request__c = unReq;
        cl.Response__c = unRes;
        cl.Service__c = service;
        cl.Timestamp__c = now;

        System.debug('CalloutLoggerService saveCalloutLogger --End insert: '+cl);
        insert cl;

    }

}