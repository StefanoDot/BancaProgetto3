@IsTest
public class QueueableDocumentGenerationTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    @IsTest static void QueueableCofaceDocumentGenerationTest(){
                               Switch_Validation__mdt testtt= QueueableDocumentGenerationTest.generateMetadataValidation();

          Account a = ObjectFactory.insertNewAccount();
        List<Id> acc = new List <Id>{a.Id};
      DocumentType__c docType = new DocumentType__c(Document_Block__c='Coface', DocumentApiName__c='?', Name='Analisi Coface', ObjectName__c = 'Account');
        
        insert docType;
        
          Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType.id;
        d.Commento_Sales_Support__c='testtt';
          d.Url_Documento__c= null;
        d.Url_Servizio_Esterno__c='TestAH.pdf';
        d.Account__c=a.id;
      
         insert d;
        
        test.startTest();
               QueueableCofaceDocumentGeneration updateJob = new QueueableCofaceDocumentGeneration(acc);

            System.enqueueJob(updateJob);
        test.stopTest();
    }

}