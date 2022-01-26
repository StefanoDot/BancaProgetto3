@isTest
public with sharing class BP_QR_ContactTest {
    @TestSetup
    static void makeData(){
        
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
        Id recordTypeIdInsFide = Schema.SObjectType.Garanzia__c.getRecordTypeInfosByDeveloperName().get('Fidejussione_Layout_Inserimento').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
            Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

            User u = new User(Alias = 'standt', Email = 'test@test.test',
                                  EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test');
            insert u;
        
            System.debug('Utente inserito ' + u);
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Manager_NomeCompleto__c = u.id;
            acc.Inside_Sales_di_Riferimento__c = u.id;
            acc.RecordTypeId = recordTypeIdInsAnag;
            acc.AccountNumber = '1548';
            acc.OwnerId = u.id;
            acc.Ricezione_Dati_Oplon__c= constants.OPLON_OK_FULL;
            acc.Tipo_di_Azienda__c= 'SRI';
            acc.Privacy__c=true;
            acc.Verifica_liste_negative__c='OK'; 
            acc.Punteggio_di_rischio__c=1;
            acc.erogazione_dei_servizi__c='YES';
            acc.Scenario__c='A';
            insert acc;
        Contact cont = new Contact();
        cont.LastName = 'test';
        cont.RecordTypeId = recordTypeIdRefOpl;
        cont.Fidejussore__c = true;
        cont.Email = 'aldora@gmail.com';
        cont.Phone = '123456789';
        cont.NDG__c = '12345';
        cont.Ruolo_in_Azienda__c = 'Legale Rappresentante';
        cont.AccountId = acc.Id;
        insert cont;
        Opportunity opp = new Opportunity(AccountId = acc.Id,
        Name = 'test',
        CloseDate = Date.today() + 1,
        StageName = constants.OPPORTUNITY_PRIMO_CONTATTO,
        Forecast_Category_Custom__c = 'Elevata Probabilità',
        Tipo_Linea_di_Credito__c = 'Mutuo',
        Finalita_Finanziamento__c = 'Liquidità',
        Ammontare_Iniziale__c = 1000,
        Durata_Partner__c = 100,
        Linea_di_Credito_in_Mesi__c = 20,
        Data_Stipula__c = Date.today(),
        OwnerId = acc.OwnerId,
        OwnerMigrazione__c = 'Utente di Test',
        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
        Sales_Support_Approver__c = u.Id,
        Inside_Sales_di_Riferimento__c = u.Id,
        Sabatini_Applicabile__c = 'Si',
        Numero_Pratica__c = '12345');
        OpportunityController.bypassTrigger = true;
        insert opp;
        OpportunityController.bypassTrigger = false;
        Quote quote = new Quote();
        quote.Name = 'testName';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Durata_Direzione__c = 10;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c = 'Investimento';
        quote.OpportunityId = opp.Id;
        quote.Status = 'In Corso';
        quote.Durata_Deliberata__c = 10;
        quote.Ammontare_Erogato__c = 100;
        quote.Durata_Erogata__c = 10;
        quote.Sabatini_Applicabile__c = 'Si';
        quote.Contratto_Verificato__c = true;
        QuoteController.bypassTrigger = true;
        insert quote;
        QuoteController.bypassTrigger = false;
        DocumentType__c docType = new DocumentType__c();
        docType.Document_Block__c = 'Documentazione pre-contrattuale';
        docType.Status_Stage_Visible__c = 'Primo Contatto';
        docType.DocumentApiName__c = 'X02_Doc_Identit_Legale_Rappresentante__c';
        docType.ObjectName__c = 'Opportunity';
        docType.Opportunita_Mutuo__c = true;
        docType.Doc_Opzionale__c = false;
        docType.ID_Tipo_Documento__c = 'SME_002';
        insert docType;
        Document__c document = new Document__c();
        document.Name = 'test';
        document.DocumentType__c = docType.Id;
        document.Id_File__c = '0691w0000010Rs9AAE';
        document.Commento_Sales_Support__c = 'testtt';
        document.File_Name__c = 'testDoc';
        document.Contact__c = cont.id;
        document.Url_Documento__c = 'prova';
        insert document;
        Garanzia__c g = new Garanzia__c();
            g.Linea_di_Credito__c= quote.id;
            g.Tipo_di_Garanzia__c = 'Fidejussione';
            g.Tipo_di_Fidejussione__c='Persona Fisica';
            g.Stato_Garanzia__c = 'Aperta';
            g.Percentuale_Garantito__c = '80';
            g.recordTypeId=recordTypeIdInsFide;
            insert g;
    }

    @isTest
    static void BP_QR_ContactTestSingleFirmatario() {
        Test.startTest();
        List<Account> listAccount = [SELECT Id FROM Account limit 1];
        List<Document__c> listDocs = [SELECT Id, IDTipoDocumentoFormula__c, Url_Documento__c, Contact__c FROM Document__c];
        List<Opportunity> listOpp = [SELECT Id FROM Opportunity];
        List<Contact> listCons = [SELECT Id FROM Contact];
        List<Garanzia__c> listGaranz = [SELECT Id FROM Garanzia__c];
        Account singleAccount; 
        Document__c singleDoc;
        Contact singleCon;
        Opportunity singleOpp;

        if (listAccount != null && !listAccount.isEmpty()) {
            singleAccount = listAccount[0];
        }
        if (listDocs != null && !listDocs.isEmpty()) {
            singleDoc = listDocs[0];
        }
        if (listCons != null && !listCons.isEmpty()) {
            singleCon = listCons[0];
        }
        if (listOpp != null && !listOpp.isEmpty()) {
            singleOpp = listOpp[0];
        }
        Fidejussione__c fid = new Fidejussione__c();
        fid.Persona_Fisica__c = singleCon.Id;
        fid.Garanzia__c = listGaranz[0].Id;
        insert fid;
        
            BP_QR_Contact.getFirmatarioContact(singleOpp.id, singleAccount.Id,'Mutuo');
        	BP_QR_Contact.getFirmatarioContact(singleOpp.id, singleAccount.Id, null);
        Test.stopTest();
    }
}