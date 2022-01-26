@isTest
public with sharing class BP_VideoConferenzaControllerTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(
            Alias = 'standt', Email = 'test@test.test',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'di Test', 
            FirstName = 'Utente', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = profileSys.Id, 
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'monica1@test.test');
        insert u;
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
        acc.OwnerMigrazione__c = 'Utente di Test';
        insert acc;
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
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
        insert opp;
        Contact cont = new Contact();
        cont.FirstName = 'testing';
        cont.LastName = 'test';
        cont.RecordTypeId = recordTypeIdRefOpl;
        cont.Fidejussore__c = true;
        cont.Email = 'aldora@gmail.com';
        cont.Phone = '123456789';
        cont.MobilePhone = '12345678';
        cont.NDG__c = '12345';
        cont.Ruolo_in_Azienda__c = 'Legale Rappresentante';
        cont.AccountId = acc.Id;
        cont.Firmatario__c = true;
        insert cont;
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
        insert quote;
    }

    @isTest
    static void grabContactsWithFirmatario() {
        test.startTest();
            List<Opportunity> listOpp = [SELECT Id, AccountId, Email_Sales_Support__c, Tipo_Linea_di_Credito__c, StatusOnboarding__c FROM Opportunity];
            List<Account> listAcc = [SELECT id, name FROM Account];
            BP_VideoConferenzaController.getAllContacts(listOpp[0].id, listAcc[0].id, 'Mutuo');
        test.stopTest();
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
    @isTest
    static void bookVideoConferenceCall(){
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
            List<Opportunity> listOpp = [SELECT Id, AccountId, Email_Sales_Support__c, Tipo_Linea_di_Credito__c, StatusOnboarding__c FROM Opportunity];
            BP_VideoConferenzaController.bookVideoConferenceCall(listOpp[0].id,false);
        test.stopTest();
    }

}