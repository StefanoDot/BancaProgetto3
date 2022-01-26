//CREATED BY ALDORA 18.03.2021

/* eslint-disable no-eval */
/* eslint-disable guard-for-in */
/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-vars */
/* eslint-disable eqeqeq */
/* eslint-disable no-dupe-class-members */
/* eslint-disable no-cond-assign */
/* eslint-disable no-unused-expressions */
/* eslint-disable dot-notation */
/* eslint-disable no-empty */
/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */

import { LightningElement, api,track,wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import updatePick from '@salesforce/apex/fileUploaderDAO.updatePick';
import updareText from '@salesforce/apex/fileUploaderDAO.updateNote';
import updateFile  from '@salesforce/apex/fileUploaderDAO.updateFile';
import getDocumentToken from '@salesforce/apex/ElevaRestApiController.getDocumentToken';
import getPicklistValues from '@salesforce/apex/Utils.getPicklistValues';
import parametersMap from '@salesforce/apex/fileUploaderDAO.conditionsDocuments';
import getRecordListDocumentAllAcc from '@salesforce/apex/fileUploaderDAO.getRecordListDocumentAllAcc';
import eliminateDocuments from '@salesforce/apex/fileUploaderDAO.eliminateDocuments';


export default class MyComponentName extends LightningElement {
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
    @api docBlockName = [];

    @track smallObjectName='Account';
    @track showFileUpload = false;
    @track recordListDocumentAllBlock = [];
    @track allDocsByTypeArray = [];
    @track uniqueDocumentTypeArray = [];
    @track finalDocArray = [];
    @track uniqueArray = [];
    @track uniqueMap = new Map();
    @track isModalOpen = false;
    @track showElmina;
    @track documentList = [
        { label: 'Bilancio Analitco', value: 'Bilancio Analitco' },
        { label: 'Documento 2 di esempio', value: 'Documento 2 di esempio' },
        { label: 'Documento 3 di esempio', value: 'Documento 3 di esempio' }
    ];
    @track documentTypeToPass;

    //wire that gets all picklist values of Document_Block__c field
    @wire(getPicklistValues, {objInfo: {'sobjectType' : 'DocumentType__c'},
    picklistFieldApi: 'Document_Block__c'}) docBlock(response){
        if(response.data){
            var array = [];
            var list = response.data;
            list.forEach(val => {
                array.push(val.label);
            })
            this.docBlockName = array;
        }
    };
    
    //we get all the picklist values of Verifica_Sales_Support__c field
    @wire(getPicklistValues, {objInfo: {'sobjectType' : 'Document__c'},
    picklistFieldApi: 'Verifica_Sales_Support__c'}) stageNameValues(response){
        if(response.data){
            var array = [];
            var list = response.data;
            for(var key in list){
                array.push({label: list[key].label,value: list[key].value});
                console.log({label: list[key].label,value: list[key].value});
            }
            console.log(array);
            this.options=array;
        }
    };

    //method that gets all neccessary parameters
    getConditionsDoc(){
        parametersMap({recordId: this.recordId, objectApiName: this.objectApiName, smallObjectName: this.smallObjectName }).then( resultApex => {
            
            console.log('parametersMap')
            
            //we give value to the global parameters
            this.isStageFirma           = resultApex.isStageFirma;
            this.isErogazioneNO         = resultApex.isErogazioneNO;
            this.isRecTypeRO            = resultApex.isRecTypeRO;
            this.isFirmaDigitale        = resultApex.isFirmaDigitale;
            this.isContratoVerificato   = resultApex.isContratoVerificato;
            this.isProfilePartner       = resultApex.isProfilePartner;
            this.isProfileSales         = resultApex.isProfileSales;
            this.isProfileInsideSales   = resultApex.isProfileInsideSales;
            this.isProfileFidimed       = resultApex.isProfileFidimed;
            this.isProfileSalesEasy     = resultApex.isProfileSalesEasy;
            this.isProfileTuttiSales    = resultApex.isProfileTuttiSales;
            this.isOppEasyPlus          = resultApex.isOppEasyPlus;
            
            //we call the method that get the list of all documents and do the calculations regarding different specifications
            this.getRecordListDocumentAllAcc();
        });
    }

    //method that gets te list of all documents
    getRecordListDocumentAllAcc(){
        getRecordListDocumentAllAcc({record: this.recordId, objectApiName: this.objectApiName, block: this.docBlockName}).then(response => {
            if(response) {
                this.refreshBlock = JSON.parse(JSON.stringify(response));
                console.log('refreshBlock = ' + this.refreshBlock);
                //console.log('JSON.stringify(this.refreshBlock) = ' + JSON.stringify(this.refreshBlock));

                for (const [key, value] of Object.entries(this.refreshBlock)) {
                    value.forEach((document, i) => {
                        let documentTypeId = document.DocumentType__r.Id;
                        this.allDocsByTypeArray.push({key: documentTypeId, value: [document]});
                        if (!this.uniqueDocumentTypeArray.includes(documentTypeId)) {
                            this.uniqueDocumentTypeArray.push(documentTypeId);
                        }

                        //we declare internal variables for each document
                        document['isModuloRichiesta'];
                        document['isUploadedSuccess'];
                        document['isUploadedError'];
                        document['isUploadedLoading'];
                        document['isDocEasyPlus'];
                        document['isDocObbligatorio']
                        document['isUploadDisabled']
                        document['isVerificaDisabled']
                        document['labelComment']
                        document['placeComment']
                        
                        if (i === 0) {
                            document.titleCondition = true;
                        }
                        
                        //we controll the upload
                        if (this.isRecTypeRO || (this.isErogazioneNO && document.DocumentType__r.Erogazione_Servizi__c==true) || (document.DocumentType__r.visibileaPartner__c==false && !this.isProfileFidimed)){
                            document.isUploadDisabled=true;
                        }
                        else{
                            document.isUploadDisabled=false;
                        }
                        
                        //we controll the combobox verifica
                        //and the check for text area and button salva
                        if((!this.isProfileTuttiSales  || this.isRecTypeRO) || (document.DocumentType__r.visibileaPartner__c==false && !this.isProfileSalesEasy)){
                            document.isVerificaDisabled=true;
                            document.labelComment='Nota del Sales Support.';
                            document.placeComment=' ';
                        }else{
                            document.isVerificaDisabled=false;
                            document.labelComment='Inserire nota supplementare, max 500 caratteri.';
                            document.placeComment='Scrivi qua... ';
                        }
                        
                        //we controll if the doc is uploaded correctly
                        if(document.Url_Documento__c != null){
                            document.isUploadedSuccess=true;
                            document.isUploadedError=false;
                            document.isUploadedLoading=false;
                        }else if((document.Url_Servizio_Esterno__c != null) && (document.Url_Documento__c == undefined) && (document.Errore_Store_Document__c != null)){
                            document.isUploadedError=true;
                            document.isUploadedSuccess=false;
                            document.isUploadedLoading=false;
                        }else if((document.Url_Servizio_Esterno__c != null) && (document.Url_Documento__c == undefined) && (document.Errore_Store_Document__c == null)){
                            document.isUploadedLoading=true;
                            document.isUploadedError=false;
                            document.isUploadedSuccess=false;
                        }

                        //we controll if the doc is obbligatorio
                        if (document.ObligatarioAcc__c == true || (document.DocumentType__r.dependeDaTipoLinea__c=='Progetto EasyPlus' && this.isOppEasyPlus)){
                            document.isDocObbligatorio=true;
                        }else{
                            document.isDocObbligatorio=false;
                        }
                    });
                    //we fill the array with all documents
                    this.recordListDocumentAllBlock.push(value);
                }
            } else if (error) {
                console.log('error',error);
            }

            for (let i = 0; i < this.uniqueDocumentTypeArray.length; i++) {
                let iElement = this.uniqueDocumentTypeArray[i];
                let index = 0;
                for (let j = 0; j < this.allDocsByTypeArray.length; j++) {
                    let jElement = this.allDocsByTypeArray[j];
                    if (iElement === jElement.key) {
                        if (index <1) {
                            this.uniqueMap.set(jElement.key, jElement.value);
                        } else {
                            let newValue = this.uniqueMap.get(jElement.key);
                            newValue.push(jElement.value[0]);
                            this.uniqueMap.set(jElement.key, newValue);
                        }
                        index++;
                    }
                }
            }
            this.uniqueMap.forEach((value, key, map) => {
                this.finalDocArray.push({key: key, value: value})
                this.uniqueArray.push({key: key, value: [value[0]]})
            })
        });
    }

    //gets the value of picklist verifica sales support in the moment we choose
    handleChange(event) {
        this.value=event.detail.value;
        this.valueId=event.target.name;

        updatePick({recordUpdateId: this.valueId,verificaSalesSupport:this.value});
        
        this.refreshApexAll();
    }
    
    
    //opens the page where we see the document in the moment we click vai al documento 
    openDocument(event){
        this.completeUrl = event.target.name;
        
        getDocumentToken({}).then( resultApex2 => {
            var docUrl = this.completeUrl + resultApex2;
            var trimmedDocToken = resultApex2.slice(1,-1);
            var trimmedDocUrl = this.completeUrl + '?token=' + trimmedDocToken;
            
            window.open(trimmedDocUrl, "_blank");
        } );
    }
    
    
    refreshApexAll(){
        refreshApex(this.refreshBlock);
    }
    
    
    // Get the list of uploaded files in the moment that we upload a file
    handleUploadFinished(event) {
        console.log('handleUploadFinished event.detail = ' + JSON.stringify(event.detail));
        console.log('handleUploadFinished event.detail.files = ' + JSON.stringify(event.detail.files));
        const uploadedFile = event.detail.files;
        var documentId  = uploadedFile[0].documentId;

        if(uploadedFile.length>0){
            this.value=event.detail.files[0].name;
            this.valueId=event.target.name;
            this.fileId=uploadedFile[0].documentId;
            var theFile = event.detail.files[0];

            updateFile({recordUpdateId: this.valueId,fileName:this.value,fileId: this.fileId}).then( resultApex => {

            });
        }
    }
    
    
    //in the moment that we start writting in the text area
    onchangeButton(event) {
        this.nameId=event.target.name;
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.visibility='visible';
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.display='inline';
    }

    addFiles(event) {
        let btn = event.target;
        let btnName = btn.name;

        for (let element = 0; element < this.allDocsByTypeArray.length; element++) {
            let value = this.allDocsByTypeArray[element].value;
            let cloneDoc = value[0];
            let key = this.allDocsByTypeArray[element].key;
            if (btnName === key) {
                value.push(cloneDoc);
            }
        }
        return "";
    }
    
    
    //in the moment that we click the button salva for the comment
    updateUrl(event) {
        console.log(JSON.stringify(event.target))
        this.nameId=event.target.name;
        this.note= this.template.querySelectorAll('.textareaUpload');
        var recordUpdateId= this.nameId;
        for(let up of this.note){
            if (up.name==this.nameId){
                var commentoSalesSupport =up.value;
            }
        }
        
        updareText({recordUpdateId: recordUpdateId,commentoSalesSupport:commentoSalesSupport});
        
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.visibility='hidden';
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.display='none';
    }
    
    get acceptedFormats() {
        return ['.pdf', '.png','.xls', '.xlsx', '.zip'];
    }
    
    connectedCallback(){
        console.log('CONNECTED CALLBACK'); 
        this.getConditionsDoc();
    }
    removeFiles(event){
        this.showElmina = true;
        this.documentTypeToPass = event.target.name;
        console.log('the documtn type is    '+this.documentTypeToPass);
        this.openModal();
    }
    replaceFiles(event){
        
        this.showElmina = false;
        this.documentTypeToPass = event.target.name;
        this.openModal();
    }
    handleReplace(event) {
        // to close modal set isModalOpen track value as false
        var eventObj = event.detail.selectedRadioValue;
        console.log('selectedId is '+event.detail.selectedRadioValue);
        console.log('documentTypeId is '+event.detail.documentTypeId);               
    }
    openModal() {
        // to open modal set isModalOpen track value as true
        console.log('open modal is called');
        this.isModalOpen = true;
    }
    handleCloseModal(event) {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = event.detail;
    }
    handleClickon() {
        // to close modal set isModalOpen track value as false
        console.log('btn here it is');
    }
}