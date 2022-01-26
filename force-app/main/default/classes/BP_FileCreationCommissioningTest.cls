@isTest
public with sharing class BP_FileCreationCommissioningTest {
    @isTest
    public static void createFileTest() {
        Opportunity o = ObjectFactory.insertNewOpportunity();
        String filename = 'Test';
        String filebody = 'Test';
        BP_CommissioningController.CommissioningFileWrapper Bpc = new BP_CommissioningController.CommissioningFileWrapper(o.Id, o.ownerId, filename, filebody);

        Test.startTest();
        ContentDocumentLink cDocLink = BP_FileCreationCommissioning.createFile(Bpc);
        System.assertEquals(true, cDocLink != null);
        Test.stopTest();
    }
}