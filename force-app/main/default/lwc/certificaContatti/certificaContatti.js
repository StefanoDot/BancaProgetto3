/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable vars-on-top */
/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDatiContact  from '@salesforce/apex/CertificaContattiController.getDatiContact';
import saveNumDoc  from '@salesforce/apex/CertificaContattiController.saveNumDoc';
import savePhone from '@salesforce/apex/CertificaContattiController.savePhone';
import saveEmail from '@salesforce/apex/CertificaContattiController.saveEmail';
import verifyContact from '@salesforce/apex/CertificaContattiController.getResponseSendCode';
import checkContact from '@salesforce/apex/CertificaContattiController.getResponseCheckCode';
import getVerifiedFlagsFromContact from '@salesforce/apex/CertificaContattiController.getVerifiedFlagsFromContact';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact from '@salesforce/schema/Contact';
import CONTACT_RECORDTYPE_FIELD from '@salesforce/schema/Contact.RecordTypeId';
import PREFISSO_INTERNAZIONALE from '@salesforce/schema/Contact.Prefisso_Internazionale__c';

import { refreshApex } from '@salesforce/apex';

export default class CertificaContatti extends LightningElement {
    
@api recordId;
@track listaDatiContatto;
@track numDoc;
@track numPhone;
@track numEmail;
@track numCodPhone;
@track numCodEmail;
@track varibaile;
@track options;
@track objectInfo;
@track recordTypeId;
@track showSpinnerCert = true;
refreshListaDatiContatto

onchangeNumDoc(event){this.numDoc=event.detail.value; console.log('passa   ' + this.numDoc)}
onchangeEmail(event){this.numEmail=event.detail.value;}
onchangePhone(event){this.numPhone=event.detail.value;}
onchangeCodPhone(event){this.numCodPhone=event.detail.value;}
onchangeCodEmail(event){this.numCodEmail=event.detail.value;}

    @wire (getDatiContact,{record: '$recordId' }) // recupero i dati dalla query del contatto
    listaContatto(value){
        
        this.refreshListaDatiContatto=value;
        const { data } = value;{
        console.log('entra qui1  '+data);
        if(data){
            this.listaDatiContatto=JSON.parse(JSON.stringify(data));
            console.log('entra qui  '+ JSON.stringify(this.listaDatiContatto));
        }
    }
}

@wire(getObjectInfo, { objectApiName: Contact })
objectInfo;

@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PREFISSO_INTERNAZIONALE })
setPicklistOptions({error, data}) {
  if (data) {
      console.log('PICKLIST VALUES '+data);
    // Apparently combobox doesn't like it if you dont supply any options at all.
    // Even though selectedOption was assigned in step 1, it wont "select" it unless it also has options
    this.options = data.values;
  } else if (error) {
    console.log(error);
  }
}

