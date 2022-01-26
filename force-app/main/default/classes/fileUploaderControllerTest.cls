@IsTest
public class fileUploaderControllerTest {

    @TestSetup
    static void setup() {

        User user = ObjectFactory.generateUser('unitTestUser@email.com', 'testUser@email.com');
        insert user;

        Account acc = ObjectFactory.generateAccount();
        acc.OwnerId = user.Id;
        insert acc;

        Contact cont = ObjectFactory.generateContact(acc);
        insert cont;

        Opportunity opp = ObjectFactory.generateCFOpportunity(acc);
        opp.AccountId = acc.Id;
        opp.OwnerId = acc.OwnerId;
      // OpportunityController.bypassTrigger=true;
        insert opp;
        //OpportunityController.bypassTrigger=false;
        Quote quote = ObjectFactory.generateMutuoQuote(opp);
        quote.OpportunityId = opp.Id;
        quote.Contratto_Verificato__c = true;
        insert quote;

        ContentVersion contentVersion = ObjectFactory.generateContentVersion();
        insert contentVersion;

    }

    @IsTest
    static Switch_Validation__mdt generateMetadataValidation() {
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(DeveloperName = 'Account', Status__c = 'ON');
        return metadata;
    }

    @IsTest
    static void testMapDocumentsConditions() {
        Map<String, List<Document__c>> allDocs = new  Map<String, List<Document__c>>();
        Opportunity opp;
        List<Document__c> docList;
        Map<String, Map<String, Integer>> result;

        Test.startTest();
        addDocsAndDocTypes();
        opp = [
                SELECT Id, (SELECT Id, StatusStageVisibleFormula__c, Url_Documento__c, Verifica_Sales_Support__c,
                        Obbligatorio__c, ObligatarioAcc__c, ObligatorioCont__c, ObligatorioQuote__c,
                        dependeDaTipoLineaFormula__c, DocumentType__c, IDTipoDocumentoFormula__c
                FROM Documenti__r)
                FROM Opportunity
                LIMIT 1
        ];
        docList = opp.Documenti__r;
        allDocs.put(opp.Id, docList);
        result = fileUploaderController.MapDocumentsConditions(allDocs);
        Test.stopTest();

        System.assertEquals(true, result.get(opp.Id).get('Total') > 0, 'No documents returned');
        System.assertEquals(true, result.get(opp.Id).get('Obligatorio') > 0, 'No Mandatory documents returned');
        System.assertEquals(true, result.get(opp.Id).get('NonObligatorio') > 0, 'No Optional documents returned');
        System.assertEquals(true, result.get(opp.Id).get('Verified') > 0, 'No Verified documents returned');
    }

    @IsTest
    static void testAllDocumentsMap() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<String> oppIdSet = new Set<String>{opp.Id};
        Map<String, List<Document__c>> result;

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.AllDocumentsMap(oppIdSet);
        Test.stopTest();

