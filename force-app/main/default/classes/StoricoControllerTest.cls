@isTest
public class StoricoControllerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    @isTest static void testAfterInsert(){
                       Switch_Validation__mdt testtt= StoricoControllerTest.generateMetadataValidation();

      /* Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        
        Account acc = ObjectFactory.insertNewAccount();
        Contact c = new Contact();
        c.LastName= 'test';
        c.AccountId = acc.Id;
        c.RecordTypeId = recordTypeIdRefOpl;
        c.Fidejussore__c = false;
        c.Email = 'aldora@gmail.com';
        c.Phone = '123456789';
        c.NDG__C = '12345';
        c.Firmatario__c= True;
        insert c;
        
         Opportunity opp1 = ObjectFactory.insertNewOpportunity();
           opp1.AccountId=acc.Id;
        Opportunity opportunityToUpdate = 
        [SELECT StageName FROM Opportunity 
         WHERE Id = :opp1.Id
         LIMIT 1];
    	opportunityToUpdate.StageName = 'Erogata';
        
   		update opportunityToUpdate;*/
            
         Opportunity opp1 = ObjectFactory.insertNewOpportunity();
        Storico_Opportunit__c a = new Storico_Opportunit__c();
        a.Opportunit__c= opp1.Id;
       
        insert a;
        
          Storico_Opportunit__c opportunityToUpdate = 
        [SELECT Fase__c FROM Storico_Opportunit__c
         WHERE Id = :a.Id
         LIMIT 1];
    	opportunityToUpdate.Fase__c = 'Erogata';
        
   		update opportunityToUpdate;
        test.startTest();
        StoricoController.AfterInsertErrogata(new List<Storico_Opportunit__c>{a});
        test.stopTest();
      
    }
}