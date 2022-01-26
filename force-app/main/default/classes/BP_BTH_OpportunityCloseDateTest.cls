@isTest
public class BP_BTH_OpportunityCloseDateTest {
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
        Opportunity o = new Opportunity(AccountId=acc.Id,
        Name = 'test',
        CloseDate = Date.today()+1,
        StageName=constants.OPPORTUNITY_PRIMO_CONTATTO,
        Forecast_Category_Custom__c='Elevata Probabilità',
        Tipo_Linea_di_Credito__c='Mutuo',
        Finalita_Finanziamento__c='Liquidità',
        Ammontare_Iniziale__c=1000,
        Durata_Partner__c=100,
        Linea_di_Credito_in_Mesi__c =20,
        Data_Stipula__c = Date.today(),
        OwnerId=acc.OwnerId,
        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
        Sales_Support_Approver__c = u.id,
        Inside_Sales_di_Riferimento__c = u.id ,  
        Sabatini_Applicabile__c='Si');
        insert o;
    }

    @isTest
    public static void BP_BTH_OpportunityCloseDateDeliberataTest() {
        
        Test.startTest();
        Utils_Constants constants = new Utils_Constants();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT id, StageName, CloseDate FROM Opportunity];
        List<Opportunity> oppList1 = new List<Opportunity>();

        for(Opportunity opp : oppList){
            Opportunity opp1 = new Opportunity();
            opp1.Id = opp.Id;
            opp1.StageName = constants.OPPORTUNITY_DELIBERATA;
            opp1.CloseDate = Date.newInstance(2021, 6, 17);
            oppList1.add(opp1);
        }
        update oppList1;
            BP_BTH_OpportunityCloseDate ocd = new BP_BTH_OpportunityCloseDate();
            Database.executeBatch(ocd);
            Database.BatchableContext BC; 
            ocd.execute(BC, oppList1);
        Test.stopTest();
        Date expectedDate = Date.newInstance(2021, 6, 17).addDays(10);
        System.assertEquals(expectedDate, oppList1.get(0).CloseDate);
    }
    @isTest
    public static void changePerFaseDue() {
        Utils_Constants constants = new Utils_Constants();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT id, StageName, CloseDate FROM Opportunity];
        List<Opportunity> oppList1 = new List<Opportunity>();

        for(Opportunity opp : oppList){
            Opportunity opp1 = new Opportunity();
            opp1.Id = opp.Id;
            opp1.StageName = constants.OPPORTUNITY_PEF_ISTRUTTORIA;
            opp1.CloseDate = Date.newInstance(2021, 6, 17);
            oppList1.add(opp1);
        }
        update oppList1;
        Test.startTest();
            BP_BTH_OpportunityCloseDate ocd = new BP_BTH_OpportunityCloseDate();
            Database.executeBatch(ocd);
            Database.BatchableContext BC; 
            ocd.execute(BC, oppList1);
        Test.stopTest();
        Date expectedDate = Date.newInstance(2021, 6, 17).addDays(15);
        System.assertEquals(expectedDate, oppList1.get(0).CloseDate);
    }
    @isTest
    public static void changePerAltreFasi() {
        Utils_Constants constants = new Utils_Constants();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT id, StageName, CloseDate FROM Opportunity];
        List<Opportunity> oppList1 = new List<Opportunity>();

        for(Opportunity opp : oppList){
            Opportunity opp1 = new Opportunity();
            opp1.Id = opp.Id;
            opp1.StageName = constants.OPPORTUNITY_PRIMA_VISITA;
            opp1.CloseDate = Date.newInstance(2021, 6, 17);
            oppList1.add(opp1);
        }
        update oppList1;
        Test.startTest();
            BP_BTH_OpportunityCloseDate ocd = new BP_BTH_OpportunityCloseDate();
            Database.executeBatch(ocd);
            Database.BatchableContext BC; 
            ocd.execute(BC, oppList1);
        Test.stopTest();
        Date expectedDate = Date.newInstance(2021, 6, 17).addDays(20);
        System.assertEquals(expectedDate, oppList1.get(0).CloseDate);
    }
}