public with sharing class fileUploaderController extends TriggerHandler {
    public static Boolean bypassTrigger{set;get;}
    public static boolean firstRun = true;
    public override void run(){
        if(bypassTrigger==null || bypassTrigger==false){
            super.run();
        }
    }

    static List<DocumentType__c> documentTypes = [
            SELECT Id, Name, Opportunita_EasyPlus__c, ObjectName__c, ID_Tipo_Documento__c,
                    Opportunity_Crediti_Fiscali__c, Obbligatorio_per_Pre_Due_Diligence__c, Obbligatorio_in_Erogazione__c,
                    Obbligatorio_in_CompletamentoDocumenti__c, Opportunita_Mutuo__c, Obbligatorio_in_Deliberata__c,
                    Obbligatorio_per_In_Stipula__c, Doc_Opzionale__c
            FROM DocumentType__c
            ORDER BY ObjectName__c
    ];

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

    /** Triggered after a Document__c is inserted into the database **/
    public override void afterInsert() {
        fileUploaderController.UpdateDocCountAfterUploadInsertDelete(Trigger.new);
    }

    /** Triggered after a Document__c is updated in the database **/
    public override void afterUpdate()
    {
        List<Document__c> listUploadedDocCountAfterVerified = new List<Document__c>();
//        List<Document__c> listUpdateDocCountAfterUpdateOptional = new List<Document__c>();
        List<Document__c> listUploadedDocCountAfterUpdateUploaded = new List<Document__c>();
        List<Id> listDocContrattoId = new List<Id>();
        List<Id> listDocContrattoDigitale = new List<Id>();
        
        fileUploaderController.conditionUpdateUrl(Trigger.new, (Map<Id, Document__c>) Trigger.oldMap);       
        //  fileUploaderController.deleteFile(Trigger.New,(Map<Id, Document__c>) Trigger.oldMap);
        
        for (Document__c d: (List<Document__c>)Trigger.new) {
            Document__c docOld = (Document__c) Trigger.oldMap.get(d.Id);

            if (d.Url_Documento__c != docOld.Url_Documento__c && d.IDTipoDocumentoFormula__c == 'SME_100' && d.Url_Documento__c != null && d.Quote__c != null){
                listDocContrattoId.add(d.Id);
            }
            if (d.Url_Documento__c != docOld.Url_Documento__c && docOld.Url_Documento__c != null && d.IDTipoDocumentoFormula__c == 'SME_100' && d.Url_Documento__c != null && d.Quote__c != null){
                listDocContrattoDigitale.add(d.Id);
            }
            if (d.Verifica_Sales_Support__c != docOld.Verifica_Sales_Support__c && d.Url_Documento__c != null ) {
                listUploadedDocCountAfterVerified.add(d);
            }

            if (( docOld.Url_Documento__c == null && d.Url_Documento__c!= null)) {
                listUploadedDocCountAfterUpdateUploaded.add(d);
            }         
        }

        if (!listUploadedDocCountAfterVerified.isEmpty()) {
            fileUploaderController.UpdateDocCountAfterUploadInsertDelete(listUploadedDocCountAfterVerified);
        }

        if (!listUploadedDocCountAfterUpdateUploaded.isEmpty()) {
            fileUploaderController.UpdateDocCountAfterUploadInsertDelete(listUploadedDocCountAfterUpdateUploaded);
        }

        if (!listDocContrattoId.isEmpty()) {
            fileUploaderController.linkUrlDocumentoQuote(listDocContrattoId);
        }
        if (!listDocContrattoDigitale.isEmpty()) {
            fileUploaderController.linkUrlDocumentoFirmaDigitale(listDocContrattoDigitale);
        }
        System.debug('fileUploaderController.afterUpdate - End');
    }

    /** Triggered after a Document__c is deleted FROM the database **/
    public override void afterDelete() {
        UpdateDocCountAfterUploadInsertDelete(Trigger.old);
    }

    /** Returns a map of opportunity Id and every document related to that opportunity **/
    public static Map<String, List<Document__c>> AllDocumentsMap (Set<String> myOpp) {
        Map<String, List<Document__c>> allDocs = new Map<String, List<Document__c>>();
        List<Opportunity> opportunityList = [
                SELECT Id, AccountId, (SELECT Id, ObligatarioAcc__c, StatusStageVisibleFormula__c, Obbligatorio__c,
                        ObligatorioCont__c, ObligatorioQuote__c, Url_Documento__c,Verifica_Sales_Support__c,
                        dependeDaTipoLineaFormula__c, File_Name__c, Opportunity__c, Account__c, Contact__c,
                        Quote__c, ObjectName__c, DocumentType__c, DocumentTypeNameFormula__c,
                        DocumentType__r.ObjectName__c, DocumentType__r.Name, IDTipoDocumentoFormula__c FROM Documenti__r)
                FROM Opportunity
                WHERE Id IN :myOpp
        ];
        Set<Id> accIdSet = new Set<Id>();

        for (Opportunity opportunity : opportunityList) {
            accIdSet.add(opportunity.AccountId);
            List<Document__c> opportunityDocs = new List<Document__c>();
            for (Document__c document : opportunity.Documenti__r) {
                if (document.DocumentType__r.ObjectName__c == 'Opportunity'){
                    opportunityDocs.add(document);
                }
            }
            allDocs.put(opportunity.Id, opportunityDocs);
        }
        
        for (Account account :[
                SELECT Id, Name, (SELECT Id, ObligatarioAcc__c, Obbligatorio__c, StatusStageVisibleFormula__c,
                        ObligatorioCont__c, ObligatorioQuote__c, Url_Documento__c, Verifica_Sales_Support__c,
                        dependeDaTipoLineaFormula__c, File_Name__c, Opportunity__c, Account__c, Contact__c, Quote__c,
                        ObjectName__c, DocumentType__c, DocumentTypeNameFormula__c, DocumentType__r.ObjectName__c,
                        DocumentType__r.Name, IDTipoDocumentoFormula__c FROM Documenti__r),
                        (SELECT Id FROM Opportunities)
                FROM Account
                WHERE Id IN :accIdSet]) {
                            List<Document__c> accountDocs = new List<Document__c>();

                            for (Document__c document : account.Documenti__r) {
                                if (document.DocumentType__r.ObjectName__c == 'Account'){
                                    accountDocs.add(document);
                                }
                            }

                            for (Opportunity opp : account.Opportunities) {
                                if (allDocs.containsKey(opp.Id)) {
                                    allDocs.get(opp.Id).addAll(accountDocs);
                                    allDocs.put(opp.Id,allDocs.get(opp.Id) );
                                }
                            }
                        }
        
        for (Contact contact : [
                SELECT Id, AccountId, Name, (SELECT Id, ObligatarioAcc__c, StatusStageVisibleFormula__c, Obbligatorio__c,
                        ObligatorioCont__c, ObligatorioQuote__c, Url_Documento__c, Verifica_Sales_Support__c,
                        dependeDaTipoLineaFormula__c, File_Name__c, Opportunity__c, Account__c, Contact__c, Quote__c,
                        ObjectName__c, DocumentType__c, DocumentTypeNameFormula__c, DocumentType__r.ObjectName__c,
                        DocumentType__r.Name, IDTipoDocumentoFormula__c FROM Documenti__r)
                FROM Contact
                WHERE AccountId IN :accIdSet
                AND Ruolo_in_Azienda__c IN ('Titolare Effettivo', 'Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')]) {
                               if (contact.Documenti__r.size() > 0) {
                                   List<Document__c> contactDocs = new List<Document__c>();
                                   for (Document__c document : contact.Documenti__r) {
                                       if (document.DocumentType__r.ObjectName__c == 'Contact') {
                                           contactDocs.add(document);
                                       }
                                   }
                                   for (Opportunity opp : opportunityList) {
                                       if (opp.AccountId == contact.AccountId) {
                                           allDocs.get(opp.Id).addAll(contactDocs);
                                           allDocs.put(opp.Id, allDocs.get(opp.Id));
                                       }
                                   }
                               }
                           }
        
        for (Quote quote : [
                SELECT Id, OpportunityId, Name,(SELECT Id, Name,ObligatarioAcc__c, StatusStageVisibleFormula__c, Obbligatorio__c,
                        ObligatorioCont__c, ObligatorioQuote__c, Url_Documento__c, Verifica_Sales_Support__c,
                        dependeDaTipoLineaFormula__c, File_Name__c, Opportunity__c, Account__c, Contact__c, Quote__c,
                        ObjectName__c, DocumentType__c, DocumentTypeNameFormula__c, DocumentType__r.ObjectName__c,
                        DocumentType__r.Name, IDTipoDocumentoFormula__c FROM Documenti__r)
                FROM Quote
                WHERE OpportunityId IN :myOpp
                AND Status != 'Annullata']) {
            if (quote.Documenti__r.size() > 0) {
                List<Document__c> quoteDocs = new List<Document__c>();

                for (Document__c document : quote.Documenti__r) {
                    if (document.DocumentType__r.ObjectName__c == 'Quote'){
                        quoteDocs.add(document);
                    }
                }

                for (Opportunity opp : opportunityList) {
                    if (opp.Id == quote.OpportunityId && allDocs.get(opp.Id) != null) {
                        allDocs.get(opp.Id).addAll(quoteDocs);
                        allDocs.put(opp.Id,allDocs.get(opp.Id) );                                            
                    }
                }
            }
        }

        return allDocs;
    }

    /** Returns a map of opportunity Id and counters for all document status options **/
    public static  Map<String, Map<String, Integer>> MapDocumentsConditions (Map<String, List<Document__c>> allDocs) {
        Schema.DescribeFieldResult opportunityStageName = Opportunity.stagename.getDescribe();
        List<Schema.PicklistEntry> stageNamePicklistValues = opportunityStageName.getPicklistValues();
        Map<String, List<String>> oppStageMap = new Map<String, List<String>>();
        Map<String, Map<String, Integer>> allOppDocNr = new Map<String, Map<String, Integer>>();
        Set<String> oppIdSet = new Set<String>();
        Set<String> myEasyOpps = new Set<String>();

        for (Id opp : allDocs.keySet()) {
            oppIdSet.add(opp);
        }

        for (Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIdSet]) {
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

            oppStageMap.put(opp.Id, visibleForStage);
        }

        for (Opportunity opp : [SELECT Id, StageName, Tipo_Linea_di_Credito__c FROM Opportunity WHERE Id IN :oppIdSet AND Tipo_Linea_di_Credito__c = 'Progetto EasyPlus']) {
            myEasyOpps.add(opp.Id);
        }

        for (Id oppId : allDocs.keySet()) {
            Map<String, Integer> data = new Map<String, Integer>();
            data.put('Total',allDocs.get(oppId).size());
            data.put('Obligatorio', 0);
            data.put('NonObligatorio', 0);
            data.put('Uploaded', 0);
            data.put('Verified', 0);
            List<String> opportunityStageList = oppStageMap.get(oppId);

            for (Document__c document : allDocs.get(oppId)) {
                if (opportunityStageList.contains(document.StatusStageVisibleFormula__c)) {
                    if (document.Url_Documento__c != null) {
                        if (document.Verifica_Sales_Support__c != 'Da Ricaricare') {
                            data.put('Uploaded', data.get('Uploaded') + 1);

                            if (document.Obbligatorio__c == false &&
                                    document.ObligatarioAcc__c == false &&
                                    document.ObligatorioCont__c == false &&
                                    document.ObligatorioQuote__c == false &&
                                    !(document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' &&
                                            myEasyOpps.contains(oppId))
                                    ) {
                                data.put('NonObligatorio', data.get('NonObligatorio') + 1);
                            }
                        }

                        if (document.Obbligatorio__c == true ||
                                document.ObligatarioAcc__c == true ||
                                document.ObligatorioCont__c == true ||
                                document.ObligatorioQuote__c == true ||
                                (document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' &&
                                        myEasyOpps.contains(oppId))
                                ) {
                            data.put('Obligatorio', data.get('Obligatorio') + 1);
                        }

                        if (document.Verifica_Sales_Support__c == 'Verifica OK' && document.Url_Documento__c != null) {
                            data.put('Verified', data.get('Verified') + 1);
                        }
                    }
                }
            }
            allOppDocNr.put(oppId,data);
        }
        return allOppDocNr;
    }

