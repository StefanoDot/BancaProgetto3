global  with sharing class ScheduleDeleteCalloutLogger implements Schedulable {
    global void execute(SchedulableContext ctx) {
        
               BatchDeleteCalloutLogger myBatchObject = new BatchDeleteCalloutLogger();
				Id batchId = Database.executeBatch(myBatchObject);
            }
            
    }