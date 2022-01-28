public with sharing class ElevaRestApiController {
    public static Utils_Constants constants = new Utils_Constants();
    
    
    // 1.1 - Invio richiesta dati Anagrafica Light + MoreScore

    public static Utils.FidejussoreResponse getMoreScore1(String taxCode, String accountId,String userMail,String oplonSubjectId) {     
            RequestBodyGetMoreScore bodyGetMoreScore = new RequestBodyGetMoreScore(taxCode, accountId, userMail,oplonSubjectId);
          
            Map<String, String> elevaParams = new Map<String, String>{
                'endpoint' => 'smelending/morescore',
                'method' => 'POST',
                'body' => JSON.serialize(bodyGetMoreScore),
                'nameString' => 'GetMoreScore ',
                'erroreString' => 'Errore invocazione servizio: ',
                'recordId' => accountId
            };

            Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            String StatusCode = res.statusCode;
            Account Acc = new Account();
            Acc.Id=accountId;
            if (res.ok == true) {
                Acc.Errore_Anagraphica_Light__c = '';

            } else {
                    if (Acc.CodiceKoOplon__c != StatusCode){
                        Acc.CodiceKoOplon__c = StatusCode;
                        Acc.Errore_Anagraphica_Light__c = elevaParams.get('erroreString');      
            }
        }
            AccountsController.bypassTrigger=true;
            update acc;
            AccountsController.bypassTrigger=false;
            return res;
    }


    @future(callout=true)
    public static void getMoreScore(String taxCode, String accountId,String userMail,String oplonSubjectId) {
        RequestBodyGetMoreScore bodyGetMoreScore = new RequestBodyGetMoreScore(taxCode, accountId, userMail,oplonSubjectId);
          
            Map<String, String> elevaParams = new Map<String, String>{
                'endpoint' => 'smelending/morescore',
                'method' => 'POST',
                'body' => JSON.serialize(bodyGetMoreScore),
                'nameString' => 'GetMoreScore ',
                'erroreString' => 'Errore invocazione servizio: ',
                'recordId' => accountId
            };

            Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            String StatusCode = res.statusCode;
            Account Acc = new Account();
            Acc.Id=accountId;
            if (res.ok == true) {
                Acc.Errore_Anagraphica_Light__c = '';

            } else {
                    if (Acc.CodiceKoOplon__c != StatusCode){
                        Acc.CodiceKoOplon__c = StatusCode;
                        Acc.Errore_Anagraphica_Light__c = elevaParams.get('erroreString');
            }
        }
            AccountsController.bypassTrigger=true;
            update acc;
            AccountsController.bypassTrigger=false;
    }
    
    
    
    @future(callout=true)
    public static void getMoreScoreTrigger(String taxCode, String accountId,String userMail,String oplonSubjectId,  String serializedElevaCredentials) { 
        RequestBodyGetMoreScore bodyGetMoreScore = new RequestBodyGetMoreScore(taxCode, accountId, userMail,oplonSubjectId);
          
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/morescore',
            'method' => 'POST',
            'body' => JSON.serialize(bodyGetMoreScore),
            'nameString' => 'GetMoreScore ',
            'erroreString' => 'Errore invocazione servizio: ',
            'recordId' => accountId,
            'serializedElevaCredentials' => serializedElevaCredentials
        };

        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
        String StatusCode = res.statusCode;
        Account Acc = new Account();
        Acc.Id=accountId;
        if (res.ok == true) {
            Acc.Errore_Anagraphica_Light__c = '';

        } else {
            if (Acc.CodiceKoOplon__c != StatusCode){
                Acc.CodiceKoOplon__c = StatusCode;
                Acc.Errore_Anagraphica_Light__c = elevaParams.get('erroreString');
            }
        }
        AccountsController.bypassTrigger=true;
        update acc;
        AccountsController.bypassTrigger=false;
    }
    public class RequestBodyGetMoreScore {
        public String fiscalCode;
        public String accountId;
        public String userEmail;
        public String oplonSubjectId;
        
        /*public RequestBodyGetMoreScore(String fiscalCode, String accountId) {
system.debug('ElevaRestApiController RequestBodyGetMoreScore - Start');
this.fiscalCode = fiscalCode;
this.accountId = accountId;
system.debug('ElevaRestApiController RequestBodyGetMoreScore - End');
}*/
      public RequestBodyGetMoreScore(String fiscalCode, String accountId,String userEmail,String oplonSubjectId) {
            system.debug('ElevaRestApiController RequestBodyGetMoreScore - Start');
            this.fiscalCode = fiscalCode;
            this.accountId = accountId;
            this.userEmail=  userEmail;
            this.oplonSubjectId = oplonSubjectId;
            
            system.debug('ElevaRestApiController RequestBodyGetMoreScore - End');
        }
    }
    
    //Metodo per scaricare i documenti Indrit 15/07
    
    
    
   // @future(callout=true)
    public static Utils.FidejussoreResponse DownloadDocs(String OpportunityId, String AccountId, List<Contact> ContactList) {
        RequestBodyDownload bodyDownload = new RequestBodyDownload(OpportunityId, AccountId,ContactList);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => '',
            'method' => 'POST',
            'body' => JSON.serialize(bodyDownload),
            'nameString' => 'Download Documenti ',
            'erroreString' => 'Errore File Documenti: ',
            'recordId' => OpportunityId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
         return res;
    
    }

 public class RequestBodyDownload{ 
        public String OpportunityId;
        public String AccountId;
        Public List<Contact> ContactList;
        
        public RequestBodyDownload(String  OpportunityId, String AccountId, List<Contact> ContactList) {
            this.OpportunityId   = OpportunityId;
            this.AccountId = AccountId;
            this.ContactList = ContactList;
        } 
 } 
 
    
    @future(callout=true)
    public static void CRreferentiTrigger(String ndg, String contactId,String serializedElevaCredentials) { 
        RequestCRreferenti bodyCRreferenti = new RequestCRreferenti(ndg, contactId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/start-cr',
            'method' => 'POST',
            'body' => JSON.serialize(bodyCRreferenti),
            'nameString' => 'GetMoreScore ',
            'erroreString' => 'Errore invocazione servizio: ',
            'recordId' => contactId,
            'serializedElevaCredentials' => serializedElevaCredentials
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
    }
    public class RequestCRreferenti {
        public String ndg;
        public String contactId;
        
        
        public RequestCRreferenti(String ndg, String contactId) {
          
            this.ndg = ndg;
            this.contactId = contactId;

        }
    }
    
    
    
    // 1.2 - Invio richiesta dati Anagrafica Full
    
    public static void getAnagraphicDetails(String taxCode, String accountId, String updateOplonUserEmail, String subjectId){
        //String userMail=Utils.getCurrentUserMail();
        List<Account> accounts=new list<Account>();
        Account acc= new Account(id=accountId);
        String userMail=Utils.getSalesDiRiferimentoAreaMail(accounts);
        //ElevaRestApiController.getMoreScore(taxCode,  accountId, userMail,oplonSubjectId);
        ElevaRestApiController.getAnagraphicDetails(taxCode,  accountId, userMail, updateOplonUserEmail, subjectId);
    }
    @future(callout=true)
    public static void getAnagraphicDetails(String taxCode, String accountId, String userEmail, String updateOplonUserEmail, string subjectId) {
        RequestBodygetAnagraphicDetails bodyGetAnagrafica = new RequestBodygetAnagraphicDetails(taxCode, accountId, userEmail, updateOplonUserEmail, subjectId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/company-data',
            'method' => 'PUT',
            'body' => JSON.serialize(bodyGetAnagrafica),
            'nameString' => 'GetAnagraphicDetails ',
            'erroreString' => 'Errore invocazione servizio: ',
            'recordId' => accountId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        String StatusCode = res.statusCode;
                Account Acc = new Account();
                Acc.Id=accountId;
                if (res.ok == true) {
                    Acc.Errore_Anagraphica_Full__c='';
                } else {
                        if (Acc.CodiceKoOplon__c != StatusCode){
                            Acc.CodiceKoOplon__c= StatusCode;
                            Acc.Errore_Anagraphica_Full__c = elevaParams.get('erroreString');
                        }
                    }
                AccountsController.bypassTrigger=true;
                update acc;
                AccountsController.bypassTrigger=false;
    }
    
    public static Utils.FidejussoreResponse getAnagraphicDetails1(String taxCode, String accountId, String userEmail, String updateOplonUserEmail, String subjectId) {
        RequestBodygetAnagraphicDetails bodyGetAnagrafica = new RequestBodygetAnagraphicDetails(taxCode, accountId, userEmail, updateOplonUserEmail, subjectId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/company-data',
            'method' => 'PUT',
            'body' => JSON.serialize(bodyGetAnagrafica),
            'nameString' => 'GetAnagraphicDetails ',
            'erroreString' => 'Errore invocazione servizio: ',
            'recordId' => accountId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        String StatusCode = res.statusCode;
                Account Acc = new Account();
                Acc.Id=accountId;
                if (res.ok == true) {
                    Acc.Errore_Anagraphica_Full__c='';
                } else {
                        if (Acc.CodiceKoOplon__c != StatusCode){
                            Acc.CodiceKoOplon__c= StatusCode;
                            Acc.Errore_Anagraphica_Full__c = elevaParams.get('erroreString');
                        }
                    }
                AccountsController.bypassTrigger=true;
                update acc;
                AccountsController.bypassTrigger=false;
            return res;
    }
    
    
    
    @future(callout=true)
    public static void getAnagraphicDetailsTrigger(String taxCode, String accountId, String userEmail,String serializedElevaCredentials, String updateOplonUserEmail, String subjectId ) {
        RequestBodygetAnagraphicDetails bodyGetAnagrafica = new RequestBodygetAnagraphicDetails(taxCode, accountId, userEmail, updateOplonUserEmail, subjectId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/company-data',
            'method' => 'PUT',
            'body' => JSON.serialize(bodyGetAnagrafica),
            'nameString' => 'GetAnagraphicDetails ',
            'erroreString' => 'Errore invocazione servizio: ',
            'recordId' => accountId,
            'serializedElevaCredentials' => serializedElevaCredentials
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
        String StatusCode = res.statusCode;
       
                Account Acc = new Account();
                Acc.Id=accountId;
                if (res.ok == true) {
                    Acc.Errore_Anagraphica_Full__c='';
                } else {
                        if (Acc.CodiceKoOplon__c != StatusCode){
                            Acc.CodiceKoOplon__c= StatusCode;
                            Acc.Errore_Anagraphica_Full__c = elevaParams.get('erroreString');
                        }
                    }
                AccountsController.bypassTrigger=true;
                update acc;
                AccountsController.bypassTrigger=false;
    }
    
    
    
    public class RequestBodygetAnagraphicDetails {
        public String fiscalCode;
        public String accountId;
        public String userEmail;
        public String updateOplonUserEmail;
        public String subjectId;
        
        
        public RequestBodygetAnagraphicDetails(String fiscalCode, String accountId,String userEmail, String updateOplonUserEmail, String subjectId) {
            system.debug('ElevaRestApiController RequestBodygetAnagraphicDetails - Start');
            this.fiscalCode = fiscalCode;
            this.accountId = accountId;
            this.userEmail=  userEmail;
            this.updateOplonUserEmail=  updateOplonUserEmail;
            this.subjectId = subjectId;
            
            
            system.debug('ElevaRestApiController RequestBodygetAnagraphicDetails - End');
        }
    }
    // 3.1 - Invio contatti da certificare
    
    public static String verifyContact(String contactId, String txtData, String txtType) {
       
        RequestBodyGetVerifyContact bodyGetVerifyContact = new RequestBodyGetVerifyContact(contactId, txtData, txtType);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/verify-contact',
            'method' => 'POST',
            'body' => JSON.serialize(bodyGetVerifyContact),
            'nameString' => 'VerifyContact ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => contactId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        String resultStr = res.responseMessage;
        
            return resultStr;
            
    }
    
    public class RequestBodyGetVerifyContact {
        public String contactId;
        public String data;
        public String type;
        
        public RequestBodyGetVerifyContact(String contactId, String data, String type) {
            system.debug('ElevaRestApiController RequestBodyGetVerifyContact - Start');
            this.contactId = contactId;
            this.data = data;
            this.type = type;
            system.debug('ElevaRestApiController RequestBodyGetVerifyContact - End');
        }
    }
    
    
    
    
    // 3.2 - Invio conferma certificazione
    
    public static String checkContact(String contactId, String txtCode, String txtType) {
        RequestBodyGetCheckContact bodyGetCheckContact = new RequestBodyGetCheckContact(contactId, txtCode, txtType);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/check-contact',
            'method' => 'PUT',
            'body' => JSON.serialize(bodyGetCheckContact),
            'nameString' => 'CheckContact ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => contactId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        String resultStr = res.responseMessage;
        
            return resultStr;
    }
    
    public class RequestBodyGetCheckContact {
        public String contactId;
        public String code;
        public String type;
        
        public RequestBodyGetCheckContact(String contactId, String code, String type) {
            system.debug('ElevaRestApiController RequestBodyGetCheckContact- Start');
            this.contactId = contactId;
            this.code = code;
            this.type = type;
            system.debug('ElevaRestApiController RequestBodyGetCheckContact- End');
        }
    }
    
    
    
    // 2.1 - Invio/Update documentazione per RapidoECM
    // 2.1 - Aggiunto Campo Formula per recupero mail user
    public static void storeDocumentBatch(String fileId,
                                          String filename, 
                                          String documentId,                                           
                                          String documentFamily, 
                                          String objectId,
                                          String accountId,
                                          Datetime uploadDate,
                                          String documentTypeId, 
                                          String docName,
                                          String taxCode, 
                                          String contractNumber,
                                          Datetime stipulationDate,
                                          String description, 
                                          String idOplon,
                                          String stage,
                                          String objectType, 
                                          String userEmail,
                                          String contactTaxCode,
                                          String nominativoReferente,
                                          String contactIdSalesforce,
                                          String action,
                                          String gui
                                         )
    {
         FileUploadBatch fb=new FileUploadBatch(
            fileId,
            filename,
            documentId,       
            documentFamily,
            objectId,
            accountId,
            uploadDate,       
            documentTypeId,
            docName, 
            taxCode, 
            contractNumber,
            stipulationDate,
            description,
            idOplon, 
            stage,
            objectType, 
            userEmail,
            contactTaxCode,
            nominativoReferente,
            contactIdSalesforce,
            action,
            gui
        );
        Database.executeBatch(fb, 1); 
    }
    public static void storeDocumentBatchContrata(String fileId,
                                                  String filename,                                          
                                                  String processGuid, 
                                                  String documentId,
                                                  String ObjectID,
                                                  String fidejussioneNameId,
                                                  String fidejussioneFileId
                                                  )
    {
        FileUploadBatchContrata fb=new FileUploadBatchContrata(
            fileId,
            filename,
            processGuid ,
            documentId,
            ObjectID,
            fidejussioneNameId,
            fidejussioneFileId
            
        );
        Database.executeBatch(fb, 1);
    }
    
    
    
    @Future(callout=true)
    public static void storeDocument2(String fileObject, String filename, String documentId, String documentFamily, String objectId, String accountId, Datetime uploadDate,
                                      String documentTypeId, String docName, String taxCode, String contractNumber, Datetime stipulationDate, String description, String idOplon, String stage,String objectType,
                                      String userEmail, String contactTaxCode, String nominativoReferente,String contactIdSalesforce,String action, String gui, String nameFileDescription)
    {
        storeDocument( fileObject,  filename,  documentId,  documentFamily,  objectId,  accountId,  uploadDate,
                      documentTypeId,  docName,  taxCode,  contractNumber,  stipulationDate,  description,  idOplon,  
                      stage, objectType,  userEmail, contactTaxCode,nominativoReferente,contactIdSalesforce,action,gui, nameFileDescription);
        
        
    }	    
    
    public static String storeDocument(String fileObject, String filename, String documentId, String documentFamily, String objectId, String accountId, Datetime uploadDate,
                                       String documentTypeId, String docName, String taxCode, String contractNumber, Datetime stipulationDate, String description, String idOplon, String stage,String objectType, 
                                       String userEmail, String contactTaxCode, String nominativoReferente,String contactIdSalesforce,String action, String gui, String nameFileDescription)
    {
        system.debug('ElevaRestApiController storeDocument- Start');
        String endpoint;
        System.debug('storeDocument objectType ' + objectType);
        if(objectType=='Opportunity'){
            Opportunity oppEndpointFilter = [Select id,Tipo_di_opportunit__c, Tipo_Linea_di_Credito__c from Opportunity where id=:objectId];
            if(oppEndpointFilter.Tipo_di_opportunit__c =='Crediti Fiscali' || oppEndpointFilter.Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
                endpoint = 'creditifiscali/store-document';
            }else{
                endpoint = 'smelending/store-document'; 
            }
        }else{
            endpoint = 'smelending/store-document';
        }
        System.debug('storeDocument endpoint ' + endpoint);
        RequestBodyStoreDocument bodyStoreDocument = new RequestBodyStoreDocument(fileObject, filename, documentId, documentFamily, objectId, accountId, uploadDate,
                    documentTypeId, docName, taxCode, contractNumber, stipulationDate, description, idOplon, 
                    stage,objectType,userEmail,contactTaxCode,nominativoReferente,contactIdSalesforce,action, gui, nameFileDescription);
       
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => endpoint,
            'method' => 'POST',
            'body' => JSON.serialize(bodyStoreDocument),
            'nameString' => 'StoreDocument ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => objectId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        String resultStr = res.responseMessage;
    
                Document__c doc = new Document__c ();
                doc.Id = documentId;
                if (res.ok == true) {
                    doc.Errore_Store_Document__c = '';
                } else {
                        doc.Errore_Store_Document__c = resultStr;
                }
                if(action != 'elimina')
                {
                	update doc;
                }
                else if(action == 'elimina')
                {
                    delete doc;
                }
                System.debug('storeDocument resultStr ' + resultStr);
            return resultStr;
    }
    
    public class RequestBodyStoreDocument{
        //String fileObject;
        String filename;
        String fileId;//JF 12/02/2021
        String documentId;
        String documentFamily;
        String objectId; //objectId;
        String accountId;
        Datetime uploadDate;
        String documentTypeId;
        String name;
        String taxCode;
        String contractNumber;
        Datetime stipulationDate;
        String description;
        String idOplon; // idOplon;
        String stage;
        String objectType; //objectType;
        String userEmail; 
        String contactTaxCode;
        String nominativoReferente;
        String contactIdSalesforce;
        String action;
        String guid;        
        String nameFileDescription; // aggiunto da SP per Cr       

        public RequestBodyStoreDocument(String fileId, String filename, String documentId, String documentFamily, String objectId, String accountId, Datetime uploadDate,
                                        String documentTypeId, String docName, String taxCode, String contractNumber, Datetime stipulationDate, String description, String idOplon, String stage,String objectType,
                                        String userEmail,String contactTaxCode, String nominativoReferente,String contactIdSalesforce,String action, String gui, String nameFileDescription){
                                            system.debug('ElevaRestApiController RequestBodyStoreDocument- Start');
                                            //this.fileObject = fileObject;
                                            this.fileId=fileId;
                                            this.filename = filename;
                                            this.documentId = documentId;
                                            this.documentFamily = documentFamily;
                                            this.objectId = objectId;
                                            this.accountId = accountId;
                                            this.uploadDate = uploadDate;
                                            this.documentTypeId = documentTypeId;
                                            this.name = docName;
                                            this.taxCode = taxCode;
                                            this.contractNumber = contractNumber;
                                            this.stipulationDate = stipulationDate;
                                            this.description = description;
                                            this.idOplon = idOplon;
                                            this.stage = stage;
                                            this.objectType = objectType;
                                            this.userEmail = userEmail;
                                            this.contactTaxCode = contactTaxCode;
                                            this.nominativoReferente = nominativoReferente;
                                            this.contactIdSalesforce = contactIdSalesforce;
                                            this.action=action;
                                            this.guid=gui;
                                            this.nameFileDescription = nameFileDescription;
                                            
                                            system.debug('ElevaRestApiController RequestBodyStoreDocument- End');
                                        }
    }
    
    
    
    // 2.1/B - Richiesta token per aprire documenti
    
    @AuraEnabled
    public static String getDocumentToken() {
        String resultStr;
        system.debug('ElevaRestApiController getDocumentToken - Start');
        
        try {
            
            List<ElevaCredentials__mdt> elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
            ElevaCredentials__mdt elevaMoonCredentials = new ElevaCredentials__mdt();
            
            if (elevaCredentials.size() > 0) {
                elevaMoonCredentials = elevaCredentials.get(0);
                system.debug('ElevaRestApiController getDocumentToken - elevaMoonCredentials: '+elevaMoonCredentials);
                String root = elevaMoonCredentials.root__c;
                //   String endpoint = elevaMoonCredentials.endpoint__c;
                String endpoint = 'smelending/token-document';
                
                String url = '' + root + endpoint;
                String nonce = Utils.generateRandomString(20);
                HttpRequest req = new HttpRequest();
                req.setEndpoint(url);
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
                req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
                req.setHeader('x-nonce', nonce);
                req.setHeader('x-hmac', Utils.generateSignature('IT', 'EXT', 'GET',nonce));
                req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
                req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
                req.setTimeout(100000);
                
                // if (!Test.isRunningTest()) {
                Http h = new Http();
                HttpResponse res = h.send(req);
                system.debug('------ getDocumentToken RESPONSE: ' + res.getBody());
                string StatusCode = String.valueOf(res.getStatusCode());
                if (res.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    system.debug('------ results ' + results);
                    resultStr = JSON.serialize(results.get('token'));
                    system.debug('ElevaRestApiController getDocumentToken RESULT STRING ' + resultStr);
                } else {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    resultStr = JSON.serialize(results.get('faults'));//resultStr
                    //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    system.debug('ElevaRestApiController getDocumentToken RESULT Error ' + resultStr);
                    
                }
                
                CalloutLoggerService.saveCalloutLogger(url,StatusCode,'GET','',req.getBody(),res.getBody(),'token-document');
                //   }
            }
            system.debug('ElevaRestApiController getDocumentToken - End');
            system.debug('return resultStr:' + resultStr);
            return resultStr;
        } catch (Exception e) {
            system.debug('ElevaRestApiController getDocumentToken: ' + e.getMessage());
            
            return e.getMessage();
        }
    }

    
    // 4.1 - Anagraphic CR
    // 
    //@future(callout=true)
    public static fileUploaderDAO.FidejussoreResponse anagraphicCr2(String opportunityId, String accountId, String accountNumber) {
        fileUploaderDAO.FidejussoreResponse response=new fileUploaderDAO.FidejussoreResponse();
        system.debug('ElevaRestApiController anagraphicCr- Start');
        system.debug('opportunityId: ' + opportunityId + 'accountId: ' + accountId + 'accountNumber: ' + accountNumber);
        
        try {  
                String endpoint = 'smelending/anagraphic-cr';
                RequestBodyAnagraphicCr bodyAnagraphicCr = new RequestBodyAnagraphicCr(opportunityId, accountId, accountNumber);
                String body =JSON.serialize(bodyAnagraphicCr);
                HttpRequest req = BP_ElevaRestApiRequest.elevaCredentialsReq(endpoint, 'POST', body);
   
                system.debug('------ anagraphicCr REQUEST: ' + req);
                system.debug('------ anagraphicCr BODY: ' + req.getBody());

                Http h = new Http();
                HttpResponse res = h.send(req);
                system.debug('------ New Opportunity Analysis RESPONSE: ' + res.getBody());
                string StatusCode = String.valueOf(res.getStatusCode());
                
                if (res.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    String resultStr = JSON.serialize(results.get('result'));
                    String totalStr = 'new-opportunity-analysis SUCCESS :: ' + resultStr + ' :: ' + UserInfo.getName() + ' :: ' + Datetime.now();
                    system.debug('new-opportunity-nalysis RESULT STRING ' + resultStr);
                    
                } else {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    system.debug('fidejussoreOnCedacri results'+results);
                    String resultStr = JSON.serialize(results.get('result'));
                    String totalStr = 'new-opportunity-analysis ERROR :: ' + resultStr + ' :: ' + UserInfo.getName() + ' :: ' + Datetime.now();
                    system.debug('new-opportunity-nalysis RESULT STRING Error' + resultStr);
                    response.ok=false;
                    // response.responseMessage ='Errore invocazione servizio: '+ (results.get('faults'));
                    response.responseMessage ='Errore invocazione servizio: '+StatusCode ;
                    
                    system.debug('fidejussoreOnCedacri results.get(faults)'+results.get('faults')) ;
                    
                    if(results.get('faults')!=null){
                        String fault=String.valueof( results.get('faults'));
                        list<String> split =fault.split(',');
                        for(String s: split){
                            system.debug('fidejussoreOnCedacri s'+s);
                            if(s.contains('faultMessage')){
                                system.debug('fidejussoreOnCedacri questo '+s);
                                
                                response.responseMessage =s.remove('faultMessage=');//+'. Contattare il Sales Support'
                            }
                        }
                        
                    }
                    system.debug('fidejussoreOnCedacri response.responseMessage'+response.responseMessage);
                }
                
                CalloutLoggerService.saveCalloutLogger(req.getEndpoint(),StatusCode,'POST',accountId,req.getBody(),res.getBody(),endpoint);
                if (res.getStatusCode() == 200) {
                    response.ok=true;
                    
                }
                
            system.debug('fidejussoreOnCedacri response.responseMessage'+response.responseMessage);
            
            return response;
            // return true;
            
        } catch (Exception e) {
            //   throw ErrorLogEventHandler.standardExceptionLog(e);
            system.debug('new-opportunity-analysis Exeption: '+ e.getMessage());
            response.ok=false;
            response.responseMessage=e.getMessage();
            return response;
        }
        
    }
    
    public class RequestBodyAnagraphicCr {
        public String opportunityId;
        public String accountId;
        public String NDG;
        public RequestBodyAnagraphicCr(String opportunityId, String accountId, String ndg) {
            this.opportunityId = opportunityId;
            this.accountId = accountId;
            this.NDG = ndg;
        }
    }
    
    
    
    
    // 8.1 - Richiesta firma digitale
    
    public static void digitalSignature(String opportunityId, String accountId) {
        
        system.debug('ElevaRestApiController digitalSignature - Start');
        system.debug('opportunityId: '+ opportunityId+ 'accountId: '+ accountId);
        RequestBodyDigitalSignature bodyDigitalSignature = new RequestBodyDigitalSignature(opportunityId, accountId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/digital-signature',
            'method' => 'POST',
            'body' => JSON.serialize(bodyDigitalSignature),
            'nameString' => 'DigitalSignature ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => accountId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        system.debug('ElevaRestApiController digitalSignature - End');
    }
    
    
    public class RequestBodyDigitalSignature {
        public String opportunityId;
        public String accountId;
        public RequestBodyDigitalSignature(String opportunityId, String accountId) {
            this.opportunityId = opportunityId;
            this.accountId = accountId;
        }
    }
    
    
    
    
    // 8.2 - Richiesta recupero URL contratto
    @future(callout=true)
    public static void generateContractFuture(String quoteId, Map<String,String> oppInfo){
        generateContract(quoteId,oppInfo);
    }
    public static void generateContract(String quoteId,Map<String,String> oppInfo) {
        System.debug('Entra qui eleva 1 ');
        String opportunityType = oppInfo.get('opportunityType');
        String accountId =oppInfo.get('acccountId');
        String endpoint;   
        String body;   
        RichiediContratto bodyDigitalSignature;
        RichiediContrattoCrediti bodyCrediti;
            if(opportunityType == constants.OPPORTUNITY_TIPO_FISCALE){
                endpoint = 'creditifiscali/create-contract-request';
                bodyCrediti = new RichiediContrattoCrediti(quoteId,accountId);
                body = JSON.serialize(bodyCrediti);
            }else{ 
                endpoint = 'smelending/create-contract-request';
                bodyDigitalSignature = new RichiediContratto(quoteId);
                body = JSON.serialize(bodyDigitalSignature);
            } 
            System.debug('endpint eleva ' + endpoint);
            Map<String, String> elevaParams = new Map<String, String>{
                'endpoint' => endpoint,
                'method' => 'POST',
                'body' => body,
                'nameString' => 'StoreDocument ',
                'erroreString' => 'Errore invocazione servizio: ', 
                'recordId' => quoteId
            };
            Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            String statusCode = res.statusCode;
            if (statusCode == '200' || statusCode == '504') {
                list<Opportunity> opps=[select id, LineeDiCreditoContrattoKO__c, Tipo_Linea_di_Credito__c,Data_Richiesta_Contratto__c,Email_Sales_Support__c from Opportunity
                                        where id in (select opportunityId from Quote where id=:quoteId and 	
                                        Status= 'In Corso')];
                
                if(!opps.isempty()){
                    opps[0].Rissotomettere__c = '';
                    if (opps[0].Data_Richiesta_Contratto__c == null){
                    opps[0].Data_Richiesta_Contratto__c = Date.today();
                    }
                OpportunityController.bypassTrigger = true;
                    update opps;
                OpportunityController.bypassTrigger = false;
                      
                } 
                
            } else {
                    list<Opportunity> opps=[select id, Errore_Richiedi_Contratto__c from Opportunity
                                            where id in (select opportunityId from Quote where id=:quoteId)];
                    
                    
                    //Commento Technico Zvilp : sul query che e sopra , perche e il condizione che  LineeDiCreditoContrattoKO__c=0 , perche questo significa che no abbiamo nessun errore guisto 
                    
                    if(!opps.isempty()){
                        opps[0].Errore_Richiedi_Contratto__c+= res.responseMessage;
                    OpportunityController.bypassTrigger = true;
                        update opps;
                    OpportunityController.bypassTrigger = false;
                    }
                   
                    // Object fault = results.get('faults');
                    // response.responseMessage =String.valueof(results.get('faults').get('faultDescription'));
                }
        
    }
    Public class RichiediContratto{
        public string sfCreditLineId;// ;//AAVV88kliuhEE;//
        public string dataStipulaContratto;// ;//2020-09-28T07:38:26.933Z;//,
        public string cittaFirma;// ;//Milano;//,
        public string siglaProvinciaFirma;//: ;//MI;//,
        public string nomeAziendaSedeFirma;//: ;//Rossi srl;//,
        public string indirizzoFirma;//: ;//Via Nicola sole 1;//,
        public string cAPFirma;//: ;//20019;//,
        public string nomeAzienda;//: ;//Banca progetto spa;//,
        public string indirizzoSedeAzienda;//: ;//via San Carlo 10;//,
        public string capSedeAzienda;//: ;//00100;//,
        public string cittaSedeAzienda;//: ;//Roma;//,
        public string siglaProvinciaSedeAzienda;//: ;//RM;//,
        public string paeseSedeAzienda;//: ;//Itala;//,
        public Integer capitaleSociale;//: 100000,
        public Integer capitaleVersato;//: 50000,
        public string codiceFiscaleAzienda;//: ;//AAAAAA00A00A000A;//,
        public string finalitaFinanziamento;//: ;//Finanziamento impresa;//,
        public Boolean flagMicroimpresa;//: false,
        public Boolean flagPiccolaMediaImpresa;//: false,
        public string casaComunaleDomicilioAzienda;//: ;//via L. Cadorna 20, Roma;//,
        list<Firmatario> firmatari;
        list<Fidejussore> fidejussori;
        public string cognomeProcuratoreSpeciale;//: ;//Rinaldi;//,
        public string nomeProcuratoreSpeciale;//: ;//Gianluca;//,
        public Integer importoFinanziamentoEuro;//: 40000,
        public string importoFinanziamentoInLettere;//: ;//Quarantamila;//,
        public Integer durataFinanziamentoMesi;//: 12,
        public string dataFineMutuo;//: ;//2021-09-28T07:38:26.933Z;//,
        public string dataFinePreammortamento;//: ;//2021-04-28T07:38:26.933Z;//,
        public Decimal percentualeSpread;//: 2,
        public string dataValiditaSpread;//: ;//2021-09-05T07:38:26.933Z;//,
        public Decimal percentualeTaeg;//: 0.5,
        public Decimal percentualeSpeseIstruttoria;//: 3.6,
        public Decimal percentualeCommissioneIntermediazioneCreditizia;//: 1.5,
        public Integer importoImpostaSostitutivaEuro;//: 10000,
        public string importoImpostaSostitutivaLettere;//: ;//Diecimila;//,
        public Integer importoCommissioneIstruttoriaEuro;//: 20000,
        public string importoCommissioneIstruttoriaLettere;//: ;//Ventimila;//,
        public string ibanAzienda;//: ;//IT000000000000000000000000;//,
        public string bancaAzienda;//: ;//Intesa san paolo;//,
        public string filialeBancaAzienda;//: ;//San Donato;//,
        public string dataDeliberaMCC;//: ;//2020-10-01T07:38:26.933Z;//,
        public Decimal importoMassimoGarantito;//: 35000,
        public Decimal percentualeCoperturaMassima;//: 85,
        //  public Integer importoCommissioneFdgEuro;//: 5000,
        //  public string importoCommissioneFdgLettere;//: ;//Cinquemila;//,
        list<Socio> soci;//,
        public Decimal sommaQuotaSoci;//: 100,
        public string eventualiAltreGaranzie;//: ;//Fidejussione;//,
        public string numeroRapporto;//: ;//14;//,
        public string idTemplate;//: ;//01_01_004_01_d;//
        public Double minimaPartecipazioneSoci;
        public String indirizzoPecAzienda;
        public String sfGuaranteeId;
        public String ndgAccount;
        public String sfAccountId;
        public String sfOpportunityId;
        public String processGuid;
        
        
        public RichiediContratto(Id lineaCreditoID){

            Quote lineaCredito= [select 
                                 
                                 //Quote
                                 id,
                                 Importo_Commissioni_di_Istruttoria__c,Filiale_Banca_Cliente__c,
                                 
                                 Finalita_Finanziamento__c,
                                 accountId,
                                 Ammontare_aggiornato__c,
                                 Durata_in_mesi__c,
                                 Data_fine_mutuo_Formula__c,
                                 Data_Fine_Preammortamento__c,
                                 Percentuale_Spread__c,
                                 Data_Validita_Spread__c,
                                 Indirizzo_Firma__c,
                                 Percentuale_Taeg__c,
                                 Percentuale_Commissioni_da_Istruttoria__c,
                                 Percentuale_Commissione_Intermediazione__c,
                                 Importo_Imposta_Sostitutiva__c,
                                 Numero_Rapporto__c,
                                 Cognome_Procuratore_Speciale__c,
                                 Nome_Procuratore_Speciale__c,
                                 Commissioni_da_Istruttoria__c,
                                 Sigla_Provincia_Stipula__c,
                                 Citta_Firma__c,
                                 Cap_Firma__c,
                                 Sigla_Provincia_Firma__c,
                                 Iindirizzo_Firma__c,
                                 Nome_Azienda_Sede_Firma__c,
                                 Data_Stipula__c,
                                 IBAN__c,
                                 Banca_Cliente__c,
                                 Filiale__c,
                                 opportunityId,
                                 processGuid__c,                   
                                 
                                 //Opportunity
                                 
                                 
                                 opportunity.Data_delibera_MCC__c,
                                 opportunity.Filiale_Banca_Cliente__c,
                                 opportunity.Banca_Cliente__c,
                                 opportunity.Richiesta_Firma_Digitale__c,
                                 opportunity.Tipo_Firma__c,
                                 //Account
                                 
                                 account.name,
                                 account.accountnumber,
                                 account.Indirizzo_Sede_Legale_Esteso__c,
                                 account.cap__c,
                                 account.Comune__c,
                                 account.Sigla_Provincia__c,
                                 account.Paese_Sede_Azienda__c,
                                 account.Capitale_Sociale__c,
                                 account.Capitale_Versato__c,
                                 account.Codice_Fiscale__c,
                                 account.Microimpresa__c,
                                 account.Piccola_Media_Impresa__c,
                                 account.Casa_Comunale_Domicilio__c,
                                 account.X24_Codice_IBAN__c,
                                 account.Email__c,
                                 account.Phone,
                                 account.Cellulare__c,

                                 //Garanzie
                                 (select id, Tipo_di_Garanzia__c, Data_delibera_MCC__c, Percentuale_Garantito__c, Percentuale_Garantito_Formula__c from Garanzie__r where Stato_Garanzia__c!='Chiusa')
                                 
                                 from quote
                                 where id=:lineaCreditoID
                                ];
            system.debug('RichiediContratto: lineaCredito'+lineaCredito);
            list<Contact> contatti= [select id,
                                     Titolo_Firmatario__c,
                                     Genere_Nascita__c,
                                     Prefisso_Internazionale__c,
                                     LastName,
                                     FirstName,
                                     Sigla_Provincia_Nascita__c,
                                     Birthdate,
                                     Oplon_Codice_Fiscale__c,
                                     MobilePhone,
                                     Comune__c,
                                     Sigla_Provincia__c,
                                     Indirizzo_Residenza_Esteso__c,			
                                     Cap__c,
                                     Ruolo_in_Azienda__c,
                                     Data_di_Nascita__c,
                                     Localita__c,
                                     Stato_di_Nascita__c,
                                     Stato_Nascita__c,
                                     Tipo_Documento__c,
                                     Numero_Documento__c,
                                     Luogo_Rilascio__c,
                                     Data_Scadenza__c,
                                     Email,                
                                     Data_Rilascio__c,
                                     Paese_Rilascio__c,	
                                     Stato_ResidenzaEstero__c,
                                     Stato_Residenza_Estero__c,
                                     Residenza__c,
                                     Codice_Catastale__c,
                                     Comune_di_Nascita__c,
                                     Provincia__c,
                                     Fidejussore__c
                                     
                                     from contact
                                     where firmatario__c =true AND 
                                     accountid =: lineaCredito.accountId
                                     
                                    ];
            
            list<Contact> contattiSoci= [select id,
                                         FirstName,
                                         lastname,
                                         name,
                                         Oplon_Codice_Fiscale__c,
                                         percentuale_di_riferimento_socio__c
                                         from contact 
                                         where accountid=: lineaCredito.accountId
                                         and percentuale_di_riferimento_socio__c!=null];
            
            system.debug('RichiediContratto: contatti'+contatti);
            
            this.sfCreditLineId = lineaCredito.Id;
            this.dataStipulaContratto=ElevaRestApiController.convertDatetoString(lineaCredito.Data_Stipula__c);
            this.cittaFirma=lineaCredito.Citta_Firma__c;
            this.siglaProvinciaFirma=lineaCredito.Sigla_Provincia_Stipula__c;
            this.processGuid= lineaCredito.processGuid__c;
            siglaProvinciaFirma=lineaCredito.Sigla_Provincia_Firma__c;//: ;//MI;//,
            nomeAziendaSedeFirma=lineaCredito.Nome_Azienda_Sede_Firma__c;//: ;//Rossi srl;//,
            indirizzoFirma= lineaCredito.Indirizzo_Firma__c;//: ;//Via Nicola sole 1;//,
            
            this.sfAccountId=lineaCredito.accountid;
            cAPFirma =lineaCredito.Cap_Firma__c;
            //this.sfCreditLineId=lineaCredito.Id;
            this.nomeAzienda=lineaCredito.account.name;
            this.indirizzoSedeAzienda = lineaCredito.account.Indirizzo_Sede_Legale_Esteso__c;
            this.capSedeAzienda= lineaCredito.account.Cap__c;
            this.cittaSedeAzienda= lineaCredito.account.Comune__c;
            this.siglaProvinciaSedeAzienda = lineaCredito.account.Sigla_Provincia__c;
            this.paeseSedeAzienda =  lineaCredito.account.Paese_Sede_Azienda__c;
            this.capitaleSociale = Integer.valueOf(lineaCredito.account.Capitale_Sociale__c);
            this.capitaleVersato=  Integer.valueOf(lineaCredito.account.Capitale_Versato__c);
            this.codiceFiscaleAzienda=lineaCredito.account.Codice_Fiscale__c;
            this.finalitaFinanziamento = lineaCredito.Finalita_Finanziamento__c;
            this.flagMicroimpresa=lineaCredito.account.Microimpresa__c =='SI';
            this.flagPiccolaMediaImpresa=lineaCredito.account.Piccola_Media_Impresa__c =='SI';
            this.casaComunaleDomicilioAzienda= lineaCredito.account.Casa_Comunale_Domicilio__c;
            this.indirizzoPecAzienda= lineaCredito.account.Email__c;
            this.sfOpportunityId=lineaCredito.opportunityId;
            this.firmatari =new list<Firmatario>();
            this.fidejussori =new list<fidejussore>();
            this.ndgAccount=lineaCredito.account.accountNumber;
            for(Contact contatto: contatti){
                    Firmatario f =new Firmatario(contatto);
                    firmatari.add(f);
                
            }
            List<Quote> quoteList = [SELECT Id FROM Quote WHERE Id =: lineaCreditoID];
            Map<String,List<Contact>> fidejussoreMap = ElevaRestApiHelper.getFidejussoreForQuote(quoteList);
            
            if( ! (fidejussoreMap.get('Persona Fisica')).isEmpty()){
                
                for(Contact contatto: fidejussoreMap.get('Persona Fisica')){
                    Fidejussore fide = new Fidejussore(contatto,true);
                    fidejussori.add(fide);
                    
                }   
            }
            if( ! (fidejussoreMap.get('Persona Giuridica')).isEmpty()){
                
                for(Contact contatto: fidejussoreMap.get('Persona Giuridica')){
                    Fidejussore fide = new Fidejussore(contatto,false);
                    fidejussori.add(fide);
                    
                } 
            }
            
            cognomeProcuratoreSpeciale=lineaCredito.Cognome_Procuratore_Speciale__c;//: ;//Rinaldi;//,
            nomeProcuratoreSpeciale=lineaCredito.Nome_Procuratore_Speciale__c;//: ;//Gianluca;//,
            importoFinanziamentoEuro=  Integer.valueOf(lineaCredito.Ammontare_aggiornato__c);//: 40000,
            //public string importoFinanziamentoInLettere;//: ;//Quarantamila;//,
            
            durataFinanziamentoMesi=  Integer.valueOf(lineaCredito.Durata_in_mesi__c);//: 12,
            dataFineMutuo=ElevaRestApiController.convertDatetoString(lineaCredito.Data_fine_mutuo_Formula__c) ;//: ;//2021-09-28T07:38:26.933Z;//,
            dataFinePreammortamento=ElevaRestApiController.convertDatetoString(lineaCredito.Data_Fine_Preammortamento__c );//: ;//2021-04-28T07:38:26.933Z;//,
            percentualeSpread=lineaCredito.Percentuale_Spread__c;//: 2,
            dataValiditaSpread= ElevaRestApiController.convertDatetoString(lineaCredito.Data_Validita_Spread__c);//: ;//2021-09-05T07:38:26.933Z;//,
            //	percentualeTaeg=lineaCredito.Percentuale_Taeg__c;//: 0.5,
            percentualeSpeseIstruttoria=lineaCredito.Percentuale_Commissioni_da_Istruttoria__c;//: 3.6,
            percentualeCommissioneIntermediazioneCreditizia= lineaCredito.Percentuale_Commissione_Intermediazione__c;//: 1.5,
            importoImpostaSostitutivaEuro= Integer.valueOf(lineaCredito.Importo_Imposta_Sostitutiva__c);//: 10000,
            // importoImpostaSostitutivaLettere;//: ;//Diecimila;//,
            importoCommissioneIstruttoriaEuro= Integer.valueOf(lineaCredito.Importo_Commissioni_di_Istruttoria__c);//: 20000,
            //public string importoCommissioneIstruttoriaLettere;//: ;//Ventimila;//,
            ibanAzienda= lineaCredito.IBAN__c;//: ;//IT000000000000000000000000;//,
            bancaAzienda= lineaCredito.Banca_Cliente__c;//: ;//Intesa san paolo;//, 
            filialeBancaAzienda= lineaCredito.Filiale_Banca_Cliente__c;//: ;//San Donato
            //: ;//2020-10-01T07:38:26.933Z;//,
            
            if(contattiSoci.isempty()){
                minimaPartecipazioneSoci=0;
            }
            
            importoMassimoGarantito=0;//: 35000,
            percentualeCoperturaMassima=0;//: 85,
            //importoCommissioneFdgEuro=0;//: 5000,
            sommaQuotaSoci=0;
            soci =new list<Socio>();//,
            for(Contact soc: contattiSoci){
                Socio s=new Socio(soc);
                soci.add(s);
                if(soc.percentuale_di_riferimento_socio__c!=null)
                    sommaQuotaSoci+=soc.percentuale_di_riferimento_socio__c;
                if(minimaPartecipazioneSoci==null || minimaPartecipazioneSoci>soc.percentuale_di_riferimento_socio__c){
                    minimaPartecipazioneSoci=soc.percentuale_di_riferimento_socio__c;
                }
                
            }
            
            
            //public Decimal sommaQuotaSoci;//: 100,
            //public string eventualiAltreGaranzie;//: ;//Fidejussione;//,
            numeroRapporto= lineaCredito.Numero_Rapporto__c;//: ;//14;//,
            idTemplate = ElevaRestApiController.generaTemplate(lineaCredito);//: ;//01_01_004_01_d;//
            //idTemplate ='01_01_004_01_c';
            system.debug('idTemplate'+idTemplate);
            eventualiAltreGaranzie='';
            Double importoMassimoGarantitoDouble=0;
            for(Garanzia__c garanzia: lineaCredito.Garanzie__r){
                if(garanzia.Tipo_di_Garanzia__c!=constants.GARANZIA_TIPO_MCC){
                    eventualiAltreGaranzie+=garanzia.Tipo_di_Garanzia__c+';';
                }
                else{
                    
                    dataDeliberaMCC= ElevaRestApiController.convertDatetoString(garanzia.Data_delibera_MCC__c);
                    sfGuaranteeId=garanzia.Id;
                    if(percentualeCoperturaMassima< Integer.valueof(garanzia.Percentuale_Garantito_Formula__c)){
                        importoMassimoGarantito=Integer.valueof(  (lineaCredito.Ammontare_aggiornato__c  *
                                                                   Integer.valueof(garanzia.Percentuale_Garantito_Formula__c))/100);
                        percentualeCoperturaMassima= Integer.valueof(garanzia.Percentuale_Garantito__c);
                        
                        //importoMassimoGarantito
                        //importoCommissioneFdgEuro
                    }
                    
                }
                
            }
            
            if(eventualiAltreGaranzie!='')
                eventualiAltreGaranzie=eventualiAltreGaranzie.removeEnd(';');
        }
    }
    public class Firmatari{
        public string idContact;
        public string firstName;
        public string lastName;
        public string codiceFiscale;
        public string email;
        public string mobile;

        public Firmatari (Contact contact){
                this.idContact=contact.id;
                this.firstName=contact.FirstName;
                this.lastName=contact.LastName;
                this.codiceFiscale=contact.Oplon_Codice_Fiscale__c;
                this.email=contact.Email;
                this.mobile=contact.MobilePhone;
            
        }
    }

    public class Fidejussore{
        public string nomeGarante;
        public string cognomeGarante;
        public string luogoNascitaGarante;
        public string provinciaNascitaGarante;
        public string dataNascitaGarante;
        public string codiceFiscaleGarante;
        public string inidrizzoResidenzaGarante;
        public string provinciaResidenzaGarante;
        public string paeseResidenzaGarante;
        public string capResidenzaGarante;
        public string tipoPersona;
        public string pecGarante;
        public string nomeAziendaGarante;
        public string indirizzoSedeAziendaGarante;
        public string capSedeAziendaGarante;
        public string cittaSedeAziendaGarante;
        public string siglaProvinciaSedeAziendaGarante;
        public string capitaleSocialeAziendaGarante;
        public string codiceFiscaleAziendaGarante;
        public string mobilePhoneGarante;
        public string descrizionePersonaGiuridica;
        public string idSalesforce;

        public Fidejussore (Contact contact, boolean isPersonaFisica){
            
            if(isPersonaFisica){
                if(contact.Stato_Residenza_Estero__c != 'ITALIA' && contact.Stato_Residenza_Estero__c != null){
                    this.provinciaResidenzaGarante = 'EE';
                    this.capResidenzaGarante = 'EE';
                } else{
                    this.provinciaResidenzaGarante=contact.Sigla_Provincia__c;
                    this.capResidenzaGarante = contact.Cap__c;
                }
                this.nomeGarante = contact.FirstName;
                this.cognomeGarante = contact.LastName;            
                this.luogoNascitaGarante = contact.Comune_di_Nascita__c;
                this.provinciaNascitaGarante = contact.Sigla_Provincia_Nascita__c;
                this.dataNascitaGarante = convertDatetoString(contact.Data_di_Nascita__c);
                this.codiceFiscaleGarante = contact.Oplon_Codice_Fiscale__c;
                this.inidrizzoResidenzaGarante = contact.Indirizzo_Residenza_Esteso__c;
                this.paeseResidenzaGarante = contact.Comune__c;
                this.tipoPersona = 'PF'; 
                this.pecGarante = contact.Email;
                this.nomeAziendaGarante = '';
                this.indirizzoSedeAziendaGarante = '';
                this.capSedeAziendaGarante = '';
                this.cittaSedeAziendaGarante = '';
                this.siglaProvinciaSedeAziendaGarante = '';
                this.capitaleSocialeAziendaGarante = '';
                this.codiceFiscaleAziendaGarante = '';
                this.mobilePhoneGarante = contact.Prefisso_Internazionale__c+contact.MobilePhone;
                this.descrizionePersonaGiuridica = contact.Ruolo_in_Azienda__c;
                this.idSalesforce=contact.Id;
            }
            else
            {
                if(contact.Stato_Residenza_Estero__c != 'ITALIA' && contact.Stato_Residenza_Estero__c != null){
                    this.provinciaResidenzaGarante = 'EE';
                    this.capResidenzaGarante = 'EE';
                } else{
                    this.provinciaResidenzaGarante=contact.Sigla_Provincia__c;
                    this.capResidenzaGarante = contact.Cap__c;
                }
                this.nomeGarante = contact.FirstName;
                this.cognomeGarante = contact.LastName;            
                this.luogoNascitaGarante = contact.Comune_di_Nascita__c;
                this.provinciaNascitaGarante = contact.Sigla_Provincia_Nascita__c;
                this.dataNascitaGarante = convertDatetoString(contact.Data_di_Nascita__c);
                this.codiceFiscaleGarante = contact.Oplon_Codice_Fiscale__c;
                this.provinciaResidenzaGarante = contact.Provincia__c;
                this.paeseResidenzaGarante = contact.Comune__c;
                this.tipoPersona = 'PG';
                this.pecGarante = contact.Email;
                this.nomeAziendaGarante = contact.account.Name;
                this.indirizzoSedeAziendaGarante = contact.account.Indirizzo_Sede_Legale_Esteso__c;
                this.capSedeAziendaGarante = contact.account.Cap__c;
                this.cittaSedeAziendaGarante = contact.account.Comune__c;
                this.siglaProvinciaSedeAziendaGarante = contact.account.Sigla_Provincia__c;
                this.capitaleSocialeAziendaGarante = String.valueOf(contact.account.Capitale_Sociale__c);
                this.codiceFiscaleAziendaGarante = contact.account.Codice_Fiscale__c;
                this.mobilePhoneGarante = contact.Prefisso_Internazionale__c+contact.MobilePhone;
                this.descrizionePersonaGiuridica = 'Legale Rappresentante';
                this.idSalesforce=contact.account.Id;
                
            }
        }
    }

    public class RichiediContrattoCrediti{
        public string processGuid;
        public string idLineaDiCredito;
        public string opportunityId;
        public string idAccount;
        public string nomeAzienda;
        public string indirizzo;
        public string cittaAnagraficaCliente;
        public string capAnagraficaCliente;
        public string siglaProvinciaAnagraficaCliente;
        public string partitaIva;
        public string indirizzoPEC;
        public String dataStipula;
        public string flagMicroimpresa;
        public string tipologiaDocumento;
        public Decimal commissioneAcquistoProSoluto;
        public Decimal corrispettivoCessione;
        public Decimal valoreLordoCredito;
        public Decimal tassoNominaleBaseAnnua;
        public Decimal valoreEuribor;
        public Decimal valoreSpread;
        public Decimal numeroGgLavorativiBonifici;
        public Decimal numeroGgLavorativiIncassiMezzoBonifico;
        public Decimal speseIstruttoriaCedente;
        public Decimal speseIstruttoriaRinnovoPraticaCedente;
        public Decimal speseIstruttoriaDebitore;
        public Decimal speseHandlingFattura;
        public Decimal speseHandlingEffetto;
        public Decimal spesePerDistinta;
        public Decimal speseHandlingPresentazione;
        public Decimal spesePerBonifico;
        public Decimal spesePerTenutaConto;
        public Decimal spesePostali;
        public Decimal spesePerBolli;
        public Decimal canoneHomeFactoring;
        public Decimal certificazioniAiRevisori;
        public string dichiarazioneCrediti;
        public String annoCrediti;
        public String dataPrevistaIncasso;
        public string contoCorrenteCliente;
        public string nomeBancaCliente;
        public string ibanBancaCliente;
        public list<Firmatari> firmatari;
        public string linkDocumentoDaFirmare;
        public string tipoFirma;
        
        public RichiediContrattoCrediti(String quoteId,String accountId){
            Quote quote = [SELECT id,processGuid__c,Documento_Da_Firmare__c,Data_Stipula__c,
            Commissione_acquisto_pro_soluto__c,
            Corrispettivo_cessione__c, Euribor__c,
            Tasso_nominale_base_annua__c, n_gg_lavorativi_Bonifici__c,
            n_gg_lavorativi_Incassi_a_mezzo_bonific__c,
            Spese_istruttoria_cedente__c,
            Spese_istruttoria_rinnovo_pratica_cedent__c,
            Spese_istruttoria_debitore__c,
            Spese_handling_per_fattura__c,
            Spese_handling_per_effetto__c,
            Spese_per_distinta__c,
            Spese_Hnadling_per_presentazione__c,
            Spese_per_bonifico__c,
            Spese_per_tenuta_conto__c,
            Spese_postali__c,
            Spese_per_bolli__c,
            Canone_Home_factoring__c,
            Certificazione_ai_revisori__c,
            Dichiarazione_crediti__c,
            Anno_crediti__c,
            Opportunity.Data_Prevista_Incasso__c,
            C_c_banca_Cedente__c,
            Banca_Cedente__c,IBAN_Cedente__c,
            OpportunityId,
            Opportunity.AccountId,
            Opportunity.Importo_del_Credito__c,
            Opportunity.Account.Name,
            Opportunity.Account.Indirizzo_Sede_Legale_Esteso__c,
            Opportunity.Account.Comune__c,
            Opportunity.Account.Cap__c,
            Opportunity.Tasso_Cliente__c,
            Opportunity.Account.Sigla_Provincia__c,
            Opportunity.Account.Partita_Iva__c,
            Opportunity.Account.Email__c,
            Opportunity.Account.Microimpresa__c,
            Opportunity.Tipo_Firma__c
            FROM Quote WHERE Id =: quoteId];
            this.opportunityId = quote.OpportunityId;
            this.processGuid=quote.processGuid__c;
            this.linkDocumentoDaFirmare=quote.Documento_Da_Firmare__c;
            this.idLineaDiCredito=quote.Id;
            this.dataStipula=ElevaRestApiController.convertDatetoString(quote.Data_Stipula__c);
            this.commissioneAcquistoProSoluto=quote.Commissione_acquisto_pro_soluto__c;
            this.corrispettivoCessione=quote.Corrispettivo_cessione__c;
            this.tassoNominaleBaseAnnua=quote.Tasso_nominale_base_annua__c;
            this.valoreEuribor=quote.Euribor__c;
            this.numeroGgLavorativiBonifici=quote.n_gg_lavorativi_Bonifici__c;
            this.numeroGgLavorativiIncassiMezzoBonifico=quote.n_gg_lavorativi_Incassi_a_mezzo_bonific__c;
            this.speseIstruttoriaCedente=quote.Spese_istruttoria_cedente__c;
            this.speseIstruttoriaRinnovoPraticaCedente=quote.Spese_istruttoria_rinnovo_pratica_cedent__c;
            this.speseIstruttoriaDebitore=quote.Spese_istruttoria_debitore__c;
            this.speseHandlingFattura=quote.Spese_handling_per_fattura__c;
            this.speseHandlingEffetto=quote.Spese_handling_per_effetto__c;
            this.spesePerDistinta=quote.Spese_per_distinta__c;
            this.speseHandlingPresentazione=quote.Spese_Hnadling_per_presentazione__c;
            this.spesePerBonifico=quote.Spese_per_bonifico__c;
            this.spesePerTenutaConto=quote.Spese_per_tenuta_conto__c;
            this.spesePostali=quote.Spese_postali__c;
            this.tipoFirma = quote.Opportunity.Tipo_Firma__c;
            if(tipoFirma == 'Firma Digitale'){
                System.debug('tipoFirma ' + tipoFirma);
            this.tipologiaDocumento='d';
            } else {
            this.tipologiaDocumento='c';  
            }
            System.debug('tipologiaDocumento ' + tipologiaDocumento);
            this.spesePerBolli=quote.Spese_per_bolli__c;
            this.canoneHomeFactoring=quote.Canone_Home_factoring__c;
            this.certificazioniAiRevisori=quote.Certificazione_ai_revisori__c;
            this.dichiarazioneCrediti=quote.Dichiarazione_crediti__c;
            this.annoCrediti=quote.Anno_crediti__c;
            this.dataPrevistaIncasso=ElevaRestApiController.convertDatetoString(quote.Opportunity.Data_Prevista_Incasso__c);
            this.contoCorrenteCliente=quote.C_c_banca_Cedente__c;
            this.nomeBancaCliente=quote.Banca_Cedente__c;
            this.ibanBancaCliente=quote.IBAN_Cedente__c;
            //account step
            this.idAccount=quote.Opportunity.AccountId;
            this.nomeAzienda=quote.Opportunity.Account.Name;
            this.valoreSpread = quote.Opportunity.Tasso_Cliente__c;
            this.indirizzo=quote.Opportunity.Account.Indirizzo_Sede_Legale_Esteso__c;
            this.cittaAnagraficaCliente=quote.Opportunity.Account.Comune__c;
            this.capAnagraficaCliente=quote.Opportunity.Account.Cap__c;
            this.siglaProvinciaAnagraficaCliente=quote.Opportunity.Account.Sigla_Provincia__c;
            this.partitaIva=quote.Opportunity.Account.Partita_Iva__c;
            this.valoreLordoCredito=quote.Opportunity.Importo_del_Credito__c;
            this.indirizzoPEC=quote.Opportunity.Account.Email__c;
            this.flagMicroimpresa=quote.Opportunity.Account.Microimpresa__c;
            this.firmatari = new List<Firmatari>();
             for(Contact contact : [SELECT id,FirstName, Oplon_Codice_Fiscale__c, Stato_di_Nascita__c, Stato_Nascita__c, Email,LastName,MobilePhone FROM Contact WHERE Firmatario__c = true AND  AccountId =: quote.Opportunity.AccountId]){
                Firmatari firmatari = new Firmatari(contact);
                this.firmatari.add(firmatari);
            }
        }
    }

    public class Socio{
        
        public string cognomeSocio;// ;//Galli;//,
        public string nomeSocio;// ;//Alberto;//,
        public string codiceFiscaleSocio;// ;//CCCCCC36C36C366C;//,
        public Decimal percentualeRiferimentoSocio;// 25,
        public String sfContactId;
        public Socio(Contact socio){
            this.cognomeSocio=socio.lastname;
            this.codiceFiscaleSocio=socio.Oplon_Codice_Fiscale__c;
            this.nomeSocio=socio.firstName;
            this.percentualeRiferimentoSocio=socio.percentuale_di_riferimento_socio__c;
            
            this.sfContactId=socio.Id;
        }
    }
    public class Firmatario{      
        public string sfContactId;
        public string titoloPersonaFirmatario;//;//Sig.;//,
        public string paeseRilascio;
        public string paeseResidenza;
        public string genereNascita;//;//M;//,
        public string cognomeFirmatario;// ;//Colombo;//,
        public string nomeFirmatario;// ;//Mario;//,
        public string cittaNascitaFirmatario;// ;//Milano;//,
        public string siglaProvinciaNascitaFirmatario;// ;//Mi;//,
        public string dataNascitaFirmatario;// ;//1970-09-01T07:38:26.933Z;//,
        public string codiceFiscaleFirmatario;// ;//BBBBBB20B20B200B;//,
        public string numCellulareFirmatario;// ;//1234567891;//,
        public string cittaResidenzaFirmatario;// ;//Rho;//,
        public string siglaProvinciaCittaResidenzaFirmatario;// ;//Mi;//,
        public string indirizzoResidenzaFirmatario;// ;//Via S. francesco 50;//,
        public string capResidenzaFirmatario;// ;//20023;//,
        public string ruoloAziendaleFirmatario;// ;//Responsabile;//
        public string codiceCatastaleFirmatario;
        public string tipoDocumentoFirmatario;
        public string numeroDocumentoFirmatario;//": "string",
        public string documentoFirmatarioEmessoDa;//": "string",
        public string documentoFirmatarioEmessoIl;//": "2020-10-12T12:08:58.417Z",
        public string scadenzaDocumentoFirmatario;//: "2020-10-12T12:08:58.417Z",
        public string emailFirmatario;
        public string statoNascitaFirmatario;
        
        
        
        
        public Firmatario(Contact referente){
            
            //statoNascitaFirmatario=referente.Stato_di_Nascita__c;
            codiceCatastaleFirmatario=referente.Codice_Catastale__c ;
            tipoDocumentoFirmatario=referente.Tipo_Documento__c;
            numeroDocumentoFirmatario=referente.Numero_Documento__c;
            documentoFirmatarioEmessoDa=referente.Luogo_Rilascio__c;
            documentoFirmatarioEmessoIl=ElevaRestApiController.convertDatetoString(referente.Data_Rilascio__c);
            scadenzaDocumentoFirmatario=ElevaRestApiController.convertDatetoString(referente.Data_Scadenza__c);
            emailFirmatario=referente.Email;

            if(referente.Stato_di_Nascita__c != null) {
                statoNascitaFirmatario=referente.Stato_di_Nascita__c;
            } else {
                statoNascitaFirmatario=referente.Stato_Nascita__c;
            }
            if(referente.Stato_ResidenzaEstero__c != null){
                this.paeseResidenza = referente.Stato_ResidenzaEstero__c;
            }
            else if (referente.Residenza__c == null){
                this.paeseResidenza ='';
            }
            else{
                this.paeseResidenza ='Italia';
            }
            if(referente.Stato_Residenza_Estero__c != 'ITALIA' && referente.Stato_Residenza_Estero__c != null){
                this.siglaProvinciaCittaResidenzaFirmatario = 'EE';
                this.capResidenzaFirmatario = 'EE';
            } else{
                this.siglaProvinciaCittaResidenzaFirmatario=referente.Sigla_Provincia__c;
                this.capResidenzaFirmatario = referente.Cap__c;
            }
            
            this.titoloPersonaFirmatario = referente.Titolo_Firmatario__c;
            this.paeseRilascio = referente.Paese_Rilascio__c;
            this.genereNascita= referente.Genere_Nascita__c;
            this.cognomeFirmatario=referente.LastName;
            this.nomeFirmatario=referente.FirstName;
            this.siglaProvinciaNascitaFirmatario=referente.Sigla_Provincia_Nascita__c;
            this.dataNascitaFirmatario =ElevaRestApiController.convertDatetoString(referente.Data_di_Nascita__c);
            this.codiceFiscaleFirmatario= referente.Oplon_Codice_Fiscale__c;
            this.numCellulareFirmatario=referente.Prefisso_Internazionale__c+ referente.MobilePhone;
            this.cittaResidenzaFirmatario=  referente.Comune__c;
            this.indirizzoResidenzaFirmatario = referente.Indirizzo_Residenza_Esteso__c;
            this.ruoloAziendaleFirmatario = referente.Ruolo_in_Azienda__c;
            cittaNascitaFirmatario=referente.Localita__c;
            sfContactId=referente.Id;
        }
    }

    
    //   @future(callout=true)
    public static void cofaceFlusso2(List<String> partitaIvaList) {
        RequestBodyCoface2 bodyGetMoreScore = new RequestBodyCoface2(partitaIvaList);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/risk-analysis-inquiry',
            'method' => 'POST',
            'body' => JSON.serialize(bodyGetMoreScore),
            'nameString' => 'CofaceFlusso2 ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => ''
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        
    } 
    
    
    public class RequestBodyCoface2 {
        List<partitaIva> partitaIva;
        
        
        public RequestBodyCoface2(List<String> partitaIvaList) {
            system.debug('ElevaRestApiController RequestBodyCoface2 - Start');
            
            List<Account> acc = [Select id,Codice_Fiscale__c from  Account where Partita_Iva__c IN :partitaIvaList ];
            partitaIva =new list<partitaIva>();//,
            for( Account account : acc){
                partitaIva s= new partitaIva(account);
                partitaIva.add(s);
            }
            
        }
    }
    
    public class partitaIva{
        public string accountId;// ;//Galli;//,
        public string piva;// ;//Alberto;//,
        
        public partitaIva(Account acc){
            this.accountId=acc.Id;
            this.piva=acc.Codice_Fiscale__c;
            
        }
    }
    
    
    // 5.1 - Creazione pre-istruttoria Anagrafica Cliente in Oplon
    
    @future(callout=true)
    public static void inquiry(String opportunityId, String accountId,List<id> creditLinesList,List<id> contactIdList,List<id> accountIdList, String userEmail, String serializedElevaCredentials) {
        Opportunity oppType = [select id,Name, Tipo_di_opportunit__c,Tipo_Linea_di_Credito__c, StageName from Opportunity where id=:opportunityId limit 1];
                String endpoint;

                if(oppType.Tipo_di_opportunit__c =='Crediti Fiscali' || oppType.Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
                    endpoint = 'creditifiscali/preliminary-inquiry';
                }else{ 
                    endpoint = 'smelending/preliminary-inquiry';
                 }
            RequestBodyDigitalSignature2 bodyDigitalSignature = new RequestBodyDigitalSignature2(opportunityId, accountId,creditLinesList,contactIdList,accountIdList,userEmail);
            Map<String, String> elevaParams = new Map<String, String>{
                'endpoint' => endpoint,
                'method' => 'POST',
                'body' => JSON.serialize(bodyDigitalSignature),
                'nameString' => 'New Opportunity Analysis ',
                'erroreString' => 'Errore invocazione servizio: ', 
                'recordId' => opportunityId,
                'serializedElevaCredentials' => serializedElevaCredentials
            };
            Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
        system.debug('ElevaRestApiController new-opportunity-analysis End');
    }
    
     
    public static void inquiry2(String opportunityId, String accountId,List<id> creditLinesList,List<id> contactIdList,List<id> accountIdList, String userEmail, String serializedElevaCredentials) {
        String body = '';
            Opportunity opp = new Opportunity();
            if(opp.Tipo_Linea_di_Credito__c=='Crediti Fiscali'){
                RequestBodyDigitalSignature3 bodyDigitalSignature = new RequestBodyDigitalSignature3(opportunityId,accountId,creditLinesList,userEmail);
                body = JSON.serialize(bodyDigitalSignature);
            } else {
                RequestBodyDigitalSignature2 bodyDigitalSignature = new RequestBodyDigitalSignature2(opportunityId, accountId,creditLinesList,contactIdList,accountIdList,userEmail);
                body = JSON.serialize(bodyDigitalSignature);
            }
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/preliminary-inquiry',
            'method' => 'POST',
            'body' => body,
            'nameString' => 'New Opportunity Analysis ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => opportunityId,
            'serializedElevaCredentials' => serializedElevaCredentials
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
        system.debug('ElevaRestApiController new-opportunity-analysis End');
    }
    // RequestBody Aggiunto per modifiche a 5.1
    public class RequestBodyDigitalSignature2 { 
        public String opportunityId;
        public String accountId;
        public List<id> creditLinesList ;
        public List<id> contactIdList ;
        public List<id> accountIdList ;
        public String userEmail;
        
        public RequestBodyDigitalSignature2(String opportunityId, String accountId,List<id> creditLinesList,List<id> contactIdList,List<id> accountIdList, String userEmail) {
            this.opportunityId = opportunityId;
            this.accountId = accountId;
            this.creditLinesList = creditLinesList;
            this.contactIdList = contactIdList;
            this.accountIdList = accountIdList;
            this.userEmail =userEmail;
            
        }
    }
    
     public class RequestBodyDigitalSignature3 { 
        public String opportunityId;
        public String accountId;
        public List<id> creditLinesList ;
        
        
        public String userEmail;
        
        public RequestBodyDigitalSignature3(String opportunityId, String accountId,List<id> creditLinesList, String userEmail) {
            this.opportunityId = opportunityId;
            this.accountId = accountId;
            this.creditLinesList = creditLinesList;     
            this.userEmail =userEmail;
            
        }
    }
    
    
    
    public static void testPaddingMethod(){
        system.debug('ElevaRestApiController testPaddingMethod - Start');
        List<ElevaCredentials__mdt> elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        system.debug('List<ElevaCredentials_mdt> : '+ elevaCredentials);
        ElevaCredentials__mdt elevaMoonCredentials = new ElevaCredentials__mdt();
        
        elevaMoonCredentials = elevaCredentials.get(0);
        
        String root = elevaMoonCredentials.root__c;
        String endpoint = 'TEST_PADDING';
        
        String url = '' + root + endpoint;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
        req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
        req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
        req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
        req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
        req.setTimeout(100000);
        
        
        RequestBodyDigitalSignature bodyDigitalSignature = new RequestBodyDigitalSignature('','');
        req.setBody(JSON.serialize(bodyDigitalSignature));
        
        system.debug('ElevaRestApiController testPaddingMethod - End');
    }
    
    public static String contrattoFirmatooCartagio(String fileId, String filename, String processGuid, String docId, String creditLineId, String docType,  String fidejussioneNameId, String fidejussioneFileId){
                String endpoint;
                if(docType == 'SME_114'){
                    endpoint = 'creditifiscali/insert-signed-contract';
                }else if(docType == 'SME_100' || docType == 'SME_058'){ 
                    endpoint = 'smelending/insert-signed-contract';
                 }
               RequestBodyCartagioFirmato bodyStoreDocumenttttt = new RequestBodyCartagioFirmato(fileId, filename, processGuid, creditLineId, fidejussioneNameId, fidejussioneFileId);
               Map<String, String> elevaParams = new Map<String, String>{
                'endpoint' => endpoint,
                'method' => 'POST',
                'body' => JSON.serialize(bodyStoreDocumenttttt),
                'nameString' => 'StoreDocument ',
                'erroreString' => 'Errore invocazione servizio: ', 
                'recordId' => 'Contratto quote'
            };
            Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            String resultStr = res.responseMessage;
           
               
                Document__c doc = new Document__c();
                doc.Id = docId;
             
                if (res.ok == true) {
                    doc.Errore_Store_Document__c = '';
                } else {
                   
                        doc.Errore_Store_Document__c = resultStr;
                    }
                update doc;
                return resultStr;
    }
    
    public class RequestBodyCartagioFirmato{
        String fileId;
        String fileName;
        String processGuid;
        String creditLineId;
        String fidejussioneNameId;
        String fidejussioneFileId;
        public RequestBodyCartagioFirmato(String fileId, String filename, String processGuid, String creditLineId, String fidejussioneNameId, String fidejussioneFileId){
            system.debug('ElevaRestApiController RequestBodyStoreDocument- Start');
            this.fileId = fileId;
            this.fileName = filename;
            this.processGuid = processGuid;
            this.creditLineId = creditLineId;
            this.fidejussioneNameId = fidejussioneNameId;
            this.fidejussioneFileId = fidejussioneFileId;
            
            system.debug('ElevaRestApiController RequestBodyStoreDocument- End');
        }
    }
    
    
    
    
    
    // 1.6 Creazione nuova Opportunity
    @future(callout=true)
    public static void newOpportunityAnalysis(String userMail, String oplonSubjectId, String opportunityId, String serializedElevaCredentials) {
        RequestBodyNewOppAnalysis bodyNewOpp = new RequestBodyNewOppAnalysis(userMail, oplonSubjectId,opportunityId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/new-opportunity-analysis',
            'method' => 'POST',
            'body' => JSON.serialize(bodyNewOpp),
            'nameString' => 'New Opportunity Analysis ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => opportunityId,  
            'serializedElevaCredentials' => serializedElevaCredentials
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
        String resultStr = res.responseMessage;
                Opportunity opp = new Opportunity();
                opp.Id=opportunityId;
                if (res.ok == true) {
                    opp.Errore_New_Opportunity_Analysis__c='';
                } else {
                        opp.Errore_New_Opportunity_Analysis__c = resultStr;
                    }
                
            OpportunityController.bypassTrigger = true;
            Update opp;
            OpportunityController.bypassTrigger = false;
    }
    
    
    public class RequestBodyNewOppAnalysis {
        public String userEmail;
        public String oplonSubjectId;
        public String opportunityId;
        
        
        public RequestBodyNewOppAnalysis(String userMail, String oplonSubjectId, String opportunityId) {
            this.oplonSubjectId = oplonSubjectId;
            this.opportunityId = opportunityId;
            this.userEmail = userMail;
            
        }
    }
    //7.3 Chiusura opportunity da Salesforce 
    @future(callout=true)
    public static void chuisuraOpportunitaSF( String oplonAnalysisId, String opportunityId,String rejectCode,String userMail,String Stage, String serializedElevaCredentials) {
        
                List<Opportunity> oppInfo = [SELECT Id, Tipo_di_opportunit__c, Tipo_Linea_di_Credito__c FROM Opportunity];
                String endpoint;
                if(oppInfo[0].Tipo_di_opportunit__c == 'Crediti Fiscali' || oppInfo[0].Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
                    endpoint = 'creditifiscali/reject-analysis';
                }else{
                    endpoint = 'smelending/reject-analysis';
                }                
                RequestBodychuisuraOpportunitaSF chuisuraOpportunitaSF = new RequestBodychuisuraOpportunitaSF(oplonAnalysisId,opportunityId,rejectCode,userMail,Stage);
                Map<String, String> elevaParams = new Map<String, String>{
                    'endpoint' => endpoint,
                    'method' => 'POST',
                    'body' => JSON.serialize(chuisuraOpportunitaSF),
                    'nameString' => 'ChuisuraOpportunitaSF ',
                    'erroreString' => 'Errore invocazione servizio: ', 
                    'recordId' => opportunityId,  
                    'serializedElevaCredentials' => serializedElevaCredentials
                };
                Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsRespMapDes(elevaParams);
                String resultStr = res.responseMessage;
                String stagename = Stage;
                Opportunity opp = new Opportunity();
                opp.Id=opportunityId;
                if (res.ok == true){         
                    opp.Errore_Chuisura_Opportunita__c = 'SUCCESS';
                } else {
                        opp.Errore_Chuisura_Opportunita__c = resultStr;
                        opp.StageName=stagename;
                }
                OpportunityController.bypassTrigger = true;
                Update opp;
                OpportunityController.bypassTrigger = false;
    }
    
    
    public class RequestBodychuisuraOpportunitaSF {
        
        public String oplonAnalysisId;
        public String opportunityId;
        public String rejectCode;
        public String userEmail;
        public String Stage;
        
        public RequestBodychuisuraOpportunitaSF(String oplonAnalysisId, String opportunityId,String rejectCode, String userMail, String Stage) {
            this.oplonAnalysisId = oplonAnalysisId;
            this.opportunityId = opportunityId;
            this.rejectCode = rejectCode;
            this.userEmail = userMail;
            this.Stage = Stage;
        }
    }
    
    
    
    
    //------ Flusso 4.3 per censimento dingolo fidejussore su cedacri
    
    //@future(callout=true)
    public static Utils.FidejussoreResponse fidejussoreOnCedacri(String guarantorType,String guarantorId,String userEmail ) {
        RequestBodyFidejussoreOnCedacri bodyNewFidejussoreOnCedacri = new RequestBodyFidejussoreOnCedacri(guarantorType , guarantorId, userEmail);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/new-guarantor',
            'method' => 'POST',
            'body' => JSON.serialize(bodyNewFidejussoreOnCedacri),
            'nameString' => 'New Opportunity Analysis ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => guarantorId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
     
            return res;
    }
    
    public class RequestBodyFidejussoreOnCedacri {
        public String guarantorType;
        public String guarantorId;
        public String userEmail;
        
        
        public RequestBodyFidejussoreOnCedacri(String guarantorType, String guarantorId, String userEmail) {
            this.guarantorType = guarantorType;
            this.guarantorId = guarantorId;
            this.userEmail= userEmail;
            
        }
    }    
    
    
    //6.2 Chuisura Quote e Garanzia 
    
    //@future(callout=true)
    public static Utils.FidejussoreResponse  chuisuraGaranziaLineaSFcallout( String quoteId,String oplonItemId,String userEmail) {
        RequestBodychuisuraGaranziaLineaSF bodychuisuraGaranziaLineaSF = new RequestBodychuisuraGaranziaLineaSF(quoteId, oplonItemId,userEmail);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/reject-creditline-guarantee',
            'method' => 'DELETE',
            'body' => JSON.serialize(bodychuisuraGaranziaLineaSF),
            'nameString' => 'ChuisuraGaranziaLineaSF ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => quoteId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
      
            if (res.ok == true) {
                    List<Garanzia__c> gList = [Select Id, Name, Stato_Garanzia__c FROM Garanzia__c where Linea_di_Credito__c = :quoteid];
                    for(Garanzia__c g : gList){
                        g.Stato_Garanzia__c = 'Chiusa'; 
                GaranzieController.bypassTrigger = true;
                update g;
                GaranzieController.bypassTrigger = false;   
                          
                    }
            }
            return res;
    }
    
    public class RequestBodychuisuraGaranziaLineaSF {
        public String quoteId ;
        public String oplonItemId ;
        public String userEmail;
        
        public RequestBodychuisuraGaranziaLineaSF(String quoteId, String oplonItemId,String userEmail) {
            this.quoteId  = quoteId ;
            this.oplonItemId  = oplonItemId ;
            this.userEmail = userEmail;
            
            
        }
    }
    public static Utils.FidejussoreResponse recuperoDatiReferenti(String contactId,String taxCode, String AccountId) {
        RequestBodyrecuperoDatiReferenti bodyrecuperoDatiReferenti = new RequestBodyrecuperoDatiReferenti(contactId,taxCode, AccountId);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/anag-by-taxcode',
            'method' => 'POST',
            'body' => JSON.serialize(bodyrecuperoDatiReferenti),
            'nameString' => 'RecuperoDatiReferenti ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => taxCode
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
               
            return res;
        
        
    }
    
    public class RequestBodyrecuperoDatiReferenti { 
        public String taxCode;
        public String contactId;
        public String AccountId;
        
        public RequestBodyrecuperoDatiReferenti(String contactId,String  taxCode, String AccountId) {
            this.contactId=contactId;
            this.taxCode   = taxCode;  
            this.AccountId = AccountId;
        }
    }
    //5.4 Desospensione    
    //@future(callout=true)
    
    public static Utils.FidejussoreResponse desospensioneOpp(String analysisId,List<Id> creditLinesList,List<Id> guaranteeList,Id opportunityId, String userEmail) {
        RequestBodyDesospenzione bodyDesospenzione = new RequestBodyDesospenzione(analysisId, creditLinesList,guaranteeList,opportunityId, userEmail);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/restart-pef',
            'method' => 'POST',
            'body' => JSON.serialize(bodyDesospenzione),
            'nameString' => 'Desospensione ',
            'erroreString' => 'Errore di allineamento Salesforce-Tigran, si prega di contattare l\'amministratore di sistema. ', 
            'recordId' => analysisId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            return res;
        
    }
    
    public class RequestBodyDesospenzione { 
        public String analysisId;
        public List<Id> guaranteeList;
        public List<Id> creditLinesList;
        public String userEmail;
        public Id opportunityId;

        public RequestBodyDesospenzione(String  analysisId, List<Id> creditLinesList, List<Id> guaranteeList, Id opportunityId, String userEmail) {
            this.analysisId   = analysisId;
            this.guaranteeList = guaranteeList;
            this.creditLinesList = creditLinesList;
            this.userEmail = userEmail;
            this.opportunityId = opportunityId;
            
            
        }
    }
    
    //5.4.1 Desospensione    
    //@future(callout=true)
    
    public static Utils.FidejussoreResponse  desospensioneOpp2(String analysisId,List<Id> creditLinesList,List<Garanzia__c> guaranteeList, String userEmail) {
        RequestBodyDesospenzione2 bodyDesospenzione = new RequestBodyDesospenzione2(analysisId, creditLinesList,guaranteeList, userEmail);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/restart-pef',
            'method' => 'POST',
            'body' => JSON.serialize(bodyDesospenzione),
            'nameString' => 'Desospensione ',
            'erroreString' => ' ', 
            'recordId' => analysisId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            return res;
        
    }
    
    public class RequestBodyDesospenzione2 { 
        public String analysisId;
        public List<Garanzia__c> guaranteeList;
        public List<Id> creditLinesList;
        public String userEmail;
        
        public RequestBodyDesospenzione2(String  analysisId, List<Id> creditLinesList, List<Garanzia__c> guaranteeList, String userEmail) {
            this.analysisId   = analysisId;
            this.guaranteeList = guaranteeList;
            this.creditLinesList = creditLinesList;
            this.userEmail = userEmail; 
        }
    }
    
    //------ Flusso 4.4 Creazione cointestazione in cedacri - Impatti Salesforce
    
    //@future(callout=true)
    public static Utils.FidejussoreResponse  cointestazioneOnCedacriCallout(String guaranteeHoldersId , List<Id> sfGuarantorIdList ,List<String> ndgList , String userEmail,String guarantorType) {
        RequestBodycointestazioneOnCedacri bodyNewcointestazioneOnCedacri = new RequestBodycointestazioneOnCedacri(guaranteeHoldersId  ,sfGuarantorIdList ,ndgList,userEmail, guarantorType);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/new-guarantors-holders',
            'method' => 'POST',
            'body' => JSON.serialize(bodyNewcointestazioneOnCedacri),
            'nameString' => 'CointestazioneOnCedacri ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => guaranteeHoldersId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
            return res;
        
    }
 
    public class RequestBodycointestazioneOnCedacri { 
        public String guaranteeHoldersId;
        public List<Id> sfGuarantorIdList ;
        public List<String> ndgList ;
        public String userEmail;
        public String guarantorType;
        
        
        
        public RequestBodycointestazioneOnCedacri(String guaranteeHoldersId  , List<Id> sfGuarantorIdList ,List<String> ndgList , String userEmail, String guarantorType ) {
            this.guaranteeHoldersId   = guaranteeHoldersId;
            this.sfGuarantorIdList  = sfGuarantorIdList ;
            this.guarantorType  = guarantorType ;
            this.ndgList  = ndgList;
            this.userEmail = userEmail;
            
            
        }
    }
 
    public static String generaTemplate(Quote lineaCredito){
        Boolean mcc=false;
        Boolean nonmcc=false;
        String template ='01'+'_';
        if(lineaCredito.Durata_in_mesi__c<18){
            template+='01_';
        }else{
            template+='02_';
        }
        if(lineaCredito.Garanzie__r.isempty()){
            template+='004_';
        }else{
            
            for(Garanzia__c garanzia: lineaCredito.Garanzie__r){
                if(garanzia.Tipo_di_Garanzia__c==constants.GARANZIA_TIPO_MCC){
                    mcc=true;
                }else{
                    nonmcc=true;
                }
                
            }
            if(mcc && nonmcc){
                template+='002_';
            }else{
                if(mcc && !nonmcc){
                    template+='001_';
                }
                else if(!mcc && nonmcc){
                    template+='003_';
                }
            }
        }
        //da cancellare
        /*if(nonmcc){
template+='01_';
}else{
template+='00_';
}*/
        if(lineaCredito.opportunity.Tipo_Firma__c=='Firma Digitale'  ){
            template+='d';
        }else{
            template+='c';
        }
        
        system.debug('generaTemplate  '+template);
        return template;
    }
 
    public static String convertDatetoString(Date d){
        system.debug('convertDatetoString inputdate'+d);
        if (d==null)
            return null;
        
        Integer day =d.day();
        Integer month=d.month();
        Integer year=d.year();
        String monthString=String.valueof(month);
        String dayString=String.valueof(day);
        if(month<10)
            monthString='0'+String.valueof(month);
        if(day<10){
            dayString='0'+String.valueof(day);
        }
        
        //1970-09-01T07:38:26.933Z;
        String outputdate= String.valueof(year)+'-'+monthString+'-'+dayString+'T00:00:00.000Z';
        system.debug('convertDatetoString outputdate'+outputdate);
        return outputdate;
    }
    
     public static Utils.FidejussoreResponse cambiaUtenti(List<String> analysesId, String userEmail, String assignedEmail,  String accountid, String subjectId, String userid) {
      
            RequestBodycambiaUtenti bodycambiaUtenti = new RequestBodycambiaUtenti(userEmail,assignedEmail,subjectId,analysesId);
            Map<String, String> elevaParams = new Map<String, String>{
                'endpoint' => 'smelending/change-analysis-assignee',
                'method' => 'POST',
                'body' => JSON.serialize(bodycambiaUtenti),
                'nameString' => 'New-opportunity-analysis ',
                'erroreString' => 'Errore invocazione servizio: ', 
                'recordId' => accountid
            };
            Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
               
                Account Acc = [Select Id, Name, Scenario__c FROM Account where Id = :accountid];
                if (res.ok == true) {
                     // If(Acc.Scenario__c=='C'){
                          Acc.Inside_Sales_di_riferimento__c=userid;
                   // }
                   /* else{
                        Acc.Sales_Crediti_Fiscali__c=userid;
                    }*/
               }
            AccountsController.bypassTrigger = true;
                update Acc;
            AccountsController.bypassTrigger = false;
                
            return res;  
    }
    
    public class RequestBodycambiaUtenti {
        public List<String> analysesId;
        public String userEmail;
        public String subjectId;
        public String assignedEmail;
        public RequestBodycambiaUtenti(String userEmail, String assignedEmail, String subjectId, List<String> analysesId) {
            this.userEmail = userEmail;
            this.assignedEmail = assignedEmail;
            this.subjectId = subjectId;
            this.analysesId = analysesId;
        }
    }
    //5.4 Desospensione    
    //
    @future(callout=true)
    public static void  desospensioneOppFutureMassivo(String oppId,  String analysisId,List<Id> creditLinesList,List<Id> guaranteeList, String userEmail) {
        RequestBodyDesospenzione3 bodyDesospenzione = new RequestBodyDesospenzione3(analysisId, creditLinesList,guaranteeList, userEmail);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/restart-pef',
            'method' => 'POST',
            'body' => JSON.serialize(bodyDesospenzione),
            'nameString' => 'New-opportunity-analysis ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => analysisId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        
                Opportunity opp = new Opportunity();
                opp.Id=oppId;
                if (res.ok == false) {
                     opp.Is_Suspended__c=false;
                }
    }
    
    public class RequestBodyDesospenzione3{ 
        public String analysisId;
        public List<Id> guaranteeList;
        public List<Id> creditLinesList;
        public String userEmail;
        
        public RequestBodyDesospenzione3(String  analysisId, List<Id> creditLinesList, List<Id> guaranteeList, String userEmail) {
            this.analysisId   = analysisId;
            this.guaranteeList = guaranteeList;
            this.creditLinesList = creditLinesList;
            this.userEmail = userEmail;
            
            
        }
    }
    //@future(callout=true)
    
    public static Utils.FidejussoreResponse  desospensioneOppBatch(Id oppId,String analysisId,List<Id> creditLinesList,List<Id> guaranteeList, String userEmail) {
        RequestBodyDesospenzione bodyDesospenzione = new RequestBodyDesospenzione(analysisId, creditLinesList, guaranteeList,oppId,userEmail);
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/restart-pef',
            'method' => 'POST',
            'body' => JSON.serialize(bodyDesospenzione),
            'nameString' => 'Desospensione ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => analysisId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                if (res.ok == true) {
                    opp.Is_Suspended__c=false;
                } 
                return res;
        
    }
    
   public static Utils.FidejussoreResponse aggiornaCedacri(Id recordId, String ndg, String type,  date documentDate,String documentType,String documentIssuePlace, String documentNumber,String accountName,String sae, String rae,String location,
                                                            String postalCode, String municipality, String Province,String streetType,String streetName, String streetHomeNumber,String erogazioneDeiServizic,String marketingBancac,String profilazioneBancac,
                                                            String valutazioneQualitaServizioc,String ricercheDiMercatoC,String datiParticolaric,String consensoSic, date dataScadenza) {
    RequestBodyaggiornaCedacri bodyCedacri = new RequestBodyaggiornaCedacri( ndg,  type,   documentDate, documentType, documentIssuePlace,  documentNumber, accountName, sae,  rae, location,
        postalCode,  municipality,  Province, streetType, streetName,  streetHomeNumber, erogazioneDeiServizic, marketingBancac, profilazioneBancac, valutazioneQualitaServizioc, ricercheDiMercatoC, datiParticolaric, consensoSic,dataScadenza);
      Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/update-ndg',
            'method' => 'POST',
            'body' => JSON.serialize(bodyCedacri),
            'nameString' => 'AggiornaCedacri ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => recordId
      };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
                return res;
                
    }
public class RequestBodyaggiornaCedacri { 
        
   public String ndg;
        public String type;  
        Public date documentDate;
        Public String documentType; 
        public String documentIssuePlace; 
        public String documentNumber; 
        public String accountName; 
        public String sae; 
        public String rae; 
        public String location; 
        public String postalCode; 
        public String municipality; 
        public String Province; 
        public String streetType; 
        public String streetName; 
        public String streetHomeNumber; 
        public String erogazioneDeiServizic; 
        public String marketingBancac; 
        public String profilazioneBancac; 
        public String valutazioneQualitaServizioc; 
        public String ricercheDiMercatoC; 
        public String datiParticolaric; 
        public String consensoSic; 
        public Date dataScadenza;
        
        public RequestBodyaggiornaCedacri(String ndg, String type, date documentDate,String documentType,String documentIssuePlace, String documentNumber,String accountName,String sae, String rae,String location,
                                                            String postalCode, String municipality, String Province,String streetType,String streetName, String streetHomeNumber,String erogazioneDeiServizic,String marketingBancac,String profilazioneBancac,
                        String valutazioneQualitaServizioc,String ricercheDiMercatoC,String datiParticolaric,String consensoSic, Date dataScadenza) {
                            this.ndg = ndg;
                            this.type = type;                              
                            this.documentDate = documentDate;
                            this.documentType = documentType;
                            this.documentIssuePlace = documentIssuePlace;      
                            this.documentNumber = documentNumber;   
                            this.accountName = accountName;
                            this.sae = sae;
                            this.rae=rae;
                            this.location=location;   
                            this.postalCode=postalCode; 
                            this.municipality=municipality;
                            this.Province=Province;
                            this.streetType=streetType;
                            this.streetName=streetName;
                            this.streetHomeNumber=streetHomeNumber;
                            this.erogazioneDeiServizic=erogazioneDeiServizic;
                            this.marketingBancac=marketingBancac;
                            this.profilazioneBancac=profilazioneBancac;
                            this.valutazioneQualitaServizioc=valutazioneQualitaServizioc;
                            this.ricercheDiMercatoC=ricercheDiMercatoC;
                            this.datiParticolaric=datiParticolaric;
                            this.consensoSic=consensoSic;
                            this.dataScadenza=dataScadenza;
                        }
    }
    
 public static void getAnagraphicDetailsForBatch(String taxCode, String accountId, String userEmail, String updateOplonUserEmail, String subjectId) {
        RequestBodygetAnagraphicDetails bodyGetAnagrafica = new RequestBodygetAnagraphicDetails(taxCode, accountId, userEmail, updateOplonUserEmail, subjectId);  
        Map<String, String> elevaParams = new Map<String, String>{
            'endpoint' => 'smelending/company-data',
            'method' => 'PUT',
            'body' => JSON.serialize(bodyGetAnagrafica),
            'nameString' => 'GetAnagraphicDetails ',
            'erroreString' => 'Errore invocazione servizio: ', 
            'recordId' => accountId
        };
        Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
        String StatusCode = res.statusCode; 
        String resultStr = res.responseMessage; 
                Account Acc = new Account();
                Acc.Id=accountId;
                if (res.ok == true) {
                    Acc.Errore_Anagraphica_Full__c='';
                } else {
                        if (Acc.CodiceKoOplon__c != StatusCode){
                            Acc.CodiceKoOplon__c= StatusCode;
                            Acc.Errore_Anagraphica_Full__c = resultStr;
                        }
                    }
                AccountsController.bypassTrigger=true;
                update acc;
                AccountsController.bypassTrigger=false;
    }
}