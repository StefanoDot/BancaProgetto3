@isTest
public with sharing class BP_BudgetReportPartnerTest {
  @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
            Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

            User u = new User(Alias = 'standt', Email = 'test@test.test',
                                  EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test');
            insert u;

            System.runAs(u) {
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

                //OpportunityController.bypassTrigger=true;
                Opportunity opp = new Opportunity(AccountId = acc.Id,
                Name = 'test',
                CloseDate = Date.today(),
                StageName = constants.OPPORTUNITY_PRIMO_CONTATTO,
                Forecast_Category_Custom__c = 'Elevata Probabilità',
                Tipo_Linea_di_Credito__c = 'Progetto EasyPlus',
                Finalita_Finanziamento__c = 'Liquidità',
                Ammontare_Iniziale__c = 1000,
                Amount = 30000,
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
                System.debug('Opportunity inserita' + opp);
                //OpportunityController.bypassTrigger=false;
                Quote quote = new Quote();
                quote.Name = 'Aldoraaaa';
                quote.ExpirationDate = Date.today() + 3;
               // quote.Data_Erogazione__c = Date.today();
                quote.Ammontare_Iniziale__c = 1000;
                quote.Ammontare_Direzione__c = 1000;
                quote.Durata_Direzione__c = 10;
                quote.Ammontare_Deliberato__c = 1000;
                quote.Durata_Partner__c = 10;
                quote.Tipo_Linea_di_Credito__c = 'Progetto EasyPlus';
                quote.Finalita_Finanziamento__c = 'Investimento';
                quote.OpportunityId = opp.Id;
                quote.Status = 'In Corso';
                quote.Durata_Deliberata__c = 10;
                quote.Ammontare_Erogato__c = 100;
                quote.Durata_Erogata__c = 10;
                quote.Sabatini_Applicabile__c = 'Si';
                quote.Contratto_Firmato_Flusso__c = true;
                quote.Contratto_Verificato__c = true;
                insert quote;
                

                Budget__c budget = new Budget__c();
                budget.name = 'Budget test';
                budget.OwnerId = u.id;
                budget.Anno__c = Date.today();
                budget.Totale_Budget_Personale__c = 10000;
                budget.Totale_Budget_Gerarchico__c = 20000;
                budget.Totale_Budget_Territoriale__c = 25000;
                insert budget;

                Budget_Mensile__c budgMens = new Budget_Mensile__c();
                budgMens.Name = 'Budget Mensile Test';
                budgMens.Tipo_prodotto__c = 'Lending';
                budgMens.Utente__c = u.id;
                budgMens.Budget__c = budget.id;
                budgMens.Importo__c = 230000;
                budgMens.Mese_di_Riferimento__c = 'Gennaio';
                insert budgMens;

                Budget_Mensile__c budgMens2 = new Budget_Mensile__c();
                budgMens2.Name = 'Budget Mensile Test 2';
                budgMens2.Tipo_prodotto__c = 'Lending';
                budgMens2.Utente__c = u.id;
                budgMens2.Budget__c = budget.id;
                budgMens2.Importo__c = 230000;
                budgMens2.Mese_di_Riferimento__c = 'Agosto';
                insert budgMens2;

                Budget_Mensile__c budgMens3 = new Budget_Mensile__c();
                budgMens3.Name = 'Budget Mensile Test 3';
                budgMens3.Tipo_prodotto__c = 'Lending';
                budgMens3.Utente__c = u.id;
                budgMens3.Budget__c = budget.id;
                budgMens3.Importo__c = 330000;
                budgMens3.Mese_di_Riferimento__c = 'Febbraio';
                insert budgMens3;
        
                Budget_Mensile__c budgMens4 = new Budget_Mensile__c();
                budgMens4.Name = 'Budget Mensile Test 4';
                budgMens4.Tipo_prodotto__c = 'Lending';
                budgMens4.Utente__c = u.id;
                budgMens4.Budget__c = budget.id;
                budgMens4.Importo__c = 440000;
                budgMens4.Mese_di_Riferimento__c = 'Marzo';
                insert budgMens4;
                
                Budget_Mensile__c budgMens5 = new Budget_Mensile__c();
                budgMens5.Name = 'Budget Mensile Test 5';
                budgMens5.Tipo_prodotto__c = 'Lending';
                budgMens5.Utente__c = u.id;
                budgMens5.Budget__c = budget.id;
                budgMens5.Importo__c = 550000;
                budgMens5.Mese_di_Riferimento__c = 'Aprile';
                insert budgMens5;

                Budget_Mensile__c budgMens6 = new Budget_Mensile__c();
                budgMens6.Name = 'Budget Mensile Test 6';
                budgMens6.Tipo_prodotto__c = 'Lending';
                budgMens6.Utente__c = u.id;
                budgMens6.Budget__c = budget.id;
                budgMens6.Importo__c = 660000;
                budgMens6.Mese_di_Riferimento__c = 'Maggio';
                insert budgMens6;

                Budget_Mensile__c budgMens7 = new Budget_Mensile__c();
                budgMens7.Name = 'Budget Mensile Test 7';
                budgMens7.Tipo_prodotto__c = 'Lending';
                budgMens7.Utente__c = u.id;
                budgMens7.Budget__c = budget.id;
                budgMens7.Importo__c = 770000;
                budgMens7.Mese_di_Riferimento__c = 'Giugno';
                insert budgMens7;
                Budget_Mensile__c budgMens8 = new Budget_Mensile__c();
                budgMens8.Name = 'Budget Mensile Test 8';
                budgMens8.Tipo_prodotto__c = 'Lending';
                budgMens8.Utente__c = u.id;
                budgMens8.Budget__c = budget.id;
                budgMens8.Importo__c = 880000;
                budgMens8.Mese_di_Riferimento__c = 'Luglio';
                insert budgMens8;

                Budget_Mensile__c budgMens9 = new Budget_Mensile__c();
                budgMens9.Name = 'Budget Mensile Test 9';
                budgMens9.Tipo_prodotto__c = 'Lending';
                budgMens9.Utente__c = u.id;
                budgMens9.Budget__c = budget.id;
                budgMens9.Importo__c = 990000;
                budgMens9.Mese_di_Riferimento__c = 'Agosto';
                insert budgMens9;

                Budget_Mensile__c budgMens10 = new Budget_Mensile__c();
                budgMens10.Name = 'Budget Mensile Test 10';
                budgMens10.Tipo_prodotto__c = 'Lending';
                budgMens10.Utente__c = u.id;
                budgMens10.Budget__c = budget.id;
                budgMens10.Importo__c = 10100000;
                budgMens10.Mese_di_Riferimento__c = 'Settembre';
                insert budgMens10;
                Budget_Mensile__c budgMens11 = new Budget_Mensile__c();
                budgMens11.Name = 'Budget Mensile Test 11';
                budgMens11.Tipo_prodotto__c = 'Lending';
                budgMens11.Utente__c = u.id;
                budgMens11.Budget__c = budget.id;
                budgMens11.Importo__c = 11110000;
                budgMens11.Mese_di_Riferimento__c = 'Ottobre';
                insert budgMens11;
                Budget_Mensile__c budgMens12 = new Budget_Mensile__c();
                budgMens12.Name = 'Budget Mensile Test 12';
                budgMens12.Tipo_prodotto__c = 'Lending';
                budgMens12.Utente__c = u.id;
                budgMens12.Budget__c = budget.id;
                budgMens12.Importo__c = 12120000;
                budgMens12.Mese_di_Riferimento__c = 'Novembre';
                insert budgMens12;
                Budget_Mensile__c budgMens13 = new Budget_Mensile__c();
                budgMens13.Name = 'Budget Mensile Test 13';
                budgMens13.Tipo_prodotto__c = 'Lending';
                budgMens13.Utente__c = u.id;
                budgMens13.Budget__c = budget.id;
                budgMens13.Importo__c = 13130000;
                budgMens13.Mese_di_Riferimento__c = 'Dicembre';
                insert budgMens13;
            }
    }
    @isTest 
    public static void testBP_BudgetReportPartnerCalculateSum(){
        Test.startTest();
        
        List<User> u = [SELECT id FROM User WHERE Name = 'Utente di test' LIMIT 1];
        System.runAs(u[0]) {
        List<Account> accs = [SELECT id, OwnerId, Gennaio_CF__c, Gennaio_LL__c, Budget_Gennaio__c,
        Febbraio_CF__c,
        Febbraio_LL__c,
        Budget_Febbraio__c,
        Marzo_CF__c,
        Marzo_LL__c,
        Budget_Marzo__c,
        Aprile_CF__c,
        Aprile_LL__c,
        Budget_Aprile__c,
        Maggio_CF__c,
        Maggio_LL__c,
        Budget_Maggio__c,
        Giugno_CF__c,
        Giugno_LL__c,
        Budget_Giugno__c,
        Luglio_CF__c,
        Luglio_LL__c,
        Budget_Luglio__c,
        Agosto_CF__c,
        Agosto_LL__c,
        Budget_Agosto__c,
        Settembre_CF__c,
        Settembre_LL__c,
        Budget_Settembre__c,
        Ottobre_CF__c,
        Ottobre_LL__c,
        Budget_Ottobre__c,
        Novembre_CF__c,
        Novembre_LL__c,
        Budget_Novembre__c,
        Dicembre_CF__c,
        Dicembre_LL__c,
        Budget_Dicembre__c FROM Account WHERE OwnerId =: u[0].id  LIMIT 1];
        List<Budget_Mensile__c> lstBudgMens = [SELECT Id, Name, Mese_di_Riferimento__c, CreatedById FROM Budget_Mensile__c WHERE Name = 'Budget Mensile Test' LIMIT 1];
        List<Opportunity> lstOppty = [SELECT Id, CloseDate, StageName, Amount FROM Opportunity limit 1];
                List<Opportunity> oppList1 = new List<Opportunity>();
                for(Opportunity opps : lstOppty){
                    Opportunity opp1 = new Opportunity();
                    opp1.Id = opps.Id;
                    opp1.StageName = 'Erogata';
                    System.debug('opp1 ' + opp1);
                    oppList1.add(opp1);
                    System.debug('oppList1 ' + oppList1);
                }
                update oppList1;

        system.debug('*******' + lstBudgMens);

       // System.runAs(u[0]) {
            BP_BudgetReportPartner.BP_BudgetReportPartnerCalculateSum();
            BP_BudgetReportPartner.BP_BudgetReportPartnerExistingImport();
        }
        Test.stopTest();
    }
}