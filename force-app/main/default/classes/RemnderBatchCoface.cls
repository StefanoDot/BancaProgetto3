global  with sharing class RemnderBatchCoface implements Schedulable {
    global void execute(SchedulableContext ctx) {
        
               CofaceBatchController myBatchObject = new CofaceBatchController();
				Id batchId = Database.executeBatch(myBatchObject, 1);
            }
            
    }