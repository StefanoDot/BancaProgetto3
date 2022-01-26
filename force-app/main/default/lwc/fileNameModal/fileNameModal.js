/**
 * Created by mocan on 22/06/2021.
 */

import { LightningElement, track, api } from 'lwc';
import addFile  from '@salesforce/apex/fileUploaderDAO.addFile';
import { error } from "c/notificationSvc";

export default class FileNameModal extends LightningElement {

  @api isModalOpen = false;
  @api documentTypeId;
  @api fileName;
  @api fileId;
  @api replaceDocId;
  @api commentToSave;
  @api accountId;
  @api opportunity;
  @api selectedContactId = '';
  @api selectedQuoteId = '';
  @api defaultFileName = '';
  @api isDocIdentitaRef = false;
  @api isSostituisci = false;

  @track header = '';
  @track showSpinner = false;
  @track descriptionFile = '';
  @track labelFile = '';
  @track labelBottone = '';

  connectedCallback() {
    if (this.isSostituisci == true) { 
      this.header = 'Sostituisci Documento';
      this.descriptionFile = 'Quale Documento vuoi Modificare ?';
      this.labelFile = 'Inserire il nome del documento:';
      this.labelBottone = 'Sostituisci';
    }
    else { 
      this.header = 'Aggiungi Documento';
      this.descriptionFile = 'Quale Documento vuoi Aggiungere ?';
      this.labelFile = 'Inserire il nome del documento da aggiungere:';
      this.labelBottone = 'Aggiungi';
    }
  }

  /** Stars the Document__c creation process when clicked **/
  aggiungiBtnClick() {
    this.showSpinner = true;
    let finalDocumentName = this.template.querySelector(`[data-id="documentNameInput"]`).value;
    if (finalDocumentName !== '') {
      if (this.isDocIdentitaRef) {
        const fields = {};
        this.template.querySelectorAll('[data-id="formDocReferente"]').forEach(element => {
            fields[element.fieldName] = element.value;
        });
        const allValid = [...this.template.querySelectorAll('[data-id="formDocReferente"]')].reduce((validSoFar, inputCmp) => {
           return validSoFar && inputCmp.reportValidity();
        }, true);
        if (allValid) {
          this.template.querySelector('[data-id="formDocRef"]').submit(fields);
          addFile({documentTypeId: this.documentTypeId, accountId: this.accountId,
             finalDocumentName: finalDocumentName, fileName: this.fileName, fileId: this.fileId,
             replaceDocId: this.replaceDocId, commentToSave: this.commentToSave, opportunity: this.opportunity,
             selectedContactId: this.selectedContactId, selectedQuoteId: this.selectedQuoteId}).then( result => {
 
             this.dispatchEvent(new CustomEvent('filenameupdated', { detail: result }));
             this.isModalOpen = false;
             this.showSpinner = false;
          });
        } else {
          error(this, 'Compilare tutti i campi correttamente', 'Campi non corretti o vuoti');
          this.showSpinner = false;
        }
      } else {
        addFile({documentTypeId: this.documentTypeId, accountId: this.accountId,
          finalDocumentName: finalDocumentName, fileName: this.fileName, fileId: this.fileId,
          replaceDocId: this.replaceDocId, commentToSave: this.commentToSave, opportunity: this.opportunity,
          selectedContactId: this.selectedContactId, selectedQuoteId: this.selectedQuoteId}).then( result => {

          this.dispatchEvent(new CustomEvent('filenameupdated', { detail: result }));
          this.isModalOpen = false;
          this.showSpinner = false;
        });
      }
    } else {
      this.showSpinner = false;
      error(this, 'Inserire nome documento', 'Nome File Non Corretto');
    }
  }

  handleSuccess(event) {
    const showWarning = new ShowToastEvent({
      title: 'Successo',
      message: 'Dati aggiornati correttamente',
      variant: 'success'
    });
    this.dispatchEvent(showWarning);
  }

  handleErrorBP(event) {
    error(this,event.detail.message);
    this.showSpinner = false;
  }

  /** closes the modal and dispatches an event to confirm **/
  closeModal() {
    this.isModalOpen = false;
    this.isDocIdentitaRef = false;
    this.dispatchEvent(new CustomEvent('closedmodal'));
  }

}