/**
 * Created by ACAPUTO00 on 05/03/2020.
 */

@isTest
public with sharing class CalloutLoggerServiceTest {

    @isTest static void testSaveCalloutLogger(){
        Test.startTest();
        CalloutLoggerService.saveCalloutLogger('', '', '', '', '', '', '');
        Test.stopTest();
    }

}