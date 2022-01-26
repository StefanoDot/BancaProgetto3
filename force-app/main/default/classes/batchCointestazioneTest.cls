@isTest
public class batchCointestazioneTest {

    @isTest
    static void testBtchCoint(){
  Cointestazione__c c = new Cointestazione__c();
        c.Tipo_di_Cointestazione__c = 'Contact';
        c.NDG_Cointestazione__c='12345';
        c.NDG__c='test';
        
        insert c;
        
        List<Cointestazione__c> coint = new list<Cointestazione__c>();
        coint.add(c);
        
      test.startTest();
        
        batchCointestazione myBatchObject = new batchCointestazione();
		Id batchId = Database.executeBatch(myBatchObject,1);
        
        test.stopTest();
    }

}