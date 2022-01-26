@isTest
public class BP_TipoAnagraficaProspectBatchTest {
    
    @isTest
    public static void testTipoAnagraficaProspectBatch(){
        
        Test.startTest();
        	Account acc = ObjectFactory.insertNewAccount();
        	BP_TipoAnagraficaProspectBatch oppJob = new BP_TipoAnagraficaProspectBatch();
        	Database.executeBatch(oppJob, 100);
        Test.stopTest();
    }
    
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        BP_TipoAnagaraProspectScheduler sh1 = new BP_TipoAnagaraProspectScheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, sh1); 
        Test.stopTest(); 
    }

}