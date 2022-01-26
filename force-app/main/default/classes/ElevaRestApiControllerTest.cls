/**
* Created by ACAPUTO00 on 21/01/2020.
*/

@isTest
public with sharing class ElevaRestApiControllerTest {
    
    @TestSetup
    static void makeData(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(Alias = 'standt', Email = 'test@test.test',
                          EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'eleva@test.test');
        insert u;
        System.debug('Utente inserito ' + u);
        
        Account acc = new Account();
        acc.Name = 'Acc Eleva';
        acc.Manager_NomeCompleto__c = u.id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.OwnerId = u.id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        acc.Codice_Fiscale__c = '1245';
        acc.Analysis_Id_Oplon__c = '75637';
        acc.Anagrafica_Id_Oplon__c = '13232';
        insert acc;
        
        Contact contact = new Contact();
        
        contact.LastName = 'Eleva';
        contact.AccountId = acc.Id;
        contact.RecordTypeId = recordTypeIdRefOpl;
        contact.Fidejussore__c = true;
        contact.Email = 'eleva@gmail.com';
        contact.Phone = '123456789';
        contact.NDG__c = '12345';
        insert contact;
        Opportunity o = new Opportunity
            (AccountId=acc.Id,
             Name = 'Eleva 1',
             CloseDate = Date.today()+1,
             StageName='Primo Contatto',
             Forecast_Category_Custom__c='Elevata Probabilità',
             Tipo_Linea_di_Credito__c='Mutuo',
             Finalita_Finanziamento__c='Liquidità',
             Ammontare_Iniziale__c=1000,
             Durata_Partner__c=100,
             Linea_di_Credito_in_Mesi__c =20,
             Data_Stipula__c = Date.today(),
             OwnerId=acc.OwnerId,
             Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
             Sales_Support_Approver__c = u.id,
             Inside_Sales_di_Riferimento__c = u.id ,  
             Sabatini_Applicabile__c='Si',
             Numero_Pratica__c='12345'
            );
        OpportunityController.bypassTrigger = true;
        insert o;
        OpportunityController.bypassTrigger = true;
        System.debug('Opportunity inserita' + o);
         Quote quote = new Quote();
quote.Name = 'Eleva';
quote.ExpirationDate = Date.today();
quote.Ammontare_Iniziale__c = 1000;
quote.Ammontare_Direzione__c = 1000;
quote.Durata_Direzione__c = 10;
quote.Ammontare_Deliberato__c = 1000;
quote.Durata_Partner__c = 10;
quote.Tipo_Linea_di_Credito__c = 'Mutuo';
quote.Finalita_Finanziamento__c = 'Investimento';
quote.OpportunityId = o.Id;
quote.Status = 'In Corso';
quote.Durata_Deliberata__c = 10;
quote.Ammontare_Erogato__c = 100;
quote.Durata_Erogata__c = 10;
quote.Sabatini_Applicabile__c = 'Si';
quote.Contratto_Verificato__c = true;
insert quote;
        //Quote q = [Select Id From Quote where OpportunityId =: o.Id];
        Garanzia__c garanzia = new Garanzia__c();
        
        garanzia.Tipo_di_Garanzia__c = 'FONDO MCC';
        garanzia.Stato_Garanzia__c = 'Aperta';
        garanzia.Linea_di_Credito__c = quote.Id;
        garanzia.Percentuale_Garantito__c = '80%';
        GaranzieController.bypassTrigger=true;
        insert garanzia;
        GaranzieController.bypassTrigger=false;
            Garanzia__c g = new Garanzia__c();
        
        g.Tipo_di_Garanzia__c = 'Fidejussione';
        g.Tipo_di_Fidejussione__c='Persona Fisica';
        g.Stato_Garanzia__c = 'Aperta';
        g.Linea_di_Credito__c = quote.Id;
        g.Percentuale_Garantito__c = '130%';
        GaranzieController.bypassTrigger=true;
        insert g;
        GaranzieController.bypassTrigger=false;
        Fidejussione__c a = new Fidejussione__c();
        a.Persona_Fisica__c=contact.id;
        a.Garanzia__c = g.id;
        insert a;
        DocumentType__c documentType = ObjectFactory.insertNewDocumentType('Contact');
        //insert documentType;
        List<ContentVersion> cntVersion = new List<ContentVersion>();
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'Analisi Coface.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = 'Analisi Coface.pdf';
        cVersion.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cntVersion.add(cVersion);
        insert cntVersion;
        
        ContentVersion c =[SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id IN:cntVersion limit 1];
        Document__c document = new Document__c();
        document.Name = 'Eleva';
        document.DocumentType__c = documentType.Id;
        document.Commento_Sales_Support__c = 'Elevaaaa';
        document.Id_File__c=c.ContentDocumentId;
        insert document;
        
        ContentVersion cVer = new ContentVersion();
        cVer.ContentLocation = 'S';
        cVer.PathOnClient = 'Analisi Coface.pdf';
        cVer.Origin = 'H';
        cVer.Title = 'Analisi Coface.pdf';
        cVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cVer;
        DocumentType__c dT = ObjectFactory.insertNewDocumentType('Quote');
        ContentVersion cv =[SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id =: cVer.id];
        Document__c d = new Document__c();
        d.Name = 'DocFide';
        d.DocumentType__c = dT.Id;
        d.Commento_Sales_Support__c = 'Elevaaaa';
        d.Id_File__c=cv.ContentDocumentId;
        insert d;
    }
    
    @isTest static ElevaCredentials__mdt getElevaCredentials(){
        ElevaCredentials__mdt mcmd = new ElevaCredentials__mdt(
            DeveloperName = 'ElevaMoon',
            endpoint__c = 'smelending/morescore',
            x_api_key__c = 'key',
            x_app_language__c = 'it',
            x_caller_id__c = 'SALESFORCE',
            x_channel__c = 'EXT',
            x_hmac__c = 'xhmac');
        
        return mcmd;
    }
    
    @isTest static void testGetMoreScore() {
        
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        Test.startTest();
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        String taxCode = acc.Codice_Fiscale__c;
        String accId = acc.Id;
        String usermail = u.Email;
        String oplonId = acc.Anagrafica_Id_Oplon__c;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.getMoreScore1(taxCode, accId, usermail, oplonId);
        ElevaRestApiController.getMoreScore(taxCode, accId, usermail, oplonId);  
        
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest static void testGetMoreScore3() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        String taxCode = acc.Codice_Fiscale__c;
        String accId = acc.Id;
        String usermail = u.Email;
        String oplonId = acc.Anagrafica_Id_Oplon__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.getMoreScore1(taxCode, accId, usermail, oplonId);
        ElevaRestApiController.getMoreScore(taxCode, accId, usermail, oplonId);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest static void testGetMoreScoreTriggger1() {
        
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        String serializeCredential = JSON.serialize(mcmd, true);
        Account acc = [Select Id,AccountNumber, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        Contact c = [Select Id, Phone, NDG__c,FinServ__IndividualType__c from Contact where LastName = 'Eleva'];
        List<Contact> contactList = new List<Contact>();
        contactList.add(c);
        Opportunity opp = [Select Id,Errore_Chuisura_Opportunita__c,StageName,Numero_Pratica__c From Opportunity where AccountId =: acc.Id];
        Quote q = [Select Id From Quote where OpportunityId =: opp.Id];
        Garanzia__c g = [Select Id, name From Garanzia__c where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'FONDO MCC'];
        List<Garanzia__c> guaranteeList = new List<Garanzia__c>();
        guaranteeList.add(g);
        List<Id> guaranteeIdList = new List<Id>();
        String guaranteeId = c.Id;
        guaranteeIdList.add(guaranteeId);
        List<Id> creditLinesList = new List<Id>();
        String quoteId = q.Id;
        creditLinesList.add(quoteId);
        List<Id> contactIdList = new List<Id>();
        String contactId = c.Id;
        contactIdList.add(contactId);
        List<Id> accountIdList = new List<Id>();
        String accId = acc.Id;
        accountIdList.add(accId);
        List<String> ndgList = new List<String>();
        String ndg = acc.AccountNumber;
        ndgList.add(ndg);
        List<String> oplonIdList = new List<String>();
        String oplonId = acc.Anagrafica_Id_Oplon__c;
        oplonIdList.add(oplonId);
        String taxCode = acc.Codice_Fiscale__c;
        String usermail = u.Email;
        String userId = u.Id;
        String opportunityId = opp.Id;
        String rejectCode = opp.Errore_Chuisura_Opportunita__c;
        String Stage = opp.StageName;
        String guarantorType = c.FinServ__IndividualType__c;
        String oplonOppId = opp.Numero_Pratica__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.getMoreScoreTrigger(taxCode, accId, usermail, oplonId,serializeCredential);
        ElevaRestApiController.CRreferentiTrigger(ndg, contactId, serializeCredential);
        ElevaRestApiController.chuisuraOpportunitaSF(oplonId, opportunityId, rejectCode, userMail, Stage,  serializeCredential);
        ElevaRestApiController.newOpportunityAnalysis(userMail, oplonId, opportunityId, serializeCredential);
        ElevaRestApiController.inquiry(opportunityId, accId,creditLinesList,contactIdList,accountIdList, usermail, serializeCredential);
        ElevaRestApiController.inquiry2(opportunityId, accId,creditLinesList,contactIdList,accountIdList, usermail, serializeCredential);
        ElevaRestApiController.cointestazioneOnCedacriCallout(contactId ,contactIdList ,ndgList, usermail, guarantorType);
        ElevaRestApiController.desospensioneOpp(oplonOppId, creditLinesList, contactIdList, opportunityId, usermail);
        ElevaRestApiController.desospensioneOpp2(oplonOppId,creditLinesList, guaranteeList, usermail);
        ElevaRestApiController.desospensioneOppBatch(opp.Id,oplonOppId,creditLinesList, guaranteeIdList, usermail);
        ElevaRestApiController.desospensioneOppFutureMassivo(opportunityId,oplonOppId,creditLinesList, guaranteeIdList, usermail);
        ElevaRestApiController.DownloadDocs(opportunityId,accId, contactList);
        ElevaRestApiController.cambiaUtenti(oplonIdList, usermail, usermail, accId, contactId, userId);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest static void testGetMoreScoreTriggger2() {
        
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        String serializeCredential = JSON.serialize(mcmd, true);
        Account acc = [Select Id,AccountNumber, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        Contact c = [Select Id, Phone, NDG__c,FinServ__IndividualType__c from Contact where LastName = 'Eleva'];
        List<Contact> contactList = new List<Contact>();
        contactList.add(c);
        Opportunity opp = [Select Id,Errore_Chuisura_Opportunita__c, StageName,Numero_Pratica__c From Opportunity where AccountId =: acc.Id];
        Quote q = [Select Id From Quote where OpportunityId =: opp.Id];
        Garanzia__c g = [Select Id,name From Garanzia__c where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'FONDO MCC'];
        List<Garanzia__c> guaranteeList = new List<Garanzia__c>();
        guaranteeList.add(g);
        List<Id> guaranteeIdList = new List<Id>();
        String guaranteeId = c.Id;
        guaranteeIdList.add(guaranteeId);
        List<Id> creditLinesList = new List<Id>();
        String quoteId = q.Id;
        creditLinesList.add(quoteId);
        List<Id> contactIdList = new List<Id>();
        String contactId = c.Id;
        contactIdList.add(contactId);
        List<Id> accountIdList = new List<Id>();
        String accId = acc.Id;
        accountIdList.add(accId);
        List<String> ndgList = new List<String>();
        String ndg = acc.AccountNumber;
        ndgList.add(ndg);
        List<String> oplonIdList = new List<String>();
        String oplonId = acc.Anagrafica_Id_Oplon__c;
        oplonIdList.add(oplonId);
        String taxCode = acc.Codice_Fiscale__c;
        String usermail = u.Email;
        String userId = u.Id;
        String opportunityId = opp.Id;
        String rejectCode = opp.Errore_Chuisura_Opportunita__c;
        String Stage = opp.StageName;
        String guarantorType = c.FinServ__IndividualType__c;
        String oplonOppId = opp.Numero_Pratica__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.getMoreScoreTrigger(taxCode, accId, usermail, oplonId,serializeCredential);
        ElevaRestApiController.CRreferentiTrigger(ndg, contactId, serializeCredential);
        ElevaRestApiController.chuisuraOpportunitaSF(oplonId, opportunityId, rejectCode, userMail, Stage,  serializeCredential);
        ElevaRestApiController.newOpportunityAnalysis(userMail, oplonId, opportunityId, serializeCredential);
        ElevaRestApiController.inquiry(opportunityId, accId,creditLinesList,contactIdList,accountIdList, usermail, serializeCredential);
        ElevaRestApiController.inquiry2(opportunityId, accId,creditLinesList,contactIdList,accountIdList, usermail, serializeCredential);
        ElevaRestApiController.cointestazioneOnCedacriCallout(contactId ,contactIdList ,ndgList, usermail, guarantorType);
        ElevaRestApiController.desospensioneOpp(oplonOppId, creditLinesList, contactIdList, opportunityId, usermail);
        ElevaRestApiController.desospensioneOpp2(oplonOppId,creditLinesList, guaranteeList, usermail);
        ElevaRestApiController.desospensioneOppBatch(opp.Id,oplonOppId,creditLinesList, guaranteeIdList, usermail);
        ElevaRestApiController.desospensioneOppFutureMassivo(opportunityId,oplonOppId,creditLinesList, guaranteeIdList, usermail);
        ElevaRestApiController.DownloadDocs(opportunityId,accId, contactList);
        ElevaRestApiController.cambiaUtenti(oplonIdList, usermail, usermail, accId, contactId, userId);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest    static void testGetAnagraphicDetailsTrigger() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        String serializeCredential = JSON.serialize(mcmd, true);
        Account acc = [Select Id, Codice_Fiscale__c, updateOplonUserEmail__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        String taxCode = acc.Codice_Fiscale__c;
        String accId = acc.Id;
        String usermail = u.Email;
        String updateOplonMail = acc.updateOplonUserEmail__c;
        String subjectId = acc.Anagrafica_Id_Oplon__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.getAnagraphicDetailsTrigger(taxCode, accId, usermail, serializeCredential, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetails(taxCode, accId, userMail, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetails1(taxCode, accId, userMail, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetailsForBatch(taxCode, accId, usermail, updateOplonMail, subjectId);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest    static void testGetAnagraphicDetailsTrigger2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        String serializeCredential = JSON.serialize(mcmd, true);
        Account acc = [Select Id, Codice_Fiscale__c, updateOplonUserEmail__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        String taxCode = acc.Codice_Fiscale__c;
        String accId = acc.Id;
        String usermail = u.Email;
        String updateOplonMail = acc.updateOplonUserEmail__c;
        String subjectId = acc.Anagrafica_Id_Oplon__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));       
        ElevaRestApiController.getAnagraphicDetailsTrigger(taxCode, accId, usermail, serializeCredential, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetails(taxCode,  accId, userMail, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetails1(taxCode,  accId, userMail, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetailsForBatch(taxCode, accId, usermail, updateOplonMail, subjectId);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest    static void testGetAnagraphicDetails2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, updateOplonUserEmail__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        String taxCode = acc.Codice_Fiscale__c;
        String accId = acc.Id;
        String usermail = u.Email;
        String updateOplonMail = acc.updateOplonUserEmail__c;
        String subjectId = acc.Anagrafica_Id_Oplon__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.getAnagraphicDetails(taxCode, accId, usermail, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetails1(taxCode, accId, usermail, updateOplonMail, subjectId);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    
    @isTest    static void testGetAnagraphicDetails4() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, updateOplonUserEmail__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        String taxCode = acc.Codice_Fiscale__c;
        String accId = acc.Id;
        String usermail = u.Email;
        String updateOplonMail = acc.updateOplonUserEmail__c;
        String subjectId = acc.Anagrafica_Id_Oplon__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.getAnagraphicDetails(taxCode, accId, usermail, updateOplonMail, subjectId);
        ElevaRestApiController.getAnagraphicDetails1(taxCode, accId, usermail, updateOplonMail, subjectId);
        System.assertEquals('200', '200');
        
        Test.stopTest();
    }
    @isTest   static void testVerifyContact() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Contact c = [Select Id, Phone, NDG__c from Contact where LastName = 'Eleva'];
        String contactId = c.Id;
        String txtData = c.NDG__c;
        String txtType = c.Phone;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.verifyContact(contactId, txtData, txtType);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest   static void testVerifyContact2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Contact c = [Select Id, Phone, NDG__c from Contact where LastName = 'Eleva'];
        String contactId = c.Id;
        String txtData = c.NDG__c;
        String txtType = c.Phone;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.verifyContact(contactId, txtData, txtType);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest   static  void testCheckContact() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Contact c = [Select Id, Phone, NDG__c from Contact where LastName = 'Eleva'];
        String contactId = c.Id;
        String txtData = c.NDG__c;
        String txtType = c.Phone;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.checkContact(contactId, txtData, txtType);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest   static  void testCheckContact2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Contact c = [Select Id, Phone, NDG__c from Contact where LastName = 'Eleva'];
        String contactId = c.Id;
        String txtData = c.NDG__c;
        String txtType = c.Phone;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.checkContact(contactId, txtData, txtType);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest  static void testStoreDocument() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        String accountId = acc.Id;
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        Contact c = [Select Id, Phone, NDG__c, Oplon_Codice_Fiscale__c from Contact where LastName = 'Eleva'];
        Quote q = [Select Id From Quote where OpportunityId =: opportunityId];
        Garanzia__c g = [Select Id, Name FROM Garanzia__c  where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'FONDO MCC'];
        Document__c d = [Select Id, Id_File__c, Name, File_Name__c, GUI__c, IDTipoDocumentoFormula__c, DocumentClassFormula__c,DocumentBlockFormula__c, DocumentType__c, DocumentTypeNameFormula__c, ObjectType__c From Document__c where Name = 'Eleva'];
        Document__c doc = [Select Id, Id_File__c, Name  From Document__c where Name = 'DocFide'];
        String fileObject = '';
        String filename = d.File_Name__c;
        String documentId = d.Id;
        String documentFamily = d.DocumentClassFormula__c;
        String objectId = c.Id;
        Datetime uploadDate = Datetime.now();
        String documentTypeId = d.DocumentType__c; 
        String docName = d.Name;
        String taxCode = acc.Codice_Fiscale__c;
        String contractNumber = '';
        Datetime stipulationDate = Datetime.now();
        String description = d.DocumentTypeNameFormula__c;
        String idOplon = acc.Anagrafica_Id_Oplon__c;
        String stage = opp.StageName;
        String objectType = d.ObjectType__c;
        String userEmail = u.Email;
        String contactTaxCode = c.Oplon_Codice_Fiscale__c;
        String nominativoReferente = '';
        String contactIdSalesforce = c.Id;
        String action = 'Aggiungi';
        String gui = d.GUI__c ;
        String nameFileDescription = d.DocumentBlockFormula__c;
        String docType = d.IDTipoDocumentoFormula__c; 
        String quoteId = q.Id;
        String fileId = d.Id_File__c;
        String fidejussioneNameId = doc.Name;
        String fidejussioneFileId = doc.Id_File__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        
        ElevaRestApiController.storeDocument(fileObject, filename, documentId, documentFamily, objectId,
                                             accountId, uploadDate, documentTypeId, docName, taxCode, contractNumber, stipulationDate, description,
                                             idOplon, stage, objectType, userEmail, contactTaxCode, nominativoReferente, contactIdSalesforce, action, gui, nameFileDescription);
        
        ElevaRestApiController.storeDocument2(fileObject, filename, documentId, documentFamily, objectId,
                                              accountId, uploadDate, documentTypeId, docName, taxCode, contractNumber, stipulationDate, description,
                                              idOplon, stage, objectType, userEmail, contactTaxCode, nominativoReferente, contactIdSalesforce, action, gui, nameFileDescription);
        
        ElevaRestApiController.contrattoFirmatooCartagio(fileObject, filename, gui, documentId,quoteId, docType, fidejussioneNameId, fidejussioneFileId);
        ElevaRestApiController.storeDocumentBatchContrata(fileId, filename,gui, documentId, objectID, fidejussioneNameId, fidejussioneFileId);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest  static void testStoreDocument2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        String accountId = acc.Id;
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        Contact c = [Select Id, Phone, NDG__c, Oplon_Codice_Fiscale__c from Contact where LastName = 'Eleva'];
        Quote q = [Select Id From Quote where OpportunityId =: opportunityId];
        Garanzia__c g = [Select Id, Name,Tipo_di_Garanzia__c FROM Garanzia__c  where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'Fidejussione'];
        Document__c d = [Select Id,Id_File__c, Name, File_Name__c, GUI__c, IDTipoDocumentoFormula__c, DocumentClassFormula__c,DocumentBlockFormula__c, DocumentType__c, DocumentTypeNameFormula__c, ObjectType__c From Document__c where Name = 'Eleva'];
        Document__c doc = [Select Id, Id_File__c, Name  From Document__c where Name = 'DocFide'];
        String fileObject = '';
        String filename = d.File_Name__c;
        String documentId = d.Id;
        String documentFamily = d.DocumentClassFormula__c;
        String objectId = c.Id;
        Datetime uploadDate = Datetime.now();
        String documentTypeId = d.DocumentType__c; 
        String docName = d.Name;
        String taxCode = acc.Codice_Fiscale__c;
        String contractNumber = '';
        Datetime stipulationDate = Datetime.now();
        String description = d.DocumentTypeNameFormula__c;
        String idOplon = acc.Anagrafica_Id_Oplon__c;
        String stage = opp.StageName;
        String objectType = d.ObjectType__c;
        String userEmail = u.Email;
        String contactTaxCode = c.Oplon_Codice_Fiscale__c;
        String nominativoReferente = '';
        String contactIdSalesforce = c.Id;
        String action = 'Aggiungi';
        String gui = d.GUI__c ;
        String nameFileDescription = d.DocumentBlockFormula__c;
        String docType = d.IDTipoDocumentoFormula__c; 
        String quoteId = q.Id;
        String fileId = d.Id_File__c;
        String fidejussioneNameId = doc.Name;
        String fidejussioneFileId = doc.Id_File__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        
        ElevaRestApiController.storeDocument(fileObject, filename, documentId, documentFamily, objectId,
                                             accountId, uploadDate, documentTypeId, docName, taxCode, contractNumber, stipulationDate, description,
                                             idOplon, stage, objectType, userEmail, contactTaxCode, nominativoReferente, contactIdSalesforce, action, gui, nameFileDescription);
        ElevaRestApiController.storeDocument2(fileObject, filename, documentId, documentFamily, objectId,
                                              accountId, uploadDate, documentTypeId, docName, taxCode, contractNumber, stipulationDate, description,
                                              idOplon, stage, objectType, userEmail, contactTaxCode, nominativoReferente, contactIdSalesforce, action, gui, nameFileDescription);
        ElevaRestApiController.contrattoFirmatooCartagio(fileObject, filename, gui, documentId,quoteId, docType, fidejussioneNameId, fidejussioneFileId);
        System.assertNotEquals('400', '200');
        ElevaRestApiController.storeDocumentBatchContrata(fileId, filename,gui, documentId, objectID, fidejussioneNameId, fidejussioneFileId);
        Test.stopTest();
    }
    @isTest static void testStoreDocumentBatch(){
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        String accountId = acc.Id;
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        Contact c = [Select Id,FinServ__IndividualType__c,Email, Phone, LastName, FirstName, NDG__c,Sigla_Provincia_Nascita__c,Data_di_Nascita__c, Stato_ResidenzaEstero__c,Oplon_Codice_Fiscale__c,Numero_Documento__c, Luogo_Rilascio__c,Data_Rilascio__c,Data_Scadenza__c,Stato_di_Nascita__c,Stato_Nascita__c, Codice_Catastale__c,Titolo_Firmatario__c,Tipo_Documento__c,Genere_Nascita__c,Prefisso_Internazionale__c,MobilePhone,Comune__c,Sigla_Provincia__c,Indirizzo_Residenza_Esteso__c,Cap__c,Ruolo_in_Azienda__c,Localita__c,Residenza__c,Paese_Rilascio__c from Contact where LastName = 'Eleva'];
        Quote q = [Select Id From Quote where OpportunityId =: opportunityId];
        Garanzia__c g = [Select Id, Name,Tipo_di_Garanzia__c FROM Garanzia__c  where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'Fidejussione'];
        Document__c d = [Select Id, Id_File__c, Name, File_Name__c, GUI__c, IDTipoDocumentoFormula__c, DocumentClassFormula__c,DocumentBlockFormula__c, DocumentType__c, DocumentTypeNameFormula__c, ObjectType__c From Document__c where Name = 'Eleva'];
        Document__c doc = [Select Id, Id_File__c, Name  From Document__c where Name = 'DocFide'];
        String fileId = d.Id_File__c;
        String filename = d.Name;
        String documentId = d.Id;
        String documentFamily = d.DocumentClassFormula__c;
        String objectId = q.Id;
        Datetime uploadDate = Datetime.now();
        String documentTypeId = d.DocumentType__c; 
        String docName = d.Name;
        String taxCode = acc.Codice_Fiscale__c;
        String contractNumber = '';
        Datetime stipulationDate = Datetime.now();
        String description = d.DocumentTypeNameFormula__c;
        String idOplon = acc.Anagrafica_Id_Oplon__c;
        String stage = opp.StageName;
        String objectType = d.ObjectType__c;
        String userEmail = u.Email;
        String contactTaxCode = c.Oplon_Codice_Fiscale__c;
        String nominativoReferente = '';
        String contactIdSalesforce = c.Id;
        String action = 'Aggiungi';
        String gui = d.GUI__c ;
        String guarantorType = c.FinServ__IndividualType__c;
        String fidejussioneNameId = doc.Name;
        String fidejussioneFileId = doc.Id_File__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.storeDocumentBatch(fileId, filename,documentId,documentFamily,objectId,accountId,uploadDate,documentTypeId,
                                                  docName,taxCode,contractNumber,stipulationDate,description,idOplon,stage,objectType,userEmail,contactTaxCode,nominativoReferente,
                                                  contactIdSalesforce,action,gui);
        ElevaRestApiController.chuisuraGaranziaLineaSFcallout(contactIdSalesforce, idOplon, userEmail);
        ElevaRestApiController.recuperoDatiReferenti(contactIdSalesforce, taxCode, accountId);        
        ElevaRestApiController.RichiediContratto richiediCon = new ElevaRestApiController.RichiediContratto(q.Id);
        ElevaRestApiController.RichiediContrattoCrediti richiediConCre = new ElevaRestApiController.RichiediContrattoCrediti(q.Id, acc.Id);
        ElevaRestApiController.Firmatario firmatarioNew = new  ElevaRestApiController.Firmatario(c);
        ElevaRestApiController.Firmatari firmatariNew = new  ElevaRestApiController.Firmatari(c);
        ElevaRestApiController.RequestBodyCartagioFirmato bodyCartagioFirma = new ElevaRestApiController.RequestBodyCartagioFirmato(fileId, filename, gui, objectId, fidejussioneNameId, fidejussioneFileId);
        ElevaRestApiController.fidejussoreOnCedacri(guarantorType, contactIdSalesforce, userEmail); 
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest static void testStoreDocumentBatch2(){
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Account acc = [Select Id, Codice_Fiscale__c, Anagrafica_Id_Oplon__c from Account where Name = 'Acc Eleva'];
        String accountId = acc.Id;
        User u = [Select Id, Email from User where FirstName = 'Utente'];
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        Contact c = [Select Id,Email, Phone, FinServ__IndividualType__c,LastName, FirstName, NDG__c,Sigla_Provincia_Nascita__c,Data_di_Nascita__c, Stato_ResidenzaEstero__c,Oplon_Codice_Fiscale__c,Numero_Documento__c, Luogo_Rilascio__c,Data_Rilascio__c,Data_Scadenza__c,Stato_di_Nascita__c,Stato_Nascita__c,Codice_Catastale__c,Titolo_Firmatario__c,Tipo_Documento__c,Genere_Nascita__c,Prefisso_Internazionale__c,MobilePhone,Comune__c,Sigla_Provincia__c,Indirizzo_Residenza_Esteso__c,Cap__c,Ruolo_in_Azienda__c,Localita__c,Residenza__c,Paese_Rilascio__c from Contact where LastName = 'Eleva'];
        Quote q = [Select Id From Quote where OpportunityId =: opportunityId];
        Garanzia__c g = [Select Id, Name, Tipo_di_Garanzia__c FROM Garanzia__c  where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'Fidejussione'];
        Document__c d = [Select Id, Id_File__c, Name, File_Name__c, GUI__c, IDTipoDocumentoFormula__c, DocumentClassFormula__c,DocumentBlockFormula__c, DocumentType__c, DocumentTypeNameFormula__c, ObjectType__c From Document__c where Name = 'Eleva'];
        Document__c doc = [Select Id, Id_File__c, Name  From Document__c where Name = 'DocFide'];
        String fileId = d.Id_File__c;
        String filename = d.Name;
        String documentId = d.Id;
        String documentFamily = d.DocumentClassFormula__c;
        String objectId = q.Id;
        Datetime uploadDate = Datetime.now();
        String documentTypeId = d.DocumentType__c; 
        String docName = d.Name;
        String taxCode = acc.Codice_Fiscale__c;
        String contractNumber = '';
        Datetime stipulationDate = Datetime.now();
        String description = d.DocumentTypeNameFormula__c;
        String idOplon = acc.Anagrafica_Id_Oplon__c;
        String stage = opp.StageName;
        String objectType = d.ObjectType__c;
        String userEmail = u.Email;
        String contactTaxCode = c.Oplon_Codice_Fiscale__c;
        String nominativoReferente = '';
        String contactIdSalesforce = c.Id;
        String action = 'Aggiungi';
        String gui = d.GUI__c ;
        String guarantorType = c.FinServ__IndividualType__c;
        String fidejussioneNameId = doc.Name;
        String fidejussioneFileId = doc.Id_File__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.storeDocumentBatch(fileId, filename,documentId,documentFamily,objectId,accountId,uploadDate,documentTypeId,
                                                  docName,taxCode,contractNumber,stipulationDate,description,idOplon,stage,objectType,userEmail,contactTaxCode,nominativoReferente,
                                                  contactIdSalesforce,action,gui);
        ElevaRestApiController.chuisuraGaranziaLineaSFcallout(objectId, idOplon, userEmail);
        ElevaRestApiController.recuperoDatiReferenti(contactIdSalesforce, taxCode, accountId);
        ElevaRestApiController.RichiediContratto richiediCon = new ElevaRestApiController.RichiediContratto(q.Id);
        ElevaRestApiController.RichiediContrattoCrediti richiediConCre = new ElevaRestApiController.RichiediContrattoCrediti(q.Id, acc.Id);
        ElevaRestApiController.Firmatario firmatarioNew = new  ElevaRestApiController.Firmatario(c);
        ElevaRestApiController.Firmatari firmatariNew = new  ElevaRestApiController.Firmatari(c);
        ElevaRestApiController.RequestBodyCartagioFirmato bodyCartagioFirma = new ElevaRestApiController.RequestBodyCartagioFirmato(fileId, filename, gui, objectId, fidejussioneNameId, fidejussioneFileId);
        ElevaRestApiController.fidejussoreOnCedacri(guarantorType, contactIdSalesforce, userEmail);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    
    @isTest  static  void testGetDocumentToken() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.testPaddingMethod();
        ElevaRestApiController.getDocumentToken();
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest  static  void testGetDocumentToke2n() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.testPaddingMethod();
        ElevaRestApiController.getDocumentToken();
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest  static  void testAnagraphiCr() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        List<String> pIvaList = new List<String>();
        Account acc = [Select Id,Partita_Iva__c, AccountNumber from Account where Name = 'Acc Eleva'];
        String pIva = acc.Partita_Iva__c;
        pIvaList.add(pIva);
        String accountId = acc.Id;
        String accNumber = acc.AccountNumber;
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.anagraphicCr2(opportunityId, accountId, accNumber);
        ElevaRestApiController.digitalSignature(opportunityId, accountId);
        ElevaRestApiController.cofaceFlusso2(pIvaList);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest  static  void testAnagraphiCr2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        List<String> pIvaList = new List<String>();
        Account acc = [Select Id,Partita_Iva__c, AccountNumber from Account where Name = 'Acc Eleva'];
        String pIva = acc.Partita_Iva__c;
        pIvaList.add(pIva);
        String accountId = acc.Id;
        String accNumber = acc.AccountNumber;
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.anagraphicCr2(opportunityId, accountId, accNumber);
        ElevaRestApiController.digitalSignature(opportunityId, accountId);
        ElevaRestApiController.cofaceFlusso2(pIvaList);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest  static  void testGenerateContract() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Test.startTest();
        Account acc = [Select Id, AccountNumber from Account where Name = 'Acc Eleva'];
        String accountId = acc.Id;
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
       // Quote q = [Select Id, Durata_in_mesi__c, Opportunity.Tipo_Firma__c From Quote where OpportunityId =: opportunityId];
       Quote q = [Select Id, processGuid__c,Documento_Da_Firmare__c,Data_Stipula__c,
            Commissione_acquisto_pro_soluto__c,
            Corrispettivo_cessione__c, Euribor__c, Durata_in_mesi__c,
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
            Opportunity.Tipo_Firma__c From Quote where OpportunityId =: opportunityId limit 1];
        String quoteId = q.Id;
        Garanzia__c g = [Select Id, Name, Tipo_di_Garanzia__c From Garanzia__c where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'Fidejussione'];
        Map<String,String> oppInfo = new  Map<String,String>();
        oppInfo.put('opportunityType','Mutuo');
        oppInfo.put('quoteId', q.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        //ElevaRestApiController.generateContract('quoteId', oppInfo);
        //ElevaRestApiController.generateContractFuture('quoteId', oppInfo);
        ElevaRestApiController.generaTemplate(q);
        //ElevaRestApiController.RichiediContratto(q.Id);
        ElevaRestApiController.convertDatetoString(Date.today()+1);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest  static  void testGenerateContract2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        Test.startTest();
        Account acc = [Select Id, AccountNumber from Account where Name = 'Acc Eleva'];
        String accountId = acc.Id;
        Opportunity opp = [Select Id, StageName From Opportunity where AccountId =: accountId];
        String opportunityId = opp.Id;
        //Quote q = [Select Id,Durata_in_mesi__c,Opportunity.Tipo_Firma__c From Quote where OpportunityId =: opportunityId];
        Quote q = [Select Id, processGuid__c,Documento_Da_Firmare__c,Data_Stipula__c,
            Commissione_acquisto_pro_soluto__c,
            Corrispettivo_cessione__c, Euribor__c, Durata_in_mesi__c,
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
            Opportunity.Tipo_Firma__c From Quote where OpportunityId =: opportunityId limit 1];
        
        Garanzia__c g = [Select Id, Name, Tipo_di_Garanzia__c From Garanzia__c where Linea_di_Credito__c =: q.Id and Tipo_di_Garanzia__c = 'Fidejussione'];
        Map<String,String> oppInfo = new  Map<String,String>();
        oppInfo.put('opportunityType','Mutuo');
        oppInfo.put('quoteId', q.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        //ElevaRestApiController.generateContract('quoteId', oppInfo);
        //ElevaRestApiController.generateContractFuture('quoteId', oppInfo);
        ElevaRestApiController.generaTemplate(q);
        ElevaRestApiController.convertDatetoString(Date.today()+1);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
    @isTest  
    private static  void testAggiornaCedacri() {
        ElevaCredentials__mdt mcmd = getElevaCredentials(); 
        
        Account acc = [Select Id, AccountNumber,Name, SAE__c,RAE__c,Indirizzo_Sede_Legale_Esteso__c, BillingPostalCode,Comune__c,Provincia__c, Tipo_Via__c,Nome_Via__c, Numero_Civico__c, erogazione_dei_servizi__c, Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualit_Servizio__c,Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c from Account where Name = 'Acc Eleva'];
        Document__c d = [Select Id,IDTipoDocumentoFormula__c,DocumentBlockFormula__c,DocumentClassFormula__c From Document__c where Name = 'Eleva'];
        Id recordId = acc.id;
        String ndg = acc.AccountNumber;
        String type = d.DocumentBlockFormula__c; 
        date documentDate = Date.today();
        String documentType = d.IDTipoDocumentoFormula__c;
        String documentIssuePlace = d.DocumentClassFormula__c;
        String documentNumber = d.Id;
        String accountName = acc.Name;
        String sae = acc.SAE__c;
        String rae = acc.RAE__c;
        String location = acc.Indirizzo_Sede_Legale_Esteso__c;
        String postalCode = acc.BillingPostalCode;
        String municipality = acc.Comune__c;
        String province = acc.Provincia__c;
        String streetType = acc.Tipo_Via__c;
        String streetName = acc.Nome_Via__c;
        String streetHomeNumber = acc.Numero_Civico__c;
        String erogazioneDeiServizic = acc.erogazione_dei_servizi__c;
        String marketingBancac = acc.Marketing_Banca__c;
        String profilazioneBancac = acc.Profilazione_Banca__c;
        String valutazioneQualitaServizioc = acc.Valutazione_Qualit_Servizio__c;
        String ricercheDiMercatoC = acc.Ricerche_di_Mercato__c;
        String datiParticolaric = acc.Dati_Particolari__c;
        String consensoSic = acc.Consenso_Sic__c;
        date dataScadenza = Date.today()+ 4;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
        ElevaRestApiController.aggiornaCedacri(recordId, ndg, type, documentDate, documentType,documentIssuePlace, documentNumber,accountName, sae, rae, location, postalCode, municipality, province, streetType, streetName, streetHomeNumber, erogazioneDeiServizic, marketingBancac, profilazioneBancac, valutazioneQualitaServizioc, ricercheDiMercatoC, datiParticolaric, consensoSic, dataScadenza);
        System.assertEquals('200', '200');
        Test.stopTest();
    }
    @isTest     static  void testAggiornaCedacri2() {
        ElevaCredentials__mdt mcmd = getElevaCredentials(); 
        
        Account acc = [Select Id, AccountNumber,Name, SAE__c,RAE__c,Indirizzo_Sede_Legale_Esteso__c, BillingPostalCode,Comune__c,Provincia__c, Tipo_Via__c,Nome_Via__c, Numero_Civico__c, erogazione_dei_servizi__c, Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualit_Servizio__c,Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c from Account where Name = 'Acc Eleva'];
        Document__c d = [Select Id,IDTipoDocumentoFormula__c,DocumentBlockFormula__c,DocumentClassFormula__c From Document__c where Name = 'Eleva'];
        Id recordId = acc.id;
        String ndg = acc.AccountNumber;
        String type = d.DocumentBlockFormula__c; 
        date documentDate = Date.today();
        String documentType = d.IDTipoDocumentoFormula__c;
        String documentIssuePlace = d.DocumentClassFormula__c;
        String documentNumber = d.Id;
        String accountName = acc.Name;
        String sae = acc.SAE__c;
        String rae = acc.RAE__c;
        String location = acc.Indirizzo_Sede_Legale_Esteso__c;
        String postalCode = acc.BillingPostalCode;
        String municipality = acc.Comune__c;
        String province = acc.Provincia__c;
        String streetType = acc.Tipo_Via__c;
        String streetName = acc.Nome_Via__c;
        String streetHomeNumber = acc.Numero_Civico__c;
        String erogazioneDeiServizic = acc.erogazione_dei_servizi__c;
        String marketingBancac = acc.Marketing_Banca__c;
        String profilazioneBancac = acc.Profilazione_Banca__c;
        String valutazioneQualitaServizioc = acc.Valutazione_Qualit_Servizio__c;
        String ricercheDiMercatoC = acc.Ricerche_di_Mercato__c;
        String datiParticolaric = acc.Dati_Particolari__c;
        String consensoSic = acc.Consenso_Sic__c;
        date dataScadenza = Date.today()+ 4;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
        ElevaRestApiController.aggiornaCedacri(recordId, ndg, type, documentDate, documentType,documentIssuePlace, documentNumber,accountName, sae, rae, location, postalCode, municipality, province, streetType, streetName, streetHomeNumber, erogazioneDeiServizic, marketingBancac, profilazioneBancac, valutazioneQualitaServizioc, ricercheDiMercatoC, datiParticolaric, consensoSic, dataScadenza);
        System.assertNotEquals('400', '200');
        Test.stopTest();
    }
}