// Obsolete method, to be removed at a later date.
//    /** Returns a map of opportunity Id and counters for optional document status options **/
//    public static  Map<String, Map<String, Integer>> MapDocumentsConditionsOptional(Map<String, List<Document__c>> allDocs) {
//
//        Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
//        List<Schema.PicklistEntry> vls = fieldResult.getPicklistValues();
//        Map<String, List<String>> oppStageMap = new Map<String, List<String>>();
//        Map<String, Map<String, Integer>> allOppDocNr = new Map<String, Map<String, Integer>>();
//        Set<String> oppId = new Set<String>();
//        Set<String> myEasyOpps = new Set<String>();
//
//        for (Opportunity opp : [SELECT Id, StageName, Tipo_Linea_di_Credito__c FROM Opportunity WHERE Id IN: oppId AND Tipo_Linea_di_Credito__c = 'Progetto EasyPlus']) {
//            myEasyOpps.add(opp.Id);
//        }
//
//        for (Id opp : allDocs.keySet()) {
//            oppId.add(opp);
//        }
//
//        for (Opportunity opp : [SELECT Id , StageName FROM Opportunity WHERE Id IN: oppId]) {
//            List<String> VisibleForStage = new List<String>();
//            Integer current;
//
//            for (Integer i = 0; i < vls.size(); i++ ) {
//                if (vls[i].getValue() == opp.StageName) {
//                    current = i;
//                }
//            }
//
//            for (Integer j = 0; j <= current; j++) {
//                VisibleForStage.add(vls[current -j].getValue());
//            }
//
//            oppStageMap.put(opp.Id,VisibleForStage);
//        }
//
//        for (Id OOP : allDocs.keySet()) {
//            Map<String, Integer> data = new Map<String, Integer>();
//            data.put('NonObligatorio', 0);
//            data.put('Uploaded', 0);
//            List<String> stage = oppStageMap.get(OOP);
//            for (Document__c document : allDocs.get(OOP)) {
//                if (stage.contains(document.StatusStageVisibleFormula__c)) {
//                    if (document.Url_Documento__c != null) {
//                        if (document.Verifica_Sales_Support__c != 'Da Ricaricare') {
//                            data.put('Uploaded', data.get('Uploaded') + 1);
//
//                            if (document.Obbligatorio__c == false &&
//                                    document.ObligatarioAcc__c == false &&
//                                    document.ObligatorioCont__c == false &&
//                                    document.ObligatorioQuote__c == false &&
//                                    !(document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' &&
//                                            myEasyOpps.contains(OOP))) {
//                                data.put('NonObligatorio', data.get('NonObligatorio') + 1);
//                            }
//                        }
//                    }
//                }
//            }
//            allOppDocNr.put(OOP,data);
//        }
//        return allOppDocNr;
//    }

// Obsolete method, to be removed at a later date.
//    /** Returns a map of opportunity Id and counters for document status options when a document is uploaded **/
//    public static  Map<String, Map<String, Integer>> MapDocumentsConditionsUploaded(Map<String, List<Document__c>> allDocs) {
//        Schema.DescribeFieldResult opportunityStageName = Opportunity.stagename.getDescribe();
//        List<Schema.PicklistEntry> stageNamePicklistValues = opportunityStageName.getPicklistValues();
//        Map<String, List<String>> oppStageMap = new Map<String, List<String>>();
//        Map<String, Map<String, Integer>> allOppDocNr = new Map<String, Map<String, Integer>>();
//        Set<String> oppId = new Set<String>();
//
//        for (Id opp : allDocs.keySet()) {
//            oppId.add(opp);
//        }
//
//        for(Opportunity opp : [SELECT Id , StageName FROM Opportunity WHERE Id IN: oppId])
//        {
//            List<String> visibleForStage = new List<String>();
//            Integer current;
//
//            for(Integer i = 0; i < stageNamePicklistValues.size(); i++ ) {
//                if(stageNamePicklistValues[i].getValue() == opp.StageName) {
//                    current= i;
//                }
//            }
//
//            for(Integer j = 0; j <= current; j++ ) {
//                visibleForStage.add(stageNamePicklistValues[current -j].getValue());
//            }
//
//            oppStageMap.put(opp.Id,visibleForStage);
//        }
//
//        for (Id OOP : allDocs.keySet()) {
//            Map<String, Integer> data = new Map<String, Integer>();
//            data.put('NonObligatorio', 0);
//            data.put('Uploaded', 0);
//            List<String> opportunityStageList = oppStageMap.get(OOP);
//
//            for (Document__c document : allDocs.get(OOP) ) {
//                if (opportunityStageList.contains(document.StatusStageVisibleFormula__c)) {
//                    if (document.Verifica_Sales_Support__c != 'Da Ricaricare') {
//                        if (document.Url_Documento__c != null) {
//                            data.put('Uploaded',  data.get('Uploaded') + 1);
//                        }
//                    }
//                }
//            }
//            allOppDocNr.put(OOP,data);
//        }
//
//        return allOppDocNr;
//    }

// Obsolete method, to be removed at a later date.
//    /** Returns a map of opportunity Id and counters for document status options when a document is verified **/
//    public static  Map<String, Map<String, Integer>> MapDocumentsConditionsVerified(Map<String, List<Document__c>> allDocs) {
//        Schema.DescribeFieldResult opportunityStageName = Opportunity.stagename.getDescribe();
//        List<Schema.PicklistEntry> stageNamePicklistValues = opportunityStageName.getPicklistValues();
//        Map<String, List<String>> oppStageMap = new Map<String, List<String>>();
//        Map<String, Map<String, Integer>> allOppDocNr = new Map<String, Map<String, Integer>>();
//        Set<String> oppIdSet = new Set<String>();
//        Set<Id> myEasyOpps = new Set<Id>();
//
//        for (String opp : allDocs.keySet()) {
//            oppIdSet.add(opp);
//        }
//
//        for (Opportunity opp : [SELECT Id , StageName FROM Opportunity WHERE Id IN: oppIdSet]) {
//            List<String> VisibleForStage = new List<String>();
//            Integer current;
//
//            for (Integer i = 0; i < stageNamePicklistValues.size(); i++ ) {
//                if (stageNamePicklistValues[i].getValue() == opp.StageName) {
//                    current = i;
//                }
//            }
//
//            for (Integer j = 0; j <= current; j++ ) {
//                VisibleForStage.add(stageNamePicklistValues[current -j].getValue());
//            }
//
//            oppStageMap.put(opp.Id,VisibleForStage);
//        }
//
//        for (Opportunity opp : [SELECT Id, StageName, Tipo_Linea_di_Credito__c FROM Opportunity WHERE Id IN: oppIdSet AND Tipo_Linea_di_Credito__c = 'Progetto EasyPlus']) {
//            myEasyOpps.add(opp.Id);
//        }
//
//        for (Id OOP : allDocs.keySet()) {
//            Map<String, Integer> data = new Map<String, Integer>();
//            data.put('Total', allDocs.get(OOP).size());
//            data.put('Obligatorio', 0);
//            data.put('NonObligatorio', 0);
//            data.put('Uploaded', 0);
//            data.put('Verified', 0);
//            List<String> opportunityStageList = oppStageMap.get(OOP);
//
//            for (Document__c document : allDocs.get(OOP)) {
//                if (opportunityStageList.contains(document.StatusStageVisibleFormula__c)) {
//                    if (document.Url_Documento__c != null) {
//                        if (document.Verifica_Sales_Support__c != 'Da Ricaricare') {
//
//                            data.put('Uploaded', data.get('Uploaded') + 1);
//                            if (document.Obbligatorio__c == false &&
//                                    document.ObligatarioAcc__c == false &&
//                                    document.ObligatorioCont__c == false &&
//                                    document.ObligatorioQuote__c == false &&
//                                    !(document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' &&
//                                            myEasyOpps.contains(OOP)))
//                            {
//                                data.put('NonObligatorio', data.get('NonObligatorio') + 1);
//                            }
//                        }
//
//                        if (document.Obbligatorio__c == true ||
//                                document.ObligatarioAcc__c == true ||
//                                document.ObligatorioCont__c == true ||
//                                document.ObligatorioQuote__c == true ||
//                                (document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' &&
//                                        myEasyOpps.contains(OOP))) {
//                            data.put('Obligatorio', data.get('Obligatorio') + 1);
//                        }
//
//                        if (document.Verifica_Sales_Support__c == 'Verifica OK' && document.Url_Documento__c != null) {
//                            data.put('Verified', data.get('Verified') + 1);
//                        }
//                    }
//                }
//            }
//            allOppDocNr.put(OOP, data);
//        }
//
//        return allOppDocNr;
//    }

    /** Returns a list of all ids related to received document list **/
    public static List<String> updatedDocCount(List<Document__c> triggerListNew) {
        Set<String> docAccounts = new Set<String>();
        Set<String> docContacts = new Set<String>();
        Set<String> docOpportunities = new Set<String>();
        Set<String> docQuotes = new Set<String>();
        List<String> docOpportunitiesList = new List<String>();

        for (Document__c doc : triggerListNew) {
            if (doc.Opportunity__c <> null) {
                docOpportunities.add(doc.Opportunity__c);
            }

            if (doc.Account__c <> null) {
                docAccounts.add(doc.Account__c);
            }

            if (doc.Contact__c <> null) {
                docContacts.add(doc.Contact__c);
            }

            if (doc.Quote__c <> null) {
                docQuotes.add(doc.Quote__c);
            }
        }

        if (docContacts.size() != 0) {
            for (Contact contact: [SELECT Id, Name , AccountId FROM Contact WHERE Id IN:docContacts ]) {
                if (contact.AccountId != null) {
                    docAccounts.add(contact.AccountId);
                }
            }
        }

        if (docAccounts.size() != 0) {
            for (Opportunity opportunity: [SELECT Id, Name FROM Opportunity WHERE AccountId IN : docAccounts ]) {
                docOpportunities.add(opportunity.Id);
            }
        }

        if (docQuotes.size() != 0) {
            for (Quote quote : [SELECT Id, OpportunityId FROM Quote WHERE Id IN:docQuotes ]) {
                docOpportunities.add(quote.OpportunityId);
            }
        }

        docOpportunitiesList.addAll(docOpportunities);
        return docOpportunitiesList;
    }

