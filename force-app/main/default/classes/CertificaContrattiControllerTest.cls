/**
 * Created by ACAPUTO00 on 05/03/2020.
 */

@isTest
public with sharing class CertificaContrattiControllerTest {

    @isTest static void testGetDatiContact(){
        Test.startTest();
        CertificaContattiController.getDatiContact('0011w00000HdQopAAF');
        Test.stopTest();
    }

    @isTest static void testSaveNumDoc(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full'
        );
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia'
        );
        insert contTest;
        Test.startTest();
        CertificaContattiController.saveNumDoc(contTest.Id,'001');
        Test.stopTest();
    }

    @isTest static void testSavePhone(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full'
        );
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia'
        );
        insert contTest;
        Test.startTest();
        CertificaContattiController.savePhone(contTest.Id,'1234567890','+39');
        Test.stopTest();
    }

    @isTest static void testGetResponseSendCode(){
        Test.startTest();
        CertificaContattiController.getResponseSendCode('','','');
        Test.stopTest();
    }

    @isTest static void testGetResponseCheckCode(){
        Test.startTest();
        CertificaContattiController.getResponseCheckCode('','','');
        Test.stopTest();
    }

    @isTest static void testSaveEmail(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full'
        );
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia'
        );
        insert contTest;
        Test.startTest();
        CertificaContattiController.saveEmail(contTest.Id,'ggg@eee.com');
        Test.stopTest();
    }

    @isTest static void testgetVerifiedFlagsFromContact(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'C',
                Ricezione_Dati_Oplon__c = 'Ok Full'
        );
        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                Stato_Nascita__c = 'Italia',
                Residenza__c = 'Italia'
        );
        insert contTest;
        Test.startTest();
        CertificaContattiController.getVerifiedFlagsFromContact(contTest.Id);
        Test.stopTest();
    }

}