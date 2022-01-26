@isTest
public with sharing class BP_LC_ServicesToastTest{
    private static Account accountRecord = new Account();
    private static Contact contactRecord = new Contact();
    private static Campaign campaignRecord = new Campaign();
    private static CampaignMember campaignMemberRecord = new CampaignMember();
    private static Opportunity opportunityRecord = new Opportunity();
    @testSetup
    static void setUpData(){
        accountRecord = accountRecordCreation();
        insert accountRecord;
        
        contactRecord = contactRecordCreation();
        contactRecord.AccountId = accountRecord.Id;
        insert contactRecord;
        
        campaignRecord = campaignRecordCreation();
        insert campaignRecord;
        
        campaignMemberRecord = campaignMemberRecordCreation();
        campaignMemberRecord.ContactId = contactRecord.Id;
        campaignMemberRecord.CampaignId = campaignRecord.Id;
        campaignMemberRecord.AccountId = accountRecord.Id;
        insert campaignMemberRecord;
        
        opportunityRecord = opportunityRecordCreation();
        opportunityRecord.AccountId = accountRecord.Id;
        insert opportunityRecord;
    }
    static Account accountRecordCreation(){
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        return accountRecord;
    }
    static Opportunity opportunityRecordCreation(){
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.CloseDate = Date.newInstance(2031, 12, 31);
        opportunityRecord.StageName = 'Primo Contatto';
        opportunityRecord.Forecast_Category_Custom__c = 'Certo'; 
        opportunityRecord.Tipo_Linea_di_Credito__c = 'Mutuo';
        opportunityRecord.Finalita_Finanziamento__c = 'Investimento';
        opportunityRecord.Sabatini_Applicabile__c = 'No';
        opportunityRecord.Ammontare_Iniziale__c = 1.5;
        return opportunityRecord;
    }
    static Contact contactRecordCreation(){
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Robin'; 
        contactRecord.LastName = 'Koehler';
        return contactRecord;
    }
    static Campaign campaignRecordCreation(){
        Campaign campaignRecord = new Campaign();
        campaignRecord.Name = 'Test';
        campaignRecord.isActive = TRUE;
        return campaignRecord;
    }
    static CampaignMember campaignMemberRecordCreation(){
        CampaignMember campaignMemberRecord = new CampaignMember();
    	campaignMemberRecord.Status = 'Sent';
        return campaignMemberRecord;
    }
    @isTest
    static void getAllCampaignNamesTest(){
        Test.startTest();
        Opportunity oppRecord = new Opportunity();
        oppRecord = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
        BP_LC_ServicesToast.getAllCampaignNames(oppRecord.Id);
        Test.stopTest();
    }
    @isTest
    static void  validatePrimaryCampaignSourceTest(){
        Test.startTest();
        Opportunity oppRecord = new Opportunity();
        oppRecord = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
        BP_LC_ServicesToast.validatePrimaryCampaignSource(oppRecord.AccountId);
        Test.stopTest();
    }
}