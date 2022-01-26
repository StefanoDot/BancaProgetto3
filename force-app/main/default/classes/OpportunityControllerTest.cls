@isTest
public with sharing class OpportunityControllerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    
    @isTest static void testAfterInsert() {
                             Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        
        DocumentType__c docType1 = ObjectFactory.insertNewDocumentType('Opportunity');
         DocumentType__c docType = new DocumentType__c(Document_Block__c='Delibera', DocumentApiName__c='test', ObjectName__c = 'Opportunity', Opportunita_EasyPlus__c=true);
        insert docType;
        DocumentType__c docType2 = ObjectFactory.insertNewDocumentType('Quote');
        DocumentType__c docType3 = new DocumentType__c(Document_Block__c='Documentazione interna', DocumentApiName__c='test', ObjectName__c = 'Quote', Opportunita_EasyPlus__c=true);
        insert docType3;
       DocumentType__c docType4 = ObjectFactory.insertNewDocumentType('Account');
      DocumentType__c docType5 = new DocumentType__c(Document_Block__c='Documentazione interna', DocumentApiName__c='test', ObjectName__c = 'Account', Opportunita_EasyPlus__c=true, Opportunita_Mutuo__c=false);
 insert docType5;
              DocumentType__c docTypeee = new DocumentType__c(Document_Block__c='Documentazione interna', DocumentApiName__c='test', ObjectName__c = 'Contact', Opportunita_EasyPlus__c=true, Opportunita_Mutuo__c=false);
insert docTypeee;
                DocumentType__c docType6 = ObjectFactory.insertNewDocumentType('Contact');

        
           Account acc = ObjectFactory.insertNewAccount();
           Contact cont = ObjectFactory.insertNewContact();
        cont.AccountId= acc.Id;
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
        Sales_Support_Approver__c = ObjectFactory.aldora.id,
        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,  
        Sabatini_Applicabile__c='Si');
        
        insert o;
     
         
    }
    
        @isTest static void testAfterInsertmutuo() {
                                         Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

      
        
        DocumentType__c docType1 = ObjectFactory.insertNewDocumentType('Opportunity');
         DocumentType__c docType = new DocumentType__c(Document_Block__c='Delibera', DocumentApiName__c='test', ObjectName__c = 'Opportunity', Opportunita_Mutuo__c=true);
        insert docType;
        DocumentType__c docType2 = ObjectFactory.insertNewDocumentType('Quote');
        DocumentType__c docType3 = new DocumentType__c(Document_Block__c='Documentazione interna', DocumentApiName__c='test', ObjectName__c = 'Quote', Opportunita_Mutuo__c=true);
        insert docType3;
       DocumentType__c docType4 = ObjectFactory.insertNewDocumentType('Account');
                DocumentType__c docType5 = ObjectFactory.insertNewDocumentType('Contact');


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
        Sabatini_Applicabile__c='Si');
        
        insert o;
     
         
    }
        @isTest static void testCreateInquiry() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();
		
        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
       Opportunity o = new Opportunity();
        o.Id=opp1.Id;
        o.Flag_Findynamic__c=true;
        o.Numero_Pratica__c='test';
        OpportunityController.bypassTrigger = true;
        update o;
        OpportunityController.bypassTrigger = false;
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>{o};
         Account a = new Account();
         a.Id= opp1.AccountId;
        a.erogazione_dei_servizi__c='YES';
        update a;  
         Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
	
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = opp1.AccountId,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl,
            	NDG__c = 'ndg',
            Interessato__c=true,
            Esecutore__c=true
            
        );
        insert contTest;
        Cointestazione__c c =ObjectFactory.insertNewCointestazione();
          
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
        q1.OpportunityId = opp1.Id;
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
        g.Cointestazione__c=c.Id;
        g.Opportunit__c=opp1.Id;

        insert g;
    
        OpportunityController.createInquiry(oppList);
          
        Test.stopTest();
    }
    @isTest static void testRitornoInCompletamento() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();
		Test.startTest();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     	a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.erogazione_dei_servizi__c = 'Yes';
        a.Privacy__c = true;
        a.Verifica_liste_negative__c = 'OK';
        a.Punteggio_di_rischio__c = 5;
        AccountsController.bypassTrigger = true;
		insert a;
        AccountsController.bypassTrigger = false;
        Opportunity opp = ObjectFactory.insertNewOpportunity();
       	 List<Opportunity> oppList = new List<Opportunity>{opp};
         List<Opportunity> oppList1 = new List<Opportunity>();
        List<Id> oppIdList = new List<Id>();
        for(Opportunity opps : oppList){
            Opportunity opp1 = new Opportunity();
            opp1.accountId = a.Id;
          	opp1.Id=opps.Id;
       		opp1.Flag_Findynamic__c=true;
        	opp1.Numero_Pratica__c='test';
            opp1.Total_Mandatories_Docs__c = 5;
            opp1.Totale_Verified_Docs_Verificati__c = 6;
            opp1.Creazione_Rete_Azienda__c = true;
            opp1.Privacy__c = 'Sì';
            opp1.Controllo_parti_correlate__c = 'Si';
            oppList1.add(opp1);
            oppIdList.add(opp1.Id);
            System.debug('oppList1 ' + oppList1);
        }
     	OpportunityController.bypassTrigger = true;
        update oppList1;
        OpportunityController.bypassTrigger = false;
        OpportunityController.CheckIfMandatoryDocTypesAreVerifiedForStage(oppList1);
        OpportunityController.CheckIfMandatoryDocTypesAreUploadedForStage(oppList1);
        OpportunityController.checkPassareInErogazione(oppList1);
        OpportunityController.ritornoInCompletamento(oppList1);
        OpportunityController.FieldSalesOwnerOpportunity(oppList1);
        OpportunityController.switchPhase(oppIdList);
       
        Test.stopTest();
    }
    
   @isTest static void testRespintiOpportunity() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();
		Test.startTest();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     	a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.erogazione_dei_servizi__c = 'Yes';
        AccountsController.bypassTrigger = true;
		insert a;
        AccountsController.bypassTrigger = false;
        Opportunity opp = ObjectFactory.insertNewOpportunity();
       	 List<Opportunity> oppList = new List<Opportunity>{opp};
         List<Opportunity> oppList1 = new List<Opportunity>();
        List<Id> oppIdList = new List<Id>();
        for(Opportunity opps : oppList){
            Opportunity opp1 = new Opportunity();
            opp1.accountId = a.Id;
          	opp1.Id=opps.Id;
       		opp1.Flag_Findynamic__c=true;
        	opp1.Numero_Pratica__c='test';
            opp1.Total_Mandatories_Docs__c = 5;
            opp1.Totale_Verified_Docs_Verificati__c = 6;
            oppList1.add(opp1);
            oppIdList.add(opp1.Id);
            System.debug('oppList1 ' + oppList1);
        }
     	OpportunityController.bypassTrigger = true;
        update oppList1;
        OpportunityController.bypassTrigger = false;
        OpportunityController.respintiOpportunity(oppIdList);
        Test.stopTest();
    }
    
    @isTest static void testCheckCambioDeliberata() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

         Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        
        List<Opportunity> oppList = new List<Opportunity>{opp1};
        
        Quote quote = new Quote();
        quote.Name = 'Aldoraaaa';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c        = 'Investimento';
        quote.OpportunityId = opp1.Id;
        quote.Status = 'In Corso';
        quote.Durata_Commerciale__c = 10;
        quote.Durata_Deliberata__c = 10; 
        quote.Durata_Direzione__c = 10;
        quote.Durata_Erogata__c = 10;
        quote.Sabatini_Applicabile__c='Si';
        
        
        insert quote;
        
     
            
        Test.startTest();
       // OpportunityController.LendingRecordType(oppList);
        Test.stopTest();
    }
    
    @isTest static void testReadOnlyRecordType() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        
        List<Id> oppList = new List<Id>{opp1.Id};
            
            
            
        Test.startTest();
       OpportunityController.ReadOnlyRecordType(oppList);
       OpportunityController.LendingRecordType(oppList);
       OpportunityController.ReadOnlyRecordTypeForCrediti(oppList);


        Test.stopTest();
            
    }
    
     @isTest static void testInErogazione() {
                                      Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

                       Utils_Constants constants = new Utils_Constants();

        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
         
         List<Quote> quote = [Select id from Quote where  OpportunityId =: opp1.Id];
         Quote qot = new Quote();
         qot.Id = quote[0].Id;
         qot.Contratto_Firmato_Flusso__c=true;
         qot.Contratto_Verificato__c=true;
         
       //  update qot;
             
             
             
             
         Opportunity opp = new Opportunity();
         opp.Id= opp1.Id;
opp.StageName = constants.OPPORTUNITY_IN_EROGAZIONE;       
opp.Numero_Pratica__c='12435';
    
            
            
        Test.startTest();
         
        // update opp;

        Test.stopTest();
            
    }
    
