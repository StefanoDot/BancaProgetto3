@isTest
public class BP_BTH_OpportunityCloseDateScheduleTest {
    
     @isTest
    public static void testschedule() {
        
        Test.StartTest();
        BP_BTH_OpportunityCloseDateSchedule sh1 = new BP_BTH_OpportunityCloseDateSchedule();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, sh1); 
        Test.stopTest(); 
    }

}