@isTest (SeeAllData=false)
public with sharing class QuoteControllerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    @isTest static void testInsert(){
        
                       Switch_Validation__mdt testtt= QuoteControllerTest.generateMetadataValidation();

        List<Quote> garanzie = new List<Quote>();
        
        User user = ObjectFactory.createNewUser('unitTestUser@email.com', 'testUser@email.com');
        //insert user;
        System.debug('Limits.getQueries() 1 = ' + Limits.getQueries()); // Limits.getQueries() 1 = 2
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Acc Dao';
        acc.Manager_NomeCompleto__c = user.Id;
        acc.Inside_Sales_di_Riferimento__c = user.Id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.OwnerId = user.Id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        acc.Codice_Fiscale__c = '1245';
        acc.Analysis_Id_Oplon__c = '75637';
        insert acc;
        System.debug('Limits.getQueries() 2 = ' + Limits.getQueries()); //Limits.getQueries() 2 = 7
        
        Opportunity o = new Opportunity(AccountId=acc.Id,
        Name = 'test',
        CloseDate = Date.today()+1,
        StageName='Primo Contatto',
        Forecast_Category_Custom__c='Elevata Probabilità',
        Tipo_Linea_di_Credito__c='Progetto EasyPlus',
        Finalita_Finanziamento__c='Liquidità',
        Ammontare_Iniziale__c=1000,
        Durata_Partner__c=100,
        Linea_di_Credito_in_Mesi__c =20,
        Data_Stipula__c = Date.today(),
        OwnerId=acc.OwnerId,
        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
        Sales_Support_Approver__c = user.id,
        Inside_Sales_di_Riferimento__c = user.id ,  
        Sabatini_Applicabile__c='Si');
        

        insert o;
        //Opportunity opp2 = ObjectFactory.generateOpportunity(acc);
        //insert opp2;
       
        
        Quote a = new Quote();
        a.Name = 'Aldoraaaa';
        a.ExpirationDate = Date.today();
        a.Ammontare_Iniziale__c = 1000;
        a.Durata_Partner__c = 10;
        a.Tipo_Linea_di_Credito__c = 'Progetto EasyPlus';
        a.Finalita_Finanziamento__c  = 'Investimento';
        a.OpportunityId = o.Id;
        a.Sabatini_Applicabile__c='Si';
        
        // Quote b = new Quote();
        // b.Name = 'Aldoraaaa 2';
        // b.ExpirationDate =  Date.today();
        // b.Ammontare_Iniziale__c = 2000;
        // b.Durata_Partner__c = 20;
        // b.Tipo_Linea_di_Credito__c = 'Mutuo';
        // b.Finalita_Finanziamento__c        = 'Investimento';
        // b.OpportunityId = opp2.Id;
        // b.Sabatini_Applicabile__c='Si';
        garanzie.add(a);
        //garanzie.add(b);
        
        
        
        
         DocumentType__c docType = new DocumentType__c(Document_Block__c='Documenti ufficiali', DocumentApiName__c='test', ObjectName__c = 'Quote', Opportunita_EasyPlus__c=true);
        
        insert docType;
        Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
        d.Quote__c=a.id;
        
		insert d;
        
        
        //   DocumentType__c docType1 = new DocumentType__c(Document_Block__c='Documenti ufficiali', DocumentApiName__c='test', ObjectName__c = 'Quote', Opportunita_Mutuo__c=true);
        
        // insert docType1;
        // Document__c d1 = new Document__c();
        // d1.Name='test';
        // d1.DocumentType__c=docType1.id;
        // d1.Id_File__c='0691w0000010Rs9AAE';
        // d1.Commento_Sales_Support__c='testtt';
        // d1.Quote__c=b.id;
        
		//insert d1;
        
        
        insert garanzie;
        
Test.startTest();
        QuoteController.AfterInsertAddDoc(garanzie);
         QuoteController.BeforeInsert(garanzie);
        delete garanzie;
        Test.stopTest();
    }
    
    @isTest static void testUpdate(){
                               Switch_Validation__mdt testtt= QuoteControllerTest.generateMetadataValidation();

        Utils_Constants costanti=new Utils_Constants();

        User user = ObjectFactory.createNewUser('unitTestUser@email.com', 'testUser@email.com');
        //insert user;
        System.debug('Limits.getQueries() 1 = ' + Limits.getQueries()); // Limits.getQueries() 1 = 2
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Acc Dao';
        acc.Manager_NomeCompleto__c = user.Id;
        acc.Inside_Sales_di_Riferimento__c = user.Id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.OwnerId = user.Id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        acc.Codice_Fiscale__c = '1245';
        acc.Analysis_Id_Oplon__c = '75637';
        insert acc;

        Opportunity opp = ObjectFactory.generateOpportunity(acc);
        opp.AccountId = acc.Id;
        opp.OwnerId = acc.OwnerId;
        insert opp;
        Quote a = new Quote();
        a.Name = 'Aldoraaaa';
        a.ExpirationDate = Date.today();
        a.Ammontare_Iniziale__c = 1000;
        a.Durata_Partner__c = 10;
        a.Tipo_Linea_di_Credito__c = 'Mutuo';
        a.Finalita_Finanziamento__c  = 'Investimento';
        a.OpportunityId = opp.Id;
        a.Sabatini_Applicabile__c='Si';
        insert a;
    	
        Quote qToUpdate = 
        [SELECT Status, Oplon_Esito_Delibera__c,Durata_Commerciale__c FROM Quote 
         WHERE Id = :a.Id
         LIMIT 1];
        
        qToUpdate.Oplon_Esito_Delibera__c='97';
        qToUpdate.Durata_Commerciale__c=10;
        qToUpdate.Linea_di_Credito_in_Mesi__c=10;
            
        update qToUpdate;
        
    }
    
    @isTest static void testMethods(){
        Switch_Validation__mdt testtt= QuoteControllerTest.generateMetadataValidation();
        
        User user = ObjectFactory.createNewUser('unitTestUser@email.com', 'testUser@email.com');
        //insert user;
        System.debug('Limits.getQueries() 1 = ' + Limits.getQueries()); // Limits.getQueries() 1 = 2
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();           
        Account acc = new Account();
        acc.Name = 'Acc Dao';
        acc.Manager_NomeCompleto__c = user.Id;
        acc.Inside_Sales_di_Riferimento__c = user.Id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.OwnerId = user.Id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        acc.Codice_Fiscale__c = '1245';
        acc.Analysis_Id_Oplon__c = '75637';
        insert acc;
        System.debug('Limits.getQueries() 2 = ' + Limits.getQueries()); //Limits.getQueries() 2 = 7

        Contact cont = ObjectFactory.generateContact(acc);
        insert cont;
        System.debug('Limits.getQueries() 3 = ' + Limits.getQueries()); // Limits.getQueries() 3 = 29

        Opportunity opp = ObjectFactory.generateOpportunity(acc);
        opp.AccountId = acc.Id;
        opp.OwnerId = acc.OwnerId;
        insert opp;
        System.debug('Limits.getQueries() 4 = ' + Limits.getQueries()); // Limits.getQueries() 4 = 71
        Test.startTest();
        Quote quote = ObjectFactory.generateMutuoQuote(opp);
        quote.OpportunityId = opp.Id;
        quote.Contratto_Verificato__c = true;
        insert quote;
          Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=quote.Id;
        g.Percentuale_Garantito__c='80%';
        g.Verifica_fondo__c=null;
        g.Esito_simulazione__c=null;
        g.Esito_delibera__c=null;

        insert g;
    
        QuoteController.resetGaranzie(new List<id>{quote.id});
        QuoteController.AnullataQuote(new List<Quote>{quote});
        QuoteController.CalculateAmontareDurataOpp(new Set<Id>{quote.OpportunityId});
        QuoteController.checkAmontareEasyPlus(new Set<Quote>{quote});
        Test.stopTest();
    }
