import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getPicklistValues from '@salesforce/apex/Utils.getPicklistValues';
import parametersMap from '@salesforce/apex/fileUploaderDAO.conditionsDocuments';
import getRecordListDocumentAllNew from '@salesforce/apex/fileUploaderDAO.getRecordListDocumentAllNew';
import getRecordListDocumentTypes from '@salesforce/apex/fileUploaderDAO.getRecordListDocumentTypes';
import updateCommentInDocuments from '@salesforce/apex/fileUploaderDAO.UpdateCommentInDocuments';
import getOpportunity from '@salesforce/apex/fileUploaderDAO.getOpportunity';
import getContactFromAccount from '@salesforce/apex/fileUploaderDAO.getContactFromAccount';
import getContact from '@salesforce/apex/fileUploaderDAO.getContact';
import getContactList from '@salesforce/apex/fileUploaderDAO.getContactList';
import {
    canProfileEditDocVerifica,
    checkIfButtonsAreDisabled,
    checkIfEnableMandatoryDocTypesInCessione
} from 'c/documentManagementUtils';

export default class MyComponentName extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isStageFirma;
    @api isErogazioneNO;
    @api isRecTypeRO;
    @api isFirmaDigitale;
    @api isContratoVerificato;
    @api isProfileSales;
    @api isProfileInsideSales;
    @api isProfileFidimed;
    @api isProfileSalesEasy;
    @api docListObjectApiName;

    @track checkForState;
    @track selectedCont;
    @track selectedContId;
    @track uniqueArray = [];
    @track documentTypeMap = new Map();
    @track documentMap = new Map();
    @track docBlockIdAndIsDisplayed = new Map();
    @track showFileNameModal = false;
    @track documentTypeId;
    @track fileName = '';
    @track fileId = '';
    @track isEliminaSostituisciModalOpen = false;
    @track showElimina;
    @track documentTypeToPass;
    @track replaceFileId = '';
    @track docBlockName = [];
    @track showSpinner = false;
    @track opportunity;
    @track contact;
    @track accountId;
    @track accSocietaApartiene;
    @track accClientelaIncidenza;
    @track accFidejussore;
    @track commentToSave = '';
    @track stageName;
    @track isProfileSalesNoFiscalPartner = false;
    @track oppIsCreditiFiscali = false;
    @track oppIsMutuo = false;
    @track oppIsEasyPlus = false;
    @track isAdmin;
    @track showDocIdRefFields = false;
    @track uploadedDocTypeId;
    @track isSostituisci = false;


    profileName;
    isProfileRespBo = '';
    disableAllButtons = false;
    defaultFileName = '';
    enableMandatoryDocTypes = false;
    stageIndex = 0;
    fidejussoreDocTypes = ['SME_010', 'SME_011', 'SME_026', 'SME_027', 'SME_062', 'SME_064', 'SME_065', 'SME_071'];
    
    mutuoStageMap = {
        'Primo Contatto' : 1,
        'Prima Visita' : 2,
        'Completamento Documenti' : 3,
        'PEF Pre-Istruttoria' : 4,
        'PEF Istruttoria' : 5,
        'Deliberata' : 6,
        'In Stipula' : 7,
        'Firma' : 8,
        'In Erogazione' : 9,
        'Closed' : 10,
        'Erogata': 11,
        'Chiusa/Persa' : 12
    };

    creditiStageMap = {
        'Primo Contatto' : 1,
        'Prima Visita' : 2,
        'Pre-Due Diligence' : 3,
        'Pre-Analisi e Pricing' : 4,
        'Due Diligence' : 5,
        'Completamento Documenti' : 6,
        'PEF Pre-Istruttoria' : 7,
        'PEF Istruttoria' : 8,
        'Deliberata' : 9,
        'In Stipula' : 10,
        'Firma e Cessione' : 11,
        'In Erogazione' : 12,
        'Closed' : 13,
        'Erogata' : 14,
        'Incasso e Chiusura' : 15,
        'Chiusa/Persa' : 16
    };

    easyPlusStageMap = {
        'Primo Contatto' : 1,
        'Prima Visita' : 2,
        'Completamento Documenti' : 3,
        'PEF Pre-Istruttoria' : 4,
        'PEF Istruttoria' : 5,
        'Deliberata' : 6,
        'In Erogazione' : 7,
        'Closed' : 8,
        'Erogata' : 9,
        'Chiusa/Persa' : 10
    };

    //wire that gets all the contacts of that opportunity of account
    @wire(getContactList,{
        recordId: '$recordId',
        objectApiName:'$objectApiName'
      }) contacts

    //wire that gets all picklist values of Document_Block__c field
    @wire(getPicklistValues, { objInfo: {'sobjectType' : 'DocumentType__c'},
    picklistFieldApi: 'Document_Block__c'}) docBlocfk(response) {
        if (response.data) {
            let array = [];
            let list = response.data;
            list.forEach(val => {
                array.push(val.label);
            })
            this.docBlockName = array;
        }
    };

    //we first check if we are in contact in order to show or no the select
    checkObject() {
        if (this.objectApiName && this.objectApiName !== 'Contact') {
            this.checkForState = true;
        }
        this.disableAllButtons = checkIfButtonsAreDisabled(this.opportunity, this.oppIsCreditiFiscali,
            this.oppIsMutuo, this.oppIsEasyPlus, this.creditiStageMap, this.mutuoStageMap, this.easyPlusStageMap);
        this.enableMandatoryDocTypes = checkIfEnableMandatoryDocTypesInCessione(this.opportunity,
            this.oppIsCreditiFiscali, this.creditiStageMap);
        this.getConditionsDoc();
    }
    
    //method that gets all neccessary parameters
    getConditionsDoc() {
        parametersMap({recordId: this.recordId, objectApiName: this.objectApiName, smallObjectName: this.docListObjectApiName }).then( resultApex => {
            //we give value to the global parameters
            this.isStageFirma = resultApex.isStageFirma;
            this.isErogazioneNO = resultApex.isErogazioneNO;
            this.isRecTypeRO = resultApex.isRecTypeRO;
            this.isFirmaDigitale = resultApex.isFirmaDigitale;
            this.isContratoVerificato = resultApex.isContratoVerificato;
            this.isProfileSales = resultApex.isProfileSales;
            this.isProfileSalesNoFiscalPartner = resultApex.isProfileSalesNoFiscalPartner;
            this.isProfileInsideSales = resultApex.isProfileInsideSales;
            this.isProfileFidimed = resultApex.isProfileFidimed;
            this.isProfileSalesEasy = resultApex.isProfileSalesEasy;
            this.isProfileTuttiSales = resultApex.isProfileTuttiSales;
            this.isAdmin = resultApex.isAdmin;
            this.profileName = resultApex.profileName;
            this.isProfileRespBo = resultApex.isProfileRespBo;

            if (this.objectApiName === 'Contact' && this.objectApiName) {
                this.getRecordListDocumentAllNew();
            }
        });
    }

    //method that gets te list of all documents
    getRecordListDocumentAllNew() {
        getRecordListDocumentAllNew({recordId: this.recordId, objectApiName: this.objectApiName, docListObjectApiName: this.docListObjectApiName, block: this.docBlockName, selectedContact: this.selectedContId}).then(response => {
                if(response) {
                    this.uniqueArray = [];
                    this.documentTypeMap = new Map();
                    this.documentMap = new Map();
                    this.refreshBlock = JSON.parse(JSON.stringify(response));
                    for (const [documentTypeId, documentsInDocTypeList] of Object.entries(this.refreshBlock)) {
                        documentsInDocTypeList.forEach((document, i) => {
                        let profilesToEditVerificaSales = document.DocumentType__r.Verifica_Documento__c;

                        //we declare internal variables for each document
                            document['isModuloRichiesta'];
                            document['isUploadedSuccess'] = false;
                            document['isUploadedError'] = false;
                            document['isUploadedLoading'] = false;
                            document['isDocEasyPlus'];
                            document['isVerificaOK'] = false;
                            document['isDaRicaricare'] = false;
                            document['isVerificaDisabled'] = false;
                            document['isWaiting'] = false;
                            document['showElimina'] = false;
                            document['disableEliminaButton'] = false;
                            document['disableSostituisciButton'] = false;

                            if (!this.isAdmin) {
                                document.isVerificaDisabled = this.disableAllButtons || canProfileEditDocVerifica(profilesToEditVerificaSales, this.profileName);
                            }

                            //we control if the doc is uploaded correctly
                            if (document.Url_Documento__c != null && document.Verifica_Sales_Support__c !== 'Verifica OK' && document.Verifica_Sales_Support__c !== 'Da Ricaricare') {
                                document.isUploadedSuccess = true;
                            } else if ((document.Url_Servizio_Esterno__c != null) && (document.Url_Documento__c === undefined) && (document.Errore_Store_Document__c != null)) {
                                document.isUploadedError = true;
                                //stefano modification to allow user delete file for any iontegration problem
                                if(document.IDTipoDocumentoFormula__c == 'SME_002' || document.IDTipoDocumentoFormula__c == 'SME_004'){
                                    document.showElimina = true;
                                    document.disableEliminaButton = false;
                                    document.disableSostituisciButton = true;
                                }
                            } else if ((document.Url_Servizio_Esterno__c != null) && (document.Url_Documento__c === undefined) && (document.Errore_Store_Document__c === null)) {
                                document.isUploadedLoading = true;
                            } else if (document.Verifica_Sales_Support__c === 'Verifica OK') {
                                document.isVerificaOK = true;
                            } else if (document.Verifica_Sales_Support__c === 'Da Ricaricare') {
                                document.isDaRicaricare = true;
                            } else if(!document.isUploadedSuccess && !document.isUploadedError && !document.isUploadedLoading && !document.isVerificaOK && !document.isDaRicaricare){
                                document.isWaiting = true;
                            }

                            if(document.DeleteFlag__c === true){
                                document.isUploadedSuccess = false;
                                document.isUploadedError = false;
                                document.isUploadedLoading = false;
                                document.isVerificaOK = false;
                                document.isDaRicaricare = false;
                                document.isWaiting = true;
                            }

                            if (this.documentMap.has(documentTypeId)) {
                                this.documentMap.get(documentTypeId).push(document);
                            } else {
                                this.documentMap.set(documentTypeId, [document]);
                            }
                        });
                    }
                } else if (error) {
                    console.log('error', error);
                }
            this.cleanDocumentMap();
            this.getRecordListDocumentTypes();
        });
    }

    /** Retrieves the list of document types which are required for this object */
    getRecordListDocumentTypes() {
        getRecordListDocumentTypes({recordId: this.recordId, objectApiName: this.objectApiName, docListObjectApiName: this.docListObjectApiName, block: this.docBlockName}).then(response => {
            if (response) {
                let parsedResponse = JSON.parse(JSON.stringify(response));
                
                for (const [documentTypeId, documentType] of Object.entries(parsedResponse)) {
                    let documentArray = this.documentMap.get(documentTypeId);
                    let enableErogazioneMandatoryDocType = false;

                    //we declare internal variables for each document
                    documentType['verificaGlobale'];
                    documentType['isUploadDisabled'] = false;
                    documentType['titleCondition'];
                    documentType['isDocTypeMandatory'];
                    documentType['isCommentAreaDisabled'] = false;
                    documentType['labelComment'];
                    documentType['placeComment'];
                    documentType['commentFromDocuments'];
                    documentType['showElimina'] = true;
                    documentType['disableEliminaButton'] = false;
                    documentType['disableSostituisciButton'] = false;
                    documentType['disableSalvaButton'] = true;
                    documentType['verificaGlobaleLabel'] = 'Verifica Sales Support Globale:';

                    if (documentType.Documento_di_Identit__c === true) {
                        documentType.showElimina = false;
                    }

                    // Set availability of comment text area and Salva button
                    if ((!this.isProfileTuttiSales  || this.isRecTypeRO) || (documentType.visibileaPartner__c === false && !this.isProfileSalesEasy)) {
                        documentType.isCommentAreaDisabled = true;
                        documentType.labelComment = 'Nota del Sales Support.';
                        documentType.placeComment = ' ';
                    } else {
                        documentType.isCommentAreaDisabled = false;
                        documentType.labelComment = 'Inserire nota supplementare, max 500 caratteri.';
                        documentType.placeComment = 'Scrivi qua... ';
                    }

                    //Set doc as Mandatory
                    if (this.opportunity) {
                        documentType.isDocTypeMandatory = this.setMandatoryFlag(documentType)
                    }

                    //Check if Upload button should be disabled
                    if (!this.isAdmin) {
                        if (this.disableAllButtons) {
                            enableErogazioneMandatoryDocType = this.enableMandatoryDocTypes &&
                                documentType.isDocTypeMandatory &&
                                documentType.Obbligatorio_in_Erogazione__c;

                            if (!this.enableMandatoryDocTypes || !enableErogazioneMandatoryDocType) {
                                this.disableDocTypeButtons(documentType);
                                this.setVerificaOkAvailabilityForDocs(documentType, true);
                            } else {
                                this.setVerificaOkAvailabilityForDocs(documentType, false);
                            }
                        } else if(this.oppIsCreditiFiscali && this.isProfileRespBo){
                            documentType.isUploadDisabled = false;
                        }else {
                            documentType.isUploadDisabled = this.isRecTypeRO || (this.isErogazioneNO && documentType.Erogazione_Servizi__c === true) || (documentType.visibileaPartner__c === false && !this.isProfileFidimed);
                            documentType.disableSalvaButton = this.isRecTypeRO
                        }
                    }

                    //Compute value for global verifica value
                    documentType.verificaGlobale = this.computeVerificaSalesSupportGlobale(documentTypeId);

                    if (documentArray) {
                        //Set Comment Sales Support on Document Type from one of the documents
                        documentType.commentFromDocuments = this.documentMap.get(documentTypeId)[0].Commento_Sales_Support__c;

                        //Check if upload and comments are disabled for current text box
                        if (!documentType.isUploadDisabled) {
                            if (documentType.Documento_di_Identit__c === true) {
                                documentType.isUploadDisabled = documentArray.length >= 1;
                            } else {
                                documentType.isUploadDisabled = documentArray.length >= 5;
                            }
                        }
                            documentType.showElimina = this.documentMap.get(documentTypeId)[0].showElimina;
                            documentType.disableEliminaButton = this.documentMap.get(documentTypeId)[0].disableEliminaButton;
                            documentType.disableSostituisciButton = this.documentMap.get(documentTypeId)[0].disableSostituisciButton;
                            console.log('showElimina2 ' + documentType.showElimina);
                            console.log('disableEliminaButton ' + documentType.disableEliminaButton);
                    } else {
                        //Disable comment area, Elimina and Sostituisci buttons if there are no documents
                        documentType.isCommentAreaDisabled = true;
                        documentType.disableEliminaButton = true;
                        documentType.disableSostituisciButton = true;
                    }

                    this.documentTypeMap.set(documentTypeId, documentType);

                    if (this.fidejussoreDocTypes.includes(documentType.ID_Tipo_Documento__c))
                    {
                        if (this.selectedCont.Fidejussore__c === true)
                        {
                            console.log('adding fidejussore');
                            this.uniqueArray.push({key: documentTypeId, value: documentType})
                        }
                    } else {
                        this.uniqueArray.push({key: documentTypeId, value: documentType})
                    }
                }
                this.uniqueArray = this.getSortedUniqueArray();
            } else if (error) {
                console.log('error',error);
            }
        });
    }

    getSortedUniqueArray() {
        let docBlockAndDocTypeMap = new Map();
        let sortedUniqueArray = [];
        let self = this;

        for (let i = 0; i < this.uniqueArray.length; i++) {
            let docType = this.uniqueArray[i].value;
            let documentBlock = docType.Document_Block__c;

            if (docBlockAndDocTypeMap.has(documentBlock)) {
                if (docType.isDocTypeMandatory) {
                    docBlockAndDocTypeMap.get(documentBlock).unshift(docType);
                } else {
                    docBlockAndDocTypeMap.get(documentBlock).push(docType);
                }
            } else {
                docBlockAndDocTypeMap.set(documentBlock, [docType])
            }
        }

        docBlockAndDocTypeMap.forEach(function(docTypeList, docBlockName) {
            if (docTypeList.length > 0) {
                for (let i = 0; i < docTypeList.length; i++) {
                    let docType = docTypeList[i];
                    docType.titleCondition = self.setTitleCondition(docType.Document_Block__c);
                    sortedUniqueArray.push({key: docType.Id, value: docType})
                }
            }
        })

        return sortedUniqueArray;
    }

    setSpecialMandatoryDocTypes(documentType, isDocTypeMandatory) {
        let docTypesForMutuoAndEasyPlusContacts = ['SME_010', 'SME_026', 'SME_027', 'SME_062', 'SME_064', 'SME_065'];

        if (documentType.ID_Tipo_Documento__c === 'SME_038' || documentType.ID_Tipo_Documento__c === 'SME_039') {
            isDocTypeMandatory = this.accSocietaApartiene === 'Si';
        } else if (documentType.ID_Tipo_Documento__c === 'SME_078') {
            isDocTypeMandatory = this.oppIsEasyPlus;
        } else if (documentType.ID_Tipo_Documento__c === 'SME_007' && (this.oppIsMutuo || this.oppIsEasyPlus)) {
            isDocTypeMandatory = ['ISMEA', 'Sace'].includes(this.opportunity.Tipo_di_Garanzia__c);
        } else if (documentType.ID_Tipo_Documento__c === 'SME_022' && (this.oppIsMutuo || this.oppIsEasyPlus)) {
            isDocTypeMandatory = this.opportunity.Finalita_Finanziamento__c === 'Investimento';
        } else if (documentType.ID_Tipo_Documento__c === 'SME_040' && (this.oppIsMutuo || this.oppIsEasyPlus)) {
            isDocTypeMandatory = this.accSocietaApartiene === 'Si';
        } else if ((documentType.ID_Tipo_Documento__c === 'SME_042' || documentType.ID_Tipo_Documento__c === 'SME_043') &&
            (this.oppIsCreditiFiscali || this.oppIsMutuo)) {
            isDocTypeMandatory = this.accSocietaApartiene === 'Si';
        } else if (documentType.ID_Tipo_Documento__c === 'SME_052' && (this.oppIsMutuo || this.oppIsEasyPlus)) {
            isDocTypeMandatory = this.accClientelaIncidenza >= 40;
        }

        return isDocTypeMandatory;
    }

    /** Cleans documentMap of empty or incorrectly formatted documents */
    cleanDocumentMap() {
        for (let [documentTypeId, documentList] of this.documentMap) {
            let documentListCopy = [];

            for (let i = 0; i < documentList.length; i++) {
                let document = documentList[i];
                if ((!(document.Opportunity__c === undefined &&
                    document.Account__c === undefined &&
                    document.Contact__c === undefined &&
                    document.Quote__c === undefined)) &&
                    document.File_Name__c !== undefined) {
                    documentListCopy.push(document);
                }
            }

            if (documentListCopy.length > 0){
                this.documentMap.set(documentTypeId, documentListCopy);
            } else {
                this.documentMap.delete(documentTypeId);
            }
        }
    }

    /** Gets the value of the changed Verifica Sales Support
     and updates Global Verifica Sales Support value */
     handleVerificaSalesSupportChanged(event) {
        const updatedDocument = event.detail;
        const updatedDocumentType = updatedDocument.DocumentType__c;
        const verificaOk = "Verifica OK";
        const verificaKo = "Verifica KO";
        const documentArray = this.documentMap.get(updatedDocument.DocumentType__c);
        let docTypeElements = this.template.querySelectorAll('[data-id="' + updatedDocumentType + '"]');
        let verificaGlobale;

        for (let i = 0; i < docTypeElements.length; i++) {
            let element = docTypeElements[i];

            if (element.name === 'verificaGlobaleTxtBox') {
                verificaGlobale = element;
                break;
            }
        }

        if (this.checkIfDocsAreValidatedAfterUpdate(verificaOk, documentArray, updatedDocument)) {
            verificaGlobale.value = verificaOk;
        } else {
            verificaGlobale.value = verificaKo;
        }

        this.refreshApexAll();
    }

    /** Iterates all the documents assigned to a DocumentType. If the field
     Verifica_Sales_Support__c is 'Verifica OK' on every document, returns true. */
    checkIfDocsAreValidatedAfterUpdate(verificaOk, documentArray, updatedDocument) {
        let allDocumentsVerified = false;
        if (updatedDocument.Verifica_Sales_Support__c === verificaOk) {
            for (let i = 0; i < documentArray.length; i++) {
                let element = documentArray[i];
                if (updatedDocument.Id === element.Id) {
                    element.Verifica_Sales_Support__c = updatedDocument.Verifica_Sales_Support__c;
                    allDocumentsVerified = true;
                } else {
                    if (element.Verifica_Sales_Support__c !== verificaOk) {
                        allDocumentsVerified = false;
                        break;
                    } else {
                        allDocumentsVerified = true;
                    }
                }
            }
        }

        return allDocumentsVerified;
    }

    /** Checks if any of the given document types are mendatory */
    setMandatoryFlag(documentType) {
        let isDocTypeMandatory = false;

        if (documentType.dependeDaTipoLinea__c === 'Progetto EasyPlus' && this.isOppEasyPlus) {
            isDocTypeMandatory = true;
        }

        if (this.oppIsCreditiFiscali) {
            this.stageIndex = this.creditiStageMap[this.stageName];
            isDocTypeMandatory = this.setMandatoryFlagForCreditiFiscali(documentType);
        }  else if (this.oppIsMutuo) {
            this.stageIndex = this.mutuoStageMap[this.stageName];
            isDocTypeMandatory = this.setMandatoryFlagForMutuo(documentType);
        } else if (this.oppIsEasyPlus) {
            this.stageIndex = this.easyPlusStageMap[this.stageName];
            isDocTypeMandatory = this.setMandatoryFlagForEasyPlus(documentType);
        }

        isDocTypeMandatory = this.setSpecialMandatoryDocTypes(documentType, isDocTypeMandatory);

        return isDocTypeMandatory
    }

    /** Sets the mandatory flag for Crediti Fiscali opp document types */
    setMandatoryFlagForCreditiFiscali(documentType) {
        let isDocTypeMandatory = false;

        if (this.stageIndex <= 3) {
            if (documentType.Opportunity_Crediti_Fiscali__c === true &&
                documentType.Obbligatorio_per_Pre_Due_Diligence__c === true) {
                isDocTypeMandatory = true;
            }
        }  else if (this.stageIndex > 3 && this.stageIndex <= 8) {
            if (documentType.Opportunity_Crediti_Fiscali__c === true &&
                (documentType.Obbligatorio_per_Pre_Due_Diligence__c === true ||
                    documentType.Obbligatorio_in_CompletamentoDocumenti__c === true)) {
                isDocTypeMandatory = true;
            }
        } else if (this.stageIndex > 8 && this.stageIndex <= 10) {
            if (documentType.Opportunity_Crediti_Fiscali__c === true &&
                (documentType.Obbligatorio_per_Pre_Due_Diligence__c === true ||
                    documentType.Obbligatorio_in_CompletamentoDocumenti__c === true ||
                    documentType.Obbligatorio_per_In_Stipula__c === true)) {
                isDocTypeMandatory = true;
            }
        } else if (this.stageIndex > 10) {
            if (documentType.Opportunity_Crediti_Fiscali__c === true &&
                (documentType.Obbligatorio_per_Pre_Due_Diligence__c === true ||
                    documentType.Obbligatorio_in_CompletamentoDocumenti__c === true ||
                    documentType.Obbligatorio_in_Erogazione__c === true ||
                    documentType.Obbligatorio_per_In_Stipula__c === true)) {
                isDocTypeMandatory = true;
            }
        }

        return isDocTypeMandatory;
    }

    /** Sets the mandatory flag for Mutuo opp document types */
    setMandatoryFlagForMutuo(documentType) {
        let isDocTypeMandatory = false;

        if (this.stageIndex <= 4) {
            if (documentType.Opportunita_Mutuo__c === true &&
                documentType.Obbligatorio_in_CompletamentoDocumenti__c === true) {
                isDocTypeMandatory = true;
            }
        } else if (this.stageIndex > 4 && this.stageIndex <= 7) {
            if (documentType.Opportunita_Mutuo__c === true &&
                (documentType.Obbligatorio_in_CompletamentoDocumenti__c === true ||
                    documentType.Obbligatorio_per_In_Stipula__c === true)) {
                isDocTypeMandatory = true;
            }
        } else if (this.stageIndex > 7) {
            if (documentType.Opportunita_Mutuo__c === true &&
                (documentType.Obbligatorio_in_CompletamentoDocumenti__c === true ||
                    documentType.Obbligatorio_in_Erogazione__c === true ||
                    documentType.Obbligatorio_per_In_Stipula__c === true)) {
                isDocTypeMandatory = true;
            }
        }

        return isDocTypeMandatory;
    }

    /** Sets the mandatory flag for Easy Plus opp document types */
    setMandatoryFlagForEasyPlus(documentType) {
        let isDocTypeMandatory = false;

        if (this.stageIndex <= 4) {
            if (documentType.Opportunita_EasyPlus__c === true &&
                documentType.Obbligatorio_in_CompletamentoDocumenti__c === true) {
                isDocTypeMandatory = true;
            }
        } else if (this.stageIndex === 5) {
            if (documentType.Opportunita_EasyPlus__c === true &&
                (documentType.Obbligatorio_in_CompletamentoDocumenti__c === true ||
                    documentType.Obbligatorio_per_In_Stipula__c === true)) {
                isDocTypeMandatory = true;
            }
        } else if (this.stageIndex > 5) {
            if (documentType.Opportunita_EasyPlus__c === true &&
                (documentType.Obbligatorio_in_CompletamentoDocumenti__c === true ||
                    documentType.Obbligatorio_in_Erogazione__c === true ||
                    documentType.Obbligatorio_per_In_Stipula__c === true)) {
                isDocTypeMandatory = true;
            }
        }

        return isDocTypeMandatory;
    }

    /** Returns the value of the verificaGlobale internal document variable */
    computeVerificaSalesSupportGlobale(documentTypeId) {
        let result = "Verifica KO";
        let docArray = this.documentMap.get(documentTypeId);

        if (docArray !== undefined && this.checkIfDocsAreValidated(docArray)) {
            result = "Verifica OK" ;
        }

        return result;
    }

    /** Iterates all the documents assigned to a DocumentType. If the field
     Verifica_Sales_Support__c is 'Verifica OK' on every document, returns true. */
    checkIfDocsAreValidated(documentArray) {
        let allDocumentsVerified = false;

        for (let i = 0; i < documentArray.length; i++) {
            let element = documentArray[i];
            if (element.Verifica_Sales_Support__c !== "Verifica OK") {
                allDocumentsVerified = false;
                break;
            } else {
                allDocumentsVerified = true;
            }
        }

        return allDocumentsVerified;
    }

    /** Sets id of uploaded document and shows file name modal. */
    handleUploadFinished(event) {
        let eventDetail = event.detail;
        let uploadedFile = eventDetail.uploadedFile;
        this.documentTypeId = eventDetail.documentTypeId;
        this.replaceFileId = eventDetail.replaceFileId;

        if (uploadedFile.length > 0) {
            this.fileName = eventDetail.fileName;
            this.fileId = eventDetail.fileId;
            this.showFileNameModal = true;
            this.defaultFileName = this.documentTypeMap.get(this.documentTypeId).Name;
            this.uploadedDocTypeId = this.documentTypeMap.get(this.documentTypeId).ID_Tipo_Documento__c;
            if (this.uploadedDocTypeId == 'SME_002') {
                this.showDocIdRefFields = true;
            }
            if (eventDetail.isReplace == true) {
                this.isSostituisci = true;
            }
        }
    }

    /** Handles file name modal after file name is updated. */
    handleFileNameUpdated(event) {
        this.handleClosedFileNameModal();
        window.location.reload();
    }

    /** Hides file name modal and refreshes page. */
    handleClosedFileNameModal(event) {
        this.showFileNameModal = false;
        this.showDocIdRefFields = false;
    }

    /** Update Comment fields in all documents related to a document Type with the current Comment box comments */
    updateCommentFieldInDocuments(event) {
        let documentTypeId = event.target.dataset.id;
        let textAreaList = this.template.querySelectorAll('.textareaUpload');
        let commentoSalesSupport = '';
        let documentIdList = [];
        this.showSpinner = true;

        for (let textArea of textAreaList) {
            if (textArea.dataset.id === documentTypeId) {
                commentoSalesSupport = textArea.value;
            }
        }

        for (let document of this.documentMap.get(documentTypeId)) {
            documentIdList.push(document.Id);
        }

        updateCommentInDocuments({documentIdList: documentIdList, commentToBeSaved: commentoSalesSupport}).then(response => {
            this.commentToSave = response
            this.showSpinner = false;
        });
    }

    /** Sets title condition as true or false for very document type */
    setTitleCondition(documentBlockId) {
        if (!this.docBlockIdAndIsDisplayed.has(documentBlockId)) {
            this.docBlockIdAndIsDisplayed.set(documentBlockId, true);
            return true;
        } else {
            return false
        }
    }

    removeFiles(event) {
        this.showElimina = true;
        this.documentTypeToPass = event.target.name;
        this.openEliminaSostituisciModal();
    }

    replaceFiles(event) {
        this.showElimina = false;
        this.documentTypeToPass = event.target.name;
        this.openEliminaSostituisciModal();
    }

    refreshApexAll() {
        refreshApex(this.refreshBlock);
    }

    openEliminaSostituisciModal() {
        this.isEliminaSostituisciModalOpen = true;
    }

    closeEliminaSostituisciModal() {
        this.isEliminaSostituisciModalOpen = false;
    }

    //function that is called in the moment that we select a contact to take his id
    getSelectedContact(event) {
        if (event.target.value) {
            this.setContact(event.target.value);
            this.refreshVariables();
            this.getRecordListDocumentAllNew();
        }  
    }

    get acceptedFormats() {
        return ['.pdf', '.xbrl','.xls', '.xlsx', '.p7m', '.txt', '.docx', '.doc','.ppt','.pptx','.p7s']
    }
    
    connectedCallback() {
        if (this.objectApiName === 'Opportunity') {
            console.log('recordId = ' + this.recordId);
            console.log('objectApiName = ' + this.objectApiName);
            getOpportunity({recordId: this.recordId}).then(result => {
                this.opportunity = result;
                this.accountId = result.AccountId;
                this.accSocietaApartiene = this.opportunity.Account.Societ_Appartiene_a_Gruppo__c;
                this.accClientelaIncidenza = this.opportunity.Account.Clientela_Incidenza__c;
                this.stageName = this.opportunity.StageName;
                this.accFidejussore = this.opportunity.Account.Fidejussore__c;
                this.setOppRecordType(this.opportunity.RecordType.DeveloperName);
                this.checkObject();
            });
        } else if (this.objectApiName === 'Account') {
            getContactFromAccount({recordId: this.recordId}).then(result => {
                this.contact = result;
                this.accountId = result.AccountId;
                this.setContact(result.Id);
                this.checkObject();
            });
        } else if (this.objectApiName === 'Contact') {
            getContact({recordId: this.recordId}).then(result => {
                this.contact = result;
                this.accountId = result.AccountId;
                this.setContact(result.Id);
                this.checkObject();
            });
        }
    }

    setContact(selectedContId) {
        this.selectedContId = selectedContId;
        let contactList = this.contacts.data;

        for (let i = 0; i < contactList.length; i++) {
            if (this.selectedContId === contactList[i].Id) {
                this.selectedCont = contactList[i];
            }
        }
    }

    setOppRecordType(recordTypeName) {
        if (recordTypeName === 'Inserimento_Crediti_Fiscali' ||
            recordTypeName === 'Crediti_Fiscale_Lending' ||
            recordTypeName === 'Crediti_Fiscale_Lending_RO') {
            this.oppIsCreditiFiscali = true;
        } else if (recordTypeName === 'Lending' ||
            recordTypeName === 'Lending_RO') {
            this.oppIsMutuo = true;
        } else if (recordTypeName === 'Lending_Easy_Plus' ||
            recordTypeName === 'Lending_Easy_Plus_RO') {
            this.oppIsEasyPlus = true;
        }
    }

    refreshVariables() {
        this.uniqueArray = [];
        this.documentMap = new Map();
        this.documentTypeMap = new Map();
        this.docBlockIdAndIsDisplayed = new Map();
    }

    setVerificaOkAvailabilityForDocs(documentType, availability) {
        let docsInDocType = this.documentMap.get(documentType.Id);

        if (docsInDocType && docsInDocType.length > 0) {
            for (let i = 0; i < docsInDocType.length; i++) {
                if (documentType.isDocTypeMandatory) {
                    if (!docsInDocType[i].isVerificaDisabled) {
                        docsInDocType[i].isVerificaDisabled = availability;
                    }
                }
            }
        }
    }

    disableDocTypeButtons(documentType) {
        documentType.isUploadDisabled = true;
        documentType.disableEliminaButton = true;
        documentType.disableSostituisciButton = true;
        documentType.isCommentAreaDisabled = true;
        documentType.disableSalvaButton = true;

        return documentType;
    }
}