        System.assertEquals(true, result.get(opp.Id).size() > 0, 'No Documents returned');
    }

    @IsTest
    static void testAllDocumentsMapInvalidInput() {
        Map<String, List<Document__c>> result;

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.AllDocumentsMap(new Set<String>());
        Test.stopTest();

        System.assertEquals(true, result.size() == 0, 'Result size should be 0');
    }

    @IsTest
    static void testAllDocumentsMapOppWithNoDocs() {
        Account acc = [SELECT Id, OwnerId FROM Account LIMIT 1];
        Opportunity newOpp = ObjectFactory.generateCFOpportunity(acc);
        Set<String> oppIdSet = new Set<String>();
        Map<String, List<Document__c>> result;

        Test.startTest();
        insert newOpp;
        oppIdSet.add(newOpp.Id);
        result = fileUploaderController.AllDocumentsMap(oppIdSet);
        Test.stopTest();

        System.assertEquals(true, result.get(newOpp.Id).size() == 0, 'Result size should be 0');
    }

    @IsTest
    static void testUpdatedDocCount() {
        List<Document__c> docList = new List<Document__c>();
        List<String> result;

        Test.startTest();
        addDocsAndDocTypes();
        docList = [SELECT Id, Opportunity__c, Account__c, Contact__c, Quote__c FROM Document__c];
        result = fileUploaderController.updatedDocCount(docList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'No opportunities returned');
        System.assertEquals(true, result.contains(docList[0].Opportunity__c), 'Opportunity not included in list');
    }

    @IsTest
    static void testUpdateDocCountAfterUploadInsertDelete() {
        Opportunity initialOpp;
        List<Document__c> docList;
        initialOpp = [
                SELECT Id, Total_Uploaded_Docs__c, Total_Mandatories_Docs__c,
                        Totale_Verified_Docs_Verificati__c
                FROM Opportunity
                LIMIT 1
        ];

        Test.startTest();
        addDocsAndDocTypes();
        docList = [SELECT Id, Opportunity__c, Account__c, Contact__c, Quote__c FROM Document__c LIMIT 1];
        fileUploaderController.UpdateDocCountAfterUploadInsertDelete(docList);
        Test.stopTest();

        Opportunity updatedOpp = [
                SELECT Id, Total_Uploaded_Docs__c, Total_Mandatories_Docs__c,
                        Totale_Verified_Docs_Verificati__c
                FROM Opportunity
                LIMIT 1
        ];

        System.assertEquals(true, updatedOpp.Total_Uploaded_Docs__c > initialOpp.Total_Uploaded_Docs__c, 'Updated uploaded doc count is invalid');
        System.assertEquals(true, updatedOpp.Total_Mandatories_Docs__c > initialOpp.Total_Mandatories_Docs__c, 'Updated Mandatory doc count is invalid');
        System.assertEquals(true, updatedOpp.Totale_Verified_Docs_Verificati__c > initialOpp.Totale_Verified_Docs_Verificati__c, 'Updated Verified doc count is invalid');
    }

    @IsTest
    static void testUpdateDocCountAfterUploadInsertDeleteInvalidInput() {
        List<Document__c> docList;
        String customException;

        Test.startTest();
        try {
            fileUploaderController.UpdateDocCountAfterUploadInsertDelete(docList);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assert(true, customException == 'Attempt to de-reference a null object');
    }

    @IsTest
    static void testGetOppIdAndDocumentsMap() {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>([
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                LIMIT 1]);
        Map<String, List<Document__c>> result;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.get(opp.Id).size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetOppIdAndDocumentsMapInvalidInput() {
        Map<String, List<Document__c>> result;

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.GetOppIdAndDocumentsMap(new Map<String, Opportunity>());
        Test.stopTest();

        System.assertEquals(true, result.size() == 0, 'Result is not empty');
    }

    @IsTest
    static void testGetOppIdAndAllDocumentsMap() {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>([
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                LIMIT 1]);
        Map<String, List<Document__c>> result;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.GetOppIdAndAllDocumentsMap(opportunityMap);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.get(opp.Id).size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetOppIdAndAllDocumentsMapInvalidInput() {
        Map<String, List<Document__c>> result;

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.GetOppIdAndAllDocumentsMap(new Map<String, Opportunity>());
        Test.stopTest();

        System.assertEquals(true, result.size() == 0, 'Result is not empty');
    }

    @IsTest
    static void testUpdateDocCountAfterStageChange() {
        List<Opportunity> initialOppList = new List<Opportunity>([SELECT Id, Total_Mandatories_Docs__c, RecordType.DeveloperName FROM Opportunity]);

        Test.startTest();
        addDocsAndDocTypes();
        initialOppList = new List<Opportunity>([
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                LIMIT 1]);

        initialOppList[0].StageName = 'Due Diligence';
        update initialOppList;
        fileUploaderController.UpdateDocCountAfterStageChange(initialOppList);
        Test.stopTest();

        Opportunity updatedOpp = [
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                LIMIT 1];

        System.assertEquals(true, updatedOpp.Total_Mandatories_Docs__c > initialOppList[0].Total_Mandatories_Docs__c, 'Mandatory doc numbers have not been updated accordingly');
    }

    @IsTest
    static void testUpdateDocCountAfterStageChangeInvalidInput() {
        String customException;

        Test.startTest();
        try {
            fileUploaderController.UpdateDocCountAfterStageChange(new List<Opportunity>());
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == null, 'Custom Exception is not null: ' + customException);
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeOneDocEach() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppIdList = new List<String>{opp.Id};
        Integer result;

        Test.startTest();
        addDocsAndDocTypes();
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        result = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(opp.Id), oppIdAndMandatoryDocTypeMap.get(opp.Id), opp, 0, 0);
        Test.stopTest();

        System.assertEquals(true, result > 0, 'Mandatory documents number computed incorrectly');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeExtraDocs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        List<String> oppIdList = new List<String>{opp.Id};
        Integer result;

        Test.startTest();
        addDocsAndDocTypes();
        addExtraMandatoryDocs(opp, cont);
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        result = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(opp.Id), oppIdAndMandatoryDocTypeMap.get(opp.Id), opp, 0, 0);
        Test.stopTest();

        System.assertEquals(true, result > 0, 'Mandatory documents number computed incorrectly');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeExtraContactDocs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppIdList = new List<String>{opp.Id};
        Integer mandatoryDocTypesSize;
        Integer result;

        Test.startTest();
        addDocsAndDocTypes();
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        mandatoryDocTypesSize = oppIdAndMandatoryDocTypeMap.get(opp.Id).size();
        result = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(opp.Id), oppIdAndMandatoryDocTypeMap.get(opp.Id), opp, 4, 0);
        Test.stopTest();

        System.assertEquals(true, result > 0, 'Mandatory documents number computed incorrectly');
        System.assertNotEquals(true, result > mandatoryDocTypesSize, 'Mandatory contact documents number computed incorrectly');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeExtraQuoteDocs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppIdList = new List<String>{opp.Id};
        Integer mandatoryDocTypesSize;
        Integer result;

        Test.startTest();
        addDocsAndDocTypes();
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        mandatoryDocTypesSize = oppIdAndMandatoryDocTypeMap.get(opp.Id).size();
        result = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(opp.Id), oppIdAndMandatoryDocTypeMap.get(opp.Id), opp, 0, 4);
        Test.stopTest();

        System.assertEquals(true, result > 0, 'Mandatory documents number computed incorrectly');
        System.assertNotEquals(true, result > mandatoryDocTypesSize, 'Mandatory contact documents number computed incorrectly');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeNoDocs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppIdList = new List<String>{opp.Id};
        Integer result;

        Test.startTest();
        addDocsAndDocTypes();
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        result = fileUploaderController.computeTotalMandatoryDocsForStageChange(new List<Document__c>(), oppIdAndMandatoryDocTypeMap.get(opp.Id), opp, 0, 0);
        Test.stopTest();

        System.assertEquals(true, result > 0, 'Mandatory documents number computed incorrectly');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeNullDocs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppIdList = new List<String>{opp.Id};
        String customException;

        Test.startTest();
        try {
            addDocsAndDocTypes();
            Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
            Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
            fileUploaderController.computeTotalMandatoryDocsForStageChange(null, oppIdAndMandatoryDocTypeMap.get(opp.Id), opp, 0, 0);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Different exception expected');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeNoMandatoryDocTypes() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Integer result;

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderController.computeTotalMandatoryDocsForStageChange(new List<Document__c>(), new Map<String, DocumentType__c>(), opp, 0, 0);
        Test.stopTest();

        System.assertEquals(true, result == 0, 'Result should be 0');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangenullMandatoryDocTypes() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String customException;

        Test.startTest();
        try {
            addDocsAndDocTypes();
            fileUploaderController.computeTotalMandatoryDocsForStageChange(new List<Document__c>(), null, opp, 0, 0);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }

        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Different exception expected');
    }

    @IsTest
    static void testComputeTotalMandatoryDocsForStageChangeNoOpp() {
        Integer result;
        String customException;

        Test.startTest();
         Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        try {
            addDocsAndDocTypes();
            result = fileUploaderController.computeTotalMandatoryDocsForStageChange(new List<Document__c>(), new Map<String, DocumentType__c>(), null, 0, 0);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Result should be 0');
    }

    @IsTest
    static void testComputeUpdatedMandatoryContactDocTypes() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id, Integer> result;

        Test.startTest();
        Contact cont2 = ObjectFactory.generateContact(acc);
        insert cont2;
        addDocsAndDocTypes();
        addExtraMandatoryDocs(opp, cont);
        addExtraMandatoryDocs(opp, cont2);
        List<Document__c> documentList = [SELECT Id, Opportunity__c, Account__c, Contact__c, Quote__c FROM Document__c LIMIT 10];
        List<String> docOpportunities = fileUploaderController.updatedDocCount(documentList);
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(docOpportunities);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        result = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Test.stopTest();

        System.assertEquals(true, result.get(opp.Id) > 0, 'Result is invalid');
    }

    @IsTest
    static void testComputeUpdatedMandatoryContactDocTypesNullMandatory() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id, Integer> result;
        String customException;

        Test.startTest();
        try {
            Contact cont2 = ObjectFactory.generateContact(acc);
            insert cont2;
            addDocsAndDocTypes();
            addExtraMandatoryDocs(opp, cont);
            addExtraMandatoryDocs(opp, cont2);
            List<Document__c> documentList = [SELECT Id, Opportunity__c, Account__c, Contact__c, Quote__c FROM Document__c LIMIT 10];
            List<String> docOpportunities = fileUploaderController.updatedDocCount(documentList);
            Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(docOpportunities);
            List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
            result = fileUploaderController.computeUpdatedMandatoryContactDocTypes(null, opportunityMap, accountIdList);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Different exception expected');
    }

    @IsTest
    static void testComputeUpdatedMandatoryContactDocTypesNullOppMap() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id, Integer> result;
        String customException;

        Test.startTest();
        try {
            Contact cont2 = ObjectFactory.generateContact(acc);
            insert cont2;
            addDocsAndDocTypes();
            addExtraMandatoryDocs(opp, cont);
            addExtraMandatoryDocs(opp, cont2);
            List<Document__c> documentList = [SELECT Id, Opportunity__c, Account__c, Contact__c, Quote__c FROM Document__c LIMIT 10];
            List<String> docOpportunities = fileUploaderController.updatedDocCount(documentList);
            Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(docOpportunities);
            Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
            List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
            result = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, null, accountIdList);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Different exception expected');
    }

    @IsTest
    static void testComputeUpdatedMandatoryContactDocTypesNullAccIdList() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id, Integer> result;
        String customException;

        Test.startTest();
        try {
            Contact cont2 = ObjectFactory.generateContact(acc);
            insert cont2;
            addDocsAndDocTypes();
            addExtraMandatoryDocs(opp, cont);
            addExtraMandatoryDocs(opp, cont2);
            List<Document__c> documentList = [SELECT Id, Opportunity__c, Account__c, Contact__c, Quote__c FROM Document__c LIMIT 10];
            List<String> docOpportunities = fileUploaderController.updatedDocCount(documentList);
            Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(docOpportunities);
            Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
            List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
            result = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Different exception expected');
    }

