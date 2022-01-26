@isTest
public class batchForTakingAccTest {
     @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
        return metadata;
     }

      @isTest static void testCalloutLogger(){
          Switch_Validation__mdt testtt=   batchForTakingAccTest.generateMetadataValidation();
          
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
        a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
        a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.Ricezione_Dati_Oplon__c= 'Ok Full';
        a.Tipo_di_Azienda__c= 'SRI';
        a.Privacy__c=true;
        a.Verifica_liste_negative__c='OK'; 
        a.Punteggio_di_rischio__c=1;
       a.erogazione_dei_servizi__c='YES';
        a.ForTakingAccInBatch__c='Test';
        insert a;
          
          
     	test.startTest();
        
        batchForTakingAcc myBatchObject = new batchForTakingAcc();
		Id batchId = Database.executeBatch(myBatchObject, 1);
        test.stopTest();
          
      }


}