// Obsolete method, to be removed at a later date.
//    /** Updates document counters after a document is verified **/
//    public static void UdateDocCountAfterDocIsVerified(List<Document__c> triggerListNew) {
//        List<String> docOpportunities = updatedDocCount(triggerListNew);
//        List<Opportunity> oppsToUpdate = new List<Opportunity>();
//        Map<String, Opportunity> opportunityMap = GetOpportunityMap(docOpportunities);
//
//        Map<String, List<Document__c>> oppIdAndDocumentsMap = GetOppIdAndDocumentsMap(opportunityMap);
//        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = MapDocumentsConditions(oppIdAndDocumentsMap);
//        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
//        List<Id> accountIdList = GetAccountIdList(opportunityMap.values());
//        Map<Id, Integer> oppIdAndMandatoryContacts = computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
//        Map<Id, Integer> oppIdAndMandatoryQuotes = computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);
//
//        for (String oppId : oppIdAndDocStatusMap.keySet()) {
//            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(oppId);
//            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(oppId);
//            Opportunity newOpp = new Opportunity ();
//
//            newOpp.Id = oppId;
//            newOpp.Total_Mandatories_Docs__c = computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), mandatoryContactDocs, mandatoryQuoteDocs);
//            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
//            newOpp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
//
//            oppsToUpdate.add(newOpp);
//        }
//        update oppsToUpdate;
//    }

// Obsolete method, was combined & replaced with UpdateDocCountAfterUploadInsert; to be removed at a later date.
//    /** Updates document counters after a file is uploaded **/
//    public static void UpdateDocCountAfterFileIsUploaded(List<Document__c> triggerListNew) {
//        List<String> docOpportunities = updatedDocCount(triggerListNew);
//        List<Opportunity> oppsToUpdate = new List<Opportunity>();
//        Map<String, Opportunity> opportunityMap = GetOpportunityMap(docOpportunities);
//
//        Map<String, List<Document__c>> oppIdAndDocumentsMap = GetOppIdAndDocumentsMap(opportunityMap);
//        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = MapDocumentsConditions(oppIdAndDocumentsMap);
//
//        for (Id oppId : oppIdAndDocStatusMap.keySet()) {
//            Opportunity newOpp = new Opportunity ();
//            newOpp.Id = oppId;
//            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
//            oppsToUpdate.add(newOpp);
//        }
//
//        update oppsToUpdate;
//    }

    /** Updates document counters after a document is inserted into the database **/
    public static void UpdateDocCountAfterUploadInsertDelete(List<Document__c> triggerListNew) {
        List<String> docOpportunities = updatedDocCount(triggerListNew);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<String, Opportunity> opportunityMap = GetOpportunityMap(docOpportunities);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = MapDocumentsConditions(oppIdAndDocumentsMap);
         /** Returns a map of mandatory document types for each opportunity **/   
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);

        for (String oppId : oppIdAndDocStatusMap.keySet()) {
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(oppId);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(oppId);
            Opportunity newOpp = new Opportunity();

            newOpp.Id = oppId;
            newOpp.Total_Mandatories_Docs__c = computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), mandatoryContactDocs, mandatoryQuoteDocs);
            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
            newOpp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
            oppsToUpdate.add(newOpp);
        }
        update oppsToUpdate;
    }

    /** Returns a filtered map of opportunity Id and every document related to that opportunity **/
    public static Map<String, List<Document__c>> GetOppIdAndDocumentsMap(Map<String, Opportunity> opportunityMap) {
        Map<String, List<Document__c>> initialOppIdAndDocumentsMap = AllDocumentsMap(opportunityMap.keySet());
        Map<String, Map<String, DocumentType__c>> oppIdAndDocTypeIdMap = GetMandatoryDocTypesMap(opportunityMap);
        Map<String, List<Document__c>> filteredOppIdAndDocumentsMap = new Map<String, List<Document__c>>();

        for (String oppId : initialOppIdAndDocumentsMap.keySet()) {
            Map<String, DocumentType__c> documentTypeMap = oppIdAndDocTypeIdMap.get(oppId);
            List<Document__c> filteredDocList = new List<Document__c>();
            Map<Id, Document__c> docIdAndDocMap = new Map<Id, Document__c>();

            for (Document__c document : initialOppIdAndDocumentsMap.get(oppId)) {
                if (document.File_Name__c != null &&
                        document.Url_Documento__c != null &&
                        (document.Opportunity__c != null ||
                                document.Account__c != null ||
                                document.Contact__c != null ||
                                document.Quote__c != null)) {
                    if (!docIdAndDocMap.containsKey(document.Id)) {
                        docIdAndDocMap.put(document.Id, document);
                        if (documentTypeMap.get(document.DocumentType__c) != null) {
                            filteredDocList.add(document);
                        }
                    }
                }
            }
            filteredOppIdAndDocumentsMap.put(oppId, filteredDocList);
        }
        return filteredOppIdAndDocumentsMap;
    }

    /** Returns a filtered map of opportunity Id and every document related to that opportunity **/
    public static Map<String, List<Document__c>> GetOppIdAndAllDocumentsMap(Map<String, Opportunity> opportunityMap) {
        Map<String, List<Document__c>> initialOppIdAndDocumentsMap = AllDocumentsMap(opportunityMap.keySet());
        Map<String, Map<String, DocumentType__c>> oppIdAndDocTypeIdMap = GetDocTypesMap(opportunityMap);
        Map<String, List<Document__c>> filteredOppIdAndDocumentsMap = new Map<String, List<Document__c>>();

        for (String oppId : initialOppIdAndDocumentsMap.keySet()) {
            Map<String, DocumentType__c> documentTypeMap = oppIdAndDocTypeIdMap.get(oppId);
            List<Document__c> filteredDocList = new List<Document__c>();
            Map<Id, Document__c> docIdAndDocMap = new Map<Id, Document__c>();

            for (Document__c document : initialOppIdAndDocumentsMap.get(oppId)) {
                if (document.File_Name__c != null &&
                        document.Url_Documento__c != null &&
                        (document.Opportunity__c != null ||
                                document.Account__c != null ||
                                document.Contact__c != null ||
                                document.Quote__c != null)) {
                    if (!docIdAndDocMap.containsKey(document.Id)) {
                        docIdAndDocMap.put(document.Id, document);
                        if (documentTypeMap.get(document.DocumentType__c) != null) {
                            filteredDocList.add(document);
                        }
                    }
                }
            }
            filteredOppIdAndDocumentsMap.put(oppId, filteredDocList);
        }
        return filteredOppIdAndDocumentsMap;
    }

// Obsolete method, to be removed at a later date.
//    /** Updates the document counters after a Document__c is deleted from the database */
//    public static void UpdateDocCountAfterDelete(List<Document__c> triggerListOld) {
//        List<String> docOpportunities = updatedDocCount(triggerListOld);
//        List<Opportunity> oppsToUpdate = new List<Opportunity>();
//        Map<String, Opportunity> opportunityMap = GetOpportunityMap(docOpportunities);
//
//        Map<String, List<Document__c>> oppIdAndDocumentsMap = GetOppIdAndDocumentsMap(opportunityMap);
//        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = MapDocumentsConditions(oppIdAndDocumentsMap);
//        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
//
//        for (Id oppId : oppIdAndDocStatusMap.keySet()){
//            Opportunity oppToUpdate = new Opportunity ();
//
//            oppToUpdate.Id = oppId;
//            oppToUpdate.Total_Mandatories_Docs__c = computeTotalMandatoryDocsAfterDelete(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), triggerListOld);
//            oppToUpdate.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
//            oppToUpdate.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
//            oppsToUpdate.add(oppToUpdate);
//        }
//
//        update oppsToUpdate;
//    }

