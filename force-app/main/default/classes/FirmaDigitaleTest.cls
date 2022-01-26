@isTest
private class FirmaDigitaleTest {
        @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    
    @isTest static void getListaReferentiFirmatariTest() {
        Switch_Validation__mdt testtt= FirmaDigitaleTest.generateMetadataValidation();

       // List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Inside_Sales_1'];

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();

        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c = ObjectFactory.aldora.Id
        );
        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25), amount = 100, Probability = 5);
        insert opp;
        Contact con = new Contact(Email = 'bbbbb@bbb.it', Phone = '3213214321321321', LastName = 'aasasas',
                FinServ__EmailVerified__c = True, FinServ__MobileVerified__c = True);
        insert con;
        List<Contact> listaRef = new List<Contact> ();
        List<Contact> datiRef = new List<Contact> ();
        Test.startTest();
        datiRef = FirmaDigitaleHandler.getViewDati(acc.Id);
        listaRef = FirmaDigitaleHandler.getListaReferentiFirmatari(opp.Id);
        Test.stopTest();
        // List<Contact> listaIs= new List<Contact> ();
        //     listaIs.add(new Contact(AccountId=acc.id, Email=con.email , Phone= con.phone,
        //             FinServ__EmailVerified__c=con.FinServ__EmailVerified__c,FinServ__MobileVerified__c=con.FinServ__MobileVerified__c));
        // system.assertEquals(listaIs, listaref);

    }

    @isTest static void testUtils() {
                Switch_Validation__mdt testtt= FirmaDigitaleTest.generateMetadataValidation();


       // List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Inside_Sales_1'];

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();

        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                    Inside_Sales_di_riferimento__c = ObjectFactory.aldora.Id
        );

        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25), amount = 100, Probability = 5);
        insert opp;

        Test.startTest();
        FirmaDigitaleHandler.getListaReferentiFirmatari(opp.Id);
        FirmaDigitaleHandler.getViewDati(acc.Id);
        FirmaDigitaleHandler.getIdAccount(opp.Id);
        Test.stopTest();

    }


}