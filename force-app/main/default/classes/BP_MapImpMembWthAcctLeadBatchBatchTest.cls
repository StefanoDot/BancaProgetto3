@isTest
public class BP_MapImpMembWthAcctLeadBatchBatchTest {

    @isTest
    public static void testBatch(){
        
        Test.startTest();
        
        Account ac = new Account();
        ac.Name = 'test account';
        ac.Codice_Fiscale__c = 'ABCDEFGH';
        insert ac;
        
        Campaign ocamp = new Campaign();
        ocamp.name = 'test';
        insert ocamp;
        
        Import_Membri__c imp = new Import_Membri__c();
        imp.Campaign__c = ocamp.Id;
        imp.Email__c = 't@g.com';
        imp.First_Name__c = 'fname';
        imp.Last_Name__c = 'lname';
        imp.Company__c = 'abc';
        imp.City__c = 'test';
        imp.Street__c = 'test street';
        imp.State_Province__c = 'New York';
        imp.Mobile__c = '123456789';
        imp.Country__c = 'United States';
        imp.Oplon_Codice_Fiscale__c = 'ABCDEFGH';
        imp.Zip_Postal_Code__c = '1234345';
        insert imp;
        
        Test.stopTest();
    }
}