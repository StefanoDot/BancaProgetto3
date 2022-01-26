/**
 * Created by mocan on 17/06/2021.
 */

import {api, track, LightningElement, wire} from "lwc";
import getDocumentToken from '@salesforce/apex/ElevaRestApiController.getDocumentToken';
import getPicklistValues from '@salesforce/apex/Utils.getPicklistValues';
import updatePick from '@salesforce/apex/fileUploaderDAO.updatePick';

export default class DocumentList extends LightningElement {
  @api documentTypeId;
  @api allDocsMap;
  @api documentFileName;
  @api showOpportunityDocuments = false;

  @track verificaSalesSupportOptions;
  @track showArray = false;
  @track documentArray = [];
  @track showSpinner = false;

  showVerificaLabel = true;
  showVerificaField = true;

  /** Get all the picklist values of Verifica_Sales_Support__c field */
  @wire(getPicklistValues, {objInfo: {'sobjectType' : 'Document__c'},
    picklistFieldApi: 'Verifica_Sales_Support__c'}) stageNameValues(response) {
    if (response.data) {
      let array = [];
      let list = response.data;
      for (let key in list) {
        array.push({label: list[key].label,value: list[key].value});
      }
      this.verificaSalesSupportOptions = array;
    }
  };

  /** Fill documentArray with the retrieved documents for the given DocumentType.  **/
  connectedCallback() {
    this.documentArray = this.allDocsMap.get(this.documentTypeId);
  }

  /** Opens the page where we see the document in the moment we click vai al documento **/
  openDocument(event) {
    this.completeUrl = event.target.name;
    getDocumentToken({}).then(resultApex2 => {
      var trimmedDocToken = resultApex2.slice(1, -1);
      var trimmedDocUrl = this.completeUrl + "?token=" + trimmedDocToken;

      window.open(trimmedDocUrl, "_blank");
    });
  }

  /** Gets the value of the Verifica Sales Support picklist
   when the user chooses a new value **/
  handleVerificaSalesSupportChange(event) {
    let verificaSalesSupport = event.detail.value;
    let documentId = event.target.name;
    this.showSpinner = true;

    updatePick({recordUpdateId: documentId, verificaSalesSupport: verificaSalesSupport}).then(result => {
      result.DocumentType__c = this.documentTypeId;
      this.showSpinner = false;
      this.dispatchEvent(new CustomEvent("valuechanged", { detail: result }));
    });
  }

}