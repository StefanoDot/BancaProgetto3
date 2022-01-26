/* eslint-disable no-restricted-globals */
/* eslint-disable no-console */
/* eslint-disable no-undef */
import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDatiContact  from '@salesforce/apex/CertificaContattiController.getDatiContact';

export default class VerificaCodice extends LightningElement {
@api recordId;
@track listaDatiContatto;

    @wire (getDatiContact,{record: '$recordId' }) // recupero i dati dalla query del contatto
    listaContatto({data}){
        console.log('entra qui1  '+data);
        if(data){
            this.listaDatiContatto=JSON.parse(JSON.stringify(data));
            console.log('entra qui  '+ JSON.stringify(this.listaDatiContatto))
        }
    }

   onclickSendPhone(){}
   onclickSendEmail(){}

    onClickSend(){
        const evt = new ShowToastEvent({
            title: 'Verifica Codice',
            message: 'codice verificato!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    onClickSave(){}

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