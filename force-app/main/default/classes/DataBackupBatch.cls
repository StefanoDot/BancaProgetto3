public class DataBackupBatch implements Database.Batchable<sObject>{
    String objectName;
    String bigObjectName;
    Map<String, String> sourceFieldsMap = new Map<String, String>();
    List<String> fieldsList = new List<String>();
    List<Integer> listOfIndex = new List<Integer>();
    String fieldsAPINames;
    public DataBackupBatch(String sourceObjName, String targetObjName){
        fieldsAPINames = '';
        this.objectName = sourceObjName;
        this.bigObjectName = targetObjName;
        Map<String, sObjectField> fieldInfos = schema.getGlobalDescribe().get(this.objectName).getDescribe().fields.getMap();
        for(String apiName: fieldInfos.keySet()){
            if(String.valueOf(fieldInfos.get(apiName).getDescribe().getType()) != 'TEXTAREA'){
                sourceFieldsMap.put(apiName.toLowerCase(), fieldInfos.get(apiName).getDescribe().getLabel());
                fieldsAPINames += apiName + ', ';
                fieldsList.add(apiName.toLowerCase());
            }
        } 
        if(fieldsAPINames != ''){
            fieldsAPINames = fieldsAPINames.removeEnd(', ');
        }
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = '';
        String label = System.Label.BackUp;
        if(Test.isRunningTest()){
            query = 'SELECT ' + fieldsAPINames + ' FROM ' + objectName + ' LIMIT 1';
        }
        else if (label == 'Si'){
            query = 'SELECT ' + fieldsAPINames + ' FROM ' + objectName + ' WHERE LastModifiedDate = YESTERDAY LIMIT 49999 ';
        } else if(label == 'No'){
            query = 'SELECT ' + fieldsAPINames + ' FROM ' + objectName + ' WHERE LastModifiedDate != null LIMIT 49999 ';
        }
        SYSTEM.DEBUG('QUERY BACKUP ' + query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<sObject> records){
        List<Object_Field_Information__b> backupMasterList = [SELECT Old_Column_Values__c, New_Column_Values__c, Id, Object_API_Name__c FROM Object_Field_Information__b WHERE Object_API_Name__c =: objectName];
        Object_Field_Information__b backupMasterRecord = new Object_Field_Information__b();
        List<Object_Field_Information__b> backupMasterRecords = new List<Object_Field_Information__b>();
        if(backupMasterList.size() > 0){
            List<String> apiNames = backupMasterList[0].New_Column_Values__c.split(',');
            if(!fieldsList.equals(apiNames)){
                backupMasterRecord.Object_API_Name__c = objectName;
                backupMasterRecord.Old_Column_Values__c = backupMasterList[0].New_Column_Values__c;
                backupMasterRecord.New_Column_Values__c = String.join(fieldsList, ',');
            }
        }
        else{
            backupMasterRecord.Object_API_Name__c = objectName;
            backupMasterRecord.New_Column_Values__c = String.join(fieldsList, ',');
        }
        backupMasterRecords.add(backupMasterRecord);
        if(backupMasterRecords.size() > 0){
            try{
                if(!Test.isRunningTest()){
                    database.insertImmediate(backupMasterRecords);
                }
            }
            catch(Exception ex){
                System.debug('Some error has occured: ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            }
        }
        List<sObject> dataBackupRecords = new List<sObject>();
        for(sObject record: records){
            List<String> listOfValue = new List<String>();
            sObject dataBackupRecord = Schema.getGlobalDescribe().get(bigObjectName).newSObject();
            for(String fieldAPIName: sourceFieldsMap.keySet()){
                if(String.isEmpty(String.valueOf(record.get(fieldAPIName)))){
                    listOfValue.add('null');
                }
                else{
                    listOfValue.add(String.valueOf(record.get(fieldAPIName)));
                }
            }
            dataBackupRecord.put('Record_Id__c', record.get('Id'));
            dataBackupRecord.put('Column_Values__c', String.join(listOfValue, '(*_*)'));
            dataBackupRecord.put('Object_Name__c', objectName);
            dataBackupRecords.add(dataBackupRecord);
        }
        if(!dataBackupRecords.isEmpty()){
            try{
                if(!Test.isRunningTest()){
                    database.insertImmediate(dataBackupRecords);
                }
            }
            catch(Exception ex){
                System.debug('Some error has occured: ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            }
        }
    }
    public void finish(Database.BatchableContext bc){
    }
}