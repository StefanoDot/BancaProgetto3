@isTest
public with sharing class BP_LC_DownloadMassivoControllerTest {

    /*Monica sta scrivendo questo */

    @TestSetup static void createDataForGetContactListForDownloadMassivoTest(){
        Account acc = new Account();
        acc.Name = 'Nome di test';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'test 1';
        con.AccountId = acc.Id;
        insert con;
        Contact con2 = new Contact();
        con2.LastName = 'test2';
        con2.AccountId = acc.Id;
        insert con2;
        Contact con3 = new Contact();
        con3.LastName = 'test3';
        insert con3;
    }

    @isTest
    static void getContactListForDownloadMassivoTest() {
        List<Account> accountList = [SELECT Id FROM Account];
        Account singleAccount;
        
        if (accountList != null && !accountList.isEmpty()) {
            singleAccount = accountList[0];
        }

        Test.startTest();
            List<Id> contactList = BP_LC_DownloadMassivoController.getContactListForDownloadMassivo(singleAccount.Id);
        Test.stopTest();

        System.assertEquals(2, contactList.size());
    }
}