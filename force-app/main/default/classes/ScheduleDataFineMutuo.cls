global  with sharing class ScheduleDataFineMutuo implements Schedulable {
    global void execute(SchedulableContext ctx) {
        
               BatchDataFineMutuo myBatchObject = new BatchDataFineMutuo();
				Id batchId = Database.executeBatch(myBatchObject);
            }
            
    }