//    @IsTest
//    static void testConditionUpdateUrl() {
//        Account acc = ObjectFactory.insertNewAccount();
//        DocumentType__c docTypeAcc = ObjectFactory.insertNewDocumentType('Account');
//        List<Document__c> documentList = new List<Document__c>();
//        Document__c document = new Document__c();
//        document.Name = 'test';
//        document.DocumentType__c = docTypeAcc.Id;
//        document.Id_File__c = '0691w0000010Rs9AAE';
//        document.Commento_Sales_Support__c = 'testComment';
//        document.Account__c = acc.Id;
//        insert document;
//
//        Map<Id, Document__c> oldOppMap = new Map<Id, Document__c>{document.Id => document};
//        documentList.add(document);
//
//        Test.startTest();
//        fileUploaderController.conditionUpdateUrl(documentList, oldOppMap);
//        fileUploaderController.deleteFile(documentList, oldOppMap);
//        Test.stopTest();
//    }
    
//    @IsTest static void testGetId() {
//        Document__c document = ObjectFactory.insertNewDocument();
//        Opportunity opportunity = ObjectFactory.insertNewOpportunity();
//        Account account = ObjectFactory.insertNewAccount();
//        Contact contact = ObjectFactory.insertNewContact();
//        Quote quote = ObjectFactory.insertNewQuote();
//        List<Id> idList = new List<Id>();
//
//        idList.add(opportunity.Id);
//        idList.add(account.Id);
//        idList.add(contact.Id);
//        idList.add(quote.Id);
//
//        Test.startTest();
//        fileUploaderController.associateIdRecord(new List<Document__c>{document});
//        fileUploaderController.associateIdFileRecord(new List<Document__c>{document});
//        fileUploaderController.getlistIdFileAllOpportunity(new List<Id>{opportunity.Id});
//        fileUploaderController.getlistIdFileAllAccount(new List<Id>{account.Id});
//        fileUploaderController.getlistIdFileAllContact(new List<Id>{contact.Id});
//        fileUploaderController.getlistIdFileAllQuote(new List<Id>{quote.Id});
//        fileUploaderController.getlistIdFileAllContentDocument(idList);
//        fileUploaderController.getIdContentDocumentId(idList,new List<Id>{document.Id} );
//        fileUploaderController.getlistIdFileDelete(idList,new List<Id>{document.Id} );
//        Map<Id,ContentDocumentLink> mapi =  fileUploaderController.getIdContentDocumentId(idList,new List<Id>{document.Id});
//        fileUploaderController.getIdFileDelete(mapi);
//        Test.stopTest();
//
//    }
    
    @IsTest static void testRecoveryFields() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1 ];
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Document__c doc = ObjectFactory.insertNewDocument();   

        fileUploaderController.recoveryAllFieldsOpportunity(new List<Document__c>{doc}, new List<Id>{opp.Id});
        fileUploaderController.recoveryAllFieldsAccount(new List<Document__c>{doc},new List<Id>{acc.Id});
        fileUploaderController.recoveryAllFieldsContact(new List<Document__c>{doc},new List<Id>{cont.Id});
        fileUploaderController.recoveryAllFieldsQuote(new List<Document__c>{doc},new List<Id>{quote.Id});
        fileUploaderController.numerimi(opp.Id);
        Test.stopTest(); 
    }

