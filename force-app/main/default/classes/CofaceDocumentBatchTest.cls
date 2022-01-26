@isTest
public class CofaceDocumentBatchTest {
          @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

    @isTest static void testDocumentBatch(){
                   Switch_Validation__mdt testtt= CofaceDocumentBatchTest.generateMetadataValidation();

         Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
       
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.Ricezione_dati_Coface__c='OK';
        
		insert a;
        
  DocumentType__c docType = new DocumentType__c(Document_Block__c='Coface', DocumentApiName__c=' ', Name='Analisi Coface', ObjectName__c = 'Account',ID_Tipo_Documento__c='SME_057');
        
        insert docType;
        
          Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
          d.Url_Documento__c= null;
        d.Url_Servizio_Esterno__c='TestAH.pdf';
        d.Account__c=a.id;
      
		insert d;
        
        
        test.startTest();
            CofaceDocumentBatch myBatchObject = new CofaceDocumentBatch();
			Id batchId = Database.executeBatch(myBatchObject, 1);
        test.stopTest();
        
    }

}