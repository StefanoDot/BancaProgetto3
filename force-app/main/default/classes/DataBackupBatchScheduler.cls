global class DataBackupBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx){
        List<String> sourceObjNames = System.Label.Data_Backup_Object_Name.split(',');
        String targetObjName = System.Label.Data_Backup_Big_Object_Name;
        for(String objName: sourceObjNames){
            DataBackupBatch batchObject = new DataBackupBatch(objName, targetObjName); 
            Id batchId = Database.executeBatch(batchObject);
        }
    }
}