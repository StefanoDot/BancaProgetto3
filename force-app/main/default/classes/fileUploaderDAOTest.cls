@IsTest
public with sharing class fileUploaderDAOTest {

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

    }
    
    @IsTest
    static void testGetContactListForOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        List<Contact> result = new List<Contact>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getContactList(opp.Id, 'Opportunity');
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'No contacts retrieved');
    }

    @IsTest
    static void testGetContactListForAccount() {
        Account acc = [SELECT Id FROM Account][0];
        List<Contact> result = new List<Contact>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getContactList(acc.Id, 'Account');
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'No contacts retrieved');
    }

    @IsTest
    static void testGetContactListForContact() {
        Contact cont = [SELECT Id FROM Contact][0];
        List<Contact> result = new List<Contact>();

        Test.startTest();
        addDocsAndDocTypes();
        result =  fileUploaderDAO.getContactList(cont.Id, 'Contact');
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'No contacts retrieved');
    }

    @IsTest
    static void testGetQuoteListForOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        List<Quote> result = new List<Quote>();

        Test.startTest();
        addDocsAndDocTypes();
        result = fileUploaderDAO.getQuoteList(opp.Id, 'Opportunity');
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'No quotes retrieved');
    }

    @IsTest
    static void testDocQuerryOppOpp() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        String oppId = opp.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Opportunity', 'Opportunity', oppId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, '');
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryOppAcc() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account][0];
        String accId = acc.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Opportunity', 'Account', accId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, '');
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryAccAcc() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account][0];
        String accId = acc.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Account', 'Account', accId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, '');
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryOppCont() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        Contact cont = [SELECT Id FROM Contact][0];
        String oppId = opp.Id;
        String contId = cont.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Opportunity', 'Contact', oppId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, contId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryContCont() {
        Test.startTest();
        Contact cont = [SELECT Id, Fidejussore__c FROM Contact][0];
        String contId = cont.Id;
        List<DocumentType__c> docTypeList = new List<DocumentType__c>();
        Set<Id> docTypeIdSet = new Set<Id>();
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        if (cont != null) {
            if (cont.Fidejussore__c == true) {
                docTypeList = [SELECT Id, Name, Referente_Fidejussore__c FROM DocumentType__c WHERE ObjectName__c = 'Contact'];
            } else if (cont.Fidejussore__c == false && ((cont.Ruolo_in_Azienda__c == 'Titolare Effettivo') || (cont.Ruolo_in_Azienda__c == 'Legale Rappresentante') || (cont.Ruolo_in_Azienda__c == 'Titolare Effettivo;Legale Rappresentante'))) {
                docTypeList = [SELECT Id, Name,Referente_Fidejussore__c FROM DocumentType__c WHERE ObjectName__c = 'Contact' AND Referente_Fidejussore__c = FALSE];
            }
        }

        for (DocumentType__c docType : docTypeList) {
            docTypeIdSet.add(docType.Id);
        }

        result = fileUploaderDAO.docQuerry('Contact', 'Contact', contId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, docTypeIdSet, contId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryOppQuote() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote][1];
        String quoteId = quote.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Opportunity', 'Quote', quoteId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, quoteId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryQuoteQuote() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote][1];
        String quoteId = quote.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Quote', 'Quote', quoteId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, quoteId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testDocQuerryAccCont() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        Contact cont = [SELECT Id FROM Contact][0];
        String oppId = opp.Id;
        String contId = cont.Id;
        List<Document__c> result = new List<Document__c>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.docQuerry('Account', 'Contact', oppId, new List<String>{'Delibera'}, new List<String>{'Primo Contatto'}, new Set<Id>{}, contId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAll() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        String oppId = opp.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAll(oppId, new List<String>{'Delibera'});
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllOppAcc() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        String oppId = opp.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllAcc(oppId, 'Opportunity', new List<String>{'Delibera'});
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllAccAcc() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account][0];
        String accId = acc.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllAcc(accId, 'Account', new List<String>{'Delibera'});
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }


    @IsTest
    static void testGetRecordListDocumentAllOppCont() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        Contact cont = [SELECT Id FROM Contact][0];
        String oppId = opp.Id;
        String contId = cont.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllCont(oppId, 'Opportunity', new List<String>{'Delibera'}, contId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllAccCont() {
        Test.startTest();
        Contact cont = [SELECT Id FROM Contact][0];
        Account acc = [SELECT Id FROM Account][0];
        String contId = cont.Id;
        String accId = acc.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllCont(accId, 'Account', new List<String>{'Delibera'}, contId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllContCont() {
        Test.startTest();
        Contact cont = [SELECT Id FROM Contact][0];
        String contId = cont.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllCont(contId, 'Contact', new List<String>{'Delibera'}, contId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllOppQuote() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        Quote quote = [SELECT Id FROM Quote][1];
        String oppId = opp.Id;
        String quoteId = quote.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllQuote(oppId, 'Opportunity', new List<String>{'Delibera'}, quoteId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecordListDocumentAllQuoteQuote() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        Quote quote = [SELECT Id FROM Quote][1];
        String oppId = opp.Id;
        String quoteId = quote.Id;
        Map<String, List<Document__c>> result = new Map<String, List<Document__c>>();

        
        addDocsAndDocTypes();
        result = fileUploaderDAO.getRecordListDocumentAllQuote(quoteId, 'Quote', new List<String>{'Delibera'}, quoteId);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        Test.stopTest();
    }
    
    @IsTest
    static void testNDG(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        String oppId = opp.Id;
        
        
        fileUploaderDAO.richiediNdg(oppId);
        Test.stopTest();

    }
    
    @IsTest
    static void testGetOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Opportunity returnedOpp = new Opportunity();
        String oppId = opp.Id;

        Test.startTest();
        returnedOpp = fileUploaderDAO.getOpportunity(oppId);
        Test.stopTest();

        System.assertEquals(true, returnedOpp != null, 'Requested opportunity does not exist in database');
        System.assertEquals(true, Schema.Opportunity.getSObjectType() == returnedOpp.getSObjectType(), 'Returned object is not an Opportunity');
        System.assertEquals(true, opp.Id == returnedOpp.Id, 'Different opp returned');
    }

    @IsTest
    static void testGetOpportunityWrongString() {
        Opportunity returnedOpp = new Opportunity();
        String customException;

        Test.startTest();
        try {
            returnedOpp = fileUploaderDAO.getOpportunity('wrongId');
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testGetOpportunityNullInput() {
        Opportunity returnedOpp = new Opportunity();
        String customException;

        Test.startTest();
        try {
            returnedOpp = fileUploaderDAO.getOpportunity(null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testGetAccount() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account returnedAcc = new Account();
        String accId = acc.Id;

        
        returnedAcc = fileUploaderDAO.getAccount(accId);
        

        System.assertEquals(true, returnedAcc != null, 'Requested account does not exist in database');
        System.assertEquals(true, Schema.Account.getSObjectType() == returnedAcc.getSObjectType(), 'Returned object is not an Account');
        System.assertEquals(true, accId == returnedAcc.Id, 'Different account returned');
        Test.stopTest();
    }

    @IsTest
    static void testGetAccountWrongString() {
        Account returnedAcc = new Account();
        String customException;

        Test.startTest();
        try {
            returnedAcc = fileUploaderDAO.getAccount('wrongId');
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testGetAccountNullInput() {
        Account returnedAcc = new Account();
        String customException;

        Test.startTest();
        try {
            returnedAcc = fileUploaderDAO.getAccount(null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testGetContactFromAccount() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact returnedCont = new Contact();
        String accId = acc.Id;

        
        returnedCont = fileUploaderDAO.getContactFromAccount(accId);
        

        System.assertEquals(true, returnedCont != null, 'Requested contact does not exist in database');
        System.assertEquals(true, Schema.Contact.getSObjectType() == returnedCont.getSObjectType(), 'Returned object is not a Contact');
        System.assertEquals(true, acc.Id == returnedCont.AccountId, 'Different contact returned');
        Test.stopTest();
    }

    @IsTest
    static void testGetContactFromAccountWrongString() {
        Account returnedAcc = new Account();
        String customException;

        Test.startTest();
        try {
            returnedAcc = fileUploaderDAO.getAccount('wrongId');
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testGetContactFromAccountNullInput() {
        Account returnedAcc = new Account();
        String customException;

        Test.startTest();
        try {
            returnedAcc = fileUploaderDAO.getAccount(null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testGetContact() {
        Test.startTest();
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Contact returnedCont = new Contact();
        String contId = cont.Id;

        
        returnedCont = fileUploaderDAO.getContact(contId);
        

        System.assertEquals(true, returnedCont != null, 'Requested contact does not exist in database');
        System.assertEquals(true, Schema.Contact.getSObjectType() == returnedCont.getSObjectType(), 'Returned object is not a Contact');
        System.assertEquals(true, contId == returnedCont.Id, 'Different contact returned');
        Test.stopTest();
    }

    @IsTest
    static void testGetContactWrongString() {
        Contact returnedCont = new Contact();
        String customException;

        Test.startTest();
        try {
            returnedCont = fileUploaderDAO.getContact('wrongId');
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List has no rows for assignment to SObject');
    }

    @IsTest
    static void testGetContactNullInput() {
        Contact returnedCont = new Contact();
        String customException;

        Test.startTest();
        try {
            returnedCont = fileUploaderDAO.getContact(null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List has no rows for assignment to SObject');
    }

    @IsTest
    static void testGetQuote() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Quote returnedQuote = new Quote();
        String quoteId = quote.Id;

        
        returnedQuote = fileUploaderDAO.getQuote(quoteId);
        

        System.assertEquals(true, returnedQuote != null, 'Requested quote does not exist in database');
        System.assertEquals(true, Schema.Quote.getSObjectType() == returnedQuote.getSObjectType(), 'Returned object is not a Quote');
        System.assertEquals(true, quoteId == returnedQuote.Id, 'Different quote returned');
        Test.stopTest();
    }

    @IsTest
    static void testGetQuoteWrongString() {
        Quote returnedQuote = new Quote();
        String customException;

        Test.startTest();
        try {
            returnedQuote = fileUploaderDAO.getQuote('wrongId');
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List has no rows for assignment to SObject');
    }

    @IsTest
    static void testGetQuoteNullInput() {
        Quote returnedQuote = new Quote();
        String customException;

        Test.startTest();
        try {
            returnedQuote = fileUploaderDAO.getQuote(null);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List has no rows for assignment to SObject');
    }

    @IsTest
    static void testUpdateCheckTrue() {
        Test.startTest();
        Document__c doc;
        Opportunity opp;
        Boolean checkBox = true;

        
        addDocsAndDocTypes();
        doc = [SELECT Id, Opportunity__c, Notifica_Inside_Sales__c FROM Document__c LIMIT 1];
        opp = [SELECT Id, Notifica_IS_Modulo_Finanziamento__c FROM Opportunity WHERE Id =: doc.Opportunity__c];
        fileUploaderDAO.updateCheck(doc.Id, checkBox);
        

        Document__c updatedDoc = [SELECT Id, Opportunity__c, Notifica_Inside_Sales__c FROM Document__c WHERE Id =: doc.Id];
        Opportunity updatedOpp = [SELECT Id, Notifica_IS_Modulo_Finanziamento__c FROM Opportunity WHERE Id =: opp.Id];

        System.assertEquals(true, updatedDoc.Notifica_Inside_Sales__c == checkBox, 'doc Notifica_Inside_Sales has incorrect value');
        System.assertEquals(true, updatedOpp.Notifica_IS_Modulo_Finanziamento__c, 'Notifica_Inside_Sales has incorrect value');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateCheckFalse() {
        Test.startTest();
        Document__c doc;
        Opportunity opp;
        Boolean checkBox = false;

        
        addDocsAndDocTypes();
        doc = [SELECT Id, Opportunity__c, Notifica_Inside_Sales__c FROM Document__c LIMIT 1];
        opp = [SELECT Id, Notifica_IS_Modulo_Finanziamento__c FROM Opportunity WHERE Id =: doc.Opportunity__c];
        fileUploaderDAO.updateCheck(doc.Id, checkBox);
        

        Document__c updatedDoc = [SELECT Id, Opportunity__c, Notifica_Inside_Sales__c FROM Document__c WHERE Id =: doc.Id];
        Opportunity updatedOpp = [SELECT Id, Notifica_IS_Modulo_Finanziamento__c FROM Opportunity WHERE Id =: opp.Id];

        System.assertEquals(true, updatedDoc.Notifica_Inside_Sales__c == checkBox, 'doc Notifica_Inside_Sales has incorrect value');
        System.assertEquals(true, updatedOpp.Notifica_IS_Modulo_Finanziamento__c, 'Notifica_Inside_Sales has incorrect value');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateCheckDocWithNoOpp() {
        Document__c doc;
        Boolean checkBox = false;
        String customException;

        Test.startTest();
        try {
            addDocsAndDocTypes();
            doc = [SELECT Id, Opportunity__c, Notifica_Inside_Sales__c FROM Document__c WHERE Opportunity__c = NULL LIMIT 1];
            fileUploaderDAO.updateCheck(doc.Id, checkBox);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, 'List index out of bounds: 0');
    }

    @IsTest
    static void testUpdateCheckWrongInput() {
        String customException;

        Test.startTest();
        try {
            fileUploaderDAO.updateCheck('wrongInd', false);
        } catch (Exception ex) {
            customException = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(customException, null);
    }

    @IsTest
    static void testConditionsDocumentsOpportunities() {
        Test.startTest();
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE StageName = 'Primo Contatto' LIMIT 1];
        Map<String, Object> result = new Map<String, Object>();

        
        result = fileUploaderDAO.conditionsDocuments(opp.Id, 'Opportunity', 'Opportunity', '');
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        System.assertEquals(true, result.get('isStageFirma') == false, 'Opportunity Stage is not Primo Contatto');
        System.assertEquals(true, sysAdminProfile.Name == result.get('profileName'), 'Profile name returned is different');
        Test.stopTest();
    }

    @IsTest
    static void testConditionsDocumentsAccounts() {
        Test.startTest();
        Account acc = [SELECT Id, erogazione_dei_servizi__c, RecordType.Name FROM Account LIMIT 1];
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Map<String, Object> result = new Map<String, Object>();

        
        result = fileUploaderDAO.conditionsDocuments(acc.Id, 'Account', 'Account', '');
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        System.assertEquals(false, result.get('isErogazioneNO') == false, 'Erogazione has incorrect value');
        System.assertEquals(true, sysAdminProfile.Name == result.get('profileName'), 'Profile name returned is different');
        Test.stopTest();
    }

    @IsTest
    static void testConditionsDocumentsContacts() {
        Test.startTest();
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Map<String, Object> result = new Map<String, Object>();

        
        result = fileUploaderDAO.conditionsDocuments(cont.Id, 'Contact', 'Contact', '');
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        System.assertEquals(false, result.get('isErogazioneNO') == false, 'Erogazione has incorrect value');
        System.assertEquals(true, sysAdminProfile.Name == result.get('profileName'), 'Profile name returned is different');
        Test.stopTest();
    }

    @IsTest
    static void testConditionsDocumentsQuotes() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Map<String, Object> result = new Map<String, Object>();

        
        result = fileUploaderDAO.conditionsDocuments(quote.Id, 'Quote', 'Quote', quote.Id);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        System.assertEquals(true, result.get('isContratoVerificato') == false, 'isContratoVerificato has incorrect value');
        System.assertEquals(true, result.get('isFirmaDigitale') == false, 'isFirmaDigitale has incorrect value');
        System.assertEquals(true, sysAdminProfile.Name == result.get('profileName'), 'Profile name returned is different');
        Test.stopTest();
    }

    @IsTest
    static void testConditionsDocumentsQuotesNullQuote() {
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Map<String, Object> result = new Map<String, Object>();

        
        result = fileUploaderDAO.conditionsDocuments(quote.Id, 'Quote', 'Quote', null);
        

        System.assertEquals(true, result.size() > 0, 'Result is null');
        System.assertEquals(true, result.get('isFirmaDigitale') == false, 'isFirmaDigitale has incorrect value');
        System.assertEquals(true, result.get('isContratoVerificato') == false, 'isContratoVerificato has incorrect value');
        System.assertEquals(true, sysAdminProfile.Name == result.get('profileName'), 'Profile name returned is different');
        Test.stopTest();
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