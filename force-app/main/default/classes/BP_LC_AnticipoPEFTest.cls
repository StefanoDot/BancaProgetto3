@isTest
public with sharing class BP_LC_AnticipoPEFTest{
    @isTest static void getOpportunityDetailsTest(){
        
        Account acc = ObjectFactory.insertNewAccount();
        
        OpportunityController.bypassTrigger = true;
            
        Opportunity opp = new Opportunity(AccountId = acc.Id,
        Name = 'Test',
        CloseDate = Date.today() + 1,
        StageName = 'Completamento Documenti',
        Forecast_Category_Custom__c = 'Elevata Probabilità',
        Tipo_Linea_di_Credito__c = 'Mutuo',
        Finalita_Finanziamento__c = 'Liquidità',
        Ammontare_Iniziale__c = 1000,
        Durata_Partner__c = 100,
        Linea_di_Credito_in_Mesi__c = 20,
        Data_Stipula__c = Date.today(),
        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',                              
        Sales_Support_Approver__c = ObjectFactory.aldora.Id,
        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.Id,  
        Sabatini_Applicabile__c = 'Si');
        insert opp;
        
        Test.startTest();
        Opportunity oppRec = BP_LC_AnticipoPEF.getOpportunityDetails(opp.Id);
        System.assertEquals(null, oppRec);
        Test.stopTest();
    }
    
    @isTest static void BP_OUT_AnticipoTest(){
        
        Account acc = ObjectFactory.insertNewAccount();
        
        OpportunityController.bypassTrigger = true;
            
        Opportunity opp = new Opportunity(AccountId = acc.Id,
        Name = 'Test',
        CloseDate = Date.today() + 1,
        StageName = 'Completamento Documenti',
        Forecast_Category_Custom__c = 'Elevata Probabilità',
        Tipo_Linea_di_Credito__c = 'Mutuo',
        Finalita_Finanziamento__c = 'Liquidità',
        Ammontare_Iniziale__c = 1000,
        Durata_Partner__c = 100,
        Linea_di_Credito_in_Mesi__c = 20,
        Data_Stipula__c = Date.today(),
        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',                              
        Sales_Support_Approver__c = ObjectFactory.aldora.Id,
        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.Id,  
        Sabatini_Applicabile__c = 'Si');
        insert opp;
        
        Quote q1 = new Quote();
        q1.Name = 'Aldoraaaa';
        q1.ExpirationDate = Date.today();
        q1.Ammontare_Iniziale__c = 1000;
        q1.Ammontare_Direzione__c = 1000;
        q1.Durata_Direzione__c = 10;
        q1.Ammontare_Deliberato__c = 1000;
        q1.Durata_Partner__c = 10;
        q1.Tipo_Linea_di_Credito__c = 'Mutuo';
        q1.Finalita_Finanziamento__c = 'Investimento';
        q1.OpportunityId = opp.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100; 
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c = 'Si';
        insert q1;
        
        Test.setMock(HttpCalloutMock.class, new API_ResponseMock());

        Test.startTest();
        BP_LC_AnticipoPEF.BP_OUT_Anticipo(opp.Id);
        Test.stopTest();
    }
    
    public class API_ResponseMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"nDG" : "225537", "codiceFiscale" : "09027030965", "ragioneSociale" : "IMMOBILIARE DOMUS S.R.L.", "naturaGiuridica" : "SC", "parereComCrediti" : "", "fidoList" : [{"chiaveFido" : "0Q03Y000002HGm1SAG", "provDestInv" : "RM", "scadenza" : "2021-06-30", "importo" : 1450000, "periodicita" : "mensile", "importoAffidato" : 1450000, "durataMesi" : 96, "RamoDestInv" : "06", "CategoriaProdotto" : "201801"}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}