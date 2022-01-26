@isTest

public class BatchDocOpportunityTest {
     @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

      @isTest static void testCalloutLogger(){
                                Switch_Validation__mdt testtt=   BatchDocOpportunityTest.generateMetadataValidation();

            Opportunity acc = ObjectFactory.insertNewOpportunity();
    
    
             DocumentType__c doc=   ObjectFactory.insertNewDocumentType('Opportunity');


      
          
            test.startTest();
        
        BatchDocOpportunity myBatchObject = new BatchDocOpportunity();
				Id batchId = Database.executeBatch(myBatchObject, 10);
        test.stopTest();
          
      }


}