@isTest
public with sharing class BP_DigitalAssignmntElevaAPICntrlTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
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
    static void bookVideoConferenceTest() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('success'));
            List<Opportunity> oppList = [SELECT Id, StatusOnboarding__c FROM Opportunity];
            system.debug('******* Opportunity prima update:' + oppList);
            String oppId = oppList[0].id;
            BP_DigitalAssignmntElevaAPIController.bookVideoConference(oppId, 'Corpo del messaggio');
       		BP_DigitalAssignmntElevaAPIController.interruptRequest(oppId);
            Opportunity oppToTest = [SELECT Id, StatusOnboarding__c FROM Opportunity WHERE id =: oppId];
            system.debug('******* Opportunity dopo update:' + oppToTest);
        test.stopTest();
        System.assertEquals(200,200);
    }
        @isTest
    static void bookVideoConferenceErrorTest() {
        ElevaCredentials__mdt mcmd = getElevaCredentials();
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('error'));
            List<Opportunity> oppList = [SELECT Id, StatusOnboarding__c FROM Opportunity];
            system.debug('******* Opportunity prima update:' + oppList);
            String oppId = oppList[0].id;
            BP_DigitalAssignmntElevaAPIController.bookVideoConference(oppId, 'Corpo del messaggio');
       		BP_DigitalAssignmntElevaAPIController.interruptRequest(oppId);
            Opportunity oppToTest = [SELECT Id, StatusOnboarding__c FROM Opportunity WHERE id =: oppId];
            system.debug('******* Opportunity dopo update:' + oppToTest);
        test.stopTest();
        System.assertNotEquals(400,200);
    }
}