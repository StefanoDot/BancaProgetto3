@isTest
public class BP_TipoAnagraficaControllerTest {
    
    @isTest
    public static void testupdateTipoAnagraficaProspect(){
        
        Test.startTest();
            Opportunity newOpp = ObjectFactory.insertNewOpportunity();
            List<Opportunity> newOppList = new List<Opportunity>();
            newOppList.add(newOpp);
            
            BP_TipoAnagraficaController.updateTipoAnagraficaProspect(newOppList);
        Test.stopTest();
        
    }
    @isTest
    public static void testupdateTipoAnagraficaCliente(){
        
        Test.startTest();
            Opportunity newOpp = ObjectFactory.insertNewOpportunity();
            List<Opportunity> newOppList = new List<Opportunity>();
            newOppList.add(newOpp);
            
            BP_TipoAnagraficaController.updateTipoAnagraficaCliente(newOppList);
        Test.stopTest();
        
    }

    @isTest
    public static void testupdateTipoAnagraficaLost(){
        
        Test.startTest();
            Opportunity newOpp = ObjectFactory.insertNewOpportunity();
            List<Opportunity> newOppList = new List<Opportunity>();
            newOppList.add(newOpp);
            
            BP_TipoAnagraficaController.updateTipoAnagraficaLost(newOppList);
        Test.stopTest();
        
    }

}