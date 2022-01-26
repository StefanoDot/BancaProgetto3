/**
 * Created by AFREGNAN01 on 11/06/2019.
 */

@isTest
public with sharing class AccountsControllerTest {
      
    @isTest static Switch_Validation__mdt generateMetadata(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }
    @isTest static void testSearchAccount() {
            Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();
        String name = 'Fogliani SpA';
        String partitaIva = '39994902359';
        String codiceFiscale = '39994902359';
        String telefono = '0284292823';

        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.Partita_Iva__c = partitaIva;
        newAccount.Codice_Fiscale__c = codiceFiscale;
        newAccount.Phone = telefono;
        newAccount.BillingPostalCode = '20135';
        
         String name1 = 'A.A. MODELLERIA S.R.L.';
        String partitaIvaa = '09972390018';
        String codiceFiscalee = '09972390018';
        String telefonoo = '323424243';

        Account accn = new Account();
        accn.Name = name1;
        accn.Partita_Iva__c = partitaIvaa;
        accn.Codice_Fiscale__c = codiceFiscalee;
        accn.Phone = telefonoo;
       accn.BillingPostalCode = '10128'; 
         
        accn.owner=ObjectFactory.aldora;

        Matrice_Di_Assegnazione__c ma = new Matrice_Di_Assegnazione__c();
        ma.CAP__c = '20135';
        ma.Codice_Provincia__c = 'MI';
        ma.Codice_Comune__c = 'MI146';
        
        
         Matrice_Di_Assegnazione__c mai = new Matrice_Di_Assegnazione__c();
        mai.CAP__c = '10128';
        mai.Codice_Provincia__c = 'TO';
        mai.Codice_Comune__c = 'TORINO';

        insert ma;
      //  INSERT mai;
        insert newAccount;
       insert accn;
		
        Test.startTest();

        AccountsController.searchAccount(name, partitaIva, codiceFiscale, telefono);
         AccountsController.getredirectToAccountCreation();
        AccountsController.searchAccount(name1, partitaIvaa, codiceFiscalee, telefonoo);

        Test.stopTest();
        
    }

    @isTest static void testAssignToCurrentUser() {
            Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        String name = 'Fogliani SpA';
        String partitaIva = '39994902359';
        String codiceFiscale = '39994902359';
        String telefono = '0284292823';

        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.Partita_Iva__c = partitaIva;
        newAccount.Codice_Fiscale__c = codiceFiscale;
        newAccount.Phone = telefono;
        newAccount.BillingPostalCode = '20135';

      
     /*    String namee = 'ACQUA DI MARE S.R.L.';
        String partitaIva1 = '00872800941';
        String codiceFiscale2 = '300872800941';
        String telefono3 = '0284292824';

        Account alb = new Account();
        alb.Name = namee;
        alb.Partita_Iva__c = partitaIva1;
        alb.Codice_Fiscale__c = codiceFiscale2;
        alb.Phone = telefono3;
        alb.BillingPostalCode = '20132';*/

        insert newAccount;
       // insert alb;
        
        
        Test.startTest();
        
        String accId = Id.valueOf(newAccount.Id);
        
        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'Inside Sales'];
        User usrInsSal = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduserinssales@testorg.com');
        insert usrInsSal ;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agente'];
        User usr = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduseragente@testorg.com',
                ManagerId = usrInsSal.Id);
        insert usr ;
		
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Manager_NomeCompleto__c = usr.Id
              //  Inside_Sales_di_riferimento__c = usrInsSal.Id
        	);

      /*  System.runAs(usr) {
            accTest.OwnerId = usr.Id;
          //  insert accTest;*/
            
            
             AccountsController.assignToCurrentUser(accId);
             AccountsController.assignToCurrentUser(accId);
      //   }

        Test.stopTest();
    }
    
    
	
   /* @isTest static void testAssignToCurrentUserPort() {

		Test.startTest();
         Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Account acc1 = new Account (
        Name = 'newAcc1'
        );  
        
        insert acc1;
        
        String accId = Id.valueOf(acc1.Id);
        
        Contact conCase = new Contact (
        AccountId = acc1.id,
        LastName = 'portalTestUserv1'
        );
        insert conCase;
        //Create user

        Profile prfile = [select Id,name from Profile where UserType in :customerUserTypes limit 1];

        User newUser1 = new User(
        profileId = prfile.id,
        username = 'newUser@yahoo.com',
        email = 'pb@f.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = conCase.id
        );
        insert newUser1;
        
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Manager_NomeCompleto__c = newUser1.Id
        	);
        
        System.runAs(newUser1) {
            accTest.OwnerId = newUser1.Id;
            insert accTest;
            
            
             AccountsController.assignToCurrentUser(accId);
         }
        Test.stopTest();
     }*/

  /*  @isTest static void TestTriggerHandlerAssignLeadsCap() {
        List<Lead> listLead = new List<Lead>();
        Lead l = new Lead();

        l.Email = 'info@info.it';
        l.PostalCode = '20135';
        l.StateCode = 'MI';
        l.State = 'Milano';

        Matrice_Di_Assegnazione__c ma = new Matrice_Di_Assegnazione__c();
        ma.CAP__c = '20135';
        ma.Codice_Provincia__c = 'MI';
        ma.Codice_Comune__c = 'MI146';

        insert ma;

        listLead.add(l);

        String jsonLeads = JSON.serialize(listLead);

        Test.startTest();
        LeadsController.triggerHandlerAssignLeads(jsonLeads);
        Test.stopTest();
    }

    @isTest static void TestTriggerHandlerAssignLeadsMap() {


        Matrice_Di_Assegnazione__c ma2 = new Matrice_Di_Assegnazione__c();
        ma2.CAP__c = '';
        ma2.Codice_Provincia__c = 'RM';
        ma2.Codice_Comune__c = 'RM005';
        ma2.Regione__c = 'Lazio';
        ma2.Provincia__c = 'Roma';

        insert ma2;

        Matrice_Di_Assegnazione__c ma3 = new Matrice_Di_Assegnazione__c();
        ma3.CAP__c = '';
        ma3.Codice_Provincia__c = 'RM';
        ma3.Codice_Comune__c = 'RM005';
        ma3.Regione__c = 'Emilia-Romagna';
        ma3.Provincia__c = 'Rimini';

        insert ma3;

        List<Lead> listLead2 = new List<Lead>();
        Lead l2 = new Lead();
        l2.Email = 'info@info.it';
        l2.PostalCode = '';
        l2.StateCode = 'RM';
        l2.State = 'Roma';
        listLead2.add(l2);
        String jsonLeads2 = JSON.serialize(listLead2);

        List<Lead> listLead3 = new List<Lead>();
        Lead l3 = new Lead();
        l3.Email = 'giovanni@info.it';
        l3.PostalCode = '';
        l3.StateCode = 'RI';
        l3.State = 'Rimini';
        listLead3.add(l3);
        String jsonLeads3 = JSON.serialize(listLead3);

        Test.startTest();
        LeadsController.triggerHandlerAssignLeads(jsonLeads2);
        LeadsController.triggerHandlerAssignLeads(jsonLeads3);
        Test.stopTest();
    }*/

    @isTest static void TestTriggerHandlerGetMoreScore() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX'
        );
        Test.startTest();
        insert accTest;
        Test.stopTest();
    }

    @isTest static void TestTriggerHandlerGetAnagraphicDetails() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C'
        );
        insert accTest;
        Test.startTest();
        accTest.MoreScore__c = 'B';
        
        update accTest;
        Test.stopTest();
    }

    @isTest static void TestNotifyMissingFields() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();


        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();

        

        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'Inside Sales'];
        User usrInsSal = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduserinssales@testorg.com');
        insert usrInsSal ;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agente'];
        User usr = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduseragente@testorg.com',
                ManagerId = usrInsSal.Id);
        insert usr ;
        
