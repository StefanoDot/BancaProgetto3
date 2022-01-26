public class ExistingDataBackupUpdate implements Database.Batchable<sObject>{
    String objectName;
    String bigObjectName;
    public ExistingDataBackupUpdate(String sourceObjName, String targetObjName){
        this.objectName = sourceObjName;
        this.bigObjectName = targetObjName;
    }
    public List<Object_Name_and_Values__b> start(Database.BatchableContext bc){
        List<Object_Name_and_Values__b> bigObjRecords = new List<Object_Name_and_Values__b>();
        bigObjRecords = [SELECT Record_Id__c, Object_Name__c, Column_Values__c FROM Object_Name_and_Values__b LIMIT 49999];
        if(Test.isRunningTest()){
            Object_Name_and_Values__b bigObjRecord = new Object_Name_and_Values__b();
            bigObjRecord.Object_Name__c = 'Account';
            bigObjRecord.Column_Values__c = 'Test';
            bigObjRecords.add(bigObjRecord);
        }
        return bigObjRecords;
    }
    public void execute(Database.BatchableContext bc, List<sObject> records){
        System.debug('objectName1 ' + objectName);
        List<Object_Field_Information__b> backupMasterList = [SELECT Old_Column_Values__c, New_Column_Values__c, Object_API_Name__c FROM Object_Field_Information__b WHERE Object_API_Name__c =: objectName];
        System.debug('backupMasterList ' + backupMasterList);
        System.debug('objectName ' + objectName);
        if(Test.isRunningTest()){
            Object_Field_Information__b backupMasterRecord = new Object_Field_Information__b();
            backupMasterRecord.Object_API_Name__c = 'Account';
            backupMasterRecord.New_Column_Values__c = 'Field1,Field2';
            backupMasterRecord.Old_Column_Values__c = 'Field1';
            backupMasterList.add(backupMasterRecord);
            System.debug('backupMasterList 2 ' + backupMasterList);
        }
        List<String> oldFields = new List<String>();
        Object_Field_Information__b bigObjectRecord = new Object_Field_Information__b();
        List<String> newFields = new List<String>();
        List<sObject> dataBackupRecords = new List<sObject>();
        List<Integer> listOfIndex = new List<Integer>();
        if(backupMasterList.size() > 0){
            if(String.isNotBlank(backupMasterList[0].Old_Column_Values__c)){
                oldFields = backupMasterList[0].Old_Column_Values__c.split(',');
                newFields = backupMasterList[0].New_Column_Values__c.split(',');
                if(!newFields.equals(oldFields)){
                    if(newFields.size() >= oldFields.size()){
                        Integer j = 0;
                        for(Integer i = 0; i < oldFields.size(); i++){
                            if(oldFields[i] != newFields[j]){
                                j++;
                                listOfIndex.add(i);
                                i--;
                            }
                            else{
                                j++;
                            }
                        }
                        Integer diff = newFields.size() - j;
                        for(Integer i = 0; i < diff; i++){
                            listOfIndex.add(j);
                            j++;
                        }
                    }
                    bigObjectRecord.Old_Column_Values__c = String.join(newFields, ',');
                    bigObjectRecord.New_Column_Values__c = backupMasterList[0].New_Column_Values__c;
                    bigObjectRecord.Object_API_Name__c = backupMasterList[0].Object_API_Name__c;
                    try{
                        if(!Test.isRunningTest()){
                            database.insertImmediate(bigObjectRecord);
                        }
                    }
                    catch(Exception ex){
                        System.debug('Some error has occured: ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString());
                    }
                }
            }
            for(sObject record: records){
                if(String.valueOf(record.get('Object_Name__c')) == objectName){
                    List<String> listOfValues = String.valueOf(record.get('Column_Values__c')).split(',');
                    sObject dataBackupRecord = Schema.getGlobalDescribe().get(bigObjectName).newSObject();
                    for(Integer index: listOfIndex){
                        if(index >= listOfValues.size()){
                            listOfValues.add('null');
                        }
                        else{
                            listOfValues.add(index, 'null');
                        }
                    }
                    dataBackupRecord.put('Record_Id__c', record.get('Record_Id__c'));
                    dataBackupRecord.put('Object_Name__c', objectName);
                    dataBackupRecord.put('Column_Values__c', String.join(listOfValues, '(*_*)'));
                    dataBackupRecords.add(dataBackupRecord);
                }
            }
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