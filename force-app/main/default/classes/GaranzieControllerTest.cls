@isTest
public with sharing class GaranzieControllerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    
    @isTest static void testBeforeInsert(){
       Switch_Validation__mdt testtt= GaranzieControllerTest.generateMetadataValidation();

        
       Garanzia__c a = ObjectFactory.insertNewGaranzia();

    }
    
    
    @isTest static void testUpdate(){
         Switch_Validation__mdt testtt= GaranzieControllerTest.generateMetadataValidation();

     Garanzia__c g1 = ObjectFactory.insertNewGaranzia();
    	
        Garanzia__c gToUpdate = 
        [SELECT Id, Stato_Garanzia__c FROM Garanzia__c 
         WHERE Id = :g1.Id
         LIMIT 1];

        update gToUpdate;
    }
    
    @isTest static void testGaranziaCuisa(){
        Garanzia__c a = ObjectFactory.insertNewGaranzia();
   
                GaranzieController.BeforeUpdate(new List<Garanzia__c>{a});

        GaranzieController.GaranziaCuisa(new List<Garanzia__c>{a});
    } 

    @isTest 
    static void testpreventGaranziainStage(){
        
        // Garanzia__c g  = ObjectFactory.insertNewGaranzia();
        // List<Garanzia__c> garanciaList = new List<Garanzia__c>();
        // garanciaList.add(g);
        //User loggedInUser = [Select Id, Profile.Name from user where Id =: System.userInfo.getUserId()];
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
                                        // Sales_Support_Approver__c = aldora.id,
                                        // Inside_Sales_di_Riferimento__c = aldora.id ,  
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'
                                       
                                       );
        insert o;
        Quote q1 = new Quote();
        q1.Name = 'Aldoraaaa';
        q1.ExpirationDate = Date.today();
        q1.Ammontare_Iniziale__c = 1000;
        q1.Ammontare_Direzione__c = 1000;
        q1.Durata_Direzione__c = 10;
        q1.Ammontare_Deliberato__c = 1000;
        q1.Durata_Partner__c = 10;
        q1.Tipo_Linea_di_Credito__c = 'Mutuo';
        q1.Finalita_Finanziamento__c        = 'Investimento';
        q1.OpportunityId = o.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100;
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c='Si';
        insert q1;

        Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=q1.Id;
        g.Percentuale_Garantito__c='80%';
       
        insert g;
        List<Garanzia__c> garanciaList = new List<Garanzia__c>();
        garanciaList.add(g);
        test.startTest();
        GaranzieController.PreventGaranziaInStages(garanciaList);
        //System.assertEquals();
        test.stopTest();
    } 
    
    @isTest
    static void restrictUserFromDeletingGaranziesTest(){
        User user = ObjectFactory.createNewUser('unitTestUser@email.com', 'testUser@email.com');
    

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
                                        // Sales_Support_Approver__c = aldora.id,
                                        // Inside_Sales_di_Riferimento__c = aldora.id ,  
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'
                                       
                                       );
        insert o;
        Quote q1 = new Quote();
        q1.Name = 'Aldoraaaa';
        q1.ExpirationDate = Date.today();
        q1.Ammontare_Iniziale__c = 1000;
        q1.Ammontare_Direzione__c = 1000;
        q1.Durata_Direzione__c = 10;
        q1.Ammontare_Deliberato__c = 1000;
        q1.Durata_Partner__c = 10;
        q1.Tipo_Linea_di_Credito__c = 'Mutuo';
        q1.Finalita_Finanziamento__c        = 'Investimento';
        q1.OpportunityId = o.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100;
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c='Si';
        insert q1;

        Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=q1.Id;
        g.Percentuale_Garantito__c='80%';
       
        insert g;
        List<Garanzia__c> garanciaList = new List<Garanzia__c>();
        garanciaList.add(g);
        test.startTest();
        GaranzieController.restrictUserFromDeletingGaranzies(garanciaList);
        //System.assertEquals();
        test.stopTest();
    } 
    }