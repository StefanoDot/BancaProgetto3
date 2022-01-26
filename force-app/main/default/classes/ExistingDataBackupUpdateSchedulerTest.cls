@isTest
public with sharing class ExistingDataBackupUpdateSchedulerTest{
    @isTest
    public static void testSchedule(){        
        Test.StartTest();
        ExistingDataBackupUpdateScheduler testSchedule = new ExistingDataBackupUpdateScheduler();
        testSchedule.execute(null);
        Test.stopTest();
    }
}