/* eslint-disable no-class-assign */
/* eslint-disable no-labels */
/* eslint-disable no-console */
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
import { refreshApex } from '@salesforce/apex';
import { LightningElement,api,wire,track } from 'lwc';
import getListaReferentiFirmatari  from '@salesforce/apex/FirmaDigitaleHandler.getListaReferentiFirmatari';
import getViewDati  from '@salesforce/apex/FirmaDigitaleHandler.getViewDati';

import {NavigationMixin} from 'lightning/navigation';
import MyComponentName from 'c/fileUploaderTest';




export default class FirmaDigitale extends LightningElement {

@api recordId;

@track listaReferentiFirmatari;
@track Idvalue;
@track Label;
@track valueOp;
@track value="Seleziona Referente";
@track accountId;
@track datiref;
// @track result;
refreshDatiReferente;

    @wire (getListaReferentiFirmatari,{record: '$recordId' }) // recupero i dati dalla query dei contatti referenti firmatari
    listaReferenti({data}){
        console.log('entra qui1  '+data);
        if(data){
            this.listaReferentiFirmatari=JSON.parse(JSON.stringify(data));
            console.log('entra qui  '+ JSON.stringify(this.listaReferentiFirmatari))
        }
    }




    get options() {  //popolo i menu a tendina con i vati referenti firmatari
        var arr =[];
        for (let i in this.listaReferentiFirmatari) { 
            console.log('passsa  '+ i)
        
         this.Label=this.listaReferentiFirmatari[i].Name;
         
         this.Idvalue=this.listaReferentiFirmatari[i].Id;
         
                console.log('passsa   '+ this.Label + '    '+ this.valueOp +   '     '+ this.Idvalue)
                
                arr.push({label: this.Label, value: this.Idvalue },);
                                console.log('passsa'+ JSON.stringify(arr))
                
            }
            
          return arr;
    
    }

    handleChange(event){ // filtro i dati a secondo del options selezionato

        var IdAccount= event.detail.value;
console.log('event.detail    '+ JSON.stringify(event.detail))
    
        console.log('accountID è     '+ IdAccount);
        getViewDati({accountId: IdAccount }).then(result => {  //chiamo metod apex e successivamente faccio il refresh dei dati dell apex/wire
            console.log('entra e prende    '+ result)
            this.datiref = result;})
        refreshApex(this.refreshDatiReferente);

    
    }


    onClickCancel(event){  //button cancel chiudo la finestra
        const value = event.target.value;
        console.log(' close  ' + value  )
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        console.log(' close  ' + valueChangeEvent  )
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
      }
    



    renderedCallback(){
        console.log('prende l id?'    + this.recordId);
        
    }
    connectedCallback(){
        console.log('prende l id?'    + this.recordId);
    }
}