@isTest
public class DueDiligenceStageCreditiTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'test@test.test',
                          EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test');
        insert u;
        Account acc = new Account();
        acc.Name = 'kottt mooouyuyuyuyu';
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = 'ggggg';
        acc.Ricezione_Dati_Oplon__c= constants.OPLON_OK_FULL;
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Punteggio_di_rischio__c=1;
        acc.OwnerId = u.id;
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
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'
                                       );      
        insert o;
    }
  /*  @isTest
    public static void testNotificationsStageDueDiligence(){
        Utils_Constants constants = new Utils_Constants();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.StageName = constants.OPPORTUNITY_IN_DUE_DILIGENCE;
            oppList1.add(oppNew);
        }
        
        update oppList1;
        
        Test.startTest();
		EmailTemplate template = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where Name = 'Notifica User per opportunity cambio stage'];
		Task tsk=new Task();
			tsk.ActivityDate=System.Today();
			tsk.Subject='Test';
			tsk.Status='In Progress';
			tsk.Priority='Normal';
			Insert tsk;
			System.assertEquals(tsk.Subject,'Test');
        DueDiligenceStageCrediti.notificationsStageDueDiligence(oppList1);
        Test.stopTest();
        
    }*/
        @isTest
    public static void testnotifyUser(){
        Utils_Constants constants = new Utils_Constants();
        Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.Name = o.Name;
            oppNew.StageName = 'Due Diligence';
            oppList1.add(oppNew);
        }
        
        update oppList1;
            test.startTest();
        DueDiligenceStageCrediti.notificationsStageDueDiligence(oppList1);
        test.stopTest();
        
    }
    @isTest
    public static void testCondizionePassaggioInCompletamentoDocumenti(){
        
        Opportunity opp = [SELECT Id, Name, Verifica_Report_Finale_Studio_Dominici__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.Esito_Due_Diligence__c = 'Positivo';
            oppNew.Verifica_Report_Finale_Studio_Dominici__c = 'Esito Positivo';
            oppList1.add(oppNew);
        }
        update oppList1;
		Test.startTest();        
        DueDiligenceStageCrediti.CondizionePassaggioInCompletamentoDocumenti(oppList1);
        DueDiligenceStageCrediti.CheckCompletamentoVerificaReportFinale(oppList1);
        DueDiligenceStageCrediti.EsitoDueDiligenceRedFlagsConditions(oppList1);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testChiusaLostDueDiligence(){
        List<Opportunity> oppList3 = [SELECT id, name, stageName, ownerid FROM Opportunity];
        test.startTest();
        DueDiligenceStageCrediti.chiusaLostDueDiligence(oppList3);
        
        test.stopTest();
    }
}