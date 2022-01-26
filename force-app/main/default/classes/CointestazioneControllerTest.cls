@isTest
public class CointestazioneControllerTest {
       @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

    
       @isTest static void testDelete(){
             Switch_Validation__mdt testtt=   CointestazioneControllerTest.generateMetadataValidation();

        
        
  	 Cointestazione__c coin3 = new Cointestazione__c();
        coin3.Tipo_di_Cointestazione__c = 'Account';
        coin3.NDG_Cointestazione__c='12345';
       
        insert coin3;
        
        
 delete coin3;
    }
    
   @isTest static void changeTipo(){
                    Switch_Validation__mdt testtt=   CointestazioneControllerTest.generateMetadataValidation();

          	 Cointestazione__c coin3 = new Cointestazione__c();
        coin3.Tipo_di_Cointestazione__c = 'Account';
        coin3.NDG_Cointestazione__c='12345';
       
        insert coin3;
        
           Cointestazione__c opportunityToUpdate = 
        [SELECT Tipo_di_Cointestazione__c FROM Cointestazione__c 
         WHERE Id = :coin3.Id
         LIMIT 1];
    	opportunityToUpdate.Tipo_di_Cointestazione__c ='Contact';
   		update opportunityToUpdate;
   
      }


    @isTest static void ndgRicheistaCR(){
      Switch_Validation__mdt testtt=   CointestazioneControllerTest.generateMetadataValidation();
   
      Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
      
      Account acc = ObjectFactory.insertNewAccount();
      Contact con = new Contact();
      con.LastName= 'test';
      con.AccountId = acc.Id;
      con.RecordTypeId = recordTypeIdRefOpl;
      con.Fidejussore__c = false;
      con.Email = 'aldora@gmail.com';
      con.Phone = '123456789';
      con.NDG__C = '12345'; 
      insert con;
      List<Id> cointestazionelistIds = new List<Id>();
      Fidejussione__c a = new Fidejussione__c();
        a.Persona_Fisica__c=con.id;
        
        insert a;
      
      Cointestazione__c coin3 = new Cointestazione__c();
      coin3.Tipo_di_Cointestazione__c = 'Account';
      coin3.NDG_Cointestazione__c='12345';

 insert coin3;
 cointestazionelistIds.add(coin3.Id);
//  List<Cointestazione__c> cointestazionelist = new List<Cointestazione__c>();
//  cointestazionelist.add(coin3);
      
 Test.startTest();
       
 CointestazioneController.ndgRicheistaCR(cointestazionelistIds);

Test.stopTest();
}
}