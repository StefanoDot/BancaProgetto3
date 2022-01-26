public class ObjectFactory {

    public static User aldora = user1();

    public static Account insertNewAccount() {
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account account = new Account();

        account.Name = 'Test Account';
        account.Manager_NomeCompleto__c = aldora.Id;
        account.Inside_Sales_di_riferimento__c = aldora.Id;
        account.RecordTypeId = recordTypeIdInsAnag;
        account.AccountNumber = '1548';
        account.OwnerId = aldora.Id;
        account.Ricezione_Dati_Oplon__c = 'Ok Full';
        account.Tipo_di_Azienda__c = 'SRI';
        account.Privacy__c = true;
        account.Verifica_liste_negative__c = 'OK';
        account.Punteggio_di_rischio__c = 1;
        account.erogazione_dei_servizi__c = 'YES';
        account.Scenario__c = 'A';

        insert account;
        return account;
    }

    public static Contact insertNewContact() {
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        Account acc = insertNewAccount();
        Contact contact = new Contact();

        contact.LastName = 'test';
        contact.AccountId = acc.Id;
        contact.RecordTypeId = recordTypeIdRefOpl;
        contact.Fidejussore__c = true;
        contact.Email = 'aldora@gmail.com';
        contact.Phone = '123456789';
        contact.NDG__c = '12345';

        insert contact;
        return contact;
    }

    public static Quote insertNewQuote() {
        Opportunity opp = insertNewOpportunity();
        Quote quote = new Quote();

        quote.Name = 'Aldoraaaa';
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

        insert quote;
        return quote;
    }

    public static List<Fidejussione__c> insertNewFidejussione() {
        List<Fidejussione__c> listFid = new List<Fidejussione__c>();
        Contact c = ObjectFactory.insertNewContact();
        Cointestazione__c coin2 = ObjectFactory.insertNewCointestazione();

        Garanzia__c garanziaPF = ObjectFactory.insertNewGaranzia();
        garanziaPF.Tipo_di_Garanzia__c = 'Fidejussione';
        garanziaPF.Tipo_di_Fidejussione__c = 'Persona Fisica';
        garanziaPF.Stato_Garanzia__c = 'Aperta';
        garanziaPF.Percentuale_Garantito__c = '80';

        Garanzia__c garanziaPG = ObjectFactory.insertNewGaranzia();
        garanziaPG.Tipo_di_Garanzia__c = 'Fidejussione';
        garanziaPG.Tipo_di_Fidejussione__c = 'Persona Giuridica';

        Fidejussione__c fide1 = new Fidejussione__c();
        fide1.Persona_Fisica__c = c.Id;
        fide1.Garanzia__c = garanziaPF.Id;

        Fidejussione__c fide2 = new Fidejussione__c();
        fide2.Persona_Giuridica__c = c.AccountId;
        fide2.Garanzia__c = garanziaPG.Id;

        Fidejussione__c fide3 = new Fidejussione__c();
        fide3.Persona_Giuridica__c = c.AccountId;
        fide2.Cointestazione__c = coin2.Id;

        listFid.add(fide1);
        listFid.add(fide2);
        listFid.add(fide3);

        insert listFid;
        return listFid;
    }

    public static Cointestazione__c insertNewCointestazione() {
        Cointestazione__c cointestazione = new Cointestazione__c();
        cointestazione.Tipo_di_Cointestazione__c = 'Contact';
        cointestazione.NDG_Cointestazione__c = '12345';
        cointestazione.NDG__c = '3454647';

        insert cointestazione;
        return cointestazione;
    }

    public static Garanzia__c insertNewGaranzia() {
        Quote quote = ObjectFactory.insertNewQuote();
        Garanzia__c garanzia = new Garanzia__c();

        garanzia.Tipo_di_Garanzia__c = 'FONDO MCC';
        garanzia.Stato_Garanzia__c = 'Aperta';
        garanzia.Linea_di_Credito__c = quote.Id;
        garanzia.Percentuale_Garantito__c = '80%';

        insert garanzia;
        return garanzia;
    }

    public static Opportunity insertNewOpportunity() {
        Account acc = insertNewAccount();
        Opportunity opp = new Opportunity(AccountId = acc.Id,
                Name = 'test',
                CloseDate = Date.today() + 1,
                StageName = 'Primo Contatto',
                Forecast_Category_Custom__c = 'Elevata Probabilità',
                Tipo_Linea_di_Credito__c = 'Mutuo',
                Finalita_Finanziamento__c = 'Liquidità',
                Ammontare_Iniziale__c = 1000,
                Durata_Partner__c = 100,
                Linea_di_Credito_in_Mesi__c = 20,
                Data_Stipula__c = Date.today(),
                OwnerId = acc.OwnerId,
                Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
                Sales_Support_Approver__c = aldora.Id,
                Inside_Sales_di_Riferimento__c = aldora.Id,
                Sabatini_Applicabile__c = 'Si',
                Numero_Pratica__c = '12345');

        insert opp;
        return opp;
    }

    public static Document__c insertNewDocument() {
        DocumentType__c documentType = ObjectFactory.insertNewDocumentType('Opportunity');
        Document__c document = new Document__c();

        document.Name = 'test';
        document.DocumentType__c = documentType.Id;
        document.Id_File__c = '0691w0000010Rs9AAE';
        document.Commento_Sales_Support__c = 'testtt';

        insert document;
        return document;
    }

    
    public static Document__c insertNewDocumentQuote() {
        DocumentType__c documentType = ObjectFactory.insertNewDocumentType('Quote');
        Document__c document = new Document__c();

        document.Name = 'test';
        document.DocumentType__c = documentType.Id;
        document.Id_File__c = '0691w0000010Rs9AAE';
        document.Commento_Sales_Support__c = 'testtt';

        insert document;
        return document;
    }

    public static DocumentType__c insertNewDocumentType(String objectName) {
        DocumentType__c docType = new DocumentType__c(Document_Block__c = 'Delibera', DocumentApiName__c = 'test', ObjectName__c = objectName, Opportunita_Mutuo__c = true);

        insert docType;
        return docType;
    }

    public static User createNewUser(String username, String email) {
        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        // Role rolInsSal1 = [SELECT Id FROM Role WHERE Name = 'Inside Sales 1'];
        User usrInsSal = new User(Alias = 'standt', Email = email,
                EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id, IsActive = true,
                TimeZoneSidKey = 'America/Los_Angeles', Username = username);

        insert usrInsSal;
        return usrInsSal;
    }

    public static User user1() {
        String username = Math.random() + '@' + Math.random() + '.test';
        Profile pInsSal = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User usrInsSal = new User(Alias = 'eww80mm2', Email = 'aldora.hajronenavetmoj@dunegrouphamomomomo.it',
                EmailEncodingKey = 'UTF-8', LastName = 'ewwmm', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id, IsActive = true, Check_Fidimed__c = true,
                TimeZoneSidKey = 'America/Los_Angeles', Username = username);

        insert usrInsSal ;
        return usrInsSal;
    }
    public static Account insertNewAccountNew(){

        
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Manager_NomeCompleto__c = aldora.id;
        a.Inside_Sales_di_Riferimento__c = aldora.id;
        a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = '1548';
        a.OwnerId = aldora.id;
        a.Ricezione_Dati_Oplon__c= 'Ok Full';
        a.Tipo_di_Azienda__c= 'SRI';
        a.Privacy__c=true;
        a.Verifica_liste_negative__c='OK'; 
        a.Punteggio_di_rischio__c=1;
       a.erogazione_dei_servizi__c='YES';
        a.Scenario__c='A';
        
        return a;
    }

    public static Opportunity insertNewOpportunityNew(){

        Account acc = insertNewAccountNew();
        
        //User usr = createNewUser('qwerty1231456789@qwerty.com');
        
        Opportunity o = new Opportunity(AccountId=acc.Id,
                                        Name = 'test',
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
                                        Sales_Support_Approver__c = aldora.id,
                                        Inside_Sales_di_Riferimento__c = aldora.id ,  
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'
                                       
                                       );
        
        
        System.debug('oooooooooo' +o);
        
        return o;
        
    }

    public static User generateUser(String username, String email) {
        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usrInsSal = new User(Alias = 'standt', Email = email,
                EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id, IsActive = true,
                TimeZoneSidKey = 'America/Los_Angeles', Username = username);

        return usrInsSal;
    }


    public static Account generateAccount() {
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account account = new Account();

        account.Name = 'Test Account';
        account.Manager_NomeCompleto__c = aldora.Id;
        account.Inside_Sales_di_riferimento__c = aldora.Id;
        account.RecordTypeId = recordTypeIdInsAnag;
        account.AccountNumber = '1548';
        account.OwnerId = aldora.Id;
        account.Ricezione_Dati_Oplon__c = 'Ok Full';
        account.Tipo_di_Azienda__c = 'SRI';
        account.Privacy__c = true;
        account.Verifica_liste_negative__c = 'OK';
        account.Punteggio_di_rischio__c = 1;
        account.erogazione_dei_servizi__c = 'YES';
        account.Scenario__c = 'A';

        return account;
    }


    public static Contact generateContact(Account acc) {
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        Contact cont = new Contact();

        cont.LastName = 'test';
        cont.RecordTypeId = recordTypeIdRefOpl;
        cont.Fidejussore__c = true;
        cont.Email = 'aldora@gmail.com';
        cont.Phone = '123456789';
        cont.NDG__c = '12345';
        cont.Ruolo_in_Azienda__c = 'Titolare Effettivo';
        cont.AccountId = acc.Id;

        return cont;
    }

    public static Document__c generateDocument(DocumentType__c docType) {
        Document__c document = new Document__c();
        document.Name = 'test';
        document.DocumentType__c = docType.Id;
        document.Id_File__c = '0691w0000010Rs9AAE';
        document.Commento_Sales_Support__c = 'testtt';
        document.File_Name__c = 'testDoc';

        return document;
    }

    public static Document__c generateOptionalDocument(DocumentType__c docType) {
        Document__c document = new Document__c();
        document.Name = 'test';
        document.DocumentType__c = docType.Id;
        document.Id_File__c = '0691w0000010Rs9AAE';
        document.Commento_Sales_Support__c = 'testtt';
        document.File_Name__c = 'testDoc';

        return document;
    }

    public static DocumentType__c generateDocumentType(String objectName) {
        DocumentType__c docType = new DocumentType__c();
        docType.Document_Block__c = 'Delibera';
        docType.Status_Stage_Visible__c = 'Primo Contatto';
        docType.DocumentApiName__c = 'test';
        docType.ObjectName__c = objectName;
        docType.Opportunita_Mutuo__c = true;
        docType.Doc_Opzionale__c = false;

        return docType;
    }

    public static DocumentType__c generateOptionalDocumentType(String objectName) {
        DocumentType__c docType = new DocumentType__c();
        docType.Document_Block__c = 'Delibera';
        docType.Status_Stage_Visible__c = 'Primo Contatto';
        docType.DocumentApiName__c = 'test';
        docType.ObjectName__c = objectName;
        docType.Opportunita_Mutuo__c = true;
        docType.Doc_Opzionale__c = true;

        return docType;
    }

    //USE THIS FUCKING METHOD ONLY FOR THE RIGHT OPPORTUNITY TYPE DO NOT CHANGE IT!!!!!!!!!!!!!
    public static Opportunity generateCFOpportunity(Account acc) {
        Id creditiFiscaliOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Crediti_Fiscale_Lending').getRecordTypeId();

        Opportunity opportunity = new Opportunity(
                AccountId = acc.Id,
                Name = 'test',
                CloseDate = Date.today()+1,
                StageName = 'Primo Contatto',
                RecordTypeId = creditiFiscaliOppRecordType,
                Forecast_Category_Custom__c = 'Elevata Probabilità',
                Tipo_Linea_di_Credito__c = 'Crediti Fiscali',
                Finalita_Finanziamento__c = 'Liquidità',
                Ammontare_Iniziale__c = 1000,
                Durata_Partner__c = 100,
                Linea_di_Credito_in_Mesi__c = 20,
                Data_Stipula__c = Date.today(),
                OwnerId = acc.OwnerId,
                Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
                Sales_Support_Approver__c = aldora.Id,
                Inside_Sales_di_Riferimento__c = aldora.Id ,
                Sabatini_Applicabile__c = 'Si',
                Numero_Pratica__c = '12345'
        );

        return opportunity;
    }
    public static Opportunity generateOpportunity(Account acc) {
        Id creditiFiscaliOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Crediti_Fiscale_Lending').getRecordTypeId();

        Opportunity opportunity = new Opportunity(
                AccountId = acc.Id,
                Name = 'test',
                CloseDate = Date.today()+1,
                StageName = 'Primo Contatto',
                RecordTypeId = creditiFiscaliOppRecordType,
                Forecast_Category_Custom__c = 'Elevata Probabilità',
                Tipo_Linea_di_Credito__c = 'Mutuo',
                Finalita_Finanziamento__c = 'Liquidità',
                Ammontare_Iniziale__c = 1000,
                Durata_Partner__c = 100,
                Linea_di_Credito_in_Mesi__c = 20,
                Data_Stipula__c = Date.today(),
                OwnerId = acc.OwnerId,
                Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
                Sales_Support_Approver__c = aldora.Id,
                Inside_Sales_di_Riferimento__c = aldora.Id ,
                Sabatini_Applicabile__c = 'Si',
                Numero_Pratica__c = '12345'
        );

        return opportunity;
    }

    public static Quote generateMutuoQuote(Opportunity opp) {
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

        return quote;
    }

    public static Quote generateCFQuote(Opportunity opp) {
        Quote quote = new Quote(
                Name = 'testName',
                ExpirationDate = Date.today(),
                Ammontare_Iniziale__c = 1000,
                Ammontare_Direzione__c = 1000,
                Durata_Direzione__c = 10,
                Ammontare_Deliberato__c = 1000,
                Durata_Partner__c = 10,
                Tipo_Linea_di_Credito__c = 'Crediti Fiscali',
                Finalita_Finanziamento__c = 'Investimento',
                OpportunityId = opp.Id,
                Status = 'In Corso',
                Durata_Deliberata__c = 10,
                Ammontare_Erogato__c = 100,
                Durata_Erogata__c = 10,
                Sabatini_Applicabile__c = 'Si',
                Contratto_Verificato__c = true
        );

        return quote;
    }

    public static ContentVersion generateContentVersion() {
        ContentVersion contentVersion = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );

        return contentVersion;
    }

    public static ContentDocumentLink generateContentDocumentLink(ContentVersion contentVersion) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = '00590000000a6dP';
        cdl.ShareType = 'V';

        return cdl;
    }
}