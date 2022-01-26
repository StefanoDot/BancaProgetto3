@isTest
public class BatchOpportunityInCompletamentoTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'Migrazione' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'test@test.test',
        EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = pInsSal.Id, IsActive = true,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test');
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
        acc.Scenario__c='A';
        insert acc;
        Opportunity opp = ObjectFactory.generateOpportunity(acc);
        insert opp;
        Contact con = ObjectFactory.generateContact(acc);
        insert con;
    }

     @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    @isTest
    static void testBatchOppInComple(){
        Switch_Validation__mdt testtt= BatchOpportunityInCompletamentoTest.generateMetadataValidation();
        Utils_Constants constants = new Utils_Constants();

        Test.startTest();
        List<Account> listAcc = [SELECT id, Name FROM Account];
        System.debug('Popolata liste account');
        List<Opportunity> listOpp = [SELECT id, StageName, Is_Suspended__c, Flag_Findynamic__c FROM Opportunity];
        System.debug('Popolata lista opportunity');
        List<Contact> listCont = [SELECT id, Interessato__c, Esecutore__c FROM Contact];
        System.debug('Popolata lista contatti');
        Account singleAcc = listAcc.get(0);
        Contact singleCon = listCont.get(0);
        Opportunity singleOpp = listOpp.get(0);

        singleAcc.erogazione_dei_servizi__c='YES';
        update singleAcc;
        singleCon.Interessato__c=true;
        singleCon.Esecutore__c=true;
        update singleCon;
        singleOpp.Flag_Findynamic__c=true;
        singleOpp.StageName = constants.OPPORTUNITY_COMPLETAMENTO_DOCUMENTI;
        update singleOpp;
        Cointestazione__c c = ObjectFactory.insertNewCointestazione();
        Quote qt = ObjectFactory.generateMutuoQuote(singleOpp);
        insert qt;
        Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=qt.Id;
        g.Percentuale_Garantito__c='80%';
        g.Cointestazione__c=c.Id;
        g.Opportunit__c=singleOpp.Id;
        insert g;
        
        BatchOpportunityInCompletamento myBatchObject = new BatchOpportunityInCompletamento();
		Id batchId = Database.executeBatch(myBatchObject,1);  
        test.stopTest();
    }
}