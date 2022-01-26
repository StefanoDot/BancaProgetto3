@istest
public with sharing class DataBackupBatchSchedulerTest{
    public static testMethod void testSchedule(){
        Account acc = new Account();
        acc.Name = 'Amazon';
        insert acc;
        Test.StartTest();
        DataBackupBatchScheduler sch = new DataBackupBatchScheduler();
        sch.execute(null);
        System.assertEquals(acc.Name, 'Amazon');
        Test.stopTest();
    }
}