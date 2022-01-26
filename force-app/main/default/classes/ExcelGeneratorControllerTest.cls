@isTest
public with sharing class ExcelGeneratorControllerTest {
    
    @isTest
    static void ExcelGeneratorControllerTest() {
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(Alias = 'standt', Email = 'test@test.test',
                                EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                                LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test', CompanyName = 'Test');
        insert u;

        System.debug('Utente inserito ' + u);
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Manager_NomeCompleto__c = u.id;
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
        acc.Gennaio_CF__c = 1000;
        acc.Gennaio_LL__c= 1000;
        acc.Budget_Gennaio__c = 1000;
        acc.Febbraio_CF__c = 1000;
        acc.Febbraio_LL__c = 1000;
        acc.Budget_Febbraio__c = 1000;
        acc.Marzo_CF__c = 1000;
        acc.Marzo_LL__c = 1000;
        acc.Budget_Marzo__c = 1000;
        acc.Aprile_CF__c = 1000;
        acc.Aprile_LL__c = 1000;
        acc.Budget_Aprile__c = 1000;
        acc.Maggio_CF__c = 1000;
        acc.Maggio_LL__c = 1000;
        acc.Budget_Maggio__c = 1000;
        acc.Giugno_CF__c = 1000;
        acc.Giugno_LL__c = 1000;
        acc.Budget_Giugno__c = 1000;
        acc.Luglio_CF__c = 1000;
        acc.Luglio_LL__c = 1000;
        acc.Budget_Luglio__c = 1000;
        acc.Agosto_CF__c = 1000;
        acc.Agosto_LL__c = 1000;
        acc.Budget_Agosto__c = 1000;
        acc.Settembre_CF__c = 1000;
        acc.Settembre_LL__c = 1000;
        acc.Budget_Settembre__c = 1000;
        acc.Ottobre_CF__c = 1000;
        acc.Ottobre_LL__c = 1000;
        acc.Budget_Ottobre__c = 1000;
        acc.Novembre_CF__c = 1000;
        acc.Novembre_LL__c = 1000;
        acc.Budget_Novembre__c = 1000;
        acc.Dicembre_CF__c = 1000;
        acc.Dicembre_LL__c = 1000;
        acc.Budget_Dicembre__c = 1000;
        insert acc;
        System.debug('Account inserito' + acc);

        Budget__c budget = new Budget__c();
        budget.name = 'Budget test';
        budget.OwnerId = u.id;
        budget.Anno__c = Date.today();
        budget.Totale_Budget_Personale__c = 10000;
        budget.Totale_Budget_Gerarchico__c = 20000;
        budget.Totale_Budget_Territoriale__c = 25000;
        insert budget;

        BudgetMensile__c budgMens = new BudgetMensile__c();
        budgMens.Name = 'Budget Mensile Test';
        budgMens.Tipo_prodotto__c = 'SME LENDING - Liquidita';
        budgMens.Utente__c = u.id;
        budgMens.Budget__c = budget.id;
        budgMens.Importo__c = 230000;
        budgMens.Mese_di_Riferimento__c = 'Gennaio';
        budgMens.OwnerId = u.id;
        insert budgMens;

        ExcelGeneratorController excel = new ExcelGeneratorController();
        Test.startTest();
            excel.exportToExcel();
        Test.stopTest();
    }
}