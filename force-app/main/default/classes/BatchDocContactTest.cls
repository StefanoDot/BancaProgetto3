@isTest

public class BatchDocContactTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

      
    @isTest static void testCalloutLogger(){
                            Switch_Validation__mdt testtt=   BatchDocContactTest.generateMetadataValidation();

          
        Id recordTypeIdRefOpll = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        
        Account accee = ObjectFactory.insertNewAccount();
        Contact c = new Contact();
        c.LastName= 'test';
        c.AccountId = accee.Id;
        c.RecordTypeId = recordTypeIdRefOpll;
        c.Fidejussore__c = false;
        c.Email = 'aldora@gmail.com';
        c.Phone = '123456789';
                c.NDG__C = '12345';
        c.Ruolo_in_Azienda__c='Legale Rappresentante';
        

        
		insert c;
        
        
        
         Contact acc = ObjectFactory.insertNewContact();
        
     DocumentType__c doc=   ObjectFactory.insertNewDocumentType('Contact');

          test.startTest();
        
        BatchDocContact myBatchObject = new BatchDocContact();
				Id batchId = Database.executeBatch(myBatchObject, 10);
        test.stopTest();
        
    }

}