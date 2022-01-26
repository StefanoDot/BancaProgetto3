@isTest
public with sharing class BP_LC_LeadConversionTest{
    private static List<Lead> leadRecords = new List<Lead>();
    private static List<Account> accountRecords = new List<Account>();
    static final Integer size = 1;
    @testSetup
    static void setUpData(){
        Lead leadRecord = leadRecordCreation();
        leadRecords.add(leadRecord);
        insert leadRecord;
    }
    static Lead leadRecordCreation(){
        Lead leadRecord = new Lead();
        leadRecord.FirstName = 'First Name';
        leadRecord.LastName = 'Last Name';
        leadRecord.LastName = 'Last Name';
        leadRecord.Email = 'test@dot.com';
        leadRecord.Company = 'DOT';
        leadRecord.Codice_Fiscale__c = '12345';
        leadRecord.Street = '2100 Woodward Ave';
        leadRecord.City = 'Detroit';
        leadRecord.State = 'New York';
        leadRecord.PostalCode = '48201';
        leadRecord.Country = 'United States';
        leadRecord.MobilePhone = '1234567890';
        return leadRecord;
    }
    @isTest
    static void getAllLeadsTest(){
        Test.startTest();
        List<Lead> leadData = new List<Lead>();
        leadData = [SELECT Id, Name FROM Lead WHERE Name = 'First Name Last Name'];
        leadRecords = BP_LC_LeadConversion.getAllLeads();
        System.assertEquals(size, leadRecords.size());
        Test.stopTest();
    }
    @isTest
    static void fetchFilteredLeadsTest(){
        Test.startTest();
        List<Lead> leadData = new List<Lead>();
        leadData = [SELECT Id, Name FROM Lead WHERE Name = 'First Name Last Name'];
        leadRecords = BP_LC_LeadConversion.fetchFilteredLeads('test@dot.com', 'Email');
        System.assertEquals(size, leadRecords.size());
        Test.stopTest();
    }
    @isTest
    static void convertLeadsToAccountsTest(){
        Test.startTest();
        List<Lead> leadData = new List<Lead>();
        leadData = [SELECT Id, Name FROM Lead WHERE Name = 'First Name Last Name'];
        BP_LC_LeadConversion.convertLeadsToAccounts(leadData);
        accountRecords = [SELECT Id, Name FROM Account];
        System.assertEquals(size, accountRecords.size());
        Test.stopTest();
    }
}