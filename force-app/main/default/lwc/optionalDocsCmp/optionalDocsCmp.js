import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import updateCommentInDocuments from '@salesforce/apex/fileUploaderDAO.UpdateCommentInDocuments';
import getPicklistValues from '@salesforce/apex/Utils.getPicklistValues';
import parametersMap from '@salesforce/apex/fileUploaderDAO.conditionsDocuments';
import getOptionalDocumentList from '@salesforce/apex/fileUploaderDAO.getOptionalDocumentList';
import getOptionalDocumentTypesList from '@salesforce/apex/fileUploaderDAO.getOptionalDocumentTypesList';
import getOpportunity from '@salesforce/apex/fileUploaderDAO.getOpportunity';
import {
    canProfileEditDocVerifica,
    checkIfButtonsAreDisabled,
    checkIfEnableMandatoryDocTypesInCessione,
} from 'c/documentManagementUtils';

export default class OptionalDocsCmp extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isStageFirma;
    @api isErogazioneNO;
    @api isRecTypeRO;
    @api isFirmaDigitale;
    @api isContratoVerificato;
    @api isProfilePartner;
    @api isProfileSales;
    @api isProfileInsideSales;
    @api isProfileFidimed;
    @api isProfileSalesEasy;
    @api isOppEasyPlus;
    @api docListObjectApiName;

    @track smallObjectName = 'Account';
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
    @track account;
    @track accSocietaApartiene;
    @track accClientelaIncidenza;
    @track accFidejussore;
    @track accountId;
    @track stageName;
    @track isProfileSalesNoFiscalPartner = false;
    @track isSostituisci = false;

    profileName = '';
    commentToSave = '';
    defaultFileName = '';
    disableAllButtons = false;
    isAdmin = false;
    enableMandatoryDocTypes = false;

    //wire that gets all picklist values of Document_Block__c field
    @wire(getPicklistValues, {objInfo: {'sobjectType' : 'DocumentType__c'},
        picklistFieldApi: 'Document_Block__c'}) docBlock(response){
        if(response.data){
            let array = [];
            let list = response.data;
            list.forEach(val => {
                array.push(val.label);
            })
            this.docBlockName = array;
        }
    };

    //method that gets all necessary parameters
    getConditionsDoc() {
        console.log('* getConditionsDoc *');
        parametersMap({recordId: this.recordId, objectApiName: 'Opportunity', smallObjectName: '' }).then( resultApex => {
            //we give value to the global parameters
            this.isStageFirma = resultApex.isStageFirma;
            this.isErogazioneNO = resultApex.isErogazioneNO;
            this.isRecTypeRO = resultApex.isRecTypeRO;
            this.isFirmaDigitale = resultApex.isFirmaDigitale;
            this.isContratoVerificato = resultApex.isContratoVerificato;
            this.isProfileSales = resultApex.isProfileSales;
            this.isProfileInsideSales = resultApex.isProfileInsideSales;
            this.isProfileFidimed = resultApex.isProfileFidimed;
            this.isProfileSalesEasy = resultApex.isProfileSalesEasy;
            this.isProfileTuttiSales = resultApex.isProfileTuttiSales;
            this.isOppEasyPlus = resultApex.isOppEasyPlus;
            this.isProfileSalesNoFiscalPartner = resultApex.isProfileSalesNoFiscalPartner;
            this.isAdmin = resultApex.isAdmin;
            this.profileName = resultApex.profileName;

            //we call the method that get the list of all documents and do the calculations regarding different specifications
            this.getOptionalDocumentList();
        });
    }

    //method that gets te list of all documents
    getOptionalDocumentList() {
        let inputMap = {
            opportunityId : this.opportunity.Id,
            accountId : this.accountId
        }

        let jsonInput = JSON.stringify(inputMap);

        getOptionalDocumentList({jsonInput: jsonInput}).then(response => {
            if (!response.error) {
                this.refreshBlock = JSON.parse(JSON.stringify(response.allDocsByDocType));
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
                        document['showApprova'];
                        document['showRichiediApprovazione'];

                        if (!this.isAdmin) {
                            document.isVerificaDisabled = this.disableAllButtons || canProfileEditDocVerifica(profilesToEditVerificaSales, this.profileName);
                        }

                        //we controll if the doc is uploaded correctly
                        if(document.Url_Documento__c != null && document.Verifica_Sales_Support__c !== 'Verifica OK' && document.Verifica_Sales_Support__c !== 'Da Ricaricare'){
                            document.isUploadedSuccess = true;
                        } else if((document.Url_Servizio_Esterno__c != null) && (document.Url_Documento__c === undefined) && (document.Errore_Store_Document__c != null)){
                            document.isUploadedError = true;
                        } else if((document.Url_Servizio_Esterno__c != null) && (document.Url_Documento__c === undefined) && (document.Errore_Store_Document__c === null)){
                            document.isUploadedLoading = true;
                        } else if(document.Verifica_Sales_Support__c === 'Verifica OK'){
                            document.isVerificaOK = true;
                        } else if(document.Verifica_Sales_Support__c === 'Da Ricaricare'){
                            document.isDaRicaricare = true;
                        }

                        if (this.documentMap.has(documentTypeId)) {
                            this.documentMap.get(documentTypeId).push(document);
                        } else {
                            this.documentMap.set(documentTypeId, [document]);
                        }
                    })
                }
            } else {
                console.log('errorMsg: ', response.errorMsg);
            }
            this.cleanDocumentMap();
            this.getOptionalDocumentTypesList();
        });
    }

    /** Retrieves the list of document types which are required for this object */
    getOptionalDocumentTypesList() {
        let jsonInput = JSON.stringify({
            recordId: this.recordId,
            block: JSON.stringify(this.docBlockName)
        })

        getOptionalDocumentTypesList({jsonInput : jsonInput}).then(response => {
            if (!response.error) {
                let parsedResponse = JSON.parse(JSON.stringify(response.allDocTypes));

                for (const [documentTypeId, documentType] of Object.entries(parsedResponse)) {
                    let documentArray = this.documentMap.get(documentTypeId);

                    //we declare internal variables for each document
                    documentType['verificaGlobale'];
                    documentType['isUploadDisabled'];
                    documentType['titleCondition'];
                    documentType['isDocTypeMandatory'] = false;
                    documentType['isCommentAreaDisabled'] = false;
                    documentType['labelComment'];
                    documentType['placeComment'];
                    documentType['commentFromDocuments'];
                    documentType['disableEliminaButton'] = false;
                    documentType['disableSostituisciButton'] = false;
                    documentType['disableSalvaButton'] = true;
                    documentType['showButtons'] = true;
                    documentType['verificaGlobaleLabel'] = 'Verifica Sales Support Globale:';

                    if (!this.isAdmin && documentType.Doc_Caricato_dal_Fiscal_Partner__c === true) {
                        documentType.showButtons = this.isProfileFiscalPartner;
                    }

                    // Set availability of comment text area and Salva button
                    if((!this.isProfileTuttiSales  || this.isRecTypeRO) || (documentType.visibileaPartner__c === false && !this.isProfileSalesEasy)) {
                        documentType.isCommentAreaDisabled = true;
                        documentType.labelComment = 'Nota del Sales Support.';
                        documentType.placeComment = ' ';
                    } else {
                        documentType.isCommentAreaDisabled = false;
                        documentType.labelComment = 'Inserire nota supplementare, max 500 caratteri.';
                        documentType.placeComment = 'Scrivi qua... ';
                    }

                    //Check if Upload button should be disabled
                    if (!this.isAdmin) {
                        if (this.disableAllButtons) {
                            if (!this.enableMandatoryDocTypes || (this.enableMandatoryDocTypes && !documentType.isDocTypeMandatory)) {
                                documentType.isUploadDisabled = true;
                                documentType.disableEliminaButton = true;
                                documentType.disableSostituisciButton = true;
                                documentType.isCommentAreaDisabled = true;
                                documentType.disableSalvaButton = true;
                            } else {
                                let docsInDocType = this.documentMap.get(documentType.Id);

                                if (docsInDocType && docsInDocType.length > 0) {
                                    for (let i = 0; i < docsInDocType.length; i++) {
                                        if (documentType.isDocTypeMandatory) {
                                            docsInDocType[i].isVerificaDisabled = false;
                                        }
                                    }
                                }
                            }
                        } else {
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
                            documentType.isUploadDisabled = documentArray.length >= 5;
                        }
                    } else {
                        //Disable comment area, Elimina and Sostituisci buttons if there are no documents
                        documentType.isCommentAreaDisabled = true;
                        documentType.disableEliminaSostituisciButtons = true;
                    }

                    this.documentTypeMap.set(documentTypeId, documentType);
                    this.uniqueArray.push({key: documentTypeId, value: documentType})
                }
                this.uniqueArray = this.getSortedUniqueArray();
            } else {
                console.log('errorMsg: ', response.errorMsg);
            }
        });
    }

    getSortedUniqueArray() {
        let docBlockAndDocTypeMap = new Map();
        let sortedUniqueArray = [];
        let altroArray = [];
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

                    if (docType.ID_Tipo_Documento__c === 'SME_095') {
                        altroArray.push({key: docType.Id, value: docType})
                    } else {
                        sortedUniqueArray.push({key: docType.Id, value: docType})
                    }

                }
            }
        })

        sortedUniqueArray.push.apply(sortedUniqueArray, altroArray);

        return sortedUniqueArray;
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

    refreshApexAll() {
        refreshApex(this.refreshBlock);
    }

    /** Sets id of uploaded document and shows file name modal. */
    handleUploadFinished(event) {
        let eventDetail = event.detail;
        let uploadedFile = eventDetail.uploadedFile;
        this.documentTypeId = eventDetail.documentTypeId;
        this.replaceFileId = eventDetail.replaceFileId;

        if(uploadedFile.length > 0){
            this.fileName = eventDetail.fileName;
            this.fileId = eventDetail.fileId;
            this.showFileNameModal = true;
            this.defaultFileName = this.documentTypeMap.get(this.documentTypeId).Name;
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

    /** Sets title condition as true or false for every document type */
    setTitleCondition(documentBlockId) {
        if (!this.docBlockIdAndIsDisplayed.has(documentBlockId)) {
            this.docBlockIdAndIsDisplayed.set(documentBlockId, true);
            return true;
        } else {
            return false
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.xbrl','.xls', '.xlsx', '.p7m', '.txt', '.docx', '.doc','.ppt','.pptx','.p7s'];
    }

    connectedCallback() {
        if (this.objectApiName === 'Opportunity') {
            getOpportunity({recordId: this.recordId}).then(result => {
                this.opportunity = result;
                this.stageName = this.opportunity.StageName;
                this.accountId = this.opportunity.AccountId;
                this.accSocietaApartiene = this.opportunity.Account.Societ_Appartiene_a_Gruppo__c;
                this.accFidejussore = this.opportunity.Account.Fidejussore__c;
                this.accClientelaIncidenza = this.opportunity.Account.Clientela_Incidenza__c;
                this.disableAllButtons = checkIfButtonsAreDisabled(this.opportunity, this.oppIsCreditiFiscali, this.oppIsMutuo,
                    this.oppIsEasyPlus, this.creditiStageMap, this.mutuoStageMap, this.easyPlusStageMap);
                this.enableMandatoryDocTypes = checkIfEnableMandatoryDocTypesInCessione(this.opportunity,
                    this.oppIsCreditiFiscali, this.creditiStageMap);
                this.getConditionsDoc();
            });
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

    handleReplace(event) {
        // to close modal set isModalOpen track value as false
        let eventObj = event.detail.selectedRadioValue;
    }

    openEliminaSostituisciModal() {
        // to open modal set isModalOpen track value as true
        this.isEliminaSostituisciModalOpen = true;
    }

    closeEliminaSostituisciModal() {
        // to open modal set isModalOpen track value as true
        this.isEliminaSostituisciModalOpen = false;
    }

}