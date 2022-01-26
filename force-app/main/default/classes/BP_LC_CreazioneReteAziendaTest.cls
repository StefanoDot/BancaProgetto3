@isTest
public with sharing class BP_LC_CreazioneReteAziendaTest{

    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        Profile p = [SELECT Id From Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'newUser1', 
                      Email = 'newuser123@testorg.com',
                      EmailEncodingKey = 'UTF-8',
                      LastName = 'Testing',
                      LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US', 
                      username = 'ownerIdErrorFix@testorg.com',
                      ProfileId = p.Id,
                      TimeZoneSidKey = 'America/Los_Angeles');
        insert u;
        OpportunityController.bypassTrigger = true;
        Account acc = ObjectFactory.generateAccount();
        acc.Tipo_di_Azienda__c = 'DI';
        acc.Oplon_Natura_Giuridica__c = 'SC';
        acc.OwnerId = u.Id;
        insert acc;
        Contact contTest = new Contact(
            FirstName = 'testName',
            LastName = 'testLastName',
            AccountId = acc.Id,
            Stato_Nascita__c = 'Italia',
            Residenza__c = 'Italia',
            Comune__c = 'SAN MARTINO SICCOMARIO',
            NDG__c = 'ndg',
            Interessato__c = true,
            Esecutore__c = true,
            RecordTypeId = recordTypeIdRefOpl,
            Ruolo_in_Azienda__c = 'Titolare Effettivo'
        );
        insert contTest;
        Opportunity opp = new Opportunity(AccountId = acc.Id,
                                          Name = 'Test',
                                          CloseDate = Date.today() + 1,
                                          StageName = constants.OPPORTUNITY_PRIMO_CONTATTO,
                                          Forecast_Category_Custom__c = 'Elevata Probabilità',
                                          Tipo_Linea_di_Credito__c = 'Mutuo',
                                          Finalita_Finanziamento__c = 'Liquidità',
                                          Ammontare_Iniziale__c = 1000,
                                          Durata_Partner__c = 100,
                                          Linea_di_Credito_in_Mesi__c = 20,
                                          Data_Stipula__c = Date.today(),
                                          Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',                              
                                          Sales_Support_Approver__c = ObjectFactory.aldora.Id,
                                          Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.Id,  
                                          Sabatini_Applicabile__c = 'Si');
        insert opp;
        OpportunityController.bypassTrigger = false;
    }
    
    @isTest static void BP_OUT_CRATest(){

        List<Opportunity> oppList = [SELECT id FROM Opportunity];

		Test.setMock(HttpCalloutMock.class, new API_ResponseMock());
        Test.startTest();
            BP_LC_CreazioneReteAzienda.BP_OUT_CRA(oppList[0].Id);      
        Test.stopTest();
    }

    
    @isTest static void BP_OUT_CRATest2(){
        
        List<Account> listAccount = [SELECT Id, Oplon_Natura_Giuridica__c FROM Account];
        List<Account> listAccount1 = new List<Account>();

        for (Account acc : listAccount) {
            Account acc1 = new Account();
            acc1.id = acc.id;
            acc1.Oplon_Natura_Giuridica__c = 'SP';
            listAccount1.add(acc1);
        }
        update listAccount1;

        List<Opportunity> oppList = [SELECT id FROM Opportunity];
		Test.setMock(HttpCalloutMock.class, new API_ResponseMock());
        Test.startTest();
            BP_LC_CreazioneReteAzienda.BP_OUT_CRA(oppList[0].Id);      
        Test.stopTest();
    }
    
    public class API_ResponseMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"opportunityId":"0061x00000L70j2AAB","ndgAccount":"1102722","legalRepresentatives":[],"beneficialOwners":[]}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    @isTest static void getOpportunityDetailsTest(){
        List<Opportunity> oppList = [SELECT id FROM Opportunity];
        Test.startTest();
        BP_LC_CreazioneReteAzienda.getOpportunityDetails(oppList[0].Id);
        BP_LC_CreazioneReteAzienda.contactValidation(oppList[0].Id);
        Test.stopTest();
    }
}