@isTest
private class DocumentTriggerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    @isTest static void TriggerTest(){
                Switch_Validation__mdt testtt= DocumentTriggerTest.generateMetadataValidation();

              Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();

        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c = ObjectFactory.aldora.id
        );

        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25), amount = 100, Probability = 5);
        insert opp;
        DocumentType__c docType= new DocumentType__c(Document_Block__c='Documentazione pre-contrattuale',DocumentApiName__c='X07_Altre_Garanzie__c');
        insert docType;
      
        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test',VersionData=Blob.valueOf('Unit Test Attachment Body'));          
        insert cv; 

        ContentVersion cv2 = new ContentVersion(title = 'test content trigger', PathOnClient ='test',VersionData=Blob.valueOf('Unit Test Attachment Body'));          
        insert cv2;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Document__c doc= new Document__c(Box__c='Primo Contatto',Name='test',Id_File__c=documents[0].Id,DocumentType__c=docType.Id,Opportunity__c=opp.Id);
        
        insert doc;
        

        ContentDocumentLink cdl= new ContentDocumentLink( ContentDocumentId=documents[0].Id,LinkedEntityId=opp.id,shareType = 'V');
        insert cdl;
        List<ContentDocument> queryDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        doc.Id_File__c=queryDocuments[1].Id;
         ContentDocumentLink cdl2= new ContentDocumentLink( ContentDocumentId=documents[1].Id,LinkedEntityId=opp.id,shareType = 'V');
        insert cdl2;
        doc.Url_Documento__c='www.googletest.it';

    
 Test.startTest();
       
        update doc;
       
Test.stopTest();
        

    }


}