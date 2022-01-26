import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eliminateDocuments from '@salesforce/apex/fileUploaderDAO.eliminateDocuments';

export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @api recordId;
    @api isModalOpen = false;
    @api documentMap;
    @api showElimina;
    @api documentType;

    @track uploadDisable = true;
    @track header;
    @track btnLabel;
    @track value;
    @track selectedRadioValue;
    @track docList = [];
    @track options = [];
    @track listToDelete = [];

    connectedCallback() {
        this.docList = this.documentMap.get(this.documentType);

        for (let element = 0; element < this.docList.length; element++) {
            let array = [];
            array = { "label": this.docList[element].File_Name__c, "value": String(this.docList[element].Id) };
            this.options.push(array);
        }

        if (this.showElimina) {
            this.setElimina();
        } else {
            this.setSostiuire();
        }
    }

    setElimina() {
        this.showElimina = true;
        this.header = 'Elimina Documento';
        this.btnLabel = 'Elimina'
    }

    setSostiuire() {
        this.header = 'Sostituire Documento';
        this.showElimina = false;
        this.btnLabel = 'Sostituire';
    }

    btnClick(event) {
        if (this.showElimina) {
            if (this.listToDelete.length > 0 ) {
                eliminateDocuments({documentIdList: this.listToDelete})
                .then(result => {
                })
                .catch(error => {
                })
                window.location.reload();
                this.closeModal();
            } else {
                const event = new ShowToastEvent({
                    title: 'Errore',
                    variant: 'error',
                    mode: 'pester',
                    message: 'Seleziona almeno un file da eliminare',
                });
                this.dispatchEvent(event);
            }
        }
    }

    handleCheckBoxChange(event) {
        if(event.target.checked) {
            this.listToDelete.push(event.target.name);            
        }
        else {
            for (let i = this.listToDelete.length - 1; i >= 0; i--) {
                if (this.listToDelete[i] === event.target.name) {
                    this.listToDelete.splice(i, 1);
                }
            }            
        }
    }

    handleRadioChange(event) {
        this.uploadDisable = false;
        this.selectedRadioValue = event.detail.value;
    }

    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
        const selectedEvent = new CustomEvent("closemodalevnt", {
            detail: this.isModalOpen
          });      
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
        
    }

    handleUploadFinished(event) {
        this.closeModal();
        let eventDetail = event.detail;

        eventDetail.isReplace = true;
        eventDetail.replaceFileId = this.selectedRadioValue;

            let uploadFinishedEvent = new CustomEvent("uploadfinished",
            {
                detail:eventDetail
            });
            this.dispatchEvent(uploadFinishedEvent);
    }
}