/*    @isTest static void testCheckCambioPEFISTRUTORIA() {
        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        
        List<Opportunity> oppList = new List<Opportunity>{opp1};
        
            Quote quote = new Quote();
        quote.Name = 'Aldoraaaa';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Durata_Direzione__c = 10;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c        = 'Investimento';
        quote.OpportunityId = opp1.Id;
        quote.Status = 'In Corso';
        quote.Durata_Deliberata__c = 10;
        
        insert quote;
            
        Test.startTest();
        OpportunityController.CheckCambioPEFISTRUTORIA(oppList);
        Test.stopTest();
            
    }*/
    
    @isTest static void testCheckCambioPEFPREISTRUTORIA() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        //Opportunity opp1 = ObjectFactory.insertNewOpportunity();
       Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        
         Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
       
     Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        
		insert a;
        
         Contact c = new Contact();
        c.LastName= 'test';
        c.AccountId = a.Id;
        c.RecordTypeId = recordTypeIdRefOpl;
        c.Fidejussore__c = false;
        c.Email = 'aldora@gmail.com';
        c.Phone = '123456789';
        c.NDG__C = ' ';
       c.Interessato__c=True;
        c.Esecutore__c=True;
        c.Ruolo_in_Azienda__c='Titolare Effettivo';
        
		insert c;
          Opportunity o = new Opportunity(AccountId=a.Id,
        Name = 'test',
        CloseDate = Date.today()+1,
        StageName = 'Primo Contatto',
        Forecast_Category_Custom__c='Elevata Probabilità',
        Tipo_Linea_di_Credito__c='Mutuo',
        Finalita_Finanziamento__c='Liquidità',
        Ammontare_Iniziale__c=1000,
        Durata_Partner__c=100,
        Linea_di_Credito_in_Mesi__c =20,
        Data_Stipula__c = Date.today(),
        OwnerId=a.OwnerId,
        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
        Sales_Support_Approver__c = ObjectFactory.aldora.id,
        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id , 
                                         Sabatini_Applicabile__c='Si');
        insert o;
        
        List<Opportunity> oppList = new List<Opportunity>{o};
        
        Quote quote = new Quote();
        quote.Name = 'Aldoraaaa';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Durata_Direzione__c = 10;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c        = 'Investimento';
        quote.OpportunityId = o.Id;
        quote.Status = 'In Corso';
        quote.Durata_Deliberata__c = 10;
        quote.Sabatini_Applicabile__c='Si';
        
        insert quote;
        
    //    Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{opp1.Id => opp1}; 
            
        Test.startTest();
        OpportunityController.checkCambioPEFPREISTRUTORIA(oppList);
                OpportunityController.checkCambioConsolidamentoDocumento(oppList);


        Test.stopTest();
            
    }
    
     @isTest static void testUpdateOplonAnalysis() {
                                      Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        List<Opportunity> oppList = new List<Opportunity>{opp1};
            
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{opp1.Id => opp1}; 
        
            
        Test.startTest();
        OpportunityController.updateOplonAnalysis(oppList, oldOppMap);
        Test.stopTest();
            
    }
    
    @isTest static void testErrogataFase() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();
		
        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        List<Opportunity> oppList = new List<Opportunity>{opp1};
        List<Id> oppIdList = new List<Id>{opp1.Id};
        System.debug('OppIdList Errogata ' + oppIdList);
        Test.startTest();    
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{opp1.Id => opp1}; 
        
        Quote quote = new Quote();
        quote.Name = 'Aldoraaaa';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Durata_Direzione__c = 10;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c = 'Investimento';
        quote.OpportunityId = opp1.Id;
        quote.Status = 'In Corso';
        quote.Durata_Deliberata__c = 10;
        quote.Ammontare_Erogato__c = 100;
        quote.Durata_Erogata__c = 10;
        quote.Sabatini_Applicabile__c='Si';
        quote.Contratto_Firmato_Flusso__c = true;
        quote.Contratto_Verificato__c = true;
        QuoteController.bypassTrigger = true;
        insert quote;
        QuoteController.bypassTrigger = false;
         Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=quote.Id;
        g.Percentuale_Garantito__c='80%';
       
        insert g;
            
        OpportunityController.checkInErogazione(oppIdList);
        OpportunityController.ErrogataFase(oppList, oldOppMap);
        Test.stopTest();
            
    }
    
    @isTest static void testChiusaFase() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        
        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{opp1.Id => opp1};
        
        Opportunity oppNew1 = opp1;
        oppNew1.StageName = 'Chiusa/Persa';
        List<Opportunity> oppList = new List<Opportunity>{oppNew1};
        List<Id> opp = new List<Id>{oppNew1.Id};
        Test.startTest();
        OpportunityController.ChiusaFase(oppList, oldOppMap);
                OpportunityController.ChiusuraFinale(opp);

        Test.stopTest();
    }
  
   
    
    @isTest static void afterUpdate() {
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
       
    	Opportunity opportunityToUpdate = 
        [SELECT Numero_Pratica__c, StageName FROM Opportunity 
         WHERE Id = :opp1.Id
         LIMIT 1];
    	opportunityToUpdate.Numero_Pratica__c = 'test123';
   		update opportunityToUpdate;
    }
    
    @isTest static void testDataScadenza(){
                                     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

    
        Quote q = ObjectFactory.insertNewQuote();
     
        Set<Id> ids = new Set<id>{q.OpportunityId};
            
      /*  Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='Fidejussione';
        g.Tipo_di_Fidejussione__c='Persona Fisica';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=q.Id;
        g.Percentuale_Garantito__c='130%';

        insert g;*/
        
        Test.startTest();
        OpportunityController.dataScadenzaGaranzia(ids);
        Test.stopTest();
    }
    
    
     @isTest static void testComissione() {
                                      Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

        Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{opp1.Id => opp1};
        
        Opportunity opportunityToUpdate = 
        [SELECT StageName FROM Opportunity 
         WHERE Id = :opp1.Id
         LIMIT 1];
    	opportunityToUpdate.Importo_commissione_FdG__c = 12.00;
   		update opportunityToUpdate;
           
    }
      @isTest static void testCheckAmmontare() {
                                       Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();

          Account acc = ObjectFactory.insertNewAccount();
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
        Sales_Support_Approver__c = ObjectFactory.aldora.id,
        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,  
        Sabatini_Applicabile__c='Si');
        

        insert o;   
          List<Opportunity> oppList= new List<Opportunity>{o};
          
        test.startTest();
    OpportunityController.motivazioneLost(oppList);
    OpportunityController.cambioDataChiusura(oppList);

          test.stopTest();
           
    }
    
     /*   @isTest
    public static void checkPassareDueDiligenceTest(){
        
     Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();
        
        Account acc = ObjectFactory.insertNewAccount();
            Opportunity o = new Opportunity (AccountId = acc.Id,
                Name = 'test',
       			CloseDate = Date.today()+1,
                StageName ='Primo Contatto',
                Tipo_Linea_di_Credito__c = 'Mutuo',
                Esito_Due_Diligence__c = 'Negativo' );
        insert o;
             List<Opportunity> oppList = new List<Opportunity>{o};
        test.startTest();
        OpportunityController.checkPassareDueDiligence(oppList);
        test.stopTest();
    }
    @isTest
    public static void checkPassareDueDiligencePositivoTest(){
         Switch_Validation__mdt testtt= OpportunityControllerTest.generateMetadataValidation();
        
        Account acc = ObjectFactory.insertNewAccount();
            Opportunity o = new Opportunity (AccountId = acc.Id,
                Name = 'test',
       			CloseDate = Date.today()+1,
                StageName ='Primo Contatto',
                Tipo_Linea_di_Credito__c = 'Mutuo',
                Esito_Due_Diligence__c = 'Positivo' );
        insert o;
             List<Opportunity> oppList = new List<Opportunity>{o};
        test.startTest();
        OpportunityController.checkPassareDueDiligencePositivo(oppList);
        test.stopTest();
    }*/
       
       
}