@isTest

public class BatchDeleteCalloutLoggerTest {
      
    @isTest 
    static void testCalloutLogger(){
        
        Callout_Logger__c call = new Callout_Logger__c();
        //call.Timestamp__c = Date.today().addDays(-100);
     //   call.CreatedDate = Date.today().addDays(-100);
        insert call;
        
        test.startTest();
        BatchDeleteCalloutLogger myBatchObject = new BatchDeleteCalloutLogger();
				Id batchId = Database.executeBatch(myBatchObject, 1);
        test.stopTest();
        System.AssertEquals(1, [SELECT count() FROM Callout_Logger__c]);

    }
    @isTest
    static void TestDelete(){
      Callout_Logger__c call = new Callout_Logger__c();
      insert call;
      Test.setCreatedDate(call.Id, Date.today().addDays(-100)); 
      
      test.startTest();
      
      BatchDeleteCalloutLogger myBatchObject = new BatchDeleteCalloutLogger();
      Id batchId = Database.executeBatch(myBatchObject, 1);
      test.stopTest();
      System.AssertEquals(0, [SELECT count() FROM Callout_Logger__c]);
    }
}