// Obsolete method, to be removed at a later date.
//    public static  Map<String, Integer> sumofDocs(List<String> myOpp, String field) {
//        Map<String, Integer> allOppDocNr = new Map<String, Integer>();
//        Map<String, Integer> allAccDocNr = new Map<String, Integer>();
//        Map<String, Integer> allCtnDocNr = new Map<String, Integer>();
//        Map<String, Integer> allQuoteDocNr = new Map<String, Integer>();
//
//        List<Id> accId = new List<Id>();
//        List<Opportunity> nrOfDocOpp = new List<Opportunity>();
//        List<Account> nrOfDocAcc = new List<Account>();
//        List<Contact> nrOfDocCont = new List<Contact>();
//        List<Quote> quote = new List<Quote>();
//        List<Opportunity> accOpp = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :myOpp];
//
//        for (Opportunity opp : accOpp) {
//            accId.add(opp.AccountId);
//        }
//
//        if (field == 'Verified' ) {
//            nrOfDocOpp = [SELECT Id,Name,Total_Uploaded_Docs__c,(SELECT Id,Url_Documento__c, Verifica_Sales_Support__c FROM Documenti__r WHERE Url_Documento__c!= NULL AND Verifica_Sales_Support__c ='Verifica OK' ) FROM Opportunity WHERE Id IN :myOpp];
//        } else if (field=='Uploaded') {
//            nrOfDocOpp = [SELECT Id,Name,Total_Uploaded_Docs__c,(SELECT Id, Url_Documento__c FROM Documenti__r WHERE Url_Documento__c!= NULL ) FROM Opportunity WHERE Id IN :myOpp];
//        }
//
//        for(Opportunity oppDoc : nrOfDocOpp) {
//            allOppDocNr.put(oppDoc.Id,oppDoc.Documenti__r.size());
//        }
//
//        if (field == 'Verified' ) {
//            nrOfDocAcc = [SELECT Id,Name,(SELECT Id,Url_Documento__c,Verifica_Sales_Support__c  FROM Documenti__r WHERE Url_Documento__c!= NULL AND Verifica_Sales_Support__c ='Verifica OK'),(SELECT Id FROM Opportunities)
//                          FROM Account WHERE Id IN :accId ];
//        } else if (field =='Uploaded') {
//            nrOfDocAcc = [SELECT Id,Name,(SELECT Id, Url_Documento__c  FROM Documenti__r WHERE Url_Documento__c!= NULL ),(SELECT Id FROM Opportunities)
//                          FROM Account WHERE Id IN :accId ];
//        }
//
//
//        for (Account accDoc : nrOfDocAcc) {
//            if (accDoc.Documenti__r.size() > 0) {
//                for (Opportunity opp : accDoc.Opportunities) {
//                    if (allOppDocNr.containsKey(opp.Id)) {
//                        allAccDocNr.put(accDoc.Id,accDoc.Documenti__r.size());
//                        allOppDocNr.put(opp.Id,allOppDocNr.get(opp.Id) + accDoc.Documenti__r.size());
//                    }
//                }
//            }
//        }
//
//        if (field == 'Verified'){
//            nrOfDocCont = [SELECT  Id, AccountId, Name ,(SELECT Id ,Url_Documento__c,Verifica_Sales_Support__c FROM Documenti__r WHERE  Url_Documento__c!= NULL AND Verifica_Sales_Support__c ='Verifica OK')
//                          FROM Contact WHERE AccountId IN :accId ];
//        }
//        else if (field=='Uploaded') {
//            nrOfDocCont = [SELECT  Id, AccountId, Name ,(SELECT Id ,Url_Documento__c FROM Documenti__r WHERE  Url_Documento__c != NULL)
//                          FROM Contact WHERE AccountId IN :accId ];
//        }
//
//        for (Contact val : nrOfDocCont ) {
//            for (Opportunity opp : accOpp) {
//                if (opp.AccountId == val.AccountId && allOppDocNr.get(opp.Id) !=null) {
//                    allCtnDocNr.put(val.Id,val.Documenti__r.size());
//                    allOppDocNr.put(opp.Id,allOppDocNr.get(opp.Id) + val.Documenti__r.size());
//                }
//            }
//        }
//
//        if (field == 'Verified') {
//            quote= [SELECT Id, OpportunityId,(SELECT Id, Url_Documento__c FROM Documenti__r WHERE  Url_Documento__c!= NULL AND Verifica_Sales_Support__c ='Verifica OK') FROM Quote WHERE OpportunityId IN : myOpp];
//        } else if (field == 'Uploaded') {
//            quote= [SELECT Id, OpportunityId,(SELECT Id, Url_Documento__c FROM Documenti__r WHERE  Url_Documento__c!= NULL) FROM Quote WHERE OpportunityId IN : myOpp];
//        }
//
//        for (Quote val : quote ) {
//            for (Opportunity opp : accOpp) {
//                if (opp.Id == val.OpportunityId && allOppDocNr.get(opp.Id) != null) {
//                    allQuoteDocNr.put(val.Id, val.Documenti__r.size());
//                    allOppDocNr.put(opp.Id, allOppDocNr.get(opp.Id) + val.Documenti__r.size());
//                }
//            }
//        }
//
//        return allOppDocNr;
//    }

    /** Updates the document counters after the opportunity stage changes **/
    public static void UpdateDocCountAfterStageChange(List<Opportunity> triggerListNew) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<String> opportunityIdList = new List<String>();

        for (Opportunity opp : triggerListNew) {
            opportunityIdList.add(opp.Id);
        }

        Map<String, Opportunity> opportunityMap = GetOpportunityMap(opportunityIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);

        for (Id oppId : oppIdAndDocStatusMap.keySet()) {
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(oppId);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(oppId);
            Opportunity newOpp = new Opportunity ();

            newOpp.Id = oppId;
            newOpp.Total_Mandatories_Docs__c = computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), mandatoryContactDocs, mandatoryQuoteDocs);

            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
            newOpp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
            oppsToUpdate.add(newOpp);
        }

        update oppsToUpdate;
    }

    /** Returns the number of total mandatory document types after an opportunity stage changes **/
    public static Integer computeTotalMandatoryDocsForStageChange(List<Document__c> documentList, Map<String, DocumentType__c> mandatoryDocumentTypeMap, Opportunity opportunity, Integer mandatoryContactDocs, Integer mandatoryQuoteDocs) {
        //docTypeIdAndDocumentMap mappa doctype id , document lst
        Map<String, List<Document__c>> docTypeIdAndDocumentMap = new Map<String, List<Document__c>>();
        Integer mandatoryDocTypes = mandatoryDocumentTypeMap.size();
        List<String> docTypesToSkipCount = new List<String> {'Contact', 'Quote'};
        Opportunity opp = [SELECT Id, Active_Quotes__c FROM Opportunity where id =: opportunity.Id];
        //mandatoryDocTypes += mandatoryContactDocs; sono già presenti in mandatoryDocumentTypeMap
        if(opp.Active_Quotes__c == 1){
            mandatoryDocTypes += mandatoryQuoteDocs;
                System.debug('mandatory quote ');
            }
        System.debug('documentList entra '+ documentList);
        for (Document__c document : documentList) {
            //mandatoryDocumentTypeMap contains all mandatory doctype
            if (mandatoryDocumentTypeMap.containsKey(document.DocumentType__c)) {
                if (docTypeIdAndDocumentMap.containsKey(document.DocumentType__c)) {
                    if (!docTypesToSkipCount.contains(document.DocumentType__r.ObjectName__c)) {
                        System.debug('document.DocumentType__r.ObjectName__cskip '+ document.DocumentType__r.ObjectName__c);
                        System.debug('Entra qua 1 ???' + !docTypesToSkipCount.contains(document.DocumentType__r.ObjectName__c));
                        docTypeIdAndDocumentMap.get(document.DocumentType__c).add(document);
                    } else {
                        List<Document__c> docList = docTypeIdAndDocumentMap.get(document.DocumentType__c);
                        String docObj = document.DocumentType__r.ObjectName__c;
                        docTypeIdAndDocumentMap.get(document.DocumentType__c).add(document);
                    }
                }  else {
                    docTypeIdAndDocumentMap.put(document.DocumentType__c, new List<Document__c> {document});
                }
            }
        }

        for (String docTypeId : docTypeIdAndDocumentMap.keySet()) {
            List<Document__c> documentListInDocType = docTypeIdAndDocumentMap.get(docTypeId);
                    if (documentListInDocType.size() > 1) {
                        mandatoryDocTypes += documentListInDocType.size() - 1;
                    }  
        }
        return mandatoryDocTypes;
    }

//    Obsolete method, to be removed at a later date
//    /** Returns the number of total mandatory document types when an opportunity has multiple related contacts **/
//    public static Integer computeMandatoryContactDocTypes(Map<String, DocumentType__c> mandatoryDocumentTypeMap, Opportunity opportunity) {
//        Integer mandatoryDocTypesForOneContact = 0;
//        Integer mandatoryContactDocTypes = 0;
//        List<Contact> contactList = [
//                SELECT Id, Name, Fidejussore__c
//                FROM Contact
//                WHERE AccountId = : opportunity.AccountId
//                AND Ruolo_in_Azienda__c IN ('Titolare Effettivo', 'Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')
//        ];
//
//        if (contactList.size() > 1) {
//            for (String docTypeId : mandatoryDocumentTypeMap.keySet()) {
//                DocumentType__c docType = mandatoryDocumentTypeMap.get(docTypeId);
//                if (docType.ObjectName__c == 'Contact') {
//                    mandatoryDocTypesForOneContact++;
//                }
//            }
//        }
//
//        mandatoryContactDocTypes = (contactList.size() - 1) * mandatoryDocTypesForOneContact;
//
//        return mandatoryContactDocTypes;
//    }

    /** Returns the number of total mandatory document types when an opportunity has multiple related contacts **/
    public static Map<Id, Integer> computeUpdatedMandatoryContactDocTypes(Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocumentTypeMap, Map<String, Opportunity> opportunityMap, List<Id> accountIdList) {
        Map<Id, Integer> oppIdAndMandatoryContactDocTypes = new Map<Id, Integer>();

        Map<Id, List<Contact>> accIdAndContactMap = new Map<Id, List<Contact>>();

        for (Contact contact : [
                SELECT Id, Name, Fidejussore__c, AccountId
                FROM Contact
                WHERE AccountId IN :accountIdList
                AND Ruolo_in_Azienda__c IN ('Titolare Effettivo', 'Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')
        ]) {
            Id relatedAccountId = contact.AccountId;

            if (accIdAndContactMap.containsKey(relatedAccountId)) {
                List<Contact> accRelatedContacts = accIdAndContactMap.get(relatedAccountId);
                accRelatedContacts.add(contact);
                accIdAndContactMap.put(relatedAccountId, accRelatedContacts);
            } else {
                accIdAndContactMap.put(relatedAccountId, new List<Contact>{contact});
            }
        }

        for (Id oppId : opportunityMap.keySet()) {
            Integer mandatoryDocTypesForOneContact = 0;
            Integer mandatoryContactDocTypes = 0;
            Map<String, DocumentType__c> mandatoryDocumentTypeMap = oppIdAndMandatoryDocumentTypeMap.get(oppId);
            Opportunity opportunity = opportunityMap.get(oppId);
            List<Contact> contactList = accIdAndContactMap.get(opportunity.AccountId);

            for (String docTypeId : mandatoryDocumentTypeMap.keySet()) {
                DocumentType__c docType = mandatoryDocumentTypeMap.get(docTypeId);
                if (docType.ObjectName__c == 'Contact') {
                    mandatoryDocTypesForOneContact++;
                }
            }

            if (contactList != null) {
                if (contactList.size() > 1) {
                    mandatoryContactDocTypes = (contactList.size() - 1) * mandatoryDocTypesForOneContact;
                }
            } else {
                mandatoryContactDocTypes = -1 * mandatoryDocTypesForOneContact;
            }

            oppIdAndMandatoryContactDocTypes.put(oppId, mandatoryContactDocTypes);
        }

        return oppIdAndMandatoryContactDocTypes;
    }

