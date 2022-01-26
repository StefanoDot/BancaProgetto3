@isTest
public class BP_BTH_alignMandatoryDocsCountersTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
        List<Profile> pInsSal = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'test@test.test',
                                  EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = pInsSal.get(0).Id, IsActive = true,
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
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name = 'test';
        opp.CloseDate = Date.today()+1;
        opp.StageName=constants.OPPORTUNITY_PRIMO_CONTATTO;
        opp.Forecast_Category_Custom__c='Elevata Probabilità';
        opp.Tipo_Linea_di_Credito__c='Mutuo';
        opp.Finalita_Finanziamento__c='Liquidità';
        opp.Ammontare_Iniziale__c=1000;
        opp.Durata_Partner__c=100;
        opp.Linea_di_Credito_in_Mesi__c =20;
        opp.Data_Stipula__c = Date.today();
        opp.OwnerId=acc.OwnerId;
        opp.Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori';                              
        opp.Sales_Support_Approver__c = u.id;
        opp.Inside_Sales_di_Riferimento__c = u.id;  
        opp.Sabatini_Applicabile__c='Si';
        opp.Total_Mandatories_Docs__c = 10;
        opp.Total_Uploaded_Docs__c = 1;
        QuoteController.bypassTrigger = true;
        OpportunityController.bypassTrigger = true;
        insert opp;
        QuoteController.bypassTrigger = false;
        OpportunityController.bypassTrigger = false;
    }
    @isTest
    static void BP_BTH_alignMandatoryDocsCountersTest() {
        test.startTest();
            List<Opportunity> listOppBeforeChange = [SELECT Id, Total_Mandatories_Docs__c FROM Opportunity];
            System.debug('**** OPPORTUNITY BEFORE CHANGE ' + listOppBeforeChange);
            BP_BTH_alignMandatoryDocsCounters myBatchObject = new BP_BTH_alignMandatoryDocsCounters();
            Id batchId = Database.executeBatch(myBatchObject, 1);
            List<Opportunity> listOppAfterChange = [SELECT Id, Total_Mandatories_Docs__c FROM Opportunity];
            System.debug('**** OPPORTUNITY AFTER CHANGE ' + listOppAfterChange);
        test.stopTest();
    }
}