@isTest
public class oppSalesSupApproverBatchTest {
    
     @isTest static void testBatch() {
         
         Opportunity opp1 = ObjectFactory.insertNewOpportunity();
         
         oppSalesSupApproverBatch oppSalesJob= new oppSalesSupApproverBatch();
         Database.executeBatch(oppSalesJob, 50);
         
     }

}