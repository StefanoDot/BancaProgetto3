@isTest
public class BP_TipoAnagraficaExClienteBatchTest {
    
    @isTest
    public static void testBP_TipoAnagraficaExClienteBatch(){
        
        Test.startTest();
        
        Account acc = ObjectFactory.insertNewAccount();
        Opportunity o = new Opportunity(AccountId=acc.Id,
                                        Name = 'test',
                                        CloseDate = Date.today()+1,
                                        StageName = 'Primo Contatto',
                                        Forecast_Category_Custom__c = 'Elevata Probabilità',
                                        Tipo_Linea_di_Credito__c = 'Progetto EasyPlus',
                                        Finalita_Finanziamento__c = 'Liquidità',
                                        Ammontare_Iniziale__c = 1000,
                                        Durata_Partner__c = 100,
                                        Linea_di_Credito_in_Mesi__c = 20,
                                        Data_Stipula__c = Date.today(),
                                        OwnerId = acc.OwnerId,
                                        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',                              
                                        Sales_Support_Approver__c = ObjectFactory.aldora.id, 
                                        Sabatini_Applicabile__c = 'Si',
                                        Data_Erogazione__c = Date.newInstance(2021, 06, 06)                                     
                                       );
        insert o;
        List<Opportunity> oppList = new List<Opportunity>{o};
        List<Opportunity> oppList1 = new List<Opportunity>();
            for (Opportunity opp: oppList) {
            opp.StageName = 'Erogata';
            oppList1.add(opp);
            }
            update oppList1;
        acc.Tipo_Anagrafica__c = 'Prospect';
        update acc;
        
        BP_TipoAnagraficaExClienteBatch oppJob = new BP_TipoAnagraficaExClienteBatch();
        Database.executeBatch(oppJob, 100);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        BP_TipoAnagaraExClientScheduler sh1 = new BP_TipoAnagaraExClientScheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, sh1); 
        Test.stopTest(); 
    }
}