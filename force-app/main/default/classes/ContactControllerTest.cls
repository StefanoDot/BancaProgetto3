/**
 * Created by ACAPUTO00 on 05/03/2020.
 */

@isTest
public with sharing class ContactControllerTest {
          @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

	
    @isTest static void testNotifyMissingFieldsServiceFidejusione() {
                   Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

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
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO'
        );
        insert accTest;
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
                Comune__c = 'PALERMO DUGNANO',
                RecordTypeId = recordTypeIdRefOpl
        );
                

        List<Contact> contacts = new List<Contact>{contTest, contTest2};
        insert contacts;
        
        Test.startTest();
        ContactController.notifyMissingFieldsServiceFidejusioneBeforeUpdate(contacts);
        ContactController.notifyMissingFieldsServiceFidejusione(contacts);
        Test.stopTest();
    }
    
    @isTest static void testDocumentazioneFidejusore() {
                           Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

        
        Contact oldCont1 = ObjectFactory.insertNewContact();
        
        oldCont1.Fidejussore__c = false;
        
        Contact newCont1 = oldCont1;
        newCont1.Fidejussore__c = true;
            
        DocumentType__c docType1 = ObjectFactory.insertNewDocumentType('Contact');
        docType1.Referente_Fidejussore__c = false;
        
        DocumentType__c docType2 = ObjectFactory.insertNewDocumentType('Contact');
        
        
        Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=docType1.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
        d.Contact__c=newCont1.id;
        
		insert d;
        
        
        List<Contact> newContacts = new List<Contact>{newCont1};
        Map<Id, Contact> oldContMap = new Map<Id, Contact>{newCont1.Id => oldCont1};
        
            
        Test.startTest();
        ContactController.DocumentazioneFidejusore(newContacts, oldContMap);
        Test.stopTest();
        
    }
    
    @isTest static void testCheckComune() {
                           Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

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
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO'
        );
        insert accTest;
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
                Comune__c = 'PALERMO DUGNANO',
                RecordTypeId = recordTypeIdRefOpl
        );
        
        List<Contact> contacts = new List<Contact>{contTest, contTest2};
        insert contacts;
        
        Map<Id, Contact> oldContMap = new Map<Id, Contact>{contTest.Id => contTest, contTest2.Id => contTest2};
            
        Test.startTest();
        ContactController.checkComune(contacts, oldContMap);
        Test.stopTest();
        
        
    }
    
    @isTest static void testCompleteField() {
                           Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

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
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO'
        );
        insert accTest;
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
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl
        );
        Contact contTest3 = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl
        );
        List<Contact> contacts = new List<Contact>{contTest, contTest2, contTest3};
        insert contacts;
        
        
        Contact newCont = [SELECT Nome_Via__c, Tipo_Via__c, Ruolo_in_Azienda__c, Referente_Oplon__c, FinServ__Gender__c, Oplon_Titolare_Effettivo__c, Oplon_Altre_Cariche__c
                              FROM Contact 
                              WHERE Id = :contTest.Id
                              LIMIT 1];
        
        newCont.Ruolo_in_Azienda__c = 'Titolare Effettivo';
        newCont.Referente_Oplon__c = false;
        newCont.FinServ__Gender__c = 'Male';
        
        Contact newCont2 = [SELECT Nome_Via__c, Tipo_Via__c, Ruolo_in_Azienda__c, Referente_Oplon__c, FinServ__Gender__c, Oplon_Altre_Cariche__c, Oplon_Titolare_Effettivo__c
                              FROM Contact 
                              WHERE Id = :contTest2.Id
                              LIMIT 1];
        
        newCont2.Oplon_Titolare_Effettivo__c = true;
        newCont2.FinServ__Gender__c = 'Female';
        newCont2.Oplon_Altre_Cariche__c = 'Altre Cariche Test';
        
        Contact newCont3 = [SELECT Nome_Via__c, Tipo_Via__c, Ruolo_in_Azienda__c, Referente_Oplon__c, FinServ__Gender__c, Oplon_Titolare_Effettivo__c, Oplon_Altre_Cariche__c
                              FROM Contact 
                              WHERE Id = :contTest3.Id
                              LIMIT 1];
        
        newCont3.Ruolo_in_Azienda__c = 'Legale Rappresentante';
        newCont3.Oplon_Titolare_Effettivo__c = true;
        newCont3.FinServ__Gender__c = 'Male';
        
        List<Contact> newContacts = new List<Contact>{newCont, newCont2, newCont3};
        update newContacts;
        
        Map<Id, Contact> oldContMap = new Map<Id, Contact>();
		oldContMap.put(contTest.Id, contTest);
        oldContMap.put(contTest2.Id, contTest2);
        oldContMap.put(contTest2.Id, contTest3);
        
         Test.startTest();
        ContactController.completeField(newContacts, oldContMap);
        Test.stopTest();
    }
    
    @isTest static void testCheckVia() {
                           Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

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
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO'
        );
        insert accTest;
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl
        );
        List<Contact> contacts = new List<Contact>{contTest};
        insert contacts;
        
        
        Contact newCont = [SELECT Nome_Via__c, Tipo_Via__c
                              FROM Contact 
                              WHERE Id = :contTest.Id
                              LIMIT 1];
        
        newCont.Nome_Via__c = 'BORGO test';
        update newCont;
        
        List<Contact> newContacts = new List<Contact>{newCont};
        
        Map<Id, Contact> oldContMap = new Map<Id, Contact>();
		oldContMap.put(contTest.Id, contTest);
        
         Test.startTest();
        ContactController.checkVia(newContacts, null);
        Test.stopTest();
    }
    
	
   /* @isTest static void testAfterInsertAddDoc() {
                           Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

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
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO'
        );
        insert accTest;
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl,
            Fidejussore__c = true
        );
        Contact contTest2 = new Contact(
                FirstName = 'testName2',
                LastName = 'testLastName2',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Estero',
                Residenza__c = 'Estero',
                Comune__c = 'PALERMO DUGNANO',
                RecordTypeId = recordTypeIdRefOpl,
            Interessato__c=true,
            Fidejussore__c = false,
            Ruolo_in_Azienda__c = 'Titolare Effettivo'
        );
        List<Contact> contacts = new List<Contact>{contTest, contTest2};
        insert contacts;
        
        DocumentType__c docType = new DocumentType__c(Document_Block__c='Documenti ufficiali',DocumentApiName__c='Doc_Test__c', ObjectName__c = 'Contact');
        DocumentType__c docType2 = new DocumentType__c(Document_Block__c='Documenti ufficiali',DocumentApiName__c='Doc_Test2__c', ObjectName__c = 'Contact', Referente_Fidejussore__c = false);
        List<DocumentType__c> docs = new List<DocumentType__c>{docType, docType2};
        insert docs;
        
         DocumentType__c doc=   ObjectFactory.insertNewDocumentType('Contact');
        
        Test.startTest();
        ContactController.AfterInsertAddDoc(contacts);
        Test.stopTest();
    }*/
    
    @isTest static void testPrivacyFlag(){
                           Switch_Validation__mdt testtt= ContactControllerTest.generateMetadataValidation();

       
       Account acc = ObjectFactory.insertNewAccount();
        Contact cont = ObjectFactory.insertNewContact();
      Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
          Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Comune__c = 'PALERMO DUGNANO' ,
                erogazione_dei_servizi__c='YES',
              Marketing_Banca__c='YES',
              Profilazione_Banca__c='YES',
              Valutazione_Qualit_Servizio__c='NO',
              Ricerche_di_Mercato__c='NO',
              Dati_Particolari__c='NO',
              Consenso_Sic__c='NO'
          );
        insert accTest;
         Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia',
                Comune__c = 'SAN MARTINO SICCOMARIO',
                RecordTypeId = recordTypeIdRefOpl,
            Fidejussore__c = true,
             Erogazione_dei_Servizi__c='YES',
             Marketing_Banca__c='YES',
             Profilazione_Banca__c='YES',
             Valutazione_Qualita_Servizio__c='NO',
              Ricerche_di_Mercato__c='NO',
             Dati_Particolari__c='NO',
             Consenso_Sic__c='NO'
        );
        insert contTest;
        
        Test.startTest();
        ContactController.UpdatePrivacyCampiInteresato(new List<Contact>{contTest}, new Set<Id>{accTest.id});
            ContactController.UpdatePrivacyCampi(new List<Contact>{cont});
         ContactController.fidejussoreUpdatePrivacyCampi(new List<Contact>{cont});
        Test.stopTest();
    }

}