@isTest
    public with sharing class AssegnazioneOppOwnerBatchTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
            Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'Migrazione' LIMIT 1];
            Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

            User u = new User(Alias = 'standt', Email = 'test@test.test',
                                  EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test');
            insert u;

                User u2 = new User(Alias = 'standt', Email = 'testing@testing.test',
            EmailEncodingKey = 'UTF-8', LastName = 'Precedente', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = pInsSal.Id, IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica2@test.test');
            insert u2;

            System.debug('Utente inserito ' + u);
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Manager_NomeCompleto__c = u.id;
            acc.Inside_Sales_di_Riferimento__c = u.id;
            acc.RecordTypeId = recordTypeIdInsAnag;
            acc.AccountNumber = '1548';
            acc.OwnerId = u2.id;
            acc.Ricezione_Dati_Oplon__c= constants.OPLON_OK_FULL;
            acc.Tipo_di_Azienda__c= 'SRI';
            acc.Privacy__c=true;
            acc.Verifica_liste_negative__c='OK'; 
            acc.Punteggio_di_rischio__c=1;
            acc.erogazione_dei_servizi__c='YES';
            acc.Scenario__c='A';
            insert acc;
            System.debug('Account inserito' + acc);

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
            Sales_Support_Approver__c = u2.Id,
            Inside_Sales_di_Riferimento__c = u2.Id,
            Sabatini_Applicabile__c = 'Si',
            Numero_Pratica__c = '12345');
            insert opp;
            System.debug('Opportunity inserita' + opp);
    }
    
    @isTest
    static void AssegnazioneOppOwnerBatchTest() {
        
        List<User> userIdperRecord = [SELECT id FROM User WHERE Name = 'Utente di Test' LIMIT 1];
        List<Opportunity> opportunityAggiornate = new List<Opportunity>();
        System.debug('Creata lista di opportunity per migrazione');

        Assegnazione_Record__c assgn1 = new Assegnazione_Record__c();
        assgn1.Name = 'Utente di Test';
        assgn1.User__c = userIdperRecord.get(0).id;
        insert assgn1;
        System.debug('Inserita matrice di assegnazione ' + assgn1);

        List<User> userIdMigrazione = [SELECT id FROM User WHERE Name = 'Utente precedente' LIMIT 1];

        Test.startTest();
        AssegnazioneOppOwnerBatch assOppOwn = new AssegnazioneOppOwnerBatch();
        Id batchId = Database.executeBatch(assOppOwn, 100);
        Test.stopTest();

        opportunityAggiornate = [SELECT id, Ownerid FROM Opportunity LIMIT 1];

        System.assertEquals(userIdperRecord.get(0).id, opportunityAggiornate.get(0).OwnerId);
    }
    @isTest 
    static void MatriceOppVuota(){
        List<Account> opportunityAggiornate2 = new List<Account>();
        System.debug('Creata lista di opty per migrazione');

        List<User> userIdMigrazione2 = [SELECT id FROM User WHERE Name = 'Utente precedente' LIMIT 1];
        Test.startTest();
        AssegnazioneOppOwnerBatch assOppOwn2 = new AssegnazioneOppOwnerBatch();
        Id batchId = Database.executeBatch(assOppOwn2, 100);
        Test.stopTest();

        opportunityAggiornate2 = [SELECT id, Ownerid FROM Account LIMIT 1];

        System.assertEquals(userIdMigrazione2.get(0).id, opportunityAggiornate2.get(0).OwnerId);
    }
}