/*    @isTest static void testDataScadenzaGaranzia(){
                               Switch_Validation__mdt testtt= QuoteControllerTest.generateMetadataValidation();

        
           Account acc = ObjectFactory.insertNewAccount();
         
        //User usr = createNewUser('qwerty1231456789@qwerty.com');
        
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
        Sabatini_Applicabile__c='Si');
        

        insert o;
        
        
        Opportunity opportunityToUpdate = 
        [SELECT StageName FROM Opportunity 
         WHERE Id = :o.Id
         LIMIT 1];
    	opportunityToUpdate.StageName = 'Deliberata';
   		update opportunityToUpdate;
        
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
        g.Opportunit__c=o.id;
        g.Percentuale_Garantito__c='80%';
      
         
        insert g;
        test.startTest();
     //   QuoteController.dataScadenzaGaranzia(new Set<Id>{q1.id});
        test.stopTest();
    }*/
    
 /*   @isTest static void testCheckFineMutuo(){
      Quote q1 = ObjectFactory.insertNewQuote();
         test.startTest();
        QuoteController.checkFineMutuo(new Set<Id>{q1.AccountId});
        test.stopTest();
    }*/

    @isTest 
    static void testPreventQuoteinStage(){
      User user = ObjectFactory.createNewUser('unitTestUser@email.com', 'testUser@email.com');
       // insert user;
        System.debug('Limits.getQueries() 1 = ' + Limits.getQueries()); // Limits.getQueries() 1 = 2
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Acc Dao';
        acc.Manager_NomeCompleto__c = user.Id;
        acc.Inside_Sales_di_Riferimento__c = user.Id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.OwnerId = user.Id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        acc.Codice_Fiscale__c = '1245';
        acc.Analysis_Id_Oplon__c = '75637';
        insert acc;
        System.debug('Limits.getQueries() 2 = ' + Limits.getQueries()); //Limits.getQueries() 2 = 7


      Opportunity o = new Opportunity(AccountId=acc.Id,
                                        Name = 'test',
                                        CloseDate = Date.today()+1,
                                        StageName=' Primo Contatto',
                                        Forecast_Category_Custom__c='Elevata Probabilità',
                                        Tipo_Linea_di_Credito__c='Mutuo',
                                        Finalita_Finanziamento__c='Liquidità',
                                        Ammontare_Iniziale__c=1000,
                                        Durata_Partner__c=100,
                                        Linea_di_Credito_in_Mesi__c =20,
                                        Data_Stipula__c = Date.today(),
                                        OwnerId=acc.OwnerId,
                                        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                               
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

        List<Quote> quoteList = new List<Quote>();
        quoteList.add(q1);
        test.startTest();
        QuoteController.PreventQuotesOnStages(quoteList);
        test.stopTest();
        
        
        
    }
    
}