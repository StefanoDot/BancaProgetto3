public with sharing class fileUploaderDAO extends ApexServiceLibraryCnt {

    public static Profile profileData;
    
    public class FidejussoreResponse {
        @AuraEnabled
        public Boolean ok { set; get; }
        @AuraEnabled
        public String responseMessage { set; get; }

    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList(String recordId, String objectApiName) {
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opp = new List<Opportunity>();
        String OppAccountId;

        if (objectApiName == 'Opportunity') {
            opp = [SELECT Id, AccountId, Name FROM Opportunity WHERE Id = :recordId LIMIT 1];
            OppAccountId = opp[0].AccountId;
            for (Contact contact : [
                    SELECT Id, AccountId, Name, Fidejussore__c, Firmatario__c, Esecutore__c, Interessato__c, Ruolo_in_Azienda__c, (SELECT Id FROM Documenti__r)
                    FROM Contact
                    WHERE AccountId = :OppAccountId
                    AND (Ruolo_in_Azienda__c IN ('Titolare Effettivo','Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante') OR Fidejussore__c = true OR Firmatario__c = true OR Esecutore__c = true OR Interessato__c = true)
            ]) {
                contactList.add(contact);
            }
        } else if (objectApiName == 'Account') {
            for (Contact val : [
                    SELECT Id, AccountId, Name, Fidejussore__c, Ruolo_in_Azienda__c, (SELECT Id FROM Documenti__r)
                    FROM Contact
                    WHERE AccountId = :recordId
                    AND Ruolo_in_Azienda__c IN ('Titolare Effettivo','Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')
            ]) {
                contactList.add(val);
            }
        } else if (objectApiName == 'Contact') {
            for (Contact val : [
                    SELECT Id, AccountId, Name, Fidejussore__c, Ruolo_in_Azienda__c, (SELECT Id FROM Documenti__r)
                    FROM Contact
                    WHERE Id = :recordId
                    AND Ruolo_in_Azienda__c IN ('Titolare Effettivo','Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')
            ]) {
                contactList.add(val);
            }
        }
        return contactList;
    }


    @AuraEnabled(cacheable=true)
    public static List<Quote> getQuoteList(String record, String objectApiName) {
        System.debug('fileUploaderDAO.getQuoteList trigger - Start record ' + record + ' objectApiName ' + objectApiName);
        List<Quote> quoteList = new List<Quote>();

        if (objectApiName == 'Opportunity') {
            for (Quote quote : [
                    SELECT Id, Name, Finalita_Finanziamento__c, Status,Dettaglio_Finalit_Finanziamento__c, Tipo_Linea_di_Credito__c,
                            Tipo_di_Garanzia__c, (SELECT Id FROM Documenti__r), (SELECT Id, Tipo_di_Garanzia__c, Tipo_di_Fidejussione__c FROM Garanzie__r)
                    FROM Quote
                    WHERE OpportunityId = :record
            ]) {
                if (quote.Status != 'Annullata') {
                    quoteList.add(quote);
                }
            }
        }

        return quoteList;
    }


    public static List<Document__c> docQuerry(String objName, String nameOfTheobj, String record, List<String> block, List<String> VisibleForStage, Set<Id> docTypeIdSet, String selectedCont) {
        List<Document__c> result = new List<Document__c>();
        String queryAddOn;

        String currentProfileName;

        if(profileData == null){
            profileData = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        }
        
        currentProfileName = profileData.Name;

        System.debug('currentProfileName ' + currentProfileName);

        String order ;
        if (nameOfTheobj == 'Account') {
            order = ' ORDER BY ObligatarioAcc__c ASC';
        } else if (nameOfTheobj == 'Opportunity') {
            order = ' ORDER BY Obbligatorio__c DESC';
        } else if (nameOfTheobj == 'Quote') {
            order = ' ORDER BY ObligatorioQuote__c ASC';
        } else if (nameOfTheobj == 'Contact') {
            order = ' ORDER BY ObligatorioCont__c DESC';
        }

        if (objName == 'Opportunity' && nameOfTheobj == 'Opportunity') {
            queryAddOn = 'WHERE Opportunity__c = :record AND DocumentBlockFormula__c in :block  AND  ' +
                    'DocumentType__r.ObjectName__c	= :nameOfTheobj AND DocumentType__r.Status_Stage_Visible__c IN :VisibleForStage ' ;
        } else if (objName == 'Account' && nameOfTheobj == 'Account') {
            queryAddOn = 'WHERE Account__c = :record AND DocumentBlockFormula__c in :block AND DocumentType__r.ObjectName__c = :nameOfTheobj ';
        } else if (objName == 'Opportunity' && nameOfTheobj == 'Account') {
            queryAddOn = 'WHERE Account__c = :record AND DocumentBlockFormula__c in :block AND DocumentType__r.ObjectName__c = :nameOfTheobj AND DocumentType__r.Status_Stage_Visible__c IN :VisibleForStage ';
        } else if (objName == 'Contact' && nameOfTheobj == 'Contact') {
            queryAddOn = 'WHERE Contact__c = :record AND DocumentBlockFormula__c in :block AND DocumentType__r.ObjectName__c = :nameOfTheobj  AND DocumentType__c in :docTypeIdSet ';
        } else if (objName == 'Opportunity' && nameOfTheobj == 'Contact') {
            queryAddOn = 'WHERE Contact__c = :selectedCont AND DocumentBlockFormula__c in :block AND  DocumentType__r.ObjectName__c = :nameOfTheobj AND DocumentType__r.Status_Stage_Visible__c IN :VisibleForStage ';
        } else if (objName == 'Account' && nameOfTheobj == 'Contact') {
            queryAddOn = 'WHERE Contact__c = :selectedCont AND  Contact__c<>null   AND DocumentBlockFormula__c in :block AND DocumentType__r.ObjectName__c = :nameOfTheobj ';
        } else if (objName == 'Quote' && nameOfTheobj == 'Quote') {
            queryAddOn = 'WHERE Quote__c = :record AND DocumentBlockFormula__c in :block AND DocumentType__r.ObjectName__c = :nameOfTheobj ';
        } else if (objName == 'Opportunity' && nameOfTheobj == 'Quote') {
            queryAddOn = 'WHERE Quote__c = :selectedCont AND Quote__c<> null AND   DocumentBlockFormula__c in :block AND DocumentType__r.ObjectName__c = :nameOfTheobj AND DocumentType__r.Status_Stage_Visible__c IN :VisibleForStage ';
        }

        queryAddOn += ' AND DocumentType__r.profileVisibilita__c INCLUDES (:currentProfileName) ' +
                'AND DocumentType__r.Doc_Opzionale__c = FALSE';

        System.debug('queryAddOn ' + queryAddOn);

        String querry = 'SELECT Id, Name, Verifica_Sales_Support__c, Verifica_Inside_Sales__c, ' +
                'Notifica_Inside_Sales__c, Commento_Sales_Support__c, ObligatarioAcc__c, ObligatorioCont__c, ObligatorioQuote__c,' +
                'Url_Documento__c, Url_Servizio_Esterno__c, Opportunity__c, Contact__c, Account__c, Quote__c, ' +
                'DocumentTypeName__c, DocumentBlockFormula__c, ' +
                'DocumentClassFormula__c, DocumentTypeNameFormula__c, ' +
                'Errore_Store_Document__c, ' +
                'IDTipoDocumentoFormula__c, SequenceFormula__c, ' +
                'StatusStageVisibleFormula__c, Id_File__c, ' +
                'DocumentType__r.Id, Obbligatorio__c, ' +
                'DocumentType__r.Name, DocumentType__r.Status_Stage_Visible__c, ' +
                'DocumentType__r.Erogazione_Servizi__c, DocumentType__r.profileVisibilita__c, DocumentType__r.dependeDaTipoLinea__c ,' +
                'Opportunity__r.StageName, DocumentType__r.ID_Tipo_Documento__c, ' +
                'Opportunity__r.Contratto_Firmato__c, ' +
                'DocumentType__r.Opportunita_Mutuo__c, DocumentType__r.Opportunita_EasyPlus__c, File_Name__c,' +
                'DocumentType__r.Doc_Caricato_dal_Fiscal_Partner__c, DocumentType__r.Documento_di_Identit__c, ' +
                'DocumentType__r.Verifica_Documento__c,' +
                'DeleteFlag__c ' +
                'FROM Document__c ' + queryAddOn + order;
        result = Database.query(querry);

        return result;
    }

    public static List<Document__c> queryOptionalDocuments(String opportunityId, String accountId, List<String> visibleForStage) {
        List<Document__c> result = new List<Document__c>();
        String currentProfileName;
        if(profileData == null){
            profileData = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        }
        
        currentProfileName = profileData.Name;

        String queryAddOn = 'WHERE DocumentType__r.Doc_Opzionale__c = TRUE ' +
                'AND File_Name__c != NULL ' +
                'AND ((ObjectName__c = \'Opportunity\' AND Opportunity__c =: opportunityId) ' +
                'OR (ObjectName__c = \'Account\' AND Account__c =: accountId)) ' +
                'AND DocumentType__r.profileVisibilita__c INCLUDES (:currentProfileName) ' +
                'AND DocumentType__r.Status_Stage_Visible__c IN :visibleForStage';

        String query = 'SELECT Id, Name, Verifica_Sales_Support__c, Verifica_Inside_Sales__c, ' +
                'Notifica_Inside_Sales__c, Commento_Sales_Support__c, ObligatarioAcc__c, ObligatorioCont__c, ObligatorioQuote__c,' +
                'Url_Documento__c, Url_Servizio_Esterno__c, Opportunity__c, Contact__c, Account__c, Quote__c, ' +
                'DocumentTypeName__c, DocumentBlockFormula__c, ' +
                'DocumentClassFormula__c, DocumentTypeNameFormula__c, ' +
                'Errore_Store_Document__c, ' +
                'IDTipoDocumentoFormula__c, SequenceFormula__c, ' +
                'StatusStageVisibleFormula__c, Id_File__c, ' +
                'DocumentType__r.Id, Obbligatorio__c, ' +
                'DocumentType__r.Name, DocumentType__r.Status_Stage_Visible__c, ' +
                'DocumentType__r.Erogazione_Servizi__c, DocumentType__r.profileVisibilita__c, DocumentType__r.dependeDaTipoLinea__c ,' +
                'Opportunity__r.StageName, DocumentType__r.ID_Tipo_Documento__c, ' +
                'Opportunity__r.Contratto_Firmato__c, ' +
                'DocumentType__r.Opportunita_Mutuo__c, DocumentType__r.Opportunita_EasyPlus__c, File_Name__c,' +
                'DocumentType__r.Doc_Caricato_dal_Fiscal_Partner__c, DocumentType__r.Documento_di_Identit__c, ' +
                'DocumentType__r.Verifica_Documento__c ' +
                'FROM Document__c ' + queryAddOn;

        result = Database.query(query);

        return result;
    }

    public static List<DocumentType__c> getDocumentTypes(String mainObjName, String objOfDocsToQuery,
            List<String> visibleForStage, List<String> block, String oppRecordType) {
        List<DocumentType__c> result = new List<DocumentType__c>();
        String currentProfileName;
        List<String> docListObjNameList = new List<String>{'Opportunity', 'Account', 'Contact', 'Quote'};

        if(profileData == null){
            profileData = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        }
        
        currentProfileName = profileData.Name;

        String query = 'SELECT Id, Name, Status_Stage_Visible__c, Erogazione_Servizi__c, profileVisibilita__c, dependeDaTipoLinea__c, ' +
                'Opportunita_Mutuo__c, Opportunita_EasyPlus__c, Document_Block__c, visibileaPartner__c, ObjectName__c, ' +
                'Obbligatorio_per_In_Stipula__c, Obbligatorio_per_Pre_Istruttoria__c, Obbligatorio_per_Pre_Due_Diligence__c,' +
                'Doc_Caricato_dal_Fiscal_Partner__c, Documento_di_Identit__c, Obbligatorio_in_Erogazione__c, ' +
                'Obbligatorio_in_Deliberata__c, Opportunity_Crediti_Fiscali__c, Obbligatorio_in_CompletamentoDocumenti__c, ' +
                'ID_Tipo_Documento__c ' +
                'FROM DocumentType__c ' +
                'WHERE Document_Block__c in :block ' +
                'AND ObjectName__c = :objOfDocsToQuery ' +
                'AND profileVisibilita__c INCLUDES (:currentProfileName) ' +
                'AND Doc_Opzionale__c = FALSE';

        if (mainObjName == 'Opportunity'  && docListObjNameList.contains(objOfDocsToQuery)) {
            query += ' AND Status_Stage_Visible__c IN :visibleForStage';

            if (oppRecordType == 'Inserimento_Crediti_Fiscali' ||
                    oppRecordType == 'Crediti_Fiscale_Lending' ||
                    oppRecordType == 'Crediti_Fiscale_Lending_RO') {
                query += ' AND Opportunity_Crediti_Fiscali__c = TRUE';
            } else if (oppRecordType == 'Lending' ||oppRecordType == 'Lending_RO') {
                query += ' AND Opportunita_Mutuo__c = TRUE';
            } else if (oppRecordType == 'Lending_Easy_Plus' ||
                    oppRecordType == 'Lending_Easy_Plus_RO') {
                query += ' AND Opportunita_EasyPlus__c = TRUE';
            }
        }

        result = Database.query(query);
        return result;
    }

    public static List<DocumentType__c> getOptionalDocTypes(List<String> visibleForStage, List<String> block, String oppRecordType) {
        List<DocumentType__c> result = new List<DocumentType__c>();
        String currentProfileName;
        if(profileData == null){
            profileData = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        }
        
        currentProfileName = profileData.Name;

        String query = 'SELECT Id, Name, Status_Stage_Visible__c, Erogazione_Servizi__c, profileVisibilita__c, dependeDaTipoLinea__c, ' +
                'Opportunita_Mutuo__c, Opportunita_EasyPlus__c, Document_Block__c, visibileaPartner__c, ObjectName__c, ' +
                'Obbligatorio_per_In_Stipula__c, Obbligatorio_per_Pre_Istruttoria__c, Obbligatorio_per_Pre_Due_Diligence__c, ' +
                'Doc_Caricato_dal_Fiscal_Partner__c, Documento_di_Identit__c, Obbligatorio_in_Erogazione__c, ' +
                'Obbligatorio_in_Deliberata__c, Opportunity_Crediti_Fiscali__c, Obbligatorio_in_CompletamentoDocumenti__c, ' +
                'ID_Tipo_Documento__c ' +
                'FROM DocumentType__c ' +
                'WHERE Document_Block__c IN :block ' +
                'AND (ObjectName__c = \'Opportunity\' OR ObjectName__c = \'Account\') ' +
                'AND profileVisibilita__c INCLUDES (:currentProfileName) ' +
                'AND Status_Stage_Visible__c IN :visibleForStage ' +
                'AND Doc_Opzionale__c = TRUE';

        if (oppRecordType == 'Inserimento_Crediti_Fiscali' ||
                oppRecordType == 'Crediti_Fiscale_Lending' ||
                oppRecordType == 'Crediti_Fiscale_Lending_RO') {
            query += ' AND Opportunity_Crediti_Fiscali__c = TRUE';
        } else if (oppRecordType == 'Lending' || oppRecordType == 'Lending_RO') {
            query += ' AND Opportunita_Mutuo__c = TRUE';
        } else if (oppRecordType == 'Lending_Easy_Plus' ||
                oppRecordType == 'Lending_Easy_Plus_RO') {
            query += ' AND Opportunita_EasyPlus__c = TRUE';
        }
        System.debug('### query = ' + query);
        result = Database.query(query);
        return result;
    }


    @AuraEnabled(cacheable = true)
    public static Map<String, List<Document__c>> getRecordListDocumentAll(String record, List<String> block) {
        List<Document__c> doc = new List<Document__c>();
        Map<String, List<Document__c>> allDoc = new Map<String, List<Document__c>>();
        List<Opportunity> opp = new List<Opportunity>();

        Integer current;
        opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :record LIMIT 1];

        Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
        List<Schema.PicklistEntry> vls = fieldResult.getPicklistValues();
        List<String> visibleForStage = new List<String>();

        for (Integer i = 0; i < vls.size(); i++) {
            if (vls[i].getValue() == opp[0].StageName) {
                current = i;
            }
        }
        System.debug('** current = ' + current);
        for (Integer j = 0; j <= current; j++) {
            visibleForStage.add(vls[current - j].getValue());
        }

        doc = docQuerry('Opportunity', 'Opportunity', record, block, visibleForStage, new Set<Id>(), '');
        System.debug('** doc' + doc.size());

        for (Document__c docData : doc) {
            List<Document__c> docList = new List<Document__c>();
            for (String docName : block) {
                if (docName == docData.DocumentBlockFormula__c) {
                    docList.clear();
                    docList.add(docData);
                    if (allDoc.get(docName) != null) {
                        docList.addAll(allDoc.get(docName));
                    }
                    allDoc.put(docName, docList);
                }
            }
        }
        System.debug('fileUploaderDAO.getRecordListDocumentAll --End doc: ' + doc + ' allDoc: ' + allDoc);
        return allDoc;
    }

    // query che mi consente di creare i vari document e block
    @AuraEnabled(cacheable = true)
    public static Map<String, List<Document__c>> getRecordListDocumentAllAcc(String record, String objectApiName, List<String> block) {
        System.debug('fileUploaderDAO getRecordListDocumentAll --Start record: ' + record + ' objectApiName: ' + objectApiName + ' block: ' + block);

        List<Opportunity> opp = new List<Opportunity>();
        List<Document__c> doc = new List<Document__c>();
        Map<String, List<Document__c>> allDoc = new Map<String, List<Document__c>>();
        List<String> visibleForStage = new List<String>();
        Set<Id> docTypeList = new Set<Id>();

        String recordFinal;
        if (objectApiName == 'Account') {
            recordFinal = record;

            doc = docQuerry('Account', 'Account', record, block, visibleForStage, docTypeList, '');

        } else if (objectApiName == 'Opportunity') {

            opp = [SELECT Id, AccountId, Name, StageName FROM Opportunity WHERE Id = :record LIMIT 1];
            Integer current;

            Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
            List<Schema.PicklistEntry> vls = fieldResult.getPicklistValues();
            for (Integer i = 0; i < vls.size(); i++) {

                if (vls[i].getValue() == opp[0].StageName) {
                    current = i;
                }
            }
            for (Integer j = 0; j <= current; j++) {
                visibleForStage.add(vls[current - j].getValue());
            }

            System.debug('final list of stages' + visibleForStage);
            recordFinal = opp[0].AccountId;

            doc = docQuerry('Opportunity', 'Account', recordFinal, block, visibleForStage, docTypeList, '');
        }

        for (Document__c docData : doc) {
            List<Document__c> docList = new List<Document__c>();
            for (String docName : block) {
                if (docName == docData.DocumentBlockFormula__c) {
                    docList.clear();
                    docList.add(docData);
                    if (allDoc.get(docName) != null) {
                        docList.addAll(allDoc.get(docName));
                    }
                    allDoc.put(docName, docList);
                }
            }
        }

        return allDoc;
    }

    @AuraEnabled
    public static String UpdateCommentInDocuments(List<String> documentIdList, String commentToBeSaved) {
        List<Document__c> documentList = [SELECT Id, Commento_Sales_Support__c FROM Document__c WHERE Id IN :documentIdList];
        for (Document__c document : documentList) {
            document.Commento_Sales_Support__c = commentToBeSaved;
        }

        update documentList;
        return commentToBeSaved;
    }

    // query che mi consente di creare i vari document e block
    @AuraEnabled(cacheable = true)
    public static Map<String, List<Document__c>> getRecordListDocumentAllNew(String recordId, String objectApiName, String docListObjectApiName, List<String> block, String selectedContact, String selectedQuote) {
        Map<String, List<Document__c>> allDocsByDocType = new Map<String, List<Document__c>>();
        List<Document__c> documentList = new List<Document__c>();
        List<String> visibleForStage = new List<String>();
        List<Quote> quoteList = new List<Quote>();
        List<String> quoteIDList = new List<String>();
        Set<Id> docTypeIdSet = getdocTypeIdSet(objectApiName, docListObjectApiName, recordId, selectedContact);

        if (objectApiName == 'Account') {
            if (docListObjectApiName == 'Contact') {
                documentList = docQuerry(objectApiName, docListObjectApiName, recordId, block, visibleForStage, docTypeIdSet, selectedContact);
            } else {
                documentList = docQuerry(objectApiName, docListObjectApiName, recordId, block, visibleForStage, docTypeIdSet, '');
            }
        } if (objectApiName == 'Contact') {
            documentList = docQuerry(objectApiName, docListObjectApiName, recordId, block, visibleForStage, docTypeIdSet, selectedContact);
        } if (objectApiName == 'Quote') {
            selectedContact = selectedQuote;
            documentList = docQuerry(objectApiName, docListObjectApiName, recordId, block, visibleForStage, docTypeIdSet, selectedContact);
        } else if (objectApiName == 'Opportunity') {
            Opportunity oportunity = [SELECT Id, AccountId, Name, StageName FROM Opportunity WHERE Id = :recordId][0];
            Integer current;
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> stagePicklistValues = fieldResult.getPicklistValues();

            for (Integer i = 0; i < stagePicklistValues.size(); i++) {
                if (stagePicklistValues[i].getValue() == oportunity.StageName) {
                    current = i;
                }
            }

            for (Integer j = 0; j <= current; j++) {
                visibleForStage.add(stagePicklistValues[current - j].getValue());
            }

            if (docListObjectApiName == 'Account' || docListObjectApiName == 'Contact') {
                recordId = oportunity.AccountId;
            } else if (docListObjectApiName == 'Quote') {
                quoteList = [SELECT Id, AccountId, Name FROM Quote WHERE OpportunityId = :recordId];
                for (Quote quote : quoteList) {
                    quoteIDList.add(quote.Id);
                }
                selectedContact = selectedQuote;
            }

            documentList = docQuerry(objectApiName, docListObjectApiName, recordId, block, visibleForStage, docTypeIdSet, selectedContact);
        }

        for (Document__c document : documentList) {
            String documentTypeId = document.DocumentType__c;
            if (allDocsByDocType.containsKey(documentTypeId)) {
                allDocsByDocType.get(documentTypeId).add(document);
            } else {
                allDocsByDocType.put(documentTypeId, new List<Document__c>{document});
            }
        }

        return allDocsByDocType;
    }

    /** Query which retrieves a list of all optional document types **/
    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getOptionalDocumentList(String jsonInput) {
        Map<String, String> params = asMap(jsonInput);
        Map<String, Object> response = new Map<String, Object>();
        String opportunityId = params.get('opportunityId');
        String accountId = params.get('accountId');
        Map<String, List<Document__c>> allDocsByDocType = new Map<String, List<Document__c>>();
        List<Document__c> documentList = new List<Document__c>();
        List<String> visibleForStage = new List<String>();
        
        try {
            Opportunity opportunityObj = [SELECT Id, AccountId, Name, StageName FROM Opportunity WHERE Id = :opportunityId][0];
            Integer current;
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> stagePicklistValues = fieldResult.getPicklistValues();

            for (Integer i = 0; i < stagePicklistValues.size(); i++) {
                if (stagePicklistValues[i].getValue() == opportunityObj.StageName) {
                    current = i;
                }
            }

            for (Integer j = 0; j <= current; j++) {
                visibleForStage.add(stagePicklistValues[current - j].getValue());
            }
            documentList = queryOptionalDocuments(opportunityId, accountId, visibleForStage);

            for (Document__c document : documentList) {
                String documentTypeId = document.DocumentType__c;
                if (allDocsByDocType.containsKey(documentTypeId)) {
                    allDocsByDocType.get(documentTypeId).add(document);
                } else {
                    allDocsByDocType.put(documentTypeId, new List<Document__c>{document});
                }
            }

            response.put('allDocsByDocType', allDocsByDocType);
            response.put('error', false);
        } catch (Exception ex) {
            response.put('error', true);
            response.put('errorMsg', ex.getMessage());
            response.put('errorTrace', ex.getStackTraceString());
        }

        return response;
    }

    public static Set<Id> getdocTypeIdSet(String objectApiName, String docListObjectApiName, String recordId, String selectedContact) {
        Set<Id> docTypeIdSet = new Set<Id>();

        if (docListObjectApiName == 'Contact') {
            String finalContactId;
            List<DocumentType__c> documentTypeList = new List<DocumentType__c>();

            if (objectApiName == 'Opportunity' || objectApiName == 'Account') {
                finalContactId = selectedContact;
            } else if (objectApiName == 'Contact') {
                finalContactId = recordId;
            }

            Contact contact = [SELECT Id, Name, Fidejussore__c, Ruolo_in_Azienda__c FROM Contact WHERE Id = :finalContactId LIMIT 1][0];

            if (contact != null) {
                if (contact.Fidejussore__c == true) {
                    documentTypeList = [
                            SELECT Id, Name, Referente_Fidejussore__c
                            FROM DocumentType__c
                            WHERE ObjectName__c = 'Contact'
                    ];
                } else if (contact.Fidejussore__c == false && ((contact.Ruolo_in_Azienda__c == 'Titolare Effettivo') ||
                        (contact.Ruolo_in_Azienda__c == 'Legale Rappresentante') ||
                        (contact.Ruolo_in_Azienda__c == 'Titolare Effettivo;Legale Rappresentante'))) {
                    documentTypeList = [
                            SELECT Id, Name, Referente_Fidejussore__c
                            FROM DocumentType__c
                            WHERE ObjectName__c = 'Contact'
                            AND Referente_Fidejussore__c = FALSE];
                }
            }

            for (DocumentType__c docType : documentTypeList) {
                docTypeIdSet.add(docType.Id);
            }
        }

        return docTypeIdSet;
    }

    // query che mi consente di creare i vari document e block
    @AuraEnabled(cacheable = true)
    public static Map<String, DocumentType__c> getRecordListDocumentTypes(String recordId, String objectApiName, String docListObjectApiName, List<String> block) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<DocumentType__c> docTypeList = new List<DocumentType__c>();
        Map<String, DocumentType__c> allDocTypes = new Map<String, DocumentType__c>();
        List<String> visibleForStage = new List<String>();

        if (objectApiName == 'Account' || objectApiName == 'Contact' || objectApiName == 'Quote') {
            docTypeList = getDocumentTypes(objectApiName, docListObjectApiName, visibleForStage, block, '');
        } else if (objectApiName == 'Opportunity') {
            Integer current;
            opportunityList = [
                    SELECT Id, AccountId, Name, StageName, RecordType.Id, RecordType.DeveloperName
                    FROM Opportunity
                    WHERE Id = :recordId
            ];
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> stageNamePicklistValues = fieldResult.getPicklistValues();
            String oppRecordType = opportunityList[0].RecordType.DeveloperName;

            for (Integer i = 0; i < stageNamePicklistValues.size(); i++) {
                if (stageNamePicklistValues[i].getValue() == opportunityList[0].StageName) {
                    current = i;
                }
            }

            for (Integer j = 0; j <= current; j++) {
                visibleForStage.add(stageNamePicklistValues[current - j].getValue());
            }

            docTypeList = getDocumentTypes(objectApiName, docListObjectApiName, visibleForStage, block, oppRecordType);
        }

        for (DocumentType__c docType : docTypeList) {
            allDocTypes.put(docType.Id, docType);
        }

        return allDocTypes;
    }

    // query che mi consente di creare i vari document e block
    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getOptionalDocumentTypesList(String jsonInput) {
        Map<String, String> params = asMap(jsonInput);
        String recordId = params.get('recordId');
        Opportunity opp = new Opportunity();
        List<String> block = new List<String>();
        List<String> visibleForStage = new List<String>();
        List<DocumentType__c> docTypeList = new List<DocumentType__c>();
        Map<String, Object> response = new Map<String, Object>();
        Map<String, DocumentType__c> allDocTypes = new Map<String, DocumentType__c>();


        try {
            if (params.get('block').length() > 0) {
                block = (List<String>) JSON.deserialize(params.get('block'), List<String>.class);
            }

            opp = [
                    SELECT Id, AccountId, Name, StageName, RecordType.Id, RecordType.DeveloperName
                    FROM Opportunity
                    WHERE Id = :recordId
            ];

            visibleForStage = getVisibleForStage(opp);
            docTypeList = getOptionalDocTypes(visibleForStage, block, opp.RecordType.DeveloperName);

            for (DocumentType__c docType : docTypeList) {
                allDocTypes.put(docType.Id, docType);
            }

            response.put('allDocTypes', allDocTypes);
            response.put('error', false);
        } catch (Exception ex) {
            response.put('error', true);
            response.put('errorMsg', ex.getMessage());
            response.put('errorTrace', ex.getStackTraceString());
        }

        return response;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, List<Document__c>> getRecordListDocumentAllCont(String record, String objectApiName, List<String> block, String selectedCont) {  // query che mi consente di creare i vari document e block
        System.debug('fileUploaderDAO getRecordListDocumentAll --Start record: ' + record + ' objectApiName: ' + objectApiName + ' block: ' + block + ' selectedCont: ' + selectedCont);

        List<Document__c> doc = new List<Document__c>();
        List<Opportunity> opp = new List<Opportunity>();
        List<Contact> contact = new List<Contact>();
        Map<String, List<Document__c>> allDoc = new Map<String, List<Document__c>>();
        List<Contact> con = new List<Contact>();
        List<String> contID = new List<String>();
        Set<Id> docTypeList = new Set<Id>();
        List<DocumentType__c> docType = new List<DocumentType__c>();
        String finalContact;

        if (objectApiName == 'Opportunity' || objectApiName == 'Account') {
            finalContact = selectedCont;

        } else if (objectApiName == 'Contact') {
            finalContact = record;
        }

        contact = [Select Id, Name, Fidejussore__c, Ruolo_in_Azienda__c from Contact Where Id = :finalContact LIMIT 1];

        if (!contact.isEmpty()) {
            if (contact[0].Fidejussore__c == true) {
                docType = [Select Id, Name, Referente_Fidejussore__c From DocumentType__c Where ObjectName__c = 'Contact'];
            } else if (contact[0].Fidejussore__c == false && ((contact[0].Ruolo_in_Azienda__c == 'Titolare Effettivo') || (contact[0].Ruolo_in_Azienda__c == 'Legale Rappresentante') || (contact[0].Ruolo_in_Azienda__c == 'Titolare Effettivo;Legale Rappresentante'))) {
                docType = [Select Id, Name,Referente_Fidejussore__c From DocumentType__c Where ObjectName__c = 'Contact' AND Referente_Fidejussore__c = false];
            }
        }
        for (DocumentType__c c : docType) {
            docTypeList.add(c.Id);
        }

        String OppAccountId;
        String recordFinal;
        if (objectApiName == 'Contact') {
            recordFinal = record;

            doc = docQuerry('Contact', 'Contact', recordFinal, block, new List<String>(), docTypeList, '');

            System.debug('fileUploaderDAO getRecordListDocumentAll docsize: ' + doc.size());
        } else if (objectApiName == 'Opportunity') {
            opp = [Select Id, AccountId, Name, StageName from Opportunity Where Id = :record LIMIT 1];
            OppAccountId = opp[0].AccountId;

            recordFinal = opp[0].AccountId;
            con = [Select Id, AccountId, Name from Contact where AccountId = :OppAccountId];

            for (Contact c : con) {
                contID.add(c.Id);
            }
            Integer current;

            Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
            List<Schema.picklistEntry> vls = fieldResult.getPicklistValues();
            List<String> VisibleForStage = new List<String>();
            for (integer i = 0; i < vls.size(); i++) {
                if (vls[i].getValue() == opp[0].StageName) {
                    current = i;
                }
            }
            for (integer j = 0; j <= current; j++) {
                VisibleForStage.add(vls[current - j].getValue());
            }
            System.debug('final list of stages' + VisibleForStage);

            doc = docQuerry('Opportunity', 'Contact', '', block, VisibleForStage, new Set<Id>(), selectedCont);

        } else if (objectApiName == 'Account') {
            con = [Select Id, AccountId, Name from Contact where AccountId = :record];
            for (Contact c : con) {
                contID.add(c.Id);
            }

            doc = docQuerry('Account', 'Contact', '', block, new List<String>(), new Set<Id>(), selectedCont);

        }
        for (Document__c docData : doc) {
            List<Document__c> docList = new List<Document__c>();
            for (String docName : block) {
                if (docName == docData.DocumentBlockFormula__c) {
                    docList.clear();
                    docList.add(docData);
                    if (allDoc.get(docName) != null) {
                        docList.addall(allDoc.get(docName));
                    }
                    allDoc.put(docName, docList);
                }
            }
        }

        System.debug('fileUploaderDAO getRecordListDocumentAll --End doc: ' + allDoc);
        return allDoc;
    }

    @AuraEnabled  //save commento note
    public static void updateNote(String recordUpdateId, String commentoSalesSupport) {
        System.debug('fileUploaderDAO updateNote --Start recordUpdateId: ' + recordUpdateId + ' commentoSalesSupport: ' + commentoSalesSupport);
        Document__c dock = new Document__c ();
        List< Document__c > uppDoc = [SELECT Id,Commento_Sales_Support__c FROM Document__c WHERE id = :recordUpdateId];
        if (uppDoc.size() > 0) {
            dock = uppDoc.get(0);
            dock.Commento_Sales_Support__c = commentoSalesSupport;
            System.debug('fileUploaderDAO updateNote --End dock: ' + dock);
            update dock;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, List<Document__c>> getRecordListDocumentAllQuote(String record, String objectApiName, List<String> block, String selectedCont) {  // query che mi consente di creare i vari document e block
        System.debug('fileUploaderDAO getRecordListDocumentAllQuote --Start record: ' + record + ' block: ' + block + ' selectedCont: ' + selectedCont);
        System.debug('objectApiName ' + objectApiName);

        List<Document__c> doc = new List<Document__c>();
        List<Opportunity> opp = new List<Opportunity>();
        List<Contact> contact = new List<Contact>();
        Map<String, List<Document__c>> allDoc = new Map<String, List<Document__c>>();
        List<Quote> quote = new List<Quote>();
        List<String> quoteID = new List<String>();
        Set<Id>docTypeList = new Set<Id>();
        List<DocumentType__c> docType = new List<DocumentType__c>();
        String OppAccountId;
        String recordFinal;

        if (objectApiName == 'Quote') {
            recordFinal = record;
            System.debug('recorFinal is' + recordFinal);

            doc = docQuerry('Quote', 'Quote', recordFinal, block, new List<String>(), new Set<Id>(), '');
        } else if (objectApiName == 'Opportunity') {
            opp = [Select Id, AccountId, Name, StageName from Opportunity Where Id = :record LIMIT 1];
            quote = [Select Id, AccountId, Name from Quote where OpportunityId = :record];

            for (Quote q : quote) {
                quoteID.add(q.Id);
            }

            Integer current;
            Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
            List<Schema.picklistEntry> vls = fieldResult.getPicklistValues();
            List<String> VisibleForStage = new List<String>();

            for (integer i = 0; i < vls.size(); i++) {
                if (vls[i].getValue() == opp[0].StageName) {
                    current = i;
                }
            }
            for (integer j = 0; j <= current; j++) {
                VisibleForStage.add(vls[current - j].getValue());
            }
            System.debug('final list of stages' + VisibleForStage);

            doc = docQuerry('Opportunity', 'Quote', '', block, VisibleForStage, new Set<Id>(), selectedCont);
        }

        System.debug('fileUploaderDAO getRecordListDocumentAll doc.size: ' + doc.size());

        for (Document__c docData : doc) {
            system.debug('docData' + docData);
            List<Document__c> docList = new List<Document__c>();
            for (String docName : block) {
                if (docName == docData.DocumentBlockFormula__c) {
                    docList.clear();
                    docList.add(docData);
                    if (allDoc.get(docName) != null) {
                        docList.addall(allDoc.get(docName));
                    }
                    allDoc.put(docName, docList);
                }
            }
        }
        System.debug('fileUploaderDAO getRecordListDocumentAll --End alldoc: ' + allDoc);
        return allDoc;
    }


    @AuraEnabled  //save picklist verifica sales support
    public static Document__c updatePick(String recordUpdateId, String verificaSalesSupport) {
    
        Document__c dock = new Document__c ();
        Utils_Constants util = new Utils_Constants();
        List< Document__c > uppDoc = [
                SELECT Id, Verifica_Sales_Support__c, Opportunity__c, Account__c, Contact__c,
                Quote__c,Quote__r.Contratto_Verificato__c, DocumentTypeName__c, IDTipoDocumentoFormula__c
                FROM Document__c
                WHERE Id = :recordUpdateId
        ];

        if (uppDoc.size() > 0) {
            dock = uppDoc.get(0);
            dock.Verifica_Sales_Support__c = verificaSalesSupport;
            if(dock.IDTipoDocumentoFormula__c=='SME_100' && dock.Verifica_Sales_Support__c== 'Verifica OK'){
                Quote quote = new Quote( id = dock.Quote__c,Contratto_Verificato__c = true
                );
                update quote ;
            }

            update dock;
        }
        return dock;
    }

    @AuraEnabled  //save check
    public static Document__c addFile (String documentTypeId, String accountId, String finalDocumentName,
            String fileName,  String fileId, String replaceDocId, String commentToSave, Opportunity opportunity,
            String selectedContactId, String selectedQuoteId) {
        DocumentType__c docType = [SELECT Id, ObjectName__c FROM DocumentType__c WHERE Id =: documentTypeId][0];
        Document__c document = new Document__c ();
        document.File_Name__c = finalDocumentName;
        document.Id_File__c = fileId;
        document.Url_Servizio_Esterno__c = fileName;
 System.debug('filename  '+fileName);
 System.debug('finalDocumentName  '+finalDocumentName);
        switch on (docType.ObjectName__c) {
            when 'Opportunity' {
                if (opportunity != null) {
                    document.Opportunity__c = opportunity.Id;
                    document.Opportunity__r = opportunity;
                }
            }
            when 'Account' {
                if (accountId != '') {
                    document.Account__c = accountId;
                }
            }
            when 'Contact' {
                if (selectedContactId != '') {
                    document.Contact__c = selectedContactId;
                }
            }
            when 'Quote' {
                if (selectedQuoteId != '') {
                    document.Quote__c = selectedQuoteId;
                }
            }
        }

        if (!String.isEmpty(replaceDocId)) {
            document.Id = replaceDocId;
            //document.Id_File__c = fileId;
            update document;
            System.debug('document after updatre  '+document.Id_File__c + ' doc  '+document.File_Name__c);
            updateFile(document.Id, fileName, fileId,'sostituisci');
        } else {
            document.DocumentType__c = documentTypeId;
            document.Commento_Sales_Support__c = commentToSave;

            insert document;
            updateFile(document.Id, fileName, fileId,'aggiungi');
        }
        return document;
    }

    @AuraEnabled(Cacheable = true)
    public static Opportunity getOpportunity (String recordId) {
        Opportunity opp = [
                SELECT Id, Name, AccountId, StageName, Total_Mandatories_Docs__c, Tipo_Firma__c, RecordType.Id,
                        RecordType.DeveloperName, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Societ_Appartiene_a_Gruppo__c, Account.Clientela_Incidenza__c, Account.Fidejussore__c,
                        Is_Suspended__c, Sabatini_Applicabile__c
                FROM Opportunity
                WHERE Id = :recordId][0];
        return opp;
    }

    @AuraEnabled(Cacheable = true)
    public static Account getAccount (String recordId) {
        Account account = [SELECT Id, Name ,userMail__c FROM Account WHERE Id = :recordId][0];
        return account;
    }

    @AuraEnabled(Cacheable = true)
    public static Contact getContactFromAccount (String recordId) {
        Contact contact = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = :recordId][0];
        return contact;
    }

    @AuraEnabled(Cacheable = true)
    public static Contact getContact (String recordId) {
        Contact contact = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :recordId];
        return contact;
    }

    @AuraEnabled(Cacheable = true)
    public static Quote getQuote (String recordId) {
        Quote quote = [SELECT Id, Name, AccountId FROM Quote WHERE Id = :recordId];
        return quote;
    }

    @AuraEnabled  //save check
    public static String updateFile(String recordUpdateId, String fileName, String fileId, String action) {
        Document__c dock = new Document__c();
        Opportunity opp = new Opportunity();
        Account accDock = new Account();
        Quote quoteDock = new Quote();
        Contact contactDock = new Contact();
        Garanzia__c garanzie = new Garanzia__c();

        Utils_Constants constants = new Utils_Constants();
        String AccountName;
        String IDAccount;
        String CodiceFiscale;
        String NumeroContratto = '';
        Datetime DataStipula = NULL ;
        String StageName = '';
        String oplonID;
        String ObjectType;
        String ObjectID;
        String processGuid;
        String nominativoReferente;
        String contactTaxCode;
        String contactIdSalesforce;
        String fidejussioneNameId;
        String fidejussioneFileId;
        String tipoGaranzie;
        String contrattoFileName;
        String contrattoFileNameId;

        List<Document__c> uppDoc = [
                SELECT Id, Data_Caricamento__c, DocumentType__c, DocumentClassFormula__c, IDTipoDocumentoFormula__c,
                        DocumentTypeNameFormula__c, Id_File__c, Opportunity__c, Account__c, Contact__c, Quote__c, GUI__c,
                        Url_Servizio_Esterno__c, Verifica_Sales_Support__c, ObjectName__c, File_Name__c, DeleteFlag__c
                FROM Document__c
                WHERE Id = :recordUpdateId
        ];
       // System.debug('fileUploaderDAO.updateFile -- uppDoc = ' + uppDoc + ' asda  '+uppDoc[0].Id_File__c);
        //System.debug('fileUploaderDAO.updateFile -- uppDoc.size() = ' + uppDoc.size());
        String docUserMail = '';

        if (!uppDoc.isEmpty() && uppDoc.size() > 0) {
            dock = uppDoc.get(0);
            dock.Url_Servizio_Esterno__c = fileName;
            dock.Id_File__c = fileId;

            if(action == 'elimina'){
                dock.DeleteFlag__c = true;
            }

            dock.Verifica_Sales_Support__c = constants.OPPORTUNITY_DA_VERIFICARE;

            Datetime uploadDate = Datetime.now();
            dock.Data_Caricamento__c = uploadDate;

            /** Select Based on Object Type */
            if (dock.ObjectName__c == 'Account') {
                List<Account> accInf = [
                        SELECT Id, Name,Codice_Fiscale__c,Anagrafica_Id_Oplon__c,userMail__c
                        FROM Account
                        WHERE Id = :dock.Account__c
                ];

                if (accInf.size() > 0) {
                    accDock = accInf.get(0);
                    AccountName = accDock.Name;
                    IDAccount = accDock.Id;
                    CodiceFiscale = accDock.Codice_Fiscale__c;
                    oplonID = accDock.Anagrafica_Id_Oplon__c;
                    ObjectType = 'Account';
                    ObjectID = dock.Account__c;
                    docUserMail = accDock.userMail__c;
                } else {
                    return '';
                }
                System.debug('Account type Object');

            } else if (dock.ObjectName__c == 'Quote') {
                List<Quote> QuoteInf = [
                        SELECT Id, AccountId,
                                Account.Name,Account.Codice_Fiscale__c, Opportunity.Numero_Contratto__c, Account.userMail__c,
                                Opportunity.StageName,Id_Analisi_Linea_Oplon__c,processGuid__c, Tipo_di_Garanzia__c, (SELECT Id, Tipo_di_Garanzia__c FROM Garanzie__r)
                        FROM Quote
                        WHERE Id = :dock.Quote__c
                ];
               
                if (QuoteInf.size() > 0) {
                    quoteDock = QuoteInf.get(0);
                    List<Garanzia__c> garanzieList = quoteDock.Garanzie__r;
                    AccountName = quoteDock.Account.Name;
                    IDAccount = quoteDock.AccountId;
                    CodiceFiscale = quoteDock.Account.Codice_Fiscale__c;
                    NumeroContratto = quoteDock.Opportunity.Numero_Contratto__c;
                    StageName = quoteDock.Opportunity.StageName;
                    oplonID = quoteDock.Id_Analisi_Linea_Oplon__c;
                    ObjectType = 'Quote';
                    ObjectID = dock.Quote__c;
                    processGuid = quoteDock.processGuid__c;
                    docUserMail = quoteDock.Account.userMail__c;
                    if (garanzieList.size() > 0){
                    garanzie = garanzieList.get(0);
                    //Stefano Fix for problem with contract
                    for(Garanzia__c gar : garanzieList){
                            if(gar.Tipo_di_Garanzia__c == 'Fidejussione'){
                                tipoGaranzie = gar.Tipo_di_Garanzia__c;
                            }
                        } 
                    }
                } else {
                    return '';
                }

            } else if (dock.ObjectName__c == 'Contact') {
                List<Contact> ContactInf = [
                        SELECT Id,AccountId, Account.Name,Account.userMail__c, Account.Codice_Fiscale__c, PersonaFisicaOplon__c, Oplon_Codice_Fiscale__c, Name
                        FROM Contact
                        WHERE Id = :dock.Contact__c
                ];

                if (ContactInf.size() > 0) {
                    contactDock = ContactInf.get(0);
                    AccountName = contactDock.Account.Name;
                    IDAccount = contactDock.AccountId;
                    CodiceFiscale = contactDock.Account.Codice_Fiscale__c;
                    oplonID = contactDock.PersonaFisicaOplon__c;
                    contactTaxCode = contactDock.Oplon_Codice_Fiscale__c;
                    contactIdSalesforce = contactDock.Id;
                    nominativoReferente = contactDock.Name;
                    ObjectType = 'Contact';
                    ObjectID = dock.Contact__c;
                    docUserMail = contactDock.Account.userMail__c;                   
                } else {
                    return '';
                }
                System.debug('Contact type Object');
            } else if (dock.ObjectName__c == 'Opportunity') {
                List<Opportunity> opportunityInf = [
                        SELECT Id, AccountId,Account.Codice_Fiscale__c,Account.Name,
                                Numero_Contratto__c,Data_Stipula__c,StageName,Account.userMail__c,
                                Numero_Pratica__c, Tipo_Linea_di_Credito__c
                        FROM Opportunity
                        WHERE Id = :dock.Opportunity__c
                ];

                if (opportunityInf.size() > 0) {
                    opp = opportunityInf.get(0);
                    AccountName = opp.Account.Name;
                    IDAccount = opp.AccountId;
                    CodiceFiscale = opp.Account.Codice_Fiscale__c;
                    NumeroContratto = opp.Numero_Contratto__c;
                    DataStipula = opp.Data_Stipula__c;
                    StageName = opp.StageName;
                    oplonID = opp.Numero_Pratica__c;
                    ObjectType = 'Opportunity';
                    ObjectID = dock.Opportunity__c;
                    docUserMail = opp.Account.userMail__c;
                } else {
                    return '';
                }
                System.debug('Opportunity type Object');
            } else {
                return '';
            }
            String storeDocumentResult;
            Boolean isFidejussione = false;
            if(tipoGaranzie == 'Fidejussione'){
            isFidejussione = true;
  
            List<Document__c> quoteDocs = [SELECT Id, DocumentType__c, IDTipoDocumentoFormula__c,
            DocumentTypeNameFormula__c, Id_File__c, Quote__c, GUI__c,Url_documento__c,
            Url_Servizio_Esterno__c, Verifica_Sales_Support__c, ObjectName__c, File_Name__c FROM Document__c
            WHERE (IDTipoDocumentoFormula__c = 'SME_100' OR IDTipoDocumentoFormula__c = 'SME_058') AND Quote__c = :dock.Quote__c];
            System.debug('UpdateFile quoteDocs ' + quoteDocs);

            Boolean sme100 = false;
            Boolean sme58 = false;
                for(Document__c doc :quoteDocs ){
                    System.debug('dock.IDTipoDocumentoFormula__c  '+doc.IDTipoDocumentoFormula__c);
                    if(doc.IDTipoDocumentoFormula__c == 'SME_058') {
                         fidejussioneNameId=doc.Url_Servizio_Esterno__c;
                         fidejussioneFileId=doc.Id_File__c;
                        for(Document__c innerDoc :quoteDocs ){
                            if(innerDoc.IDTipoDocumentoFormula__c =='SME_100' && innerDoc.Url_documento__c != null && action == 'sostituisci' && innerDoc.Id_File__c != null ){
                                sme100=true;
                                break;
                            }
                        }
                    }else if (doc.IDTipoDocumentoFormula__c == 'SME_100'){
                            contrattoFileName=doc.Url_Servizio_Esterno__c;
                            contrattoFileNameId=doc.Id_File__c;
                        for(Document__c innerDoc :quoteDocs ){
                            if(innerDoc.IDTipoDocumentoFormula__c =='SME_058' && innerDoc.Url_documento__c != null && action == 'sostituisci' && innerDoc.Id_File__c != null){
                                sme58=true;
                                break;
                            }
                        }
                    }
                }
                System.debug('sme100 ' + sme100 +'  sme58 ' + sme58);
                if(sme100 && sme58){
                    ElevaRestApiController.storeDocumentBatchContrata(contrattoFileNameId, contrattoFileName, processGuid, dock.Id, ObjectID, fidejussioneNameId, fidejussioneFileId);
                }
            }

           if(!isFidejussione && (dock.IDTipoDocumentoFormula__c == 'SME_100' || dock.IDTipoDocumentoFormula__c == 'SME_114')) {
                ElevaRestApiController.storeDocumentBatchContrata(fileId, fileName, processGuid, dock.Id, ObjectID, fidejussioneNameId, fidejussioneFileId);
            } else if (dock.IDTipoDocumentoFormula__c == 'SME_057') {
                System.debug('** sme 057 **');
                String contentVersionId = getContentVersion(fileId);
                ElevaRestApiController.storeDocument(contentVersionId, fileName, dock.Id, dock.DocumentClassFormula__c, ObjectID, IDAccount, uploadDate, dock.IDTipoDocumentoFormula__c, AccountName,
                        CodiceFiscale, NumeroContratto, DataStipula, dock.DocumentTypeNameFormula__c, oplonID, StageName, ObjectType, docUserMail, contactTaxCode, nominativoReferente, contactIdSalesforce,action, dock.GUI__c,dock.File_name__c);
                return '';
           }  else if(dock.IDTipoDocumentoFormula__c != 'SME_114' && dock.IDTipoDocumentoFormula__c != 'SME_057' && dock.IDTipoDocumentoFormula__c != 'SME_058'&&  dock.IDTipoDocumentoFormula__c != 'SME_100'){
                System.debug('** OTHER SME **');
                ElevaRestApiController.storeDocumentBatch(fileId, fileName, dock.Id, dock.DocumentClassFormula__c, ObjectID, IDAccount, uploadDate,
                        dock.IDTipoDocumentoFormula__c, AccountName,
                        CodiceFiscale, NumeroContratto, DataStipula, dock.DocumentTypeNameFormula__c, oplonID, StageName, ObjectType, docUserMail,
                        contactTaxCode, nominativoReferente, contactIdSalesforce, action, dock.GUI__c
                );
            } 
            update dock;
            return '';
        } else {
            return '';
        }
    }


    public static String getContentVersion(String fileId) {
        System.debug('fileUploaderDAO.getContentVersion --Start fileId: ' + fileId);
        ContentVersion cv = new ContentVersion();
        List<ContentVersion> contentVersions = [SELECT Id,ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId];
        if (contentVersions.size() > 0) {
            cv = contentVersions.get(0);
            System.debug('fileUploaderDAO.getContentVersion --End' +contentVersions[0].id );
            return contentVersions[0].id;//EncodingUtil.base64Encode(cv.VersionData);
        } else {
            System.debug('fileUploaderDAO.getContentVersion --End');
            return '';
        }
    }


    @AuraEnabled
    public static String richiediNdg(String oppId) {
        System.debug('fileUploaderDAO.richiediNdg --Start oppId: ' + oppId);

        List<Switch__mdt> metadata = [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName = 'NDG_Eleva'];
        FidejussoreResponse response = new FidejussoreResponse();
        response.ok = true;
        String finalMessage = '';

        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId];

        if (opps.size() > 0) {
            String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
            /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Referente_Oplon'];
            if (recordTypes.size() > 0) {
                recordTypeId = recordTypes.get(0).Id;
            }*/

            String accId = opps.get(0).AccountId;
            List<Account> accounts = [SELECT Id, AccountNumber, Erogazione_dei_Servizi__c, Marketing_Banca__c, Profilazione_Banca__c, Valutazione_Qualit_Servizio__c, Ricerche_di_Mercato__c, Dati_Particolari__c, Consenso_Sic__c FROM Account WHERE Id = :accId];
            Account acc = accounts.get(0);
            List<Contact> contacts = [SELECT Id, AccountId,Skip_Flag_Privacy__c, Erogazione_dei_Servizi__c, Marketing_Banca__c, Profilazione_Banca__c, Valutazione_Qualita_Servizio__c, Ricerche_di_Mercato__c, Dati_Particolari__c, Consenso_Sic__c FROM Contact WHERE RecordTypeId = :recordTypeId AND AccountId = :accId];

            if (metadata[0].Status__c == 'Active') {
                response = ElevaRestApiController.anagraphicCr2(oppId, accId, acc.AccountNumber);
            } else if (!Test.isRunningTest()) {
                response.ok = false;
                response.responseMessage = 'ATTENZIONE! La funzionalità di richiesta NDG è stata disabilitata. Contattare l\'amministratore di sistema. ';
            }

            if (response.ok == true) {
                finalMessage = 'Approvazione effettuata correttamente!';
                acc.erogazione_dei_servizi__c = 'YES';
                opps.get(0).Approvazione_Modulo_Richiesta__c = true;

                for (Contact cont : contacts) {
                    if (cont.Skip_Flag_Privacy__c == null) {
                        cont.Skip_Flag_Privacy__c = 1;
                    } else {
                        cont.Skip_Flag_Privacy__c++;
                    }
                    cont.Erogazione_dei_Servizi__c = 'YES';
                }
                System.debug('fileUploaderDAO richiediNdg acc: ' + acc + ' contacts: ' + contacts);
                update acc;
                update contacts;
                update opps.get(0);
            } else {
                finalMessage = response.responseMessage;
            }
        }
        System.debug('fileUploaderDAO richiediNdg --End finalMessage: ' + finalMessage);
        return finalMessage;
    }


    @AuraEnabled  //save check
    public static void updateCheck(String recordUpdateId, Boolean checkBok) {
        System.debug('fileUploaderDAO.updateCheck --Start recordUpdateId: ' + recordUpdateId + ' checkBok: ' + checkBok);
        Document__c dock = new Document__c ();

        List<Document__c> uppDoc = [SELECT Id,Notifica_Inside_Sales__c,Opportunity__c FROM Document__c WHERE Id = :recordUpdateId];
        if (uppDoc.size() > 0) {
            dock = uppDoc.get(0);
            dock.Notifica_Inside_Sales__c = checkBok;
            String oppId = dock.Opportunity__c;
            List<Opportunity> opps = [SELECT Id,Notifica_IS_Modulo_Finanziamento__c FROM Opportunity WHERE Id = :oppId];
            Opportunity opp = opps.get(0);
            opp.Notifica_IS_Modulo_Finanziamento__c = true;

            update dock;
            update opp;
            System.debug('fileUploaderDAO.updateCheck --End dock: ' + dock + ' opp: ' + opp);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> conditionsDocuments(String recordId, String objectApiName, String smallObjectName, String selectedCont) {
        Boolean isStageFirma;
        Boolean isErogazioneNO;
        Boolean isRecTypeRO;
        Boolean isFirmaDigitale;
        Boolean isContratoVerificato;
        Boolean isProfileSales;
        Boolean isProfileSalesNoFiscalPartner;
        Boolean isProfileInsideSales;
        Boolean isProfileFidimed;
        Boolean isProfileSalesEasy;
        Boolean isProfileTuttiSales;
        Boolean isProfileFiscalPartner;
        Boolean isSwitchActive = true;
        Boolean isOppEasyPlus;
        Boolean isProfileAgente;
        Boolean isProfileMediatore;
        Boolean isProfileIntermediario;
        Boolean isProfileBackOffice;
        Boolean isProfileRespBo;
        Boolean isProfileRespBoCedenti;

        Map<String, Object> varMap = new Map<String, Object>();

        String profileName;
        
        if(profileData == null){
            profileData = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        }
        
        profileName = profileData.Name;

        Boolean admin = profileName == 'System Administrator' || profileName == 'Amministratore del sistema' ? true : false;

        isProfileFiscalPartner = profileName == 'Fiscal Partner';
        isProfileInsideSales = profileName == 'Inside Sales' || admin ? true : false;
        isProfileFidimed = profileName == 'Fidimed' ||  isProfileFiscalPartner || admin ? true : false;
        isProfileSales = profileName == 'Sales Support' || isProfileFiscalPartner ||  profileName == 'Sales Support Supervisor' || admin ? true : false;
        isProfileSalesNoFiscalPartner = profileName == 'Sales Support' ||  profileName == 'Sales Support Supervisor' || admin ? true : false;
        isProfileSalesEasy = profileName == 'Sales Support Easy Plus' || admin ? true : false;
        isProfileTuttiSales = isProfileSales || isProfileSalesEasy ? true : false;
        isProfileAgente = profileName == 'Agente' ? true : false;
        isProfileMediatore = profileName == 'Mediatore Creditizio' ? true : false;
        isProfileIntermediario = profileName == 'Intermediario Finanziario' ? true : false;
        isProfileBackOffice = profileName == 'Back Office Cedenti Ceduti' ? true : false;
        isProfileRespBo = profileName == 'Responsabile BO cedenti ceduti' ? true : false;
        isProfileRespBoCedenti = profileName == 'Back Office Cedenti Ceduti' ? true : false;


        if (objectApiName == 'Opportunity') {
            Opportunity opp = [Select Id, AccountId, StageName, Account.erogazione_dei_servizi__c, RecordType.Name, Tipo_Firma__c, Tipo_Linea_di_Credito__c from Opportunity Where Id = :recordId][0];
            isStageFirma = opp.StageName == 'Firma' ? true : false;
            isErogazioneNO = opp.Account.erogazione_dei_servizi__c == 'YES' ? false : true;
            isRecTypeRO = (opp.RecordType.Name == 'Lending RO' || opp.RecordType.Name == 'Lending Easy Plus RO' ) && !admin ? true : false;
            isFirmaDigitale = opp.Tipo_Firma__c == 'Firma Digitale' ? true : false;
            isOppEasyPlus = opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus' ? true : false;
        } else if (objectApiName == 'Account') {
            Account acc = [Select Id,erogazione_dei_servizi__c,RecordType.Name from Account Where Id = :recordId][0];
            isRecTypeRO = acc.RecordType.Name == 'AccountNoOpp' && !admin ? true : false;
            isErogazioneNO = acc.erogazione_dei_servizi__c == 'YES' ? false : true;
        } else if (objectApiName == 'Quote') {
            Quote quote = [Select Id, Contratto_Verificato__c, Opportunity.RecordType.Name, Opportunity.StageName, Opportunity.Account.erogazione_dei_servizi__c, Opportunity.Tipo_Firma__c from Quote Where Id = :recordId][0];
            isStageFirma = quote.Opportunity.StageName == 'Firma' ? true : false;
            isErogazioneNO = quote.Opportunity.Account.erogazione_dei_servizi__c == 'YES' ? false : true;
            isRecTypeRO = (quote.Opportunity.RecordType.Name == 'Lending RO' || quote.Opportunity.RecordType.Name == 'Lending Easy Plus RO') && !admin ? true : false;
            isFirmaDigitale = quote.Opportunity.Tipo_Firma__c == 'Firma Digitale' ? true : false;
            isContratoVerificato = quote.Contratto_Verificato__c == true ? true : false;
            isFirmaDigitale = quote.Opportunity.Tipo_Firma__c == 'Firma Manuale' ? true : false;
        } else if (objectApiName == 'Contact') {
            Contact cont = [Select Id, Account.erogazione_dei_servizi__c, Account.RecordType.Name from Contact Where Id = :recordId][0];
            isErogazioneNO = cont.Account.erogazione_dei_servizi__c == 'YES' ? false : true;
            isRecTypeRO = cont.Account.RecordType.Name == 'AccountNoOpp' && !admin ? true : false;
        }

        if (smallObjectName == 'Quote' && selectedCont != null) {
            Quote quote = [Select Id, Contratto_Verificato__c from Quote Where Id = :selectedCont][0];
            isContratoVerificato = quote.Contratto_Verificato__c == true ? true : false;
        }

        List<Switch__mdt> metadata = [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName = 'NDG_Eleva'];
        if (metadata.size() == 1) {
            if (metadata[0].Status__c == 'Active') {
                isSwitchActive = false;
                system.debug('isSwitchActive' + isSwitchActive);
            }
        }

        varMap.put('isStageFirma', isStageFirma);
        varMap.put('isErogazioneNO', isErogazioneNO);
        varMap.put('isRecTypeRO', isRecTypeRO);
        varMap.put('isFirmaDigitale', isFirmaDigitale);
        varMap.put('isProfileSales', isProfileSales);
        varMap.put('isProfileSalesNoFiscalPartner', isProfileSalesNoFiscalPartner);
        varMap.put('isContratoVerificato', isContratoVerificato);
        varMap.put('isProfileInsideSales', isProfileInsideSales);
        varMap.put('isProfileFidimed', isProfileFidimed);
        varMap.put('isProfileSalesEasy', isProfileSalesEasy);
        varMap.put('isProfileTuttiSales', isProfileTuttiSales);
        varMap.put('isProfileFiscalPartner', isProfileFiscalPartner);
        varMap.put('isSwitchActive', isSwitchActive);
        varMap.put('isOppEasyPlus', isOppEasyPlus);
        varMap.put('isAdmin', admin);
        varMap.put('profileName', profileName);
        varMap.put('isProfileAgente', isProfileAgente);
        varMap.put('isProfileMediatore', isProfileMediatore);
        varMap.put('isProfileIntermediario', isProfileIntermediario);
        varMap.put('isProfileBackOffice', isProfileBackOffice);
        varMap.put('isProfileRespBo', isProfileRespBo);
        varMap.put('isProfileRespBoCedenti', isProfileRespBoCedenti);

        System.debug('varMap' + varMap);
        System.debug('varMap isSwitchActive' + varMap.get('isSwitchActive'));

        return varMap;
    }

    @AuraEnabled(Cacheable=false)
    public static void eliminateDocuments(List<String> documentIdList) {
        List<Document__c> listToDelete = [SELECT Id,File_Name__c,Id_File__c FROM Document__c WHERE Id IN: documentIdList];
        for(Document__c document : listToDelete) {
            updateFile(document.Id, document.File_Name__c, document.Id_File__c,'elimina');
        }
    }

    @TestVisible
    private static List<String> getVisibleForStage (Opportunity opp) {
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> stageNamePicklistValues = fieldResult.getPicklistValues();
        List<String> visibleForStage = new List<String>();
        Integer current;

        for (Integer i = 0; i < stageNamePicklistValues.size(); i++) {
            if (stageNamePicklistValues[i].getValue() == opp.StageName) {
                current = i;
            }
        }

        for (Integer j = 0; j <= current; j++) {
            visibleForStage.add(stageNamePicklistValues[current - j].getValue());
        }

        return visibleForStage;
    }

}