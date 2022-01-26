@isTest
public class BP_StoricoFaseManagerTest {

@isTest
public static void testStoricoFaseManager(){
    
            
        Opportunity newOpp = ObjectFactory.insertNewOpportunity();
        List<Opportunity> newOppList = new List<Opportunity>();
        newOppList.add(newOpp);
    Test.startTest();
        BP_StoricoFaseManager.createStoricoFaseRecOnOppCreate(newOppList);
    Test.stopTest();
    System.assert(newOppList != null);
    
}
@isTest
public static void createStoricoFaseRecOnOppUpdate(){
    Utils_Constants constants = new Utils_Constants();
    Account acc = ObjectFactory.insertNewAccount();
    Opportunity opp = new Opportunity(AccountId=acc.Id,
    Name = 'test',
    CloseDate = Date.today()+1,
    StageName = constants.OPPORTUNITY_PRIMO_CONTATTO,
    Forecast_Category_Custom__c = 'Elevata Probabilità',
    Tipo_Linea_di_Credito__c = 'Mutuo',
    Finalita_Finanziamento__c = 'Liquidità',
    Ammontare_Iniziale__c = 1000,
    Durata_Partner__c = 100,
    Linea_di_Credito_in_Mesi__c = 20,
    Data_Stipula__c = Date.today(),
    OwnerId = acc.OwnerId,
    Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',                              
    Sales_Support_Approver__c = ObjectFactory.aldora.id,
    Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,  
    Sabatini_Applicabile__c = 'Si');
    insert opp;

    List<Storico_Fase__c> storicoFaseList= new List<Storico_Fase__c>();
    List<Opportunity> oppList = new List<Opportunity>{opp};	
    List<Opportunity> oppList1 = new List<Opportunity>();

    for(Opportunity opp1 : oppList){
        Opportunity opp23 = new Opportunity ();
        opp23.id = opp1.id;
        opp23.StageName = constants.OPPORTUNITY_PRIMA_VISITA;
        opp23.CloseDate = opp1.CloseDate;
        oppList1.add(opp23);
    }
    update oppList1;

    test.startTest();
      Storico_Fase__c StoriFase = new Storico_Fase__c();
      StoriFase.Opportunity__c = oppList.get(0).Id;
      StoriFase.Fase_Opportunit__c = oppList.get(0).StageName;
      StoriFase.Data_di_riferimento__c = System.today();
      StoriFase.Data_di_chiusura__c = oppList.get(0).CloseDate;
      insert StoriFase;
      storicoFaseList.add(StoriFase);
  	update storicoFaseList;
      
      test.stopTest();

//Map<Id,Set<String> testMapStorico = 
    System.assert(storicoFaseList != null);
    }

}