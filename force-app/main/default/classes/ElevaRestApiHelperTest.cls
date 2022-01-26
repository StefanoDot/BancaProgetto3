@isTest
public with sharing class ElevaRestApiHelperTest {
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
        cont.LastName = 'test';
        cont.RecordTypeId = recordTypeIdRefOpl;
        cont.Fidejussore__c = true;
        cont.Email = 'aldora@gmail.com';
        cont.Phone = '123456789';
        cont.NDG__c = '12345';
        cont.Ruolo_in_Azienda__c = 'Legale Rappresentante';
        cont.AccountId = acc.Id;
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
    static void getAllFidejussoriTest() {
        test.startTest();
            Id recordTypeIdInsFide = Schema.SObjectType.Garanzia__c.getRecordTypeInfosByDeveloperName().get('Fidejussione_Layout_Inserimento').getRecordTypeId();
            List<Opportunity> oppList = [SELECT id FROM Opportunity];
            List<Quote> qtList = [SELECT id FROM Quote];
            List<Contact> contactList = [SELECT Id, AccountId, Firmatario__c, FinServ__EmailVerified__c,FinServ__MobileVerified__c, NDG__c,Tipo_Documento__c, Stato_Nascita__c, Data_Scadenza__c, Fidejussore__c, Localita__c, Localita_Residenza__c, Phone , MobilePhone, Name,FirstName, LastName, Comune_di_Nascita__c, FinServ__Gender__c, Luogo_Rilascio__c, Sigla_Provincia_Nascita__c, Data_di_Nascita__c, Oplon_Codice_Fiscale__c, Indirizzo_Residenza_Esteso__c, Provincia__c, Sigla_Provincia__c, Account.Cellulare__c, Comune__c, Cap__c, Email, Ruolo_in_Azienda__c, Account.Name, Account.Indirizzo_Sede_Legale_Esteso__c, Residenza__c, Numero_Documento__c,Data_Rilascio__c, Account.Cap__c ,Prefisso_Internazionale__c, Account.Comune__c, Account.Sigla_Provincia__c, Account.Capitale_Sociale__c, Account.Codice_Fiscale__c, Account.Phone FROM Contact];
            List<Fidejussione__c> fidList = [SELECT id, Persona_Fisica__c, Garanzia__c FROM Fidejussione__c];
            Garanzia__c g = new Garanzia__c();
            g.Linea_di_Credito__c= qtList[0].id;
            g.Tipo_di_Garanzia__c = 'Fidejussione';
            g.Tipo_di_Fidejussione__c='Persona Fisica';
            g.Stato_Garanzia__c = 'Aperta';
            g.Percentuale_Garantito__c = '80';
            g.recordTypeId=recordTypeIdInsFide;
            insert g;
            Fidejussione__c fid = new Fidejussione__c();
            fid.Persona_Fisica__c = contactList[0].Id;
            fid.Garanzia__c = g.Id;
            insert fid;
            List<Contact> conListResult = ElevaRestApiHelper.getAllFidejussori(oppList[0].id);
        test.stopTest();
        //System.AssertEquals(contactList,conListResult);
    }
}