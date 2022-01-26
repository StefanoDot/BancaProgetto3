@isTest
public class BP_LC_SalesAssignmentTest {
    
    @isTest
    public static void testStoricoFaseManager(){
        
        Test.startTest();
        
        	Matrice_di_Assegnazione__c oMat = new Matrice_di_Assegnazione__c();
        	oMat.Sales_di_Riferimento__c = system.UserInfo.getUserId();
        	oMat.Codice_Provincia__c = 'PV';
        	oMat.Provincia__c = 'PV';
        	insert oMat;
        
        	Lead oLead = new Lead();
            oLead.Email = 'test@testing.com';
            oLead.Company = 'test';
            oLead.Codice_Fiscale__c = '546432211';
            oLead.Status = 'Nuovo';
            oLead.FirstName = 'test';
            oLead.LastName = 'last name';
            oLead.MobilePhone = '9754321909';
            oLead.State = 'New York';
            oLead.Country = 'United States';
            oLead.Street = 'New Street';
            oLead.City = 'New York';
            oLead.PostalCode = '1234';
        	oLead.Sigla_Provincia__c = 'PV';
        	insert oLead;
        
        	oLead.Sigla_Provincia__c = 'MB';
        	update oLead;
        	
        Test.stopTest();

        
    }

}