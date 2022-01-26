@isTest
private class fileUploaderTest {
  /*  @isTest static void getListaReferentiFirmatariTest() {

      //  User usrInsSal = insertUserRole();

        List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Inside_Sales_1'];

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();

        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c = users.get(0).Id
        );

        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25), amount = 100, Probability = 5);
        insert opp;
        DocumentType__c docType = new DocumentType__c(Document_Block__c = 'Documentazione pre-contrattuale');
        insert docType;
        Document__c doc = new Document__c(Box__c = 'Deliberata', Name = 'test', Id_File__c = '0011w00000HdQopAAF', DocumentType__c = docType.Id, Opportunity__c = opp.Id);
        insert doc;

        List<Document__c> listaDocument = new List<Document__c> ();

        Test.startTest();
        listaDocument = fileUploaderDAO.getRecordListDocumentAll(opp.Id, 'Documentazione pre-contrattuale');
        fileUploaderDAO.updateNote(doc.Id, 'commento test , campo note');
        fileUploaderDAO.updatePick(doc.Id, 'Verifica OK');
        fileUploaderDAO.updatePickVIS(doc.Id, 'Verifica OK');
        fileUploaderDAO.updateCheck(doc.Id, true);
        fileUploaderDAO.updateFile(doc.Id, 'wwww.test.it', doc.Id_File__c);
        Test.stopTest();


    }

    @isTest static void testConditionUpdateUrl() {

     //   User usrInsSal = insertUserRole();

        List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Inside_Sales_1'];

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();

        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c = users.get(0).Id
        );

        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.id, Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25), amount = 100, Probability = 5);
        insert opp;
        DocumentType__c docType = new DocumentType__c(Document_Block__c = 'Documentazione pre-contrattuale',Name = 'Bilancio Analitico',DocumentApiName__c = 'X26_Bilancio_Analitico__c');
        insert docType;
        Document__c doc = new Document__c(Box__c = 'Deliberata', Name = 'test', Id_File__c = '0011w00000HdQopAAF', DocumentType__c = docType.Id, Url_Documento__c='', Opportunity__c = opp.Id);
        insert doc;

        Test.startTest();

        doc.Url_Documento__c = 'XXX';
        update doc;

        doc.Url_Documento__c = '';
        update doc;

        doc.Url_Documento__c = 'ZZZ';
        update doc;

        Test.stopTest();

    }

    @isTest static void testRichiediNdg() {
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();

        List<User> users = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Inside_Sales_1'];

        Account accTest = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c = users.get(0).Id
        );
        insert accTest;

        Contact contTest = new Contact(
                FirstName = 'testName',
                LastName = 'testLastName',
                AccountId = accTest.Id,
                RecordTypeId = recordTypeIdRefOpl
        );
        Contact contTest2 = new Contact(
                FirstName = 'testName2',
                LastName = 'testLastName2',
                AccountId = accTest.Id,
                RecordTypeId = recordTypeIdRefOpl
        );

        Opportunity opp = new Opportunity(AccountId = accTest.id, Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25), amount = 100, Probability = 5);
        insert opp;

        List<Contact> contacts = new List<Contact>{contTest, contTest2};
        insert contacts;
        Test.startTest();
        fileUploaderDAO.richiediNdg(opp.Id);
        Test.stopTest();
    }

    @isTest static void testGetlistIdFileAllContentDocument() {
        List<Id> listIds = new List<Id>{'0011w00000HdQopAAF'};
        Test.startTest();
        fileUploaderController.getlistIdFileAllContentDocument(listIds);
        Test.stopTest();
    }*/

}