System.runAs(usr) {
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Manager_NomeCompleto__c = usr.Id,
                Inside_Sales_di_riferimento__c = usrInsSal.Id
        );

        
            accTest.OwnerId = usr.Id;
            insert accTest;
            Contact contTest = new Contact(
                    FirstName = 'testName',
                    LastName = 'testLastName',
                    AccountId = accTest.Id,
                    RecordTypeId = recordTypeIdRefOpl,
                    Stato_Nascita__c = 'Italia',
                    Residenza__c = 'Italia',
                Esecutore__c = true
            );
            Contact contTest2 = new Contact(
                    FirstName = 'testName2',
                    LastName = 'testLastName2',
                    AccountId = accTest.Id,
                    RecordTypeId = recordTypeIdRefOpl,
                    Stato_Nascita__c = 'Estero',
                    Residenza__c = 'ITALIA',
                Esecutore__c = true
            );
            insert contTest;
            insert contTest2;
            List<Account> accounts = new List<Account>{
                    accTest
            };           
                
            Test.startTest();
           		 AccountsController.notifyMissingFields(accounts);
               AccountsController.ncgCambiaMorescore(accounts);

            Test.stopTest();
        }
    }

    @isTest static void TestNotifyMissingFieldsForOpportunity() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();

        Test.startTest();

        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'Inside Sales'];
        User usrInsSal = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduserinssales@testorg.com');
        insert usrInsSal ;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agente'];
        User usr = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduseragente@testorg.com',
                ManagerId = usrInsSal.Id);
        insert usr ;

        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Manager_NomeCompleto__c = usr.Id,
                Inside_Sales_di_riferimento__c = usrInsSal.Id
        );

        System.runAs(usr) {
            accTest.OwnerId = usr.Id;
            insert accTest;
            Contact contTest = new Contact(
                    FirstName = 'testName',
                    LastName = 'testLastName',
                    AccountId = accTest.Id,
                    RecordTypeId = recordTypeIdRefOpl,
                    Stato_Nascita__c = 'Italia',
                    Residenza__c = 'Italia'
            );
            Contact contTest2 = new Contact(
                    FirstName = 'testName2',
                    LastName = 'testLastName2',
                    AccountId = accTest.Id,
                    RecordTypeId = recordTypeIdRefOpl,
                    Stato_Nascita__c = 'Estero',
                    Residenza__c = 'Italia'
            );
            insert contTest;
            insert contTest2;
            List<Account> accounts = new List<Account>{
                    accTest
            };
            Opportunity opp = new Opportunity(
                    AccountId = accTest.Id
            );
            List<Opportunity> opps = new List<Opportunity>{
                    opp
            };
           //AccountsController.notifyMissingFieldsForOpportunityService(opps);
            Test.stopTest();
        }
    }

    @isTest static void testCheckComune() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        
        Matrice_di_Assegnazione__c mda = new Matrice_di_Assegnazione__c(
                Name = 'SAN MARTINO SICCOMARIO',
                Codice_Provincia__c = 'PV',
                CAP__c = '27028',
                Regione__c = 'Lombardia',
                Provincia__c = 'Pavia'
        );
        insert mda;
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Comune__c = 'SAN MARTINO SICCOMARIO'
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'C',
                Comune__c = 'PALERMO DUGNANO'
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;
        
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl
        );
        Contact contTest2 = new Contact(
                FirstName = 'testName2',
                LastName = 'testLastName2',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Estero',
                Residenza__c = 'Italia',
                Comune__c = '',
                RecordTypeId = recordTypeIdRefOpl
        );
        List<Contact> contacts = new List<Contact>{contTest, contTest2};
        insert contacts;
        
        Test.startTest();
        AccountsController.checkComune(accounts);
      //  AccountsController.checkComuneService(accounts);
        Test.stopTest();
    }

    @isTest static void testGetAccountsFromId(){
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();


        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Matrice_di_Assegnazione__c mda = new Matrice_di_Assegnazione__c(
                Name = 'SAN MARTINO SICCOMARIO',
                Codice_Provincia__c = 'PV',
                CAP__c = '27028',
                Regione__c = 'Lombardia',
                Provincia__c = 'Pavia'
        );
        insert mda;
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Comune__c = 'SAN MARTINO SICCOMARIO'
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'C',
                Comune__c = 'PALERMO DUGNANO'
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;

        List<String> fields = new List<String>{'Name'};
        Set<String> accIds = new Set<String>{accTest.Id,accTest2.Id};

        Test.startTest();
        AccountsDAO.getAccountFromIds(fields, accIds);
        Test.stopTest();

    }
    
    @isTest static void testDocumentazioneFidejusore() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Comune__c = 'SAN MARTINO SICCOMARIO'
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'C',
                Comune__c = 'PALERMO DUGNANO'
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;
        
        DocumentType__c docType = new DocumentType__c(Document_Block__c='Documenti ufficiali',DocumentApiName__c='Doc_Test__c', ObjectName__c = 'Account');
        insert docType;
        
         Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
        d.Account__c=accTest2.id;
        
		insert d;
        
        DocumentType__c docType2 = new DocumentType__c(Document_Block__c='Documenti ufficiali',DocumentApiName__c='Doc_Test2__c', ObjectName__c = 'Account', Referente_Fidejussore__c = true);
        insert docType2;
        
         Document__c d1 = new Document__c();
        d1.Name='test';
        d1.DocumentType__c=docType2.id;
        d1.Id_File__c='0691w0000010Rs9AAE';
        d1.Commento_Sales_Support__c='testtt';
        d1.Account__c=accTest.id;
        
		insert d1;
        
		Test.startTest();
        AccountsController.DocumentazioneFidejusore(accounts);
        Test.stopTest();        
    }
    
    @isTest static void testNotifyMissingFieldsServiceFidejusione() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        
        User u1 = ObjectFactory.createNewUser('test1@aldora.com', 'test1@gmail.com');
        User u2 = ObjectFactory.createNewUser('test2@aldora.com', 'test2@gmail.com');

         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
              Inside_Sales_di_riferimento__c=u1.id,
            Manager_NomeCompleto__c=u2.Id,
                Comune__c = 'SAN MARTINO SICCOMARIO',
             	campi_mancanti_fidejussione__c = ''
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
             Inside_Sales_di_riferimento__c=u2.id,
            Manager_NomeCompleto__c=u1.id,
            
                MoreScore__c = 'C',
                Comune__c = 'PALERMO DUGNANO'
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;
        
        
        
        Test.startTest();
        AccountsController.notifyMissingFieldsServiceFidejusione(accounts);
        Test.stopTest();      
    }
    
    @isTest static void testCollegamentoInsideSales() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'A',
                Comune__c = 'SAN MARTINO SICCOMARIO'
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'C',
           
                Comune__c = 'PALERMO DUGNANO'
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;
        
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'OpportunityTEst';
        oppTest.CloseDate = Date.today();
        oppTest.StageName = 'Primo Contatto';
        oppTest.Forecast_Category_Custom__c = 'Certo';
        oppTest.Tipo_Linea_di_Credito__c = 'Mutuo';
        oppTest.Ammontare_Iniziale__c        = 200;
        oppTest.Durata_Partner__c = 10;
        oppTest.AccountId = accTest.Id;
        
        insert oppTest;
        
        Test.startTest();
        AccountsController.collegamentoInsideSales(accounts);
        Test.stopTest();
    }
    
    @isTest static void testActionBeforeUpdate() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

         Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
             	Ricezione_Dati_Oplon__c = 'Ok Light',
                Comune__c = 'SAN MARTINO SICCOMARIO',
             	Fidejussore__c = true
        );
        
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'A',
            Ricezione_Dati_Oplon__c = 'Ko Light',
                Comune__c = 'PALERMO DUGNANO'
        );
        
        Account accTest3 = new Account(
                Name = 'testTest3',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'A',
             	Ricezione_Dati_Oplon__c = 'Ok Light',
                Comune__c = 'SAN MARTINO SICCOMARIO',
             	Fidejussore__c = true
        );
        List<Account> accounts = new List<Account>{accTest, accTest2, accTest3};
        insert accounts;
        
        Map<Id, Account> oldAccMap = new Map<Id, Account>();
        Account accTestOld = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
             	Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'SAN MARTINO SICCOMARIO'
        );
        Account accTestOld2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'A',
            Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO'
        );
        Account accTestOld3 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'A',
                Comune__c = 'PALERMO DUGNANO'
        );
		oldAccMap.put(accTest.Id, accTestOld);
		oldAccMap.put(accTest2.Id, accTestOld2);
        oldAccMap.put(accTest3.Id, accTestOld3);
        
        Test.startTest();
        AccountsController.ActionBeforeUpdate(accounts, oldAccMap);
        Test.stopTest();
    }
    
    @isTest static void afterUpdate() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
             User u1 = ObjectFactory.createNewUser('test11@aldora.com', 'test3@gmail.com');
        User u2 = ObjectFactory.createNewUser('test23@aldora.com', 'test4@gmail.com');

         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
             	Ricezione_Dati_Oplon__c = 'Ok Light',
                Comune__c = 'SAN MARTINO SICCOMARIO',
             Inside_Sales_di_riferimento__c=u1.id,
            Manager_NomeCompleto__c=u2.id,
             Fidejussore__c = false
        );
        
        insert accTest;
        
        Account accountToUpdate = 
        [SELECT MoreScore__c, Comune__c, Fidejussore__c FROM Account 
         WHERE Id = :accTest.Id
         LIMIT 1];
        
        accountToUpdate.MoreScore__c = 'D';
        accountToUpdate.Comune__c    = '';
        accountToUpdate.Ricezione_Dati_Oplon__c = 'Ok Full';
        accountToUpdate.Fidejussore__c = true;
        
        update accountToUpdate;
        }
    
    @isTest static void testAssignAccounts() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        
		Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'Inside Sales'];
        User usrInsSal = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'TestingInsSal', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pInsSal.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduserinssales@testorg.com');
        insert usrInsSal ;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agente'];
        User usr = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduseragente@testorg.com',
                ManagerId = usrInsSal.Id);
        insert usr ;
        
        
        String name = 'Fogliani SpA';
        String partitaIva = '39994902359';
        String codiceFiscale = '39994902359';
        String telefono = '0284292823';

        Account accTest = new Account();
        accTest.Name = name;
        accTest.Partita_Iva__c = partitaIva;
        accTest.Codice_Fiscale__c = codiceFiscale;
        accTest.Phone = telefono;
        accTest.BillingPostalCode = '20135';
        accTest.OwnerId = usr.Id;
        accTest.Canale__C = 'Agente';
		
        
        Matrice_Di_Assegnazione__c ma = new Matrice_Di_Assegnazione__c();
        ma.CAP__c = '20135';
        ma.Codice_Provincia__c = 'MI';
        ma.Codice_Comune__c = 'MI146';
		
        List<Account> accounts = new List<Account>{accTest};
        
        insert ma;
        insert accounts;
        
        Test.startTest();        
        AccountsController.assignAccounts(accounts);
        Test.stopTest();
    }
    
    @isTest static void testTriggerHandlerAssignAccounts() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Comune__c = 'SAN MARTINO SICCOMARIO',
             	BillingStreet = 'Test Street'
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'C',
                Comune__c = 'PALERMO DUGNANO'
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;
        
        Map<Id, Account> oldMap = new Map<Id, Account>();
		oldMap.put(accTest.Id, accTest);
		oldMap.put(accTest2.Id, accTest2);
        
        Test.startTest();
        AccountsController.triggerHandlerAssignAccounts(accounts, oldMap);
        Test.stopTest();
    }
    
    @isTest static void testAfterInsertAddDoc() {
            Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();
        
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
         Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Comune__c = 'SAN MARTINO SICCOMARIO',
             Fidejussore__c = true
        );
        Account accTest2 = new Account(
                Name = 'testTest2',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXY',
                MoreScore__c = 'C',
                Comune__c = 'PALERMO DUGNANO',
                Fidejussore__c = false
        );
        List<Account> accounts = new List<Account>{accTest, accTest2};
        insert accounts;
        
        DocumentType__c docType = new DocumentType__c(Document_Block__c='Documenti ufficiali',DocumentApiName__c='Doc_Test__c', ObjectName__c = 'Account');
        insert docType;
        
        DocumentType__c docType2 = new DocumentType__c(Document_Block__c='Documenti ufficiali',DocumentApiName__c='Doc_Test2__c', ObjectName__c = 'Account', Referente_Fidejussore__c = false);
        insert docType2;
        
        Test.startTest();
        AccountsController.AfterInsertAddDoc(accounts);
        Test.stopTest();
        
    }
    @isTest static void updareContatiInteresati(){
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Account acc = ObjectFactory.insertNewAccount();
         Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        
    
        Contact c = new Contact();
        c.Interessato__c= true;
        c.Skip_Flag_Privacy__c= null;
        c.LastName= 'test';
        c.AccountId = acc.Id;
        c.RecordTypeId = recordTypeIdRefOpl;
        c.Fidejussore__c = false;
        c.Email = 'aldora@gmail.com';
        c.Phone = '123456789';
                c.NDG__C = '12345';

        
		insert c;

        test.startTest();
        AccountsController.updareContatiInteresati(new List<Id>{acc.Id});
        test.stopTest();
        
        
    }
    @isTest static void testAttachPDF() {
                    Switch_Validation__mdt testttt=   AccountsControllerTest.generateMetadata();

        Account a = ObjectFactory.insertNewAccount();
        List<Id> acc = new List <Id>{a.Id};
      DocumentType__c docType = new DocumentType__c(Document_Block__c='Coface', DocumentApiName__c=' ', Name='Analisi Coface', ObjectName__c = 'Account');
        
        insert docType;
        
          Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType.id;
        d.Commento_Sales_Support__c='testtt';
          d.Url_Documento__c= null;
        d.Url_Servizio_Esterno__c='TestAH.pdf';
        d.Account__c=a.id;
      
         insert d;
        
        test.startTest();
        AccountsController.attachPDFSync(acc);
        test.stopTest();   
    }
    
    

}