@isTest
public class PreDueDiligenceCreditiCondizioniTest {
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
                                        Numero_Pratica__c='12345',
                                        Importo_del_Credito__c =20000,
                                        Tempo_di_Incasso_Stimato__c =5
                                       );      
        insert o;
    }
/*@isTest
    public static void testFieldEsitoPropostaPricing(){
        Account acc = ObjectFactory.insertNewAccount();
     
        
        Opportunity o = new Opportunity(AccountId=acc.Id,
                                        Name = 'test',
                                        CloseDate = Date.today()+1,
                                        StageName='Primo Contatto',
                                        Forecast_Category_Custom__c='Elevata Probabilità',
                                        Tipo_Linea_di_Credito__c='Mutuo',
                                        Finalita_Finanziamento__c='Liquidità',
                                        Ammontare_Iniziale__c=1000,
                                        Durata_Partner__c=100,
                                        Linea_di_Credito_in_Mesi__c =20,
                                        Data_Stipula__c = Date.today(),
                                        OwnerId=acc.OwnerId,
                                        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
                                        Sales_Support_Approver__c = ObjectFactory.aldora.id,
                                        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,  
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'
            
                                       );      
        insert o;
        List<Opportunity> oppList = new List<Opportunity>{o};
            test.startTest();
        PreDueDiligenceCreditiCondizioni.FieldEsitoPropostaPricing(oppList);
        test.stopTest();
        
    }*/
    @isTest
    public static void testEsitoPropostaPricingPositivo(){
        Utils_Constants constants = new Utils_Constants();
        UfficioTerritorialeAE__c ut = new UfficioTerritorialeAE__c();
        ut.Name = 'Milano';
        insert ut;
        Opportunity opp = [SELECT Id,StageName, Procedura_delega_Agenzia_Riscossione__c, UfficioTerritorialeAE__c, Tempo_di_Incasso_Stimato__c, Importo_del_Credito__c, Pratica_complessa__c, Esito_Proposta_Pricing__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
        system.debug('*************** Questo è oppList2 ' + oppList2);
        List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.StageName = constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE;
            oppNew.UfficioTerritorialeAE__c = ut.id;
            oppNew.Procedura_delega_Agenzia_Riscossione__c = true;
            oppNew.Esito_Proposta_Pricing__c='Esito Positivo';
            oppNew.Tempo_di_Incasso_Stimato__c = 8;
            oppNew.Pratica_complessa__c='Si';
            oppNew.Importo_del_Credito__c =20000;
            oppList1.add(oppNew);
        }
        test.startTest();
        update oppList1;
        PreDueDiligenceCreditiCondizioni.EsitoPropostaPricingPositivo(oppList1);
        test.stopTest();
        
        Opportunity oppAgg = [SELECT id, StageName FROM Opportunity WHERE id =: opp.id];
        system.assertEquals(constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE,oppAgg.StageName);
        
    }
        @isTest
    public static void testEsitoPropostaPricingNegativo(){
        Utils_Constants constants = new Utils_Constants();
        Opportunity opp = [SELECT Id,StageName,Esito_Proposta_Pricing__c, Importo_del_Credito__c, Procedura_delega_Agenzia_Riscossione__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
        List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.StageName = constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE;
            oppNew.Esito_Proposta_Pricing__c='Esito Negativo';
            oppNew.Procedura_delega_Agenzia_Riscossione__c = true;
            oppList1.add(oppNew);
        }
        test.startTest();
        update oppList1;       
        PreDueDiligenceCreditiCondizioni.EsitoPropostaPricingNegativo(oppList1);
        test.stopTest();
        Opportunity oppAgg = [SELECT id, StageName FROM Opportunity WHERE id =: opp.id];
        system.assertEquals(constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE,oppAgg.StageName);
    }
    public static testMethod void notificationsStagePreDueDiligenceTest(){
        Utils_Constants constants = new Utils_Constants();
        UfficioTerritorialeAE__c ut = new UfficioTerritorialeAE__c();
        ut.Name = 'Milano';
        insert ut;
        Opportunity opp = [SELECT Id, name, StageName,Esito_Proposta_Pricing__c, Importo_del_Credito__c, Procedura_delega_Agenzia_Riscossione__c FROM Opportunity][0];
        List<Opportunity> oppList2 = new List<Opportunity>{opp};
        List<Opportunity> oppList1 = new List<Opportunity>();
        for (Opportunity o: oppList2) {
            Opportunity oppNew = new Opportunity();
            oppNew.id = o.id;
            oppNew.Name = 'Teest';
            oppNew.StageName = constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE;
            oppNew.UfficioTerritorialeAE__c = ut.id;
            oppNew.Procedura_delega_Agenzia_Riscossione__c = true;
            oppNew.Esito_Proposta_Pricing__c='Esito Positivo';
            oppNew.Tempo_di_Incasso_Stimato__c = 8;
            oppNew.Pratica_complessa__c='Si';
            oppNew.Importo_del_Credito__c =20000;
            oppList1.add(oppNew);
        }
        test.startTest();
        update oppList1;   
        PreDueDiligenceCreditiCondizioni.notificationsStagePreDueDiligence(opplist1);
		Test.stopTest(); 
        Opportunity oppAgg = [SELECT id, StageName FROM Opportunity WHERE id =: opp.id];
        system.assertEquals(constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE,oppAgg.StageName);
	}

}