//   @IsTest static void testReplaceUrl() {
//       Document__c doc = ObjectFactory.insertNewDocument();
//       Opportunity opp = ObjectFactory.insertNewOpportunity();
//       Account acc = ObjectFactory.insertNewAccount();
//       Contact cont = ObjectFactory.insertNewContact();
//       Quote quote = ObjectFactory.insertNewQuote();
//
//       Test.startTest();
//       fileUploaderController.replaceUrlOpportunity(new List<Document__c>{doc}, new Map<Id, Opportunity>{opp.Id => opp});
//       fileUploaderController.replaceUrlQuote(new List<Document__c>{doc}, new Map<Id, Quote>{quote.Id => quote});
//       fileUploaderController.replaceUrlContact(new List<Document__c>{doc}, new Map<Id, Contact>{cont.Id => cont});
//       fileUploaderController.replaceUrlAccount(new List<Document__c>{doc}, new Map<Id, Account>{acc.Id => acc});
//       Test.stopTest();
//   }
    
//    @IsTest static void testLinkUrlDocumentoQuote() {
//        Quote q = ObjectFactory.insertNewQuote();
//        DocumentType__c documentType = ObjectFactory.insertNewDocumentType('Opportunity');
//        Document__c document = new Document__c();
//        document.Name = 'test';
//        document.DocumentType__c = documentType.Id;
//        document.Id_File__c = '0691w0000010Rs9AAE';
//        document.Commento_Sales_Support__c = 'testtt';
//        document.Quote__c = q.Id;
//
//        insert document;
//
//        Test.startTest();
//        fileUploaderController.linkUrlDocumentoQuote(new List<Id>{document.Id});
//        Test.stopTest();
//    }

    private static void addDocsAndDocTypes() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Quote quote = [SELECT Id FROM Quote][1];

        List<DocumentType__c> docTypeList = generateDocTypes();
        insert docTypeList;

        List<Document__c> docList = generateDocs(docTypeList, opp, acc, cont, quote);
        insert docList;
    }

    private static List<DocumentType__c> generateDocTypes() {
        List<DocumentType__c> docTypeList = new List<DocumentType__c>();

        for (Integer i = 0; i < 12; i++) {
            String objectName;

            if (i < 3) {
                objectName = 'Opportunity';
            } else if (i >= 3 && i < 6) {
                objectName = 'Account';
            } else if (i >= 6 && i < 9) {
                objectName = 'Quote';
            } else if (i >= 9 && i < 12) {
                objectName = 'Contact';
            }

            DocumentType__c docType = ObjectFactory.generateDocumentType(objectName);
            DocumentType__c optDocType = ObjectFactory.generateOptionalDocumentType(objectName);
            docType.Status_Stage_Visible__c = 'Primo Contatto';
            optDocType.Status_Stage_Visible__c = 'Primo Contatto';

            if (i == 1) {
                docType.ID_Tipo_Documento__c = 'SME_095';
                optDocType.ID_Tipo_Documento__c = 'SME_096';
            } else if (i == 2) {
                docType.ID_Tipo_Documento__c = 'SME_025';
                docType.Opportunity_Crediti_Fiscali__c = true;
                docType.Opportunita_Mutuo__c = true;
                docType.Opportunita_EasyPlus__c = true;
                docType.Erogazione_Servizi__c = true;
                docType.Obbligatorio_per_Pre_Due_Diligence__c = true;
            } else if (i == 4) {
                docType.ID_Tipo_Documento__c = 'SME_057';
                optDocType.ID_Tipo_Documento__c = 'SME_058';
            } else if (i == 5) {
                docType.ID_Tipo_Documento__c = 'SME_020';
                docType.Opportunity_Crediti_Fiscali__c = true;
                docType.Opportunita_Mutuo__c = true;
                docType.Opportunita_EasyPlus__c = true;
                docType.Erogazione_Servizi__c = true;
                docType.Obbligatorio_in_CompletamentoDocumenti__c = true;
            } else if (i == 7) {
                docType.ID_Tipo_Documento__c = 'SME_100';
                optDocType.ID_Tipo_Documento__c = 'SME_101';
            } else if (i == 8) {
                docType.ID_Tipo_Documento__c = 'SME_004';
            } else if (i == 10) {
                docType.ID_Tipo_Documento__c = 'SME_026';
                optDocType.ID_Tipo_Documento__c = 'SME_027';
            } else if (i == 11) {
                docType.ID_Tipo_Documento__c = 'SME_002';
                docType.Opportunity_Crediti_Fiscali__c = true;
                docType.Opportunita_Mutuo__c = true;
                docType.Opportunita_EasyPlus__c = true;
                docType.Erogazione_Servizi__c = true;
                docType.Obbligatorio_per_Pre_Due_Diligence__c = true;
            }

            docTypeList.add(docType);
            docTypeList.add(optDocType);
        }

        return docTypeList;
    }

    private static List<Document__c> generateDocs(List<DocumentType__c> docTypeList, Opportunity opp, Account acc,
            Contact cont, Quote quote ) {
        List<Document__c> docList = new List<Document__c>();

        for (Integer i = 0; i < docTypeList.size(); i++) {
            DocumentType__c docType = docTypeList[i];
            Document__c newDoc = new Document__c();
            Document__c secondaryDoc = new Document__c();

            if (docType.Doc_Opzionale__c) {
                newDoc = ObjectFactory.generateOptionalDocument(docType);
                secondaryDoc = ObjectFactory.generateOptionalDocument(docType);
            } else {
                newDoc = ObjectFactory.generateDocument(docType);
                secondaryDoc = ObjectFactory.generateDocument(docType);
            }

            if (docType.ObjectName__c == 'Opportunity') {
                newDoc.Opportunity__c = opp.Id;
                secondaryDoc.Opportunity__c = opp.Id;
            } else if (docType.ObjectName__c == 'Account') {
                newDoc.Account__c = acc.Id;
                secondaryDoc.Account__c = acc.Id;
            } else if (docType.ObjectName__c == 'Contact') {
                newDoc.Contact__c = cont.Id;
                secondaryDoc.Contact__c = cont.Id;
            } else if (docType.ObjectName__c == 'Quote') {
                newDoc.Quote__c = quote.Id;
                secondaryDoc.Quote__c = quote.Id;
            }

            if ((i / 2) == Math.round(i / 2)) {
                newDoc.Url_Documento__c = 'www.linkToDocument.com';
                newDoc.Verifica_Sales_Support__c = 'Verifica OK';
                docList.add(secondaryDoc);
            }

            docList.add(newDoc);
        }

        return docList;
    }

    private static List<Document__c> addExtraMandatoryDocs(Opportunity opp, Contact cont) {
        Document__c newOppDoc = ObjectFactory.generateDocument([SELECT Id FROM DocumentType__c WHERE ID_Tipo_Documento__c = 'SME_025' LIMIT 1]);
        Document__c newContactDoc = ObjectFactory.generateDocument([SELECT Id FROM DocumentType__c WHERE ID_Tipo_Documento__c = 'SME_002' LIMIT 1]);
        List<Document__c> docsToInsert = new List<Document__c>();

        newOppDoc.Opportunity__c = opp.Id;
        newOppDoc.Url_Documento__c = 'www.linkToDocument.com';
        newOppDoc.Verifica_Sales_Support__c = 'Verifica OK';
        newContactDoc.Contact__c = cont.Id;
        newContactDoc.Url_Documento__c = 'www.linkToDocument.com';
        newContactDoc.Verifica_Sales_Support__c = 'Verifica OK';
        docsToInsert.add(newOppDoc);
        docsToInsert.add(newContactDoc);

        insert docsToInsert;
        return docsToInsert;
    }

    private static Map<String, Map<String, DocumentType__c>> GetMandatoryDocTypesMap (Map<String, Opportunity> opportunityMap) {
        List<DocumentType__c> documentTypes = [
                SELECT Id, Name, Opportunita_EasyPlus__c, ObjectName__c, ID_Tipo_Documento__c,
                        Opportunity_Crediti_Fiscali__c, Obbligatorio_per_Pre_Due_Diligence__c, Obbligatorio_in_Erogazione__c,
                        Obbligatorio_in_CompletamentoDocumenti__c, Opportunita_Mutuo__c, Obbligatorio_in_Deliberata__c,
                        Obbligatorio_per_In_Stipula__c
                FROM DocumentType__c
                ORDER BY ObjectName__c
        ];
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypesMap = new Map<String, Map<String, DocumentType__c>>();

        for (String oppId : opportunityMap.keySet()) {
            Opportunity opportunity = opportunityMap.get(oppId);
            Map<String, DocumentType__c> docTypeMap = new Map<String, DocumentType__c>();
            List<DocumentType__c> mandatoryDocTypesForOpp = fileUploaderController.GetMandatoryDocTypesInOpp(opportunity, creditiStageMap, mutuoStageMap, easyPlusStageMap, documentTypes);
            if (mandatoryDocTypesForOpp.size() > 0) {
                docTypeMap = fileUploaderController.getFilteredMandatoryDocTypeMap(opportunity, mandatoryDocTypesForOpp);
                oppIdAndMandatoryDocTypesMap.put(oppId, docTypeMap);
            } else {
                oppIdAndMandatoryDocTypesMap.put(oppId, new Map<String, DocumentType__c>());
            }
        }

        return oppIdAndMandatoryDocTypesMap;
    }

    static Map<String, Integer> mutuoStageMap = new Map<String, Integer>{
            'Primo Contatto' => 1,
            'Prima Visita' => 2,
            'Completamento Documenti' => 3,
            'PEF Pre-Istruttoria' => 4,
            'PEF Istruttoria' => 5,
            'Deliberata' => 6,
            'In Stipula' => 7,
            'Firma' => 8,
            'In Erogazione' => 9,
            'Closed' => 10,
            'Erogata' => 11,
            'Chiusa/Persa' => 12
    };

    static Map<String, Integer> creditiStageMap = new Map<String, Integer>{
            'Primo Contatto' => 1,
            'Prima Visita' => 2,
            'Pre-Due Diligence' => 3,
            'Pre-Analisi e Pricing' => 4,
            'Due Diligence' => 5,
            'Completamento Documenti' => 6,
            'PEF Pre-Istruttoria' => 7,
            'PEF Istruttoria' => 8,
            'Deliberata' => 9,
            'In Stipula' => 10,
            'Firma e Cessione' => 11,
            'In Erogazione' => 12,
            'Closed' => 13,
            'Erogata' => 14,
            'Incasso e Chiusura' => 15,
            'Chiusa/Persa' => 16
    };

    static Map<String, Integer> easyPlusStageMap = new Map<String, Integer> {
            'Primo Contatto' => 1,
            'Prima Visita' => 2,
            'Completamento Documenti' => 3,
            'PEF Pre-Istruttoria' => 4,
            'PEF Istruttoria' => 5,
            'Deliberata' => 6,
            'In Erogazione' => 7,
            'Closed' => 8,
            'Erogata' => 9,
            'Chiusa/Persa' => 10
    };

}