@isTest
public class CofaceBatchControllerTest {
      @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }


    @isTest static void testBATCH(){
                                                Switch_Validation__mdt testtt= CofaceBatchControllerTest.generateMetadataValidation();

                Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();

        
           Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.Partita_Iva__c='123456789';
        a.Ricezione_dati_Coface__c='Presa in carico';
        
		insert a;
        
        TEST.startTest();
                       CofaceBatchController myBatchObject = new CofaceBatchController();
				Id batchId = Database.executeBatch(myBatchObject, 1);
        test.stopTest();
    }
    }