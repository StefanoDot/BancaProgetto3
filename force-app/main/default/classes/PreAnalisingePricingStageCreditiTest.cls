@isTest
public class PreAnalisingePricingStageCreditiTest {

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
    @isTest
    public static void testCheckCampoNoteEsitoNegativo(){
        
        Opportunity opp = [SELECT Id,StageName,Note_Esito_Negativo_Due_Diligence__c FROM Opportunity][0];
        System.debug('Vjen Opportunity par ' + opp);
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
        System.debug('Vjen ne Liste ' +oppList2);

            List<Opportunity> oppList1 = new List<Opportunity>();
       		 for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            //oppNew.StageName = 'Pre-Analisi e Pricing';
            oppNew.Note_Esito_Negativo_Due_Diligence__c = 'test';
            oppList1.add(oppNew);
        }
        System.debug('Vjen ne Liste1 ' +oppList1);
        test.startTest();
        update oppList1;
        System.debug('Update ne Liste ' +oppList1);
            
        PreAnalisingePricingStageCrediti.checkCampoNoteEsitoNegativo(oppList1);
        test.stopTest();
        
    }
      @isTest
    public static void testCheckCampoNoteEsitoRedFlags(){
        Opportunity opp = [SELECT Id,StageName,Note_sospensive_Due_Diligence__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            //oppNew.StageName = 'Pre-Analisi e Pricing';
            oppNew.Note_sospensive_Due_Diligence__c = 'test';
            oppList1.add(oppNew);
        }
        
            test.startTest();
            update oppList1;
        PreAnalisingePricingStageCrediti.checkCampoNoteEsitoRedFlags(oppList1);
        test.stopTest();
        
    }
    @isTest
    public static void testCheckCampoEsitoValutazioneRedFlags(){
        Opportunity opp = [SELECT Id,StageName,Note_Desospensione__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            //oppNew.StageName = 'Pre-Analisi e Pricing';
            oppNew.Note_Desospensione__c = 'test';
            oppList1.add(oppNew);
        }
        
            test.startTest();
            update oppList1;
        PreAnalisingePricingStageCrediti.checkCampoEsitoValutazioneRedFlags(oppList1);
        test.stopTest();
        
    }
    @isTest
    public static void testCheckCampoEsitoDueDiligencePositivoDaRedFlags(){
        Opportunity opp = [SELECT Id,StageName,Note_Desospensione__c,Pricing__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            //oppNew.StageName = 'Pre-Analisi e Pricing';
            oppNew.Note_Desospensione__c = 'test';
            oppNew.Pricing__c = 2;
            oppList1.add(oppNew);
        }
        
            test.startTest();
            update oppList1;
        PreAnalisingePricingStageCrediti.checkCampoEsitoDueDiligencePositivoDaRedFlags(oppList1);
        PreAnalisingePricingStageCrediti.FieldEsitoPropostaPricing(oppList1);
        test.stopTest();
        
    }
    @isTest
    public static void testCheckPassareStageInDueDiligence(){
        Opportunity opp = [SELECT Id,StageName,Esito_Proposta_Pricing__c,Procedura_delega_Agenzia_delle_Entrate__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.StageName = 'Pre-Analisi e Pricing';
            oppNew.Esito_Proposta_Pricing__c = 'Esito positivo';
            oppNew.Procedura_delega_Agenzia_delle_Entrate__c = true; 
            oppList1.add(oppNew);
        }
        
            test.startTest();
            update oppList1;
        PreAnalisingePricingStageCrediti.checkPassareStageInDueDiligence(oppList1);
        test.stopTest();
        
    }
    @isTest
    public static void testCheckPassareStageInChiusaPersaDaPreAnalising(){
        Utils_Constants constants = new Utils_Constants();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.StageName = 'Pre-Analisi e Pricing';
            oppList1.add(oppNew);
        }
        
        update oppList1;
            test.startTest();
        PreAnalisingePricingStageCrediti.checkPassareStageInChiusaPersaDaPreAnalising(oppList1);
        test.stopTest();
        
    }
    @isTest
    public static void testnotifyUser(){
        Utils_Constants constants = new Utils_Constants();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
            List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.StageName = 'Pre-Analisi e Pricing';
            oppList1.add(oppNew);
        }
        
        update oppList1;
            test.startTest();
        PreAnalisingePricingStageCrediti.notifyUser(oppList1);
        test.stopTest();
        
    }
}