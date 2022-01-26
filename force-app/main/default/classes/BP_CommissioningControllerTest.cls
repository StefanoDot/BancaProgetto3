@isTest
public class BP_CommissioningControllerTest {
    @TestSetup
    static void makeData(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
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
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        insert acc;
        System.debug('Account inserito' + acc);

        Opportunity o = new Opportunity(AccountId = acc.Id,
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
        OwnerMigrazione__c = 'Utente di Test',
        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
        Sales_Support_Approver__c = u.Id,
        Inside_Sales_di_Riferimento__c = u.Id,
        Sabatini_Applicabile__c = 'Si',
        Numero_Pratica__c = '12345');
        insert o;
        System.debug('Opportunity inserita' + o);
        Quote q1 = ObjectFactory.generateMutuoQuote(o);
        insert q1;
    }
    
    @isTest
    public static void generateStringTest(){
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT id, Finalita_Finanziamento__c, Data_Erogazione__c FROM Opportunity];

        Test.startTest();
        Map<Id, List<String>> result = BP_CommissioningController.generateString(oppList);
        Test.stopTest();
        System.assertEquals(true, result != null, 'Check!');
    }
    
    @isTest
    public static void commissioningFileWrapperTest(){
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT id, OwnerId FROM Opportunity];
        
        String test = 'TestName';
        String testBody = 'TestBody';
      
        BP_CommissioningController.CommissioningFileWrapper wrapp = new BP_CommissioningController.CommissioningFileWrapper(oppList.get(0).Id, oppList.get(0).OwnerId,  test, testBody);
    }
}