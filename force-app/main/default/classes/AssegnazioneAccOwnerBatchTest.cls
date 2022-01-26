@isTest
    public with sharing class AssegnazioneAccOwnerBatchTest {
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
            acc.OwnerMigrazione__c = 'Utente di Test';
            insert acc;
            System.debug('Account inserito' + acc);

        }

        @isTest
        static void AssegnazioneAccOwnerBatchTest() {

            List<User> userIdperRecord = [SELECT id FROM User WHERE Name = 'Utente di Test' LIMIT 1];
            List<Account> accountAggiornati = new List<Account>();
            System.debug('Creata lista di account per migrazione');

            Assegnazione_Record__c assgn1 = new Assegnazione_Record__c();
            assgn1.Name = 'Utente di Test';
            assgn1.User__c = userIdperRecord.get(0).id;
            insert assgn1;
            System.debug('Inserita matrice di assegnazione ' + assgn1);

            List<User> userIdMigrazione = [SELECT id FROM User WHERE Name = 'Utente precedente' LIMIT 1];

            Test.startTest();
            AssegnazioneAccOwnerBatch assAccOwn = new AssegnazioneAccOwnerBatch();
            Id batchId = Database.executeBatch(assAccOwn, 100);
            Test.stopTest();

            accountAggiornati = [SELECT id, Ownerid FROM Account LIMIT 1];

            System.assertEquals(userIdperRecord.get(0).id, accountAggiornati.get(0).OwnerId);
        }
        @isTest 
        static void matriceVuota(){
            List<Account> accountAggiornati2 = new List<Account>();
            System.debug('Creata lista di account per migrazione');

            List<User> userIdMigrazione2 = [SELECT id FROM User WHERE Name = 'Utente precedente' LIMIT 1];
            Test.startTest();
            AssegnazioneAccOwnerBatch assAccOwn2 = new AssegnazioneAccOwnerBatch();
            Id batchId = Database.executeBatch(assAccOwn2, 100);
            Test.stopTest();

            accountAggiornati2 = [SELECT id, Ownerid FROM Account LIMIT 1];

            System.assertEquals(userIdMigrazione2.get(0).id, accountAggiornati2.get(0).OwnerId);
        }
}