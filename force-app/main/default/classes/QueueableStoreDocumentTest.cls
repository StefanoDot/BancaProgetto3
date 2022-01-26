@IsTest
public class QueueableStoreDocumentTest {
     @IsTest static void QueueableCofaceDocumentGenerationTest(){
          
      DocumentType__c docType = new DocumentType__c(Document_Block__c='Coface', DocumentApiName__c='?', Name='Analisi Coface', ObjectName__c = 'Account');
        
        insert docType;
        
          Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
          d.Url_Documento__c= null;
        d.Url_Servizio_Esterno__c='TestAH.pdf';
        
      
         insert d;
         List<Document__c> doc = new List<Document__c>{d};
        
        test.startTest();
               QueueableCofaceStoreDocument updateJob = new QueueableCofaceStoreDocument(doc);

            System.enqueueJob(updateJob);
        test.stopTest();
    }

}