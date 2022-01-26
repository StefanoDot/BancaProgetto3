@isTest
private class OpportunityTriggerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    @isTest static void TriggerTest(){
                                     Switch_Validation__mdt testtt= OpportunityTriggerTest.generateMetadataValidation();

       
        /* Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Inside Sales' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',     FirstName='JASON',   Alias = 'jliv',   Email = 'jason.liveston@asdf.com',   Username = 'testeston@asdf.com',
                     ProfileId = profileId.id,     TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US',   EmailEncodingKey = 'UTF-8',     LocaleSidKey = 'en_US'   );
        System.runAs(usr){}

        List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Inside_Sales_1'];*/

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();

        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c = ObjectFactory.aldora.Id
        );

        insert acc;

        Opportunity opp= new Opportunity(AccountId=acc.id,Name='aaa',StageName='Primo Contatto', CloseDate= Date.newInstance(2021,12,25),amount=100,Probability=5,
        Inside_Sales_di_Riferimento__c= ObjectFactory.aldora.Id,Manager_NomeCompleto__c=ObjectFactory.aldora.Id);
        
        
        DocumentType__c docType= new DocumentType__c(Document_Block__c='Documentazione pre-contrattuale',DocumentApiName__c='X07_Altre_Garanzie__c');
        insert docType;
      
        ContentVersion cv = new ContentVersion(title = 'test content trigger', PathOnClient ='test',VersionData=Blob.valueOf('Unit Test Attachment Body'));          
         insert cv; 

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Document__c doc= new Document__c(Box__c='Deliberata',Name='test',Id_File__c=documents[0].Id,DocumentType__c=docType.Id);
        insert doc;

        // ContentDocumentLink cdl= new ContentDocumentLink( ContentDocumentId=documents[0].Id,LinkedEntityId=opp.id,shareType = 'V');
        // insert cdl;

        
    
 Test.startTest();
       
      insert opp;
Test.stopTest();
        

    }


}