//    Obsolete method, to be removed at a later date
//    /** Returns the number of total mandatory document types when an opportunity has multiple related quotes **/
//    public static Integer computeMandatoryQuoteDocTypes(Map<String, DocumentType__c> mandatoryDocumentTypeMap, Opportunity opportunity) {
//        Integer mandatoryDocTypesForOneQuote = 0;
//        Integer mandatoryQuoteDocTypes = 0;
//        List<Quote> quoteList = [
//                SELECT Id, Name
//                FROM Quote
//                WHERE OpportunityId =: opportunity.Id
//                AND Status != 'Annullata'
//        ];
//
//        if (quoteList.size() > 1) {
//            for (String docTypeId : mandatoryDocumentTypeMap.keySet()) {
//                DocumentType__c docType = mandatoryDocumentTypeMap.get(docTypeId);
//                if (docType.ObjectName__c == 'Quote') {
//                    mandatoryDocTypesForOneQuote++;
//                }
//            }
//        }
//
//        mandatoryQuoteDocTypes = (quoteList.size() - 1) * mandatoryDocTypesForOneQuote;
//
//        return mandatoryQuoteDocTypes;
//    }

    /** Returns the number of total mandatory document types when an opportunity has multiple related quotes **/
    public static Map<Id, Integer> computeUpdatedMandatoryQuoteDocTypes(Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocumentTypeMap, Map<String, Opportunity> opportunityMap) {
        Map<Id, Integer> oppIdAndMandatoryQuoteDocTypes = new Map<Id, Integer>();
        Map<Id, List<Quote>> oppIdAndQuoteMap = new Map<Id, List<Quote>>();

        for (Quote quote : [
                SELECT Id, Name, OpportunityId
                FROM Quote
                WHERE OpportunityId IN :opportunityMap.keySet()
                AND Status != 'Annullata'
        ]) {
            Id oppId = quote.OpportunityId;

            if (oppIdAndQuoteMap.containsKey(oppId)) {
                List<Quote> relatedQuotes = oppIdAndQuoteMap.get(oppId);
                relatedQuotes.add(quote);
                oppIdAndQuoteMap.put(oppId, relatedQuotes);
            } else {
                oppIdAndQuoteMap.put(oppId, new List<Quote>{quote});
            }
        }

        for (Id oppId : opportunityMap.keySet()) {
            Integer mandatoryDocTypesForOneQuote = 0;
            Integer mandatoryQuoteDocTypes = 0;
            Map<String, DocumentType__c> mandatoryDocumentTypeMap = oppIdAndMandatoryDocumentTypeMap.get(oppId);
            List<Quote> relatedQuotes = oppIdAndQuoteMap.get(oppId);
            //Stefano modification
            if(relatedQuotes != null){
                if (relatedQuotes.size() > 1) {
                    for (String docTypeId : mandatoryDocumentTypeMap.keySet()) {
                        DocumentType__c docType = mandatoryDocumentTypeMap.get(docTypeId);
                        if (docType.ObjectName__c == 'Quote') {
                            mandatoryDocTypesForOneQuote++;
                        }
                    }
                }
            }
                //Stefano modification
            if(relatedQuotes != null){
                if (relatedQuotes.size() > 1) {
                    mandatoryQuoteDocTypes = (relatedQuotes.size() - 1) * mandatoryDocTypesForOneQuote;
                }
            }

            oppIdAndMandatoryQuoteDocTypes.put(oppId, mandatoryQuoteDocTypes);
        }
        System.debug('oppIdAndMandatoryQuoteDocTypes ' + oppIdAndMandatoryQuoteDocTypes);
        System.debug('oppIdAndMandatoryQuoteDocTypes2 ' + oppIdAndMandatoryQuoteDocTypes.size());

        return oppIdAndMandatoryQuoteDocTypes;
    }

    /** Returns the number of total mandatory document types after a document is deleted **/
    public static Integer computeTotalMandatoryDocsAfterDelete(List<Document__c> documentList, Map<String, DocumentType__c> mandatoryDocumentTypeMap, Opportunity opportunity, List<Document__c> deletedDocs) {
        Map<String, List<Document__c>> docTypeIdAndDocumentMap = new Map<String, List<Document__c>>();
        Integer mandatoryDocTypes = (Integer) opportunity.Total_Mandatories_Docs__c;
        List<String> docTypesToSkipCount = new List<String> {'Contact', 'Quote'};

        for (Document__c document : documentList) {
            if (mandatoryDocumentTypeMap.containsKey(document.DocumentType__c)) {
                if (docTypeIdAndDocumentMap.containsKey(document.DocumentType__c) && !docTypesToSkipCount.contains(document.DocumentType__r.ObjectName__c)) {
                    docTypeIdAndDocumentMap.get(document.DocumentType__c).add(document);
                } else {
                    docTypeIdAndDocumentMap.put(document.DocumentType__c, new List<Document__c>{document});
                }
            }
        }

        for (Document__c document : deletedDocs) {
            if (mandatoryDocumentTypeMap.containsKey(document.DocumentType__c)) {
                List<Document__c> documentListInDocType = docTypeIdAndDocumentMap.get(document.DocumentType__c);
                if (documentListInDocType != null && documentListInDocType.size() >= 1) {
                    mandatoryDocTypes--;
                }
            }
        }

        return mandatoryDocTypes;
    }

    public static void conditionUpdateUrl(List<Document__c> triggerListNew,Map<Id,Document__c> mappaTriggerOld) {
        List<Document__c> flitDoc = associoTrigggerNewOld(triggerListNew,mappaTriggerOld); //get all the doc WHERE the url doc is changed

        if ((flitDoc.size() > 0) && (flitDoc != null)) {
            // List<Id> listId=  associateIdRecord(flitDoc);
            List<Id> opportunityId = new List<Id>();
            List<Id> contactId = new List<Id>();
            List<Id> accountId = new List<Id>();
            List<Id> quoteId = new List<Id>();
            List<Document__c> opportunityDocs = new List<Document__c>();
            List<Document__c> contactDocs = new List<Document__c>();
            List<Document__c> accountDocs = new List<Document__c>();
            List<Document__c> quoteDocs = new List<Document__c>();

            //check if the changed doc is of acc, cont, quote, opp
            for (Document__c doc: flitDoc) {
                if (doc.Contact__c != null) {
                    contactDocs.add(doc);
                    contactId.add(doc.Contact__c);
                } else if (doc.Account__c != null) {
                    accountDocs.add(doc);
                    accountId.add(doc.Account__c);
                } else if (doc.Quote__c != null) {
                    quoteDocs.add(doc);
                    quoteId.add(doc.Quote__c);
                } else if (doc.Opportunity__c != null) {
                    opportunityDocs.add(doc);
                    opportunityId.add(doc.Opportunity__c);
                }
            }
            
            if (!opportunityDocs.isEmpty()) {
                Map<Id,Opportunity> mapTypeDoc = recoveryAllFieldsOpportunity(opportunityDocs,opportunityId);
                List<Opportunity> oppUpdate = replaceUrlOpportunity(opportunityDocs,mapTypeDoc);
                if(!oppUpdate.isEmpty())
                {
                    update oppUpdate;
                }
            }

            if (!quoteDocs.isEmpty()) {
                Map<Id,Quote> mapTypeDoc = recoveryAllFieldsQuote(quoteDocs,quoteId);
                List<Quote> quoteUpdate = replaceUrlQuote(quoteDocs, mapTypeDoc);
                if(!quoteUpdate.isEmpty())
                {
                    update quoteUpdate;
                }
            }

            if (!contactDocs.isEmpty()) {
                Map<Id,Contact> mapTypeDoc = recoveryAllFieldsContact(contactDocs,contactId);
                List<Contact> contactToUpdate = replaceUrlContact(contactDocs, mapTypeDoc);
                if(!contactToUpdate.isEmpty())
                {
                    update contactToUpdate;
                }
            }
        }
    }

    public static void deleteFile(List<Document__c> triggerListNew,Map<Id,Document__c> mappaTriggerOld) {
        List<Document__c> flitDoc = associoTrigggerNewOldForDelete(triggerListNew,mappaTriggerOld);

        if ((flitDoc.size() > 0) && (flitDoc != null)) {
            List<Id> opportunityId = new List<Id>();
            List<Id> contactId = new List<Id>();
            List<Id> accountId = new List<Id>();
            List<Id> quoteId = new List<Id>();
            List<Id> listIdFileAll = new List<Id>();
            List<Id> listAll = new List<Id>();

            for (Document__c doc: flitDoc) { //check if the changed doc is of acc, cont, quote, opp
                
                if (doc.Contact__c!=null) {
                    contactId.add(doc.Contact__c);
                } else if (doc.Account__c != null) {
                    accountId.add(doc.Account__c);
                } else if (doc.Quote__c != null) {
                    quoteId.add(doc.Quote__c);      
                } else if(doc.Opportunity__c != null) {
                    opportunityId.add(doc.Opportunity__c);
                }
            }

            if (!opportunityId.isEmpty()) {
                List<Id> listIdFileOpportunity = getlistIdFileAllOpportunity(opportunityId); // lista di tutti gli id file presenti in Document__c con condizione if idfile!=null
                listIdFileAll.addAll(listIdFileOpportunity);
            }

            if (!accountId.isEmpty()) {
                List<Id> listIdFileAccount = getlistIdFileAllAccount(accountId);
                listIdFileAll.addAll(listIdFileAccount);
            }

            if (!contactId.isEmpty()) {
                List<Id> listIdFileContact = getlistIdFileAllContact(contactId);
                listIdFileAll.addAll(listIdFileContact);
            }

            if (!quoteId.isEmpty()) {
                List<Id> listIdFileQuote = getlistIdFileAllQuote(quoteId);
                listIdFileAll.addAll(listIdFileQuote);
            }

            listAll.addAll(opportunityId);
            listAll.addAll(accountId);
            listAll.addAll(contactId);
            listAll.addAll(quoteId);
            List<Id> listIdFileAllContentDocument = getlistIdFileAllContentDocument(listAll); // lista di tutti gli id file presenti in ContentDocument con condizione if idfile!=null
            List<Id> listIdFileDelete = getlistIdFileDelete(listIdFileAll,listIdFileAllContentDocument); //file sovrascritti da cancellare
            List<Id> listIdFile = associateIdFileRecord(flitDoc);// lista id idfle

            //aggiungo la lista file sovrascritti da cancellare alla lista del file da cancellare dle record
            for (Integer i = 0; i < listIdFileDelete.size(); i++) {
                listIdFile.add(listIdFileDelete[i]);
            }
            
            Map<Id,ContentDocumentLink> listIdContentDocument = getIdContentDocumentId(listAll,listIdFile);//lista di idContentDocumetn WHERE id file e id opp
            List<ContentDocument> idFileDelete = getIdFileDelete(listIdContentDocument);//lista file da cancellare WHERE id contentDocumetnLink
            delete idFileDelete;
        }
    }
    
    @TestVisible private static List<Document__c> associoTrigggerNewOldForDelete(List<Document__c> triggerListNew,Map<Id,Document__c> mappaTriggerOld) {
        List<Document__c> flitDoc = new List<Document__c>();

        for (Document__c d: triggerListNew) {
            if ((mappaTriggerOld.get(d.Id).Url_Documento__c != d.Url_Documento__c)) {
                flitDoc.add(d);
            }
        }

        return flitDoc;
    }
    
    @TestVisible   private static List<Document__c> associoTrigggerNewOld(List<Document__c> triggerListNew,Map<Id,Document__c> mappaTriggerOld) {
        List<Document__c> flitDoc= new List<Document__c>();

        for (Document__c d: triggerListNew) {
            if ((mappaTriggerOld.get(d.Id).Url_Documento__c != d.Url_Documento__c)&&(d.DocumentTypeName__c != null)&&(d.Url_Documento__c != null)&&(d.Url_Documento__c != '')) {
                flitDoc.add(d);
            }
        }

        return flitDoc;
    }
    
    
    @TestVisible private static List<Id> associateIdRecord( List<Document__c> flitDoc) {
        List<Id> listId= new List<Id>();//lista dove assoccio gli Id dei record scattati di opportunity

        for (Document__c docId: flitDoc) {
            listId.add(docId.Opportunity__c);
        }

        return listId;
    }
    
    @TestVisible private static List<Id> getlistIdFileAllOpportunity(List<Id> opportunityId) {
        List<Id> listIdFileCaricati = new List<Id>();
        Map<Id, Document__c> queryIdfile = new Map<Id, Document__c> ([SELECT Id_File__c
                                              FROM Document__c
                                              WHERE Opportunity__c IN :opportunityId]);

        for (Document__c idFile:queryIdfile.values()) {
            if (idFile.Id_File__c != null) {
                listIdFileCaricati.add(idFile.Id_File__c);
            }
        }

        return listIdFileCaricati;
    }
    
    @TestVisible private static List<Id> getlistIdFileAllAccount (List<Id> accountId) {
        List<Id> listIdFileCaricati = new List<Id>();
        //lista dove assoccio gli Id dei file esistenti dl Opportunità scattata
        Map<Id, Document__c> queryIdfile = new Map<Id, Document__c> ([SELECT Id_File__c
                                              FROM Document__c
                                              WHERE Account__c IN : accountId]); 

        for (Document__c idFile:queryIdfile.values()) {
            if (idFile.Id_File__c != null) {
                listIdFileCaricati.add(idFile.Id_File__c);
            }
        }

        System.debug('fileUploaderController getlistIdFileAllAccount --End listIdFileCaricati'+ listIdFileCaricati);
        return listIdFileCaricati;
    }
    
    @TestVisible private static List<Id> getlistIdFileAllContact(List<Id> contactId){
        List<Id> listIdFileCaricati = new List<Id> ();
        //lista dove assoccio gli Id dei file esistenti dl Opportunità scattata
        Map<Id, Document__c> queryIdfile = new Map<Id, Document__c> ([SELECT Id_File__c
                                              FROM Document__c
                                              WHERE Contact__c IN : contactId]); 

        for (Document__c idFile:queryIdfile.values()) {
            if (idFile.Id_File__c != null) {
                listIdFileCaricati.add(idFile.Id_File__c);
            }
        }

        return listIdFileCaricati;
    }

    @TestVisible private static List<Id> getlistIdFileAllQuote(List<Id> quoteId) {
        List<Id> listIdFileCaricati = new List<Id> ();
        //lista dove assoccio gli Id dei file esistenti dl Opportunità scattata
        Map<Id,Document__c> queryIdfile = new Map<Id,Document__c>([SELECT Id_File__c
                                              FROM Document__c
                                              WHERE Quote__c IN : quoteId]);

        for (Document__c idFile:queryIdfile.values()) {
            if (idFile.Id_File__c != null) {
                listIdFileCaricati.add(idFile.Id_File__c);
            }
        }

        return listIdFileCaricati;
    }


    public static List<Id> getlistIdFileAllContentDocument(List<Id> listId) {
        List<Id> listIdFileCaricati = new List<Id> ();
        //lista dove assoccio gli Id dei file esistenti dl Opportunità scattata
        Map<Id, ContentDocumentLink> queryIdfile = new Map<Id, ContentDocumentLink> ([SELECT ContentDocumentId, Id, IsDeleted, LinkedEntityId FROM ContentDocumentLink
                                                      WHERE LinkedEntityId IN :listId]);

        for (ContentDocumentLink idFile : queryIdfile.values()) {
            if (idFile.ContentDocumentId != null) {
                listIdFileCaricati.add(idFile.ContentDocumentId);
            }
        }

        return listIdFileCaricati;
    }
    
    
    
    @TestVisible private static List<Id> getlistIdFileDelete(List<Id> listIdFileAll, List<Id> listIdFileAllContentDocument){
        List<Id> listaIdFile = new List<Id>();
        
        for (Integer i = 0; i < listIdFileAllContentDocument.size(); i++) {
            if (!listIdFileAll.contains(listIdFileAllContentDocument[i])) {
                listaIdFile.add(listIdFileAllContentDocument[i]);
            }
        }

        return listaIdFile;
    }

    @TestVisible private static List<Id> associateIdFileRecord( List<Document__c> flitDoc) {
        //lista dove assoccio gli Id dei record scattati di opportunity
        List<Id> listIdFile = new List<Id>();

        for (Document__c docId:flitDoc) {
            listIdFile.add(docId.Id_File__c);
        }

        return listIdFile;
    }
    
    @TestVisible private static Map<Id,Opportunity> recoveryAllFieldsOpportunity(List<Document__c> flitDoc, List<Id> listId) {
        List<String> queryAllOpp= new List<String> ();
        Map<Id, Opportunity> listTypeDoc = new Map<Id, Opportunity>();

        for (SObjectField f : Opportunity.SObjectType.getDescribe().fields.getMap().values()) {
            queryAllOpp.add(f.getDescribe().getName());
        }

        String fieldsString = String.join(queryAllOpp, ',');
        String query = 'SELECT ' + fieldsString + ' FROM Opportunity '+ 'WHERE Id IN :listId';
        Map<Id, Opportunity> oppList = new Map<Id, Opportunity>((List<Opportunity>) Database.query(query));
        
        for (Document__c d:flitDoc) {
            Opportunity objOpp= oppList.get(d.Opportunity__c);
            listTypeDoc.put(d.Id,objOpp);
        }

        return listTypeDoc;
    }
    
    @TestVisible private static Map<Id,Account> recoveryAllFieldsAccount(List<Document__c> flitDoc, List<Id> listId) {
        List<String> queryAllAcc = new List<String> ();
        Map<Id,Account> listTypeDoc = new Map<Id,Account>();
        //devo fare query SELECT* form opportunity, quindi metto tutti i campi dell'oggettoOpportunity in una lista.

        for (SObjectField f : Account.SObjectType.getDescribe().fields.getMap().values()) {
            queryAllAcc.add(f.getDescribe().getName());
        }

        String fieldsString = String.join(queryAllAcc, ',');
        String query = 'SELECT ' + fieldsString + ' FROM Account '+ 'WHERE Id IN :listId';
        Map<Id, Account> accountList = new Map<Id, Account>((List<Account>) Database.query(query));
        
        for (Document__c d : flitDoc) {
            Account objOpp= accountList.get(d.Account__c);
            listTypeDoc.put(d.Id,objOpp);
        }

        return listTypeDoc;
    }
    
    @TestVisible  private static Map<Id,Contact> recoveryAllFieldsContact(  List<Document__c> flitDoc, List<Id> listId){
        List<String> queryAllContact = new List<String>();
        Map<Id, Contact> listTypeDoc = new Map<Id, Contact>();
        //devo fare query SELECT* form opportunity, quindi metto tutti i campi dell'oggettoOpportunity in una lista.

        for (SObjectField f : Contact.SObjectType.getDescribe().fields.getMap().values()) {
            queryAllContact.add(f.getDescribe().getName());
        }

        String fieldsString = String.join(queryAllContact, ',');
        String query = 'SELECT ' + fieldsString + ' FROM Contact '+ 'WHERE Id IN :listId';
        Map<Id, Contact> ContactList = new Map<Id, Contact>((List<Contact>) Database.query(query));
        
        for (Document__c d : flitDoc) {
            Contact objOpp= ContactList.get(d.Contact__c);
            listTypeDoc.put(d.Id,objOpp);
        }

        return listTypeDoc;
    }
    
    @TestVisible private static Map<Id,Quote> recoveryAllFieldsQuote(List<Document__c> flitDoc, List<Id> listId) {
        List<String> queryAllQuote= new List<String> ();
        Map<Id, Quote> listTypeDoc = new Map<Id,Quote>();
        //devo fare query SELECT* form opportunity, quindi metto tutti i campi dell'oggettoOpportunity in una lista.

        for(SObjectField f : Quote.SObjectType.getDescribe().fields.getMap().values()){
            queryAllQuote.add(f.getDescribe().getName());
        }

        String fieldsString = String.join(queryAllQuote, ',');
        String query = 'SELECT ' + fieldsString + ' FROM Quote '+ 'WHERE Id IN :listId';
        Map<Id, Quote> QuoteList = new Map<Id,Quote>((List<Quote>) Database.query(query));
        
        for (Document__c d:flitDoc) {
            Quote objOpp = QuoteList.get(d.Quote__c);
            listTypeDoc.put(d.Id,objOpp);
        }

        return listTypeDoc;
    }
    
    @TestVisible private static List<Opportunity> replaceUrlOpportunity(List<Document__c> flitDoc, Map<Id, Opportunity> listTypeDoc) {
        List<Opportunity> documenteUpdate = new List<Opportunity>();
        //setto il campo con una stringa custom e cambio il valore delle checkbox
        Set<Opportunity> opps = new Set<Opportunity>();
        
        for (Opportunity opp : listTypeDoc.values()) {
            opps.add(opp);
        }
        
        for (Opportunity opp : opps) {
            for (Document__c d : flitDoc) {
                if (d.Opportunity__c == opp.Id) {
                    String fields = d.DocumentTypeName__c;
                    if (fields != 'contratto') {
                        opp.put(fields,true);
                    } else {
                        opp.X100_Contratto__c = true;
                    }

                    if (fields == 'X01_Modulo_Richiesta_Finanziamento__c') {
                        opp.Notifica_IS_Modulo_Finanziamento__c = false;
                    }
                }
            }
            documenteUpdate.add(opp);
        }

        return documenteUpdate;
    }
    
    @TestVisible private static List<Quote> replaceUrlQuote(List<Document__c> flitDoc, Map<Id, Quote> listTypeDoc) {
        List<Quote> documenteUpdate = new List<Quote>();
        //setto il campo con una stringa custom e cambio il valore delle checkbox
        Set<Quote> quotes = new Set<Quote>();

        for (Quote opp : listTypeDoc.values()) {
            quotes.add(opp);
        }
        
        for (Quote qt : quotes) {
            for (Document__c d : flitDoc) {
                if (d.Quote__c == qt.Id) {
                    String fields = d.DocumentTypeName__c;
                    System.debug('fields' + fields);
                    qt.put(fields,true);                                                             
                }
            }
            documenteUpdate.add(qt);
        }        

        return documenteUpdate;
    }
    
    @TestVisible private static List<Contact> replaceUrlContact(List<Document__c> flitDoc, Map<Id, Contact> listTypeDoc) {
        List<Contact> documenteUpdate = new List<Contact>();
        Set<Contact> contacts = new Set<Contact>();
        
        for (Contact ct : listTypeDoc.values()) {
            contacts.add(ct);
        }
        
        for (Contact ct : contacts) {
            for (Document__c d : flitDoc) {
                if (d.Contact__c == ct.Id) {
                    String fields = d.DocumentTypeName__c;
                    System.debug(' d.DocumentTypeName__c; ' + d.DocumentTypeName__c);
                    ct.put(fields,true);                                                             
                }
            }
            documenteUpdate.add(ct);
        }        

        return documenteUpdate;
    }
    
    @TestVisible private static List<Account> replaceUrlAccount(List<Document__c> flitDoc, Map<Id, Account> listTypeDoc) {
        List<Account> documenteUpdate = new List<Account>();
        //setto il campo con una stringa custom e cambio il valore delle checkbox
        Set<Account> accounts = new Set<Account>();
        
        for (Account acc : listTypeDoc.values()) {
            accounts.add(acc);
        }
        
        for (Account acc : accounts) {
            for (Document__c d : flitDoc) {
                if (d.Account__c == acc.Id) {
                    String fields = d.DocumentTypeName__c;
                    acc.put(fields,true);                                                             
                }
            }
            documenteUpdate.add(acc);
        }        

        return documenteUpdate;
    }
    
    @TestVisible private static Map<Id, ContentDocumentLink> getIdContentDocumentId(List<Id> listId, List<Id> listIdFile){
        Map<Id, ContentDocumentLink>  ContentDocumentId= new  Map<Id,ContentDocumentLink> ();
        ContentDocumentId = new Map<Id,ContentDocumentLink> (
            [SELECT ContentDocumentId 
             FROM ContentDocumentLink
             WHERE LinkedEntityId IN :listId  AND ContentDocumentId IN :listIdFile]);  // WHERE LinkedEntityId =:recordId

        return ContentDocumentId;
    }
    
    @TestVisible private static List<ContentDocument> getIdFileDelete(Map<Id, ContentDocumentLink> listIdContentDocument) {
        Set<Id> setId = listIdContentDocument.keySet();
        Set<Id> setIdList = new Set<Id>();

        for (Id dcl:setId) {
            setIdList.add(listIdContentDocument.get(dcl).ContentDocumentId);
        }
        
        List<ContentDocument> fileDelete = new  List<ContentDocument>();
        fileDelete = [SELECT Id,Title
                    FROM ContentDocument
                    WHERE Id IN :setIdList];

        return fileDelete;
    }
    
    public static void linkUrlDocumentoQuote(List<Id> newDocList) {
        //Modificato da Stefano poichè eleva ora setta il verifica ok
        List<Document__c> docList = [SELECT Id, Quote__c, Quote__r.Id,Quote__r.Contratto_Verificato__c, Quote__r.Opportunity.Tipo_Firma__c, Name, Url_Documento__c, Verifica_Sales_Support__c FROM Document__c WHERE Id IN : newDocList];
        List<Quote> quoteToUpdate = new List<Quote>();
        List<Document__c> docToUpdate = new List<Document__c>();
        
        for (Document__c doc : docList) {
            Quote quote = new Quote();
            Document__c newDocument;
            if (doc.Quote__r.Opportunity.Tipo_Firma__c == 'Firma Digitale') {
                quote.Id = doc.Quote__r.Id;
               // quote.Contratto_Verificato__c = false;
                
            }else{
                
                quote.Id = doc.Quote__r.Id;
                newDocument = new Document__c();
                newDocument.Id = doc.Id;
                newDocument.Verifica_Sales_Support__c = 'Da Verificare';
                quote.Link_URL_Documento__c = doc.Url_Documento__c;
                docToUpdate.add(newDocument);
            }
           
            quoteToUpdate.add(quote);
        }

        if ( docToUpdate.size() != 0 ) {
            System.debug('docToUpdate  '+JSON.serialize(docToUpdate) +'size  '+docToUpdate.size()  );
            update docToUpdate;
        }
        if(!quoteToUpdate.isEmpty()){
            update quoteToUpdate;
        }
        
        
    }
    public static void linkUrlDocumentoFirmaDigitale(List<Id> newDocList) {
        //Modificato da Stefano poichè eleva ora setta il verifica ok
        List<Document__c> docList = [SELECT Id, Quote__c, Quote__r.Id,Quote__r.Contratto_Verificato__c, Quote__r.Opportunity.Tipo_Firma__c, Name, Url_Documento__c, Verifica_Sales_Support__c FROM Document__c WHERE Id IN : newDocList];
        List<Quote> quoteToUpdate = new List<Quote>();
        
        
        for (Document__c doc : docList) {
            Quote quote = new Quote();
            Document__c newDocument;
            if (doc.Quote__r.Opportunity.Tipo_Firma__c == 'Firma Digitale') {
                quote.Id = doc.Quote__r.Id;
                quote.Contratto_Verificato__c = true;

            }
           
            quoteToUpdate.add(quote);
        }
        if(!quoteToUpdate.isEmpty()){
            QuoteController.bypassTrigger = true;
            update quoteToUpdate;
            QuoteController.bypassTrigger = false;
        }
        
        
    }

    public static void numerimi (Id recId) {
        List<Document__c> allDocs = new List<Document__c>();
        List<Opportunity> accOpp = [SELECT Id, AccountId ,StageName,Tipo_Linea_di_Credito__c,(SELECT Id, ObligatarioAcc__c,StatusStageVisibleFormula__c,Obbligatorio__c,ObligatorioCont__c,ObligatorioQuote__c, Url_Documento__c,Verifica_Sales_Support__c, dependeDaTipoLineaFormula__c FROM Documenti__r) FROM Opportunity WHERE Id = :recId];
        String accId = accOpp[0].AccountId;
        List<Account> accountList = [SELECT Id,Name,(SELECT Id,  ObligatarioAcc__c,Obbligatorio__c,StatusStageVisibleFormula__c,ObligatorioCont__c,ObligatorioQuote__c, Url_Documento__c,Verifica_Sales_Support__c, dependeDaTipoLineaFormula__c  FROM Documenti__r)
        FROM Account WHERE Id =:accId];

        if (accOpp[0].Documenti__r.size() > 0) {
            for (Document__c doc : accOpp[0].Documenti__r) {
                allDocs.add(doc);
            }
        }
        
        if (accountList[0].Documenti__r.size() > 0) {
            for (Document__c doc : accountList[0].Documenti__r) {
                allDocs.add(doc);
            }
        }                

        for (Contact contact : [SELECT  Id, AccountId, Name ,(SELECT Id,DocumentTypeNameFormula__c,ObligatarioAcc__c,dependeDaTipoLineaFormula__c,StatusStageVisibleFormula__c,Obbligatorio__c,ObligatorioCont__c,ObligatorioQuote__c, Url_Documento__c,Verifica_Sales_Support__c  FROM Documenti__r)
                           FROM Contact WHERE AccountId = :accId]) {
                               if (contact.Documenti__r.size() > 0) {
                                   for (Document__c d : contact.Documenti__r) {
                                       allDocs.add(d);  
                                   }
                               }
                           }
        
        
        for (Quote quote : [SELECT Id, OpportunityId, (SELECT Id,   ObligatarioAcc__c,StatusStageVisibleFormula__c,Obbligatorio__c,ObligatorioCont__c,ObligatorioQuote__c, Url_Documento__c,Verifica_Sales_Support__c, dependeDaTipoLineaFormula__c  FROM Documenti__r)
                         FROM Quote WHERE OpportunityId =: recId AND Status !='Annullata']) {
                             if (quote.Documenti__r.size() > 0) {
                                 for (Document__c doc : quote.Documenti__r) {
                                     allDocs.add(doc);    
                                 }
                             }
                         }
        
        Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
        List<Schema.PicklistEntry> vls = fieldResult.getPicklistValues();
        List<String> VisibleForStage = new List<String>();
        Integer current;
        Id myEasyOpps;

        for (Integer i=0; i<vls.size(); i++ ) {
            if (vls[i].getValue() == accOpp[0].StageName) {
                current= i;
            }
        }

        for (Integer j=0; j<=current; j++ ) {
            VisibleForStage.add(vls[current -j].getValue());
        }

        if (accOpp[0].Tipo_Linea_di_Credito__c=='Progetto EasyPlus') {
            myEasyOpps=accOpp[0].Id;
        }

        List<String> stage = VisibleForStage;
        Map<String, Integer> data = new Map<String, Integer>();
        data.put('Total',allDocs.size());
        data.put('Obligatorio',0);
        data.put('NonObligatorio',0);
        data.put('Uploaded',0);
        data.put('Verified',0);

        for (Document__c document : allDocs) {
            if (stage.contains(document.StatusStageVisibleFormula__c)) {
                if (document.Verifica_Sales_Support__c != 'Da Ricaricare') {
                    if (document.Url_Documento__c != null) {
                        data.put('Uploaded', data.get('Uploaded') + 1);
                        if (document.Obbligatorio__c == false && document.ObligatarioAcc__c == false && document.ObligatorioCont__c == false && document.ObligatorioQuote__c == false && !(document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' && myEasyOpps <> null)) {
                            data.put('NonObligatorio', data.get('NonObligatorio') + 1);
                        }
                    }
                }
                if (document.Obbligatorio__c == true || document.ObligatarioAcc__c == true || document.ObligatorioCont__c == true || document.ObligatorioQuote__c == true || (document.dependeDaTipoLineaFormula__c == 'Progetto EasyPlus' && myEasyOpps <> null)) {
                    data.put('Obligatorio', data.get('Obligatorio') + 1);
                }
                
                if (document.Verifica_Sales_Support__c == 'Verifica OK' && document.Url_Documento__c != null) {
                    data.put('Verified', data.get('Verified') + 1);
                }
                
            }
        }

        Opportunity oppUpdate = new Opportunity();
        oppUpdate.Id = recId;
        oppUpdate.Total_Mandatories_Docs__c = data.get('Obligatorio');
        oppUpdate.Total_Optional_Docs__c = data.get('NonObligatorio');
        oppUpdate.Total_Uploaded_Docs__c = data.get('Uploaded');
        oppUpdate.Totale_Verified_Docs_Verificati__c = data.get('Verified');

        update oppUpdate;
    }

    /** Returns a map of mandatory document types for each opportunity **/
    public static Map<String, Map<String, DocumentType__c>> GetMandatoryDocTypesMap(Map<String, Opportunity> opportunityMap) {
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypesMap = new Map<String, Map<String, DocumentType__c>>();

        for (String oppId : opportunityMap.keySet()) {
            Opportunity opportunity = opportunityMap.get(oppId);
            Map<String, DocumentType__c> docTypeMap = new Map<String, DocumentType__c>();
            List<DocumentType__c> mandatoryDocTypesForOpp = GetMandatoryDocTypesInOpp(opportunity, creditiStageMap, mutuoStageMap, easyPlusStageMap, documentTypes);

            if (mandatoryDocTypesForOpp.size() > 0) {
                docTypeMap = getFilteredMandatoryDocTypeMap(opportunity, mandatoryDocTypesForOpp);
                oppIdAndMandatoryDocTypesMap.put(oppId, docTypeMap);
            } else {
                oppIdAndMandatoryDocTypesMap.put(oppId, new Map<String, DocumentType__c>());
            }
        }

        return oppIdAndMandatoryDocTypesMap;
    }

    /** Returns a map of all document types for each opportunity **/
    public static Map<String, Map<String, DocumentType__c>> GetDocTypesMap(Map<String, Opportunity> opportunityMap) {
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypesMap = new Map<String, Map<String, DocumentType__c>>();

        for (String oppId : opportunityMap.keySet()) {
            Opportunity opportunity = opportunityMap.get(oppId);
            Map<String, DocumentType__c> docTypesInOpp = GetAllDocTypesInOpp(opportunity, documentTypes);

            if (docTypesInOpp.size() > 0) {
                oppIdAndMandatoryDocTypesMap.put(oppId, docTypesInOpp);
            } else {
                oppIdAndMandatoryDocTypesMap.put(oppId, new Map<String, DocumentType__c>());
            }
        }

        return oppIdAndMandatoryDocTypesMap;
    }

    /** Returns a filtered map of mandatory document types **/
    public static Map<String, DocumentType__c> getFilteredMandatoryDocTypeMap(Opportunity opportunity, List<DocumentType__c> mandatoryDocTypesForOpp) {

        Map<String, DocumentType__c> docTypeMap = new Map<String, DocumentType__c>();
        Boolean oppIsCrediti = opportunity.RecordType.DeveloperName == 'Inserimento_Crediti_Fiscali' ||
                opportunity.RecordType.DeveloperName == 'Crediti_Fiscale_Lending' ||
                opportunity.RecordType.DeveloperName == 'Crediti_Fiscale_Lending_RO';
        Boolean oppIsMutuo = opportunity.RecordType.DeveloperName == 'Lending' || opportunity.RecordType.DeveloperName == 'Lending_RO';
        Boolean oppIsEasyPlus = opportunity.RecordType.DeveloperName == 'Lending_Easy_Plus' ||
                opportunity.RecordType.DeveloperName == 'Lending_Easy_Plus_RO';
        Account oppAccount = opportunity.Account;
        String accountSociet = oppAccount.Societ_Appartiene_a_Gruppo__c;
        Double accountClientelaIncidenza = oppAccount.Clientela_Incidenza__c;
        List<String> mandatoryOtherQuotes = new List<String> {'ISMEA','SACE'};
        List<String> docTypesForMutuo = new List<String> {'SME_035', 'SME_036', 'SME_037', 'SME_028'};
        List<String> docTypesForMutuoAndEasyPlus = new List<String> {'SME_030', 'SME_031', 'SME_032', 'SME_033', 'SME_034'};
        List<String> situazioneFinanziariaDocTypes = new List<String> {'SME_017', 'SME_021'};

        for (DocumentType__c docType : mandatoryDocTypesForOpp) {
            if (docType.ID_Tipo_Documento__c == 'SME_038' || docType.ID_Tipo_Documento__c == 'SME_039') {
                if (accountSociet == 'Si') {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_078') {
                if (oppIsEasyPlus) {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_007') {
                List<Quote> quoteList = [SELECT Id, (SELECT Id, Tipo_di_Garanzia__c FROM Garanzie__r) FROM Quote WHERE OpportunityId =: opportunity.Id];
                List<Garanzia__c> warrantyList = new List<Garanzia__c>();
                Boolean countMandatoryQuoteDoc = false;

                for (Quote quote : quoteList) {
                    List<Garanzia__c> quoteWarranties = quote.Garanzie__r;
                    if (quoteWarranties != null) {
                        warrantyList.addAll(quoteWarranties);
                    }
                }

                for (Garanzia__c warranty : warrantyList) {
                    if (mandatoryOtherQuotes.contains(warranty.Tipo_di_Garanzia__c)) {
                        countMandatoryQuoteDoc = true;
                        break;
                    }
                }

                if ((oppIsMutuo || oppIsEasyPlus) && countMandatoryQuoteDoc) {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_022') {
                if ((oppIsMutuo || oppIsEasyPlus) && opportunity.Finalita_Finanziamento__c == 'Investimento') {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_040') {
                if ((oppIsMutuo || oppIsEasyPlus) && accountSociet == 'Si') {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_042' || docType.ID_Tipo_Documento__c == 'SME_043') {
                if ((oppIsCrediti || oppIsMutuo) && accountSociet == 'Si') {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_052') {
                if ((oppIsMutuo || oppIsEasyPlus) && accountClientelaIncidenza >= 40) {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docType.ID_Tipo_Documento__c == 'SME_063') {
                if ((oppIsMutuo || oppIsEasyPlus) && oppAccount.Fidejussore__c == true) {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (docTypesForMutuoAndEasyPlus.contains(docType.ID_Tipo_Documento__c)) {
                if ((oppIsMutuo || oppIsEasyPlus) && oppAccount.Fidejussore__c == true) {
                    docTypeMap.put(docType.Id, docType);
                }
            } else if (oppIsMutuo && docTypesForMutuo.contains(docType.ID_Tipo_Documento__c) && oppAccount.Fidejussore__c == true) {
                docTypeMap.put(docType.Id, docType);
            } else if (situazioneFinanziariaDocTypes.contains(docType.ID_Tipo_Documento__c)) {
                if (oppIsMutuo || oppIsEasyPlus) {
                    docTypeMap.put(docType.Id, docType);
                }
                //stefano modification to remove cert notarile su update Tigran
            }else if (docType.ID_Tipo_Documento__c == 'SME_047')  {
                if(opportunity.StageName !='PEF Istruttoria'){
                    docTypeMap.put(docType.Id, docType);
                }
            }else if(docType.ID_Tipo_Documento__c == 'SME_094'){
                if(opportunity.StageName !='PEF Istruttoria'){
                    docTypeMap.put(docType.Id, docType);
                }
            } else {
                docTypeMap.put(docType.Id, docType);
            }
        }
        return docTypeMap;
    }

    /** Returns addon query for SELECTing mandatory document types for currently SELECTed opportunity */
    public static List<DocumentType__c> GetMandatoryDocTypesInOpp(Opportunity opportunity, Map<String, Integer> creditiStageMap,
            Map<String, Integer> mutuoStageMap, Map<String, Integer> easyPlusStageMap, List<DocumentType__c> documentTypes) {
        Integer stageIndex = 0;
        String stageName = opportunity.StageName;
        List<DocumentType__c> mandatoryDocTypesInOpp = new List<DocumentType__c>();

        if (opportunity.RecordType.DeveloperName == 'Inserimento_Crediti_Fiscali' ||
                opportunity.RecordType.DeveloperName == 'Crediti_Fiscale_Lending' ||
                opportunity.RecordType.DeveloperName == 'Crediti_Fiscale_Lending_RO') {
            stageIndex = creditiStageMap.get(stageName);

            mandatoryDocTypesInOpp = GetMandatoryDocTypesForCrediti(stageIndex, documentTypes);
        } else if (opportunity.RecordType.DeveloperName == 'Lending' ||
                opportunity.RecordType.DeveloperName == 'Lending_RO') {
            stageIndex = mutuoStageMap.get(stageName);

            mandatoryDocTypesInOpp = GetMandatoryDocTypesForMutuo(stageIndex, documentTypes);
        } else if (opportunity.RecordType.DeveloperName == 'Lending_Easy_Plus' ||
                opportunity.RecordType.DeveloperName == 'Lending_Easy_Plus_RO') {
            stageIndex = easyPlusStageMap.get(stageName);

            mandatoryDocTypesInOpp = GetMandatoryDocTypesForEasyPlus(stageIndex, documentTypes);
        }

        return mandatoryDocTypesInOpp;
    }

    /** Returns addon query for SELECTing mandatory document types for currently SELECTed opportunity */
    public static Map<String, DocumentType__c> GetAllDocTypesInOpp(Opportunity opportunity, List<DocumentType__c> documentTypes) {

        Map<String, DocumentType__c> docTypesInOpp = new Map<String, DocumentType__c>();

        if (opportunity.RecordType.DeveloperName == 'Inserimento_Crediti_Fiscali' ||
                opportunity.RecordType.DeveloperName == 'Crediti_Fiscale_Lending' ||
                opportunity.RecordType.DeveloperName == 'Crediti_Fiscale_Lending_RO') {

            docTypesInOpp = GetAllDocTypesForCrediti(documentTypes);
        } else if (opportunity.RecordType.DeveloperName == 'Lending' ||
                opportunity.RecordType.DeveloperName == 'Lending_RO') {

            docTypesInOpp = GetAllDocTypesForMutuo(documentTypes);
        } else if (opportunity.RecordType.DeveloperName == 'Lending_Easy_Plus' ||
                opportunity.RecordType.DeveloperName == 'Lending_Easy_Plus_RO') {

            docTypesInOpp = GetAllDocTypesForEasyPlus(documentTypes);
        }

        return docTypesInOpp;
    }

    /** Returns a list of all documents assigned to Crediti opportunities */
    public static Map<String, DocumentType__c> GetAllDocTypesForCrediti(List<DocumentType__c> documentTypes) {
        Map<String, DocumentType__c> oppDocumentTypes = new Map<String, DocumentType__c>();

        for (DocumentType__c docType : documentTypes) {
            if(docType.Opportunity_Crediti_Fiscali__c == true) {
                oppDocumentTypes.put(docType.Id, docType);
            }
        }

        return oppDocumentTypes;
    }

    /** Returns a list of all documents assigned to Mutuo opportunities */
    public static Map<String, DocumentType__c> GetAllDocTypesForMutuo(List<DocumentType__c> documentTypes) {
        Map<String, DocumentType__c> oppDocumentTypes = new Map<String, DocumentType__c>();

        for (DocumentType__c docType : documentTypes) {
            if(docType.Opportunita_Mutuo__c == true) {
                oppDocumentTypes.put(docType.Id, docType);
            }
        }

        return oppDocumentTypes;
    }

    /** Returns a list of all documents assigned to EasyPlus opportunities */
    public static Map<String, DocumentType__c> GetAllDocTypesForEasyPlus(List<DocumentType__c> documentTypes) {
        Map<String, DocumentType__c> oppDocumentTypes = new Map<String, DocumentType__c>();

        for (DocumentType__c docType : documentTypes) {
            if(docType.Opportunita_EasyPlus__c == true) {
                oppDocumentTypes.put(docType.Id, docType);
            }
        }

        return oppDocumentTypes;
    }

    /** Returns addon query for SELECTing mandatory document types for CreditiFiscali opportunities */
    public static List<DocumentType__c> GetMandatoryDocTypesForCrediti(Integer stageIndex, List<DocumentType__c> documentTypes) {
        List<DocumentType__c> mandatoryDocumentTypes = new List<DocumentType__c>();

        for (DocumentType__c docType : documentTypes) {
            if (stageIndex <= 3) {
                if (docType.Opportunity_Crediti_Fiscali__c == true &&
                        docType.Obbligatorio_per_Pre_Due_Diligence__c == true) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex > 3 && stageIndex <= 8) {
                if (docType.Opportunity_Crediti_Fiscali__c == true &&
                        (docType.Obbligatorio_per_Pre_Due_Diligence__c == true ||
                                docType.Obbligatorio_in_CompletamentoDocumenti__c == true)) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex > 8 && stageIndex <= 10) {
                if (docType.Opportunity_Crediti_Fiscali__c == true &&
                        (docType.Obbligatorio_per_Pre_Due_Diligence__c == true ||
                                docType.Obbligatorio_in_CompletamentoDocumenti__c == true ||
                                docType.Obbligatorio_per_In_Stipula__c == true)) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex > 10) {
                if (docType.Opportunity_Crediti_Fiscali__c == true &&
                        (docType.Obbligatorio_per_Pre_Due_Diligence__c == true ||
                                docType.Obbligatorio_in_CompletamentoDocumenti__c == true ||
                                docType.Obbligatorio_per_In_Stipula__c == true ||
                                docType.Obbligatorio_in_Erogazione__c == true)) {
                    mandatoryDocumentTypes.add(docType);
                }
            }
        }

        return mandatoryDocumentTypes;
    }

    /** Returns addon query for SELECTing mandatory document types for Mutuo opportunities */
    public static List<DocumentType__c> GetMandatoryDocTypesForMutuo(Integer stageIndex, List<DocumentType__c> documentTypes) {
        List<DocumentType__c> mandatoryDocumentTypes = new List<DocumentType__c>();

        for (DocumentType__c docType : documentTypes) {
            if (stageIndex <= 4) {
                if (docType.Opportunita_Mutuo__c == true &&
                        docType.Obbligatorio_in_CompletamentoDocumenti__c == true) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex > 4 && stageIndex <= 7) {
                if (docType.Opportunita_Mutuo__c == true &&
                        (docType.Obbligatorio_in_CompletamentoDocumenti__c == true ||
                                docType.Obbligatorio_per_In_Stipula__c)) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex > 7) {
                if (docType.Opportunita_Mutuo__c == true &&
                        (docType.Obbligatorio_in_CompletamentoDocumenti__c == true ||
                                docType.Obbligatorio_per_In_Stipula__c ||
                                docType.Obbligatorio_in_Erogazione__c == true)) {
                    mandatoryDocumentTypes.add(docType);
                }
            }
        }

        return mandatoryDocumentTypes;
    }

    /** Returns addon query for SELECTing mandatory document types for EasyPlus opportunities */
    public static List<DocumentType__c> GetMandatoryDocTypesForEasyPlus(Integer stageIndex, List<DocumentType__c> documentTypes) {
        List<DocumentType__c> mandatoryDocumentTypes = new List<DocumentType__c>();

        for (DocumentType__c docType : documentTypes) {
            if (stageIndex <= 4) {
                if (docType.Opportunita_EasyPlus__c == true &&
                        docType.Obbligatorio_in_CompletamentoDocumenti__c == true) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex == 5) {
                if (docType.Opportunita_EasyPlus__c == true &&
                        (docType.Obbligatorio_in_CompletamentoDocumenti__c == true ||
                                docType.Obbligatorio_per_In_Stipula__c)) {
                    mandatoryDocumentTypes.add(docType);
                }
            } else if (stageIndex > 5) {
                if (docType.Opportunita_EasyPlus__c == true &&
                        (docType.Obbligatorio_in_CompletamentoDocumenti__c == true ||
                                docType.Obbligatorio_per_In_Stipula__c ||
                                docType.Obbligatorio_in_Erogazione__c == true)) {
                    mandatoryDocumentTypes.add(docType);
                }
            }
        }

        return mandatoryDocumentTypes;
    }

    public static Map<String, Opportunity> GetOpportunityMap(List<String> docOpportunityIds) {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();

        for (Opportunity opp : [
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, Active_Quotes__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                WHERE Id IN :docOpportunityIds
        ]) {
            opportunityMap.put(opp.Id, opp);
        }

        return opportunityMap;
    }

    public static List<Id> GetAccountIdList(List<Opportunity> opportunityList) {
        List<Id> accountIdList = new List<Id>();

        for (Opportunity opportunity : opportunityList) {
            if (!accountIdList.contains(opportunity.AccountId)) {
                accountIdList.add(opportunity.AccountId);
            }
        }

        return accountIdList;
    }

}