connectedCallback(){
    this.showSpinnerCert = false;
}


    onclickcheckPhone(){//chiamata servizio esterno conferma codice
        this.numCodPhone=this.template.querySelectorAll(".lightning-input-check-phone")[0].value;
        console.log(' codice phone è   '  + this.numCodPhone);
        checkContact({record: this.recordId,code: this.numCodPhone,type: 'MOBILE_PHONE'}).then(resultApex=>{
            var result=JSON.parse(resultApex);
            console.log('entra nel salva e passa '+ result[0].faultMessage)
            if(resultApex == '"OK"'){
                               
                const evt = new ShowToastEvent({
                    title: 'Richiesta Riuscita',
                    message: 'Codice inviato. Verifica la certificazione sulla scheda referente.',
                    variant: 'info',
            });
                this.dispatchEvent(evt);
               
            }else {
                    const evt = new ShowToastEvent({
                        title: 'Richiesta Fallita',
                        message: result[0].faultMessage,
                        variant: 'error',
                });
                    this.dispatchEvent(evt);
            }


        });
     
    }

    showToastCustom(){
        const evt = new ShowToastEvent({
            title: 'Richiesta Riuscita',
            message: 'xxx',
            variant: 'success',
    });
        this.dispatchEvent(evt);
    }


    onclickcheckEmail(){ //chiamata servizio esterno conferma codice
        this.numCodEmail=this.template.querySelectorAll(".lightning-input-check-email")[0].value;
        console.log(' codice email è   '  + this.numCodEmail);
        checkContact({record: this.recordId,code: this.numCodEmail,type: 'EMAIL'}).then(resultApex=>{
            var result=JSON.parse(resultApex);
            console.log('entra nel salva e passa '+ result[0].faultMessage)
        if(resultApex == '"OK"'){          
            const evt = new ShowToastEvent({
                    title: 'Richiesta Riuscita',
                    message: 'Codice inviato. Verifica la certificazione sulla scheda referente.',
                    variant: 'info',
            });
                 this.dispatchEvent(evt);
                // this.dispatchEvent(new CustomEvent('recordChange'));

        }else {
            const evt = new ShowToastEvent({
                title: 'Richiesta Fallita',
                message: result[0].faultMessage,
                variant: 'error',
        });
            this.dispatchEvent(evt);
        
        }   
        });            
    }

    onclickSendPhone(){        
        if(this.numPhone !== undefined){

            var prefix = this.template.querySelector('[data-id="prefisso-internazionale"]').value;
            console.log('PREFIX '+prefix);

                //richiamo metodo apex per il salva
            savePhone({record: this.recordId,phone:this.numPhone,prefix:prefix  }).then(()=>{
                refreshApex(this.refreshListaDatiContatto);
            });

        }else {
             this.numPhone = this.template.querySelectorAll(".lightning-input-send-phone")[0].value
            console.log('test prova entra else   '+this.numPhone);
               
        }

        if(this.numPhone !== undefined){
            console.log('chiamata servizio esterno num è   '+this.numPhone);

            var prefix = this.template.querySelector('[data-id="prefisso-internazionale"]').value;
            console.log('** PREFIX '+prefix);
            var completeNumber = prefix + this.numPhone;
            console.log('** COMPLETE NUMBER '+completeNumber);

            verifyContact({record: this.recordId, data: completeNumber,type: 'MOBILE_PHONE'}).then(resultApex =>{
                var result=JSON.parse(resultApex);
                console.log('entra nel salva e passa '+ result[0].faultMessage)
                if(resultApex == '"OK"'){
                    const evt = new ShowToastEvent({
                        title: 'Richiesta Riuscita',
                        message: 'Codice inviato correttamente al numero inserito.',
                        variant: 'success',
                });
                    this.dispatchEvent(evt);                       
                }else {
                    const evt = new ShowToastEvent({
                        title: 'Richiesta Fallita',
                        message: result[0].faultMessage,
                        variant: 'error',
                });
                    this.dispatchEvent(evt);
                }   
            });
        
        }
    }


    onclickSendEmail(){    
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
                }, true);

        if (allValid) {
            if(this.numEmail!==undefined){
                saveEmail({record: this.recordId,email:this.numEmail  }).then(()=>{
                    refreshApex(this.refreshListaDatiContatto);                               
                });
    
            }else {
                this.numEmail = this.template.querySelectorAll(".lightning-input-send-email")[0].value;
                console.log('test prova entra else   '+this.numEmail);
            }
            
            if(this.numEmail!==undefined){
                verifyContact({record: this.recordId, data: this.numEmail,type: 'EMAIL'}).then(resultApex =>{
                    var result=JSON.parse(resultApex);
                    console.log('entra nel salva e passa '+ result[0].faultMessage)
                if(resultApex == '"OK"'){
                    const evt = new ShowToastEvent({
                        title: 'Richiesta Riuscita',
                        message: 'Codice inviato correttamente all\'email inserita.',
                        variant: 'success',
                    });
                        this.dispatchEvent(evt);
                               
                }else {
                    const evt = new ShowToastEvent({
                        title: 'Richiesta Fallita',
                        message: result[0].faultMessage,
                        variant: 'error',
                    });
                        this.dispatchEvent(evt);  
                    }   
                });
            //chiamo il servizio esterno
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error Email',
                    message: 'Formato Email Sbagliato!',
                    variant: 'error',
                    });
                        this.dispatchEvent(evt);
            }
        }           
    }


    onClickSave(){
        console.log('passa2   ' + this.numDoc)
        // this.numDoc=this.onchangeNumDoc();
        console.log('passa3   ' + this.numDoc)
        console.log('numDoc      '+ this.numDoc)
        console.log('il valore è '+this.numDoc+'  quindi  ' +(this.numDoc !== undefined))
        if(this.numDoc !== undefined){
        saveNumDoc({record: this.recordId,numDoc:this.numDoc  }).then(()=>{
                console.log('entra nel salva e passa '+ this.recordId +'   '+ this.numDoc)
                const evt = new ShowToastEvent({
                    title: 'Numero Docuemento',
                    message: 'Numero Documento Salvato!',
                    variant: 'success',
                });
                    this.dispatchEvent(evt);
                refreshApex(this.refreshListaDatiContatto);
            });
        }
    }

    onClickCancel(event){
        const value = event.target.value;
        console.log(' close  ' + value  )
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        console.log(' close  ' + valueChangeEvent  )
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

}