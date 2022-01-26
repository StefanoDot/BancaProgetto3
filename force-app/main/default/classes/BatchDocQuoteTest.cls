@isTest

public class BatchDocQuoteTest {

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
    Opportunity o = ObjectFactory.generateOpportunity(acc);
    insert o;
    Opportunity opp = new Opportunity(
                AccountId = acc.Id,
                Name = 'test',
                CloseDate = Date.today()+1,
                StageName = constants.OPPORTUNITY_PRIMO_CONTATTO,
                Forecast_Category_Custom__c = 'Elevata Probabilità',
                Tipo_Linea_di_Credito__c = 'Progetto EasyPlus',
                Finalita_Finanziamento__c = 'Liquidità',
                Ammontare_Iniziale__c = 1000,
                Durata_Partner__c = 100,
                Linea_di_Credito_in_Mesi__c = 20,
                Data_Stipula__c = Date.today(),
                OwnerId = acc.OwnerId,
                Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
                Sales_Support_Approver__c = u.Id,
                Inside_Sales_di_Riferimento__c = u.Id ,
                Sabatini_Applicabile__c = 'Si',
                Numero_Pratica__c = '12345'
        );
    insert opp;
  }
    
     @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

    @isTest static void testCalloutLogger(){
      Utils_Constants constants = new Utils_Constants();
      Switch_Validation__mdt testtt=   BatchDocQuoteTest.generateMetadataValidation();

      test.startTest();
      List<Opportunity> listOppEasyP = [SELECT id, StageName FROM Opportunity WHERE Tipo_Linea_di_Credito__c = 'Progetto EasyPlus'];
      List<Opportunity> listOppMutuo = [SELECT id, StageName FROM Opportunity WHERE Tipo_Linea_di_Credito__c = 'Mutuo'];

      Quote q1 = ObjectFactory.generateMutuoQuote(listOppMutuo.get(0));
      insert q1;
      Quote q2 = new Quote();
      q2.Name = 'Aldoraaaa';
      q2.ExpirationDate = Date.today();
      q2.Ammontare_Iniziale__c = 1000;
      q2.Ammontare_Direzione__c = 1000;
      q2.Durata_Direzione__c = 10;
      q2.Ammontare_Deliberato__c = 1000;
      q2.Durata_Partner__c = 10;
      q2.Tipo_Linea_di_Credito__c = 'Progetto EasyPlus';
      q2.Finalita_Finanziamento__c = 'Investimento';
      q2.OpportunityId = listOppEasyP.get(0).Id;
      q2.Status = 'In Corso';
      q2.Durata_Deliberata__c = 10;
      q2.Ammontare_Erogato__c = 100;
      q2.Durata_Erogata__c = 10;
      q2.Sabatini_Applicabile__c='Si';
      insert q2;

      DocumentType__c docType = ObjectFactory.generateDocumentType('Quote');
      DocumentType__c docType2 = ObjectFactory.generateDocumentType('Quote');
      docType2.Opportunita_EasyPlus__c=true;
      insert docType;
      insert docType2;

      Document__c d = ObjectFactory.generateDocument(docType);
      d.Quote__c = q1.Id;
      insert d;
      Document__c d1 = ObjectFactory.generateDocument(docType2);
      d1.Quote__c = q2.Id;
      insert d1;

      BatchDocQuote myBatchObject = new BatchDocQuote();
			Id batchId = Database.executeBatch(myBatchObject, 10);
      test.stopTest();  
    } 
}