@IsTest
public with sharing class fileUploaderDAOTestOther {
    
 	@TestSetup
    static void setup() {
        User user = ObjectFactory.createNewUser('unitTestUser@email.com', 'testUser@email.com');
        //insert user;

        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Acc Dao';
        acc.Manager_NomeCompleto__c = user.Id;
        acc.Inside_Sales_di_Riferimento__c = user.Id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.OwnerId = user.Id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        acc.Codice_Fiscale__c = '1245';
        acc.Analysis_Id_Oplon__c = '75637';
        insert acc;

        Contact cont = ObjectFactory.generateContact(acc);
        insert cont;

        Opportunity opp = ObjectFactory.generateOpportunity(acc);
        opp.AccountId = acc.Id;
        opp.OwnerId = acc.OwnerId;
        insert opp;

        Quote quote = ObjectFactory.generateMutuoQuote(opp);
        quote.OpportunityId = opp.Id;
        quote.Contratto_Verificato__c = true;
        insert quote;

        ContentVersion contentVersion = ObjectFactory.generateContentVersion();
        insert contentVersion;

//        ContentDocumentLink contentDocLink = ObjectFactory.generateContentDocumentLink(contentVersion);
//        insert contentDocLink;
    }

    @IsTest
    static void testGetRecordListDocumentAllNewAccObjContactDocList() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        DocumentType__c docType;
        String accId = acc.Id;
        String contId = cont.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Contact' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(accId, 'Account', 'Contact', documentTypeBlockList, contId, '');
           System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewAccObjAccDocList() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        DocumentType__c docType;
        String accId = acc.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Account' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(accId, 'Account', 'Account', documentTypeBlockList, '', '');
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewContObj() {
         Test.startTest();
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        DocumentType__c docType;
        String contId = cont.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Contact' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(contId, 'Contact', 'Contact', documentTypeBlockList, contId, '');
           System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewQuoteObj() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote WHERE Contratto_Verificato__c = TRUE][0];
        DocumentType__c docType;
        String quoteId = quote.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Quote' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(quoteId, 'Quote', 'Quote', documentTypeBlockList, '', quoteId);
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewOppObjOppDocList() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Opportunity' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(oppId, 'Opportunity', 'Opportunity', documentTypeBlockList, '', '');
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewOppObjAccDocList() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Account' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(oppId, 'Opportunity', 'Account', documentTypeBlockList, '', '');
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewOppObjContDocList() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        String contId = cont.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Contact' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(oppId, 'Opportunity', 'Contact', documentTypeBlockList, contId, '');
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewOppObjQuoteDocList() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE OpportunityId =: opp.Id AND Contratto_Verificato__c = TRUE][0];
        DocumentType__c docType;
        String oppId = opp.Id;
        String quoteId = quote.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
         addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Quote' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentAllNew(oppId, 'Opportunity', 'Quote', documentTypeBlockList, '', quoteId);
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        System.assertEquals(true, result.get(docType.Id).size() > 0, 'Document list is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewWrongInput() {
        Test.startTest();
        List<String> documentTypeBlockList = new List<String>();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        result = fileUploaderDAO.getRecordListDocumentAllNew('wrongId', 'wrongObj', 'wrongObj', documentTypeBlockList, 'wrongId', 'wrongId');
       System.assertEquals(true, result.size() == 0, 'Result is not empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllNewNullInput() {
        Test.startTest();
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();
        result = fileUploaderDAO.getRecordListDocumentAllNew(null, null, null, null, null, null);
        System.assertEquals(true, result.size() == 0, 'Result is not empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentTypesOppObjOppDocList() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Opportunity' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(oppId, 'Opportunity', 'Opportunity', documentTypeBlockList);
        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
        Test.stopTest();        
    }

    @IsTest
    static void testGetRecordListDocumentTypesOppObjAccDocList() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Account' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(oppId, 'Opportunity', 'Account', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
    }

    @IsTest
    static void testGetRecordListDocumentTypesOppObjContDocList() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Contact' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(oppId, 'Opportunity', 'Contact', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
    }

    @IsTest
    static void testGetRecordListDocumentTypesOppObjQuoteDocList() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        DocumentType__c docType;
        String oppId = opp.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Quote' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(oppId, 'Opportunity', 'Quote', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
    }

    @IsTest
    static void testGetRecordListDocumentTypesAccObjAccDocList() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        DocumentType__c docType;
        String accId = acc.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Account' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(accId, 'Account', 'Account', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
    }

    @IsTest
    static void testGetRecordListDocumentTypesContObjContDocList() {
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        DocumentType__c docType;
        String contId = cont.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Contact' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(contId, 'Contact', 'Contact', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
    }

    @IsTest
    static void testGetRecordListDocumentTypesQuoteObjQuoteDocList() {
        Quote quote = [SELECT Id FROM Quote  WHERE Contratto_Verificato__c = TRUE LIMIT 1];
        DocumentType__c docType;
        String quoteId = quote.Id;
        List<String> documentTypeBlockList = getDocBlockList();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id, ObjectName__c, Doc_Opzionale__c, Status_Stage_Visible__c FROM DocumentType__c WHERE ObjectName__c = 'Quote' LIMIT 1];
        result = fileUploaderDAO.getRecordListDocumentTypes(quoteId, 'Quote', 'Quote', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
        System.assertEquals(true, result.containsKey(docType.Id), 'Document Type not saved in result');
    }

    @IsTest
    static void testGetRecordListDocumentTypesWrongInput() {
        List<String> documentTypeBlockList = new List<String>();
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        result = fileUploaderDAO.getRecordListDocumentTypes('wrongId', 'wrongObj', 'wrongObj', documentTypeBlockList);
        Test.stopTest();

        System.assertEquals(true, result.size() == 0, 'Result is not empty');
    }

    @IsTest
    static void testGetRecordListDocumentTypesNullInput() {
        Map<String, DocumentType__c> result = new Map<String, DocumentType__c>();

        Test.startTest();
        result = fileUploaderDAO.getRecordListDocumentTypes(null, null, null, null);
        Test.stopTest();

        System.assertEquals(true, result.size() == 0, 'Result is not empty');
    }

    @IsTest
    static void testUpdateCommentInDocuments() {
        DocumentType__c docType;
        Map<String, Document__c> documentList;
        List<String> documentIdList;
        String commentToBeSaved = 'More Documents Required';
        String result;

        Test.startTest();
        addDocsAndDocTypes();
        docType = [SELECT Id FROM DocumentType__c LIMIT 1];
        documentList = new Map<String, Document__c>([SELECT Id FROM Document__c WHERE DocumentType__c = :docType.Id]);
        documentIdList = new List<String>(documentList.keySet());
        result = fileUploaderDAO.UpdateCommentInDocuments(documentIdList, commentToBeSaved);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Result is null');
        System.assertEquals(true, result == commentToBeSaved, 'Saved comment is different');
    }

    @IsTest
    static void testUpdateCommentInDocumentsNullDocList() {
        String commentToBeSaved = 'More Documents Required';
        String customException, result;

        Test.startTest();
        try {
            result = fileUploaderDAO.UpdateCommentInDocuments(null, commentToBeSaved);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == 'Attempt to de-reference a null object', 'Result is not null');
    }

    @IsTest
    static void testUpdateCommentInDocumentsNullComment() {
        String customException, result;

        Test.startTest();
        try {
            addDocsAndDocTypes();
            DocumentType__c docType = [SELECT Id FROM DocumentType__c LIMIT 1];
            Map<String, Document__c> documentList = new Map<String, Document__c>([SELECT Id FROM Document__c WHERE DocumentType__c = :docType.Id]);
            List<String> documentIdList = new List<String>(documentList.keySet());
            result = fileUploaderDAO.UpdateCommentInDocuments(documentIdList, null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, result == null, 'Result is not null');
    }

    @IsTest
    static void testGetdocTypeIdSetOppCont() {
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        String contId = cont.Id;
        Set<Id> result = new Set<Id>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getdocTypeIdSet('Opportunity', 'Contact', '', contId);
        Test.stopTest();

        System.assertEquals(true,result.size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetdocTypeIdSetAccCont() {
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        String contId = cont.Id;
        Set<Id> result = new Set<Id>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getdocTypeIdSet('Account', 'Contact', '', contId);
        Test.stopTest();

        System.assertEquals(true,result.size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetdocTypeIdSetContCont() {
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        String contId = cont.Id;
        Set<Id> result = new Set<Id>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getdocTypeIdSet('Contact', 'Contact', contId, '');
        Test.stopTest();

        System.assertEquals(true,result.size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetOptionalDocumentList() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String oppId = opp.Id;
        String accId = acc.Id;
        Map<String, String> input = new Map<String, String> {
                'opportunityId' => oppId,
                'accountId' => accId
        };
        Map<String, Object> result = new Map<String, Object>();
        Map<String, List<Document__c>> allDocsByDocType = new Map<String, List<Document__c>>();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getOptionalDocumentList(JSON.serialize(input));
        allDocsByDocType = (Map<String, List<Document__c>> ) result.get('allDocsByDocType');
        System.assertEquals(true, allDocsByDocType.size() > 0, 'Result is empty');
        Test.stopTest();
    }

    @IsTest
    static void testGetOptionalDocumentListWrongIds() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String oppId = opp.Id;
        String accId = acc.Id;
        Map<String, String> input = new Map<String, String> {
                'opportunityId' => accId,
                'accountId' => oppId
        };
        Map<String, Object> result = new Map<String, Object>();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getOptionalDocumentList(JSON.serialize(input));
        System.assertEquals(true, result.get('error'), 'Result is NOT an error');
        System.assertEquals(true, result.get('errorMsg') == 'List index out of bounds: 0', 'List is NOT out of bounds');
        Test.stopTest();
    }


    @IsTest
    static void testGetOptionalDocumentTypesList() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        List<String> docBlocks = getDocBlockList();
        Map<String, String> input = new Map<String, String> {
                'recordId' => oppId,
                'block' => JSON.serialize(docBlocks)
        };
        Map<String, Object> result = new Map<String, Object>();
        Map<String, DocumentType__c> allDocTypes = new Map<String, DocumentType__c>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getOptionalDocumentTypesList(JSON.serialize(input));
        Test.stopTest();

        allDocTypes = (Map<String, DocumentType__c>) result.get('allDocTypes');

        System.assertEquals(true, allDocTypes.size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetOptionalDocumentTypesListWrongInput() {
        List<String> docBlocks = getDocBlockList();
        Map<String, String> input = new Map<String, String> {
                'recordId' => '',
                'block' => JSON.serialize(docBlocks)
        };
        Map<String, Object> result = new Map<String, Object>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getOptionalDocumentTypesList(JSON.serialize(input));
        Test.stopTest();

        System.assertEquals(true, result.get('error') == true, 'Result is not an error');
        System.assertEquals(true, result.get('errorMsg') == 'List has no rows for assignment to SObject', 'List has no rows for assignment to SObject');
    }

    @IsTest
    static void testGetVisibleForStage() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        List<String> result = new List<String>();

        Test.startTest();
        result = fileUploaderDAO.getVisibleForStage(opp);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result is empty');
    }

    @IsTest
    static void testGetVisibleForStageWrongInput() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String errorMsg;

        Test.startTest();
        try {
            fileUploaderDAO.getVisibleForStage(opp);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, errorMsg == 'SObject row was retrieved via SOQL without querying the requested field: Opportunity.StageName', errorMsg);
    }

    @IsTest
    static void testGetConditionsDocumentsOpp() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        Map<String, Object> result = new Map<String, Object>();
        result = fileUploaderDAO.conditionsDocuments(oppId, 'Opportunity', '', '');
        System.assertEquals(true, result.get('isAdmin') == true, 'User is not admin');
        System.assertEquals(true, result.get('profileName') == profileName, 'Returned profile name is incorrect');
        System.assertEquals(true, result.get('isStageFirma') == false, 'Opp stage is incorrect');
        Test.stopTest();
    }

    @IsTest
    static void testGetConditionsDocumentsAccount() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String accId = acc.Id;
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        Map<String, Object> result = new Map<String, Object>();
        result = fileUploaderDAO.conditionsDocuments(accId, 'Account', '', '');
        System.assertEquals(true, result.get('isAdmin') == true, 'User is not admin');
        System.assertEquals(true, result.get('profileName') == profileName, 'Returned profile name is incorrect');
        System.assertEquals(true, result.get('isErogazioneNO') == true, 'Incorrect erogazione_dei_servizi__c value for account');
        Test.stopTest();
    }

    @IsTest
    static void testGetConditionsDocumentsOppQuote() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        Quote quote = [SELECT Id FROM Quote][1];
        String quoteId = quote.Id;
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        Map<String, Object> result = new Map<String, Object>();
        result = fileUploaderDAO.conditionsDocuments(oppId, 'Opportunity', 'Quote', quoteId);
        System.assertEquals(true, result.get('isAdmin') == true, 'User is not admin');
        System.assertEquals(true, result.get('profileName') == profileName, 'Returned profile name is incorrect');
        System.assertEquals(true, result.get('isStageFirma') == false, 'Opp stage is incorrect');
        System.assertEquals(true, result.get('isContratoVerificato') == true, 'Quote contract value is incorrect');
         Test.stopTest();
    }

    @IsTest
    static void testGetConditionsDocumentsQuote() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote][1];
        String quoteId = quote.Id;
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        Map<String, Object> result = new Map<String, Object>();
        result = fileUploaderDAO.conditionsDocuments(quoteId, 'Quote', 'Quote', quoteId);
         System.assertEquals(true, result.get('isAdmin') == true, 'User is not admin');
        System.assertEquals(true, result.get('profileName') == profileName, 'Returned profile name is incorrect');
        System.assertEquals(true, result.get('isStageFirma') == false, 'Opp stage is incorrect');
        System.assertEquals(true, result.get('isContratoVerificato') == true, 'Quote contract value is incorrect');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateNote() {
        Document__c document = new Document__c();

        Test.startTest();
        addDocsAndDocTypes();
        document = [SELECT Id, Commento_Sales_Support__c FROM Document__c LIMIT 1];
        fileUploaderDAO.updateNote(document.Id, 'Comment to be saved');
        Test.stopTest();

        Document__c updatedDoc = [SELECT Id, Commento_Sales_Support__c FROM Document__c WHERE Id = :document.Id];

        System.assertEquals(true, updatedDoc.Commento_Sales_Support__c == 'Comment to be saved', 'Saved comment is different');
    }

    @IsTest
    static void testUpdateNoteWrongInput() {
        String customException;

        Test.startTest();
        try {
            fileUploaderDAO.updateNote('wrongId', 'Comment to be saved');
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException == null, 'Returned list is not nullll');
    }

    @IsTest
    static void testUpdatePickVerificaOK() {
        Document__c document = new Document__c();
        Document__c result = new Document__c();
        String verificaValue = 'Verifica OK';

        Test.startTest();
        addDocsAndDocTypes();
        document = [SELECT Id, Verifica_Sales_Support__c FROM Document__c LIMIT 1];
        result = fileUploaderDAO.updatePick(document.Id, verificaValue);
        Test.stopTest();

        System.assertEquals(true, result.Id == document.Id, 'Wrong document returned');
        System.assertEquals(true, result.Verifica_Sales_Support__c == verificaValue, 'Wrong verifica value returned');
    }

    @IsTest
    static void testUpdatePickDaVerificare() {
        Document__c document = new Document__c();
        Document__c result = new Document__c();
        String verificaValue = 'Da Verificare';

        Test.startTest();
        addDocsAndDocTypes();
        document = [SELECT Id, Verifica_Sales_Support__c FROM Document__c LIMIT 1];
        result = fileUploaderDAO.updatePick(document.Id, verificaValue);
        Test.stopTest();

        System.assertEquals(true, result.Id == document.Id, 'Wrong document returned');
        System.assertEquals(true, result.Verifica_Sales_Support__c == verificaValue, 'Wrong verifica value returned');
    }

    @IsTest
    static void testUpdatePickInvalidVerifica() {
        Document__c document = new Document__c();
        String verificaValue = 'Invalid Value';
        String customException;

        Test.startTest();
        addDocsAndDocTypes();
        document = [SELECT Id, Verifica_Sales_Support__c FROM Document__c LIMIT 1];
        try {
            fileUploaderDAO.updatePick(document.Id, verificaValue);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, customException != null, 'No error was thrown');
        System.assertEquals(true, customException.contains('Verifica Sales Support: bad value for restricted picklist field'));
    }

    @IsTest
    static void testUpdatePickInvalidDocument() {
        String verificaValue = 'Verifica OK';
        Document__c result;

        Test.startTest();
        result = fileUploaderDAO.updatePick('wrongId', verificaValue);
        Test.stopTest();
        System.debug('result = ' + result);
        System.debug('result.Id = ' + result.Id);
        System.assertEquals(true, result.Id == null, 'No Document record was returned');
    }


    @IsTest
    static void testAddFileOpp() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String commentToSave = 'Comment to be saved';
        String fileName = 'Test File Name';
        String docName = 'Test Doc Name';
        Document__c result = new Document__c();
        DocumentType__c documentType = new DocumentType__c();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        addDocsAndDocTypes();
        documentType = [SELECT Id, ID_Tipo_Documento__c FROM DocumentType__c WHERE ObjectName__c = 'Opportunity' AND ID_Tipo_Documento__c != NULL LIMIT 1];
        result = fileUploaderDAO.addFile(documentType.Id, '', docName, fileName, contentVersion.ContentDocumentId, '',
                commentToSave, opp, '', '');
        System.assertEquals(true, documentType.Id == result.DocumentType__c, 'Document has an invalid Document Type');
        System.assertEquals(true, result.Commento_Sales_Support__c == commentToSave, 'Wrong Comment value returned');
        System.assertEquals(true, result.File_Name__c == docName, 'Wrong file name returned');
        Test.stopTest();
    }

    @IsTest
    static void testAddFileAcc() {
         Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String commentToSave = 'Comment to be saved';
        String fileName = 'Test File Name';
        String docName = 'Test Doc Name';
        Document__c result = new Document__c();
        DocumentType__c documentType = new DocumentType__c();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        addDocsAndDocTypes();
        documentType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Account' LIMIT 1];
        result = fileUploaderDAO.addFile(documentType.Id, acc.Id, docName, fileName, contentVersion.ContentDocumentId, '',
                commentToSave, opp, '', '');
        System.assertEquals(true, documentType.Id == result.DocumentType__c, 'Document has an invalid Document Type');
        System.assertEquals(true, result.Commento_Sales_Support__c == commentToSave, 'Wrong Comment value returned');
        System.assertEquals(true, result.File_Name__c == docName, 'Wrong file name returned');
        Test.stopTest();
    }

    @IsTest
    static void testAddFileQuote() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id FROM Quote][1];
        String commentToSave = 'Comment to be saved';
        String fileName = 'Test File Name';
        String docName = 'Test Doc Name';
        Document__c result = new Document__c();
        DocumentType__c documentType = new DocumentType__c();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        addDocsAndDocTypes();
        documentType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Quote' LIMIT 1];
        result = fileUploaderDAO.addFile(documentType.Id, '', docName, fileName, contentVersion.ContentDocumentId, '',
                commentToSave, opp, '', quote.Id);
        System.assertEquals(true, documentType.Id == result.DocumentType__c, 'Document has an invalid Document Type');
        System.assertEquals(true, result.Commento_Sales_Support__c == commentToSave, 'Wrong Comment value returned');
        System.assertEquals(true, result.File_Name__c == docName, 'Wrong file name returned');
        Test.stopTest();
    }

    @IsTest
    static void testAddFileContact() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        String commentToSave = 'Comment to be saved';
        String fileName = 'Test File Name';
        String docName = 'Test Doc Name';
        Document__c result = new Document__c();
        DocumentType__c documentType = new DocumentType__c();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        addDocsAndDocTypes();
        documentType = [SELECT Id FROM DocumentType__c WHERE ObjectName__c = 'Contact' LIMIT 1];
        result = fileUploaderDAO.addFile(documentType.Id, '', docName, fileName, contentVersion.ContentDocumentId, '',
                commentToSave, opp, cont.Id, '');
        System.assertEquals(true, documentType.Id == result.DocumentType__c, 'Document has an invalid Document Type');
        System.assertEquals(true, result.Commento_Sales_Support__c == commentToSave, 'Wrong Comment value returned');
        System.assertEquals(true, result.File_Name__c == docName, 'Wrong file name returned');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateFileAggiungiOpp() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        Document__c result = new Document__c();
        addDocsAndDocTypes();
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Opportunity' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
        result = [SELECT Id, Id_File__c FROM Document__c WHERE Id =: document.Id];
        System.assertEquals(true, result.Id == document.Id, 'Wrong document updated');
        System.assertEquals(true, result.Id_File__c == contentVersion.ContentDocumentId, 'Wrong file id updated');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateFileAggiungiOppNoOpps() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        String result;
        addDocsAndDocTypes();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        delete oppList;
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Opportunity' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        result = fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
        System.assertEquals(true, result == '', 'Result should be empty string');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateFileAggiungiAcc() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        Document__c result = new Document__c();
        addDocsAndDocTypes();
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Account' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
        result = [SELECT Id, Id_File__c FROM Document__c WHERE Id =: document.Id];
        List<ContentVersion> cvList = [Select Id, ContentDocumentId FROM ContentVersion];
        System.assertEquals(true, result.Id == document.Id, 'Wrong document updated');
        Test.stopTest();

    }

    @IsTest
    static void testUpdateFileAggiungiAccNoAccs() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        String result;
        addDocsAndDocTypes();
        List<Account> accsToDelete = [SELECT Id FROM Account];
        delete accsToDelete;
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Account' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        result = fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
        System.assertEquals(true, result == '', 'Result should be empty string');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateFileAggiungiContact() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        Document__c result = new Document__c();
        addDocsAndDocTypes();
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Contact' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
  		result = [SELECT Id, Id_File__c FROM Document__c WHERE Id =: document.Id];
        System.assertEquals(true, result.Id == document.Id, 'Wrong document updated');
        System.assertEquals(true, result.Id_File__c == contentVersion.ContentDocumentId, 'Wrong file id updated');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateFileAggiungiContactNoContacts() {
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        String result;

        Test.startTest();
        addDocsAndDocTypes();
        List<Contact> contList = [SELECT Id FROM Contact];
        delete contList;
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Contact' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        result = fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
        Test.stopTest();

        System.assertEquals(true, result == '', 'Result should be empty string');
    }

    @IsTest
    static void testUpdateFileAggiungiQuote() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c result = new Document__c();
        addDocsAndDocTypes();
        DocumentType__c documentType = ObjectFactory.insertNewDocumentType('Contact');
        //insert documentType;
        List<ContentVersion> cntVersion = new List<ContentVersion>();
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'Analisi Coface.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = 'Analisi Coface.pdf';
        cVersion.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cntVersion.add(cVersion);
        insert cntVersion;
        
        ContentVersion c =[SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id IN:cntVersion limit 1];
        Document__c document = new Document__c();
        document.Name = 'Eleva';
        document.DocumentType__c = documentType.Id;
        document.Commento_Sales_Support__c = 'Elevaaaa';
        document.Id_File__c=c.ContentDocumentId;
        insert document;
        
        ContentVersion cVer = new ContentVersion();
        cVer.ContentLocation = 'S';
        cVer.PathOnClient = 'Analisi Coface.pdf';
        cVer.Origin = 'H';
        cVer.Title = 'Analisi Coface.pdf';
        cVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cVer;
        DocumentType__c dT = ObjectFactory.insertNewDocumentType('Quote');
        ContentVersion cv =[SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id =: cVer.id];
        Document__c d = new Document__c();
        d.Name = 'DocFide';
        d.DocumentType__c = dT.Id;
        d.Commento_Sales_Support__c = 'Elevaaaa';
        d.Id_File__c=cv.ContentDocumentId;
        insert d;
        Document__c doc = [Select Id, Id_File__c, Name  From Document__c where Name = 'DocFide'];
        Document__c docu = [SELECT Id, Id_File__c FROM Document__c WHERE Name = 'Eleva'];
        String fileId = docu.Id_File__c;
        String fidejussioneFileId = doc.Id_File__c;
        fileUploaderDAO.updateFile(fileId, 'Test File Name', fidejussioneFileId, 'aggiungi');
       // System.assertEquals(true, fidejussioneFileId == fileId, 'Wrong document updated');
        //System.assertEquals(true, result.Id_File__c == contentVersion.ContentDocumentId, 'Wrong file id updated');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateFileAggiungiQuoteNoQuotes() {
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        String result;

        Test.startTest();
        addDocsAndDocTypes();
        List<Quote> quoteList = [SELECT Id FROM Quote];
        delete quoteList;
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Quote' AND IDTipoDocumentoFormula__c != NULL LIMIT 1];
        result = fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'aggiungi');
        Test.stopTest();

        System.assertEquals(true, result == '', 'Result should be empty string');
    }

    @IsTest
    static void testUpdateFileElimina() {
        Test.startTest();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Document__c document = new Document__c();
        Document__c result = new Document__c();
        addDocsAndDocTypes();
        document = [SELECT Id FROM Document__c WHERE ObjectName__c = 'Quote' LIMIT 1];
        fileUploaderDAO.updateFile(document.Id, 'Test File Name', contentVersion.ContentDocumentId, 'elimina');
        result = [SELECT Id, Id_File__c FROM Document__c WHERE Id =: document.Id];
        System.assertEquals(true, result.Id == document.Id, 'Wrong document updated');
        System.assertEquals(true, result.Id_File__c == contentVersion.ContentDocumentId, 'Wrong file id updated');
        Test.stopTest();
    }

    @IsTest
    static void testEliminateDocuments() {
        Test.startTest();
        addDocsAndDocTypes();
        Map<String, Document__c> docsToDelete = new Map<String, Document__c>([SELECT Id FROM Document__c LIMIT 5]);
        List<String> docIdsToDelete = new List<String>(docsToDelete.keySet());
        fileUploaderDAO.eliminateDocuments(docIdsToDelete);
        Test.stopTest();
    }

    private static List<String> getDocBlockList() {
         List<String> documentTypeBlockList = new List<String>();
         Schema.DescribeFieldResult fieldResult = DocumentType__c.Document_Block__c.getDescribe();
         List<Schema.PicklistEntry> piclistValues = fieldResult.getPicklistValues();

         for (Schema.PicklistEntry pickListVal : piclistValues) {
             documentTypeBlockList.add(pickListVal.getLabel());
         }

         return documentTypeBlockList;
     }

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
            } else if (i == 4) {
                docType.ID_Tipo_Documento__c = 'SME_057';
                optDocType.ID_Tipo_Documento__c = 'SME_058';
            } else if (i == 7) {
                docType.ID_Tipo_Documento__c = 'SME_100';
                optDocType.ID_Tipo_Documento__c = 'SME_101';
            } else if (i == 10) {
                docType.ID_Tipo_Documento__c = 'SME_026';
                optDocType.ID_Tipo_Documento__c = 'SME_027';
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

            docList.add(newDoc);

            if ((i / 2) == Math.round(i / 2)) {
                docList.add(secondaryDoc);
            }
        }

        return docList;
    }

}