@isTest

public class BatchDocAccTest {
          
    @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

      
    @isTest static void testCalloutLogger(){
        
       
                    Switch_Validation__mdt testtt=   BatchDocAccTest.generateMetadataValidation();
           
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
       
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.Fidejussore__c = true;
        a.OwnerId = ObjectFactory.aldora.id;
        a.Ricezione_Dati_Oplon__c= 'Ok Full';
        a.Tipo_di_Azienda__c= 'SRI';
      a.Punteggio_di_rischio__c=1;

		insert a;
        
          Account acc = ObjectFactory.insertNewAccount();

     DocumentType__c doc=   ObjectFactory.insertNewDocumentType('Account');

          test.startTest();
        
        BatchDocAccCrea myBatchObject = new BatchDocAccCrea();
				Id batchId = Database.executeBatch(myBatchObject, 10);
        test.stopTest();
        
    }

}