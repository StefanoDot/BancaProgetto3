/**
 * Created by ACAPUTO00 on 21/01/2020.
 */

@isTest
private class ElevaServiceLightningControllerTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    

    static testMethod void testGetMoreScore(){
        
        Switch_Validation__mdt testtt= ElevaServiceLightningControllerTest.generateMetadataValidation();

        ElevaCredentials__mdt mcmd = new ElevaCredentials__mdt(
                DeveloperName = 'ElevaMoon',
                endpoint__c = 'smelending/morescore',
                x_api_key__c = 'key',
                x_app_language__c = 'it',
                x_caller_id__c = 'SALESFORCE',
                x_channel__c = 'EXT',
                x_hmac__c = 'xhmac');

        account acc = ObjectFactory.insertNewAccount();
        acc.Data_Aggiornamento_MoreScore__c=date.today();
        update acc;
        Test.startTest();
        ElevaServiceLightningController.aggiornaMoreScore(acc.id, 'test', 'aldora','test');
      ElevaServiceLightningController.moreScore(acc.id);
        Test.stopTest();

    }

}