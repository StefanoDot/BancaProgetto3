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
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api,track,wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import updatePickVIS  from '@salesforce/apex/fileUploaderDAO.updatePickVIS';
import updatePick from '@salesforce/apex/fileUploaderDAO.updatePick';
import updareText from '@salesforce/apex/fileUploaderDAO.updateNote';
import updateFile  from '@salesforce/apex/fileUploaderDAO.updateFile';
import updateCheck from '@salesforce/apex/fileUploaderDAO.updateCheck';
import getRecordListDocumentAll from '@salesforce/apex/fileUploaderDAO.getRecordListDocumentAll';
import getDocumentToken from '@salesforce/apex/ElevaRestApiController.getDocumentToken';
import isVerificaInsideSalesVisible from '@salesforce/apex/fileUploaderDAO.isVerificaInsideSalesVisible';
import isComboboxDisabled from '@salesforce/apex/fileUploaderDAO.isComboboxDisabled';
import richiediNdg from '@salesforce/apex/fileUploaderDAO.richiediNdg';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPicklistValues from '@salesforce/apex/Utils.getPicklistValues';
import clickBttnNDG from '@salesforce/apex/fileUploaderDAO.clickBttnNDG';
import isVisibleNotificaInsideSalesToritorial from '@salesforce/apex/fileUploaderDAO.isVisibleNotificaInsideSalesToritorial';
import switchSystems from '@salesforce/apex/Utils.switchSystems';
import checkErogazioneServizi from '@salesforce/apex/fileUploaderDAO.checkErogazioneServizi';
import checkRecordTypeRO from '@salesforce/apex/fileUploaderDAO.checkRecordTypeRO';
import isSalesSupportEasyPlus from '@salesforce/apex/fileUploaderDAO.isSalesSupportEasyPlus';
import isSalesFidimed from '@salesforce/apex/fileUploaderDAO.isSalesFidimed';


const optionsContrattoFirmato = [
    {label: '', value: 'option1'}
]

export default class MyComponentName extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track recordListDocumentAllBlock = [];
    @track recordListDocumentAllBlockA;
    @track recordListDocumentAllBlockB;
    @track recordListDocumentAllBlockC;
    @track recordListDocumentAllBlockD;
    @track recordListDocumentAllBlockE;
    @track recordListDocumentAllBlockF;
    @track recordListDocumentAllBlockG;
    @track recordListDocumentAllBlockH;
    @track recordListDocumentAllBlockI;
    @track recordListDocumentAllBlockL;
    @track boolViewA=false;
    @track boolViewB=false;
    @track boolViewC=false;
    @track boolViewD=false;
    @track boolViewE=false;
    @track boolViewF=false;
    @track boolViewG=false;
    @track boolViewH=false;
    @track boolViewI=false;
    @track boolViewL=false;
    @track boolButton=false;
    @track isVerInsSalesVisible=false;
    @track isNotificaTeritorial=false;
    @track noteVisbile= true;
    @track aprovaVisibile = false;
    @track salvabuttonhidden= true;
    @track labelComment = ' ';
    @track placeComment = ' ';

    @track isCombBoxDis=false;
    @track numeroStage;
    @track value;
    @track valueCheck=[];
    @track uppRecordList;
    @track valueId;
    @track note;
    @track nameId;
    @track valoreFieldsUrl;
    @track esitoDocumento;
    @track test='a1P1w000000aoyo';
    @track fileId;
    @track isModalOpen = false;
    @track aprovaVisbile = false;
    @track completeUrl = '';
    @track selectedOption= '';
    @track defauldRecorType;
    @track options=[];
    @track messageNDG = '';
    @track docBlockName = '';
    @track rerenderCpm = false;
    @track isErogazioneServizi;
    @track isRecTypeRO;
    @track isDocEasyPlus=false;
    @track stopFidimed=false;
    @track isNotFidimed;
    @track fidimedAndErogazione;
    @track disableRichiedi=false;	
    @track showLoadingSpinner;
  

    firstStage = 'Primo Contatto';
    refreshBlock;

    //@api obj_name_opp = 'Opportunity'

    @wire(getRecord, { recordId: '$recordId', fields: ['AccountId'] })
  record;

  @wire(getRecordListDocumentAll,{
    record: '$recordId' , 
    block:'$docBlockName'  
} ) 
ButtonView({ error, data }){
    if(data) {
      console.log('data',Array.isArray(data));
      console.log('data',data);
      this.refreshBlock = data;
      data = JSON.parse(JSON.stringify(data));
      for (const [key, value] of Object.entries(data)) {
          console.log(key)
                  console.log('EEEERRRRRRIIIII',value)         
                  value.forEach((wo, i)=> {

                      wo["boolPrimoContatto"] ;
                      wo["boolPrimaVisita"] ;
                      wo["boolDeliberata"] ;
                      wo['boolViewModuloRichiesta'];
                      wo['boolUrlApproval'];
                      wo['boolUrlStandBy'];
                      wo['boolLoading'];
                      wo['boolServizi'];
                      wo['isDocEasyPlus'];

                      console.log('midle', wo.DocumentTypeNameFormula__c)
                    if(i == 0) {
                        wo.titleCondition = true;
                    }


                      if(wo.DocumentTypeNameFormula__c =='Modulo Richiesta Finanziamento'){
                          wo.boolViewModuloRichiesta=true;
                      }

                      console.log('serviziiii', wo.DocumentType__r.Erogazione_Servizi__c)
                      if(wo.DocumentType__r.Erogazione_Servizi__c ==true){
                        wo.boolServizi=true;
                    }

                     if(wo.DocumentType__r.visibileaPartner__c==false){
                        wo.isDocEasyPlus=true;
                    }
          
          
                      if(wo.Url_Documento__c != null){
                            wo.boolUrlApproval=true;
                            wo.boolUrlStandBy=false;
                            wo.boolLoading=false;
                      }else if((wo.Url_Servizio_Esterno__c != null) && (wo.Url_Documento__c == undefined) && (wo.Errore_Store_Document__c != null)){
                            wo.boolUrlStandBy=true;
                            wo.boolUrlApproval=false;
                            wo.boolLoading=false;       
                      }
                      else if((wo.Url_Servizio_Esterno__c != null) && (wo.Url_Documento__c == undefined) && (wo.Errore_Store_Document__c == null)){
                        wo.boolLoading=true;
                        wo.boolUrlStandBy=false;
                        wo.boolUrlApproval=false;       
                  }
                  });
                //   console.log('TESTSKEY',key)
                console.log('TESTS',value)

                this.recordListDocumentAllBlock.push(value);
                console.log('this.recordListDocumentAllBlock',JSON.stringify(this.recordListDocumentAllBlock))
                //  this.checkcrecordListDocumentAllBlocVal(key,value)
      }

    } else if (error) {
      console.log('error',error);
    }      
}

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

  openModal() {
    this.isModalOpen = true;
}
closeModal() {
    this.messageNDG = '';
    this.isModalOpen = false;
} 

getNDG(event) {
    this.disableRichiedi=true;
    this.showLoadingSpinner=true;
    console.log('sa here vjen')
    richiediNdg({oppId: this.recordId}).then( resultApex => {
        const evt = new ShowToastEvent({
            
            title: 'Success',
            message: resultApex,
            variant: 'success',
            mode: 'sticky',
        });
        this.showLoadingSpinner=false; 
        this.closeModal();
        this.dispatchEvent(evt);       
    } );
}

    handleChange(event) {//picklist verifica sales support
        this.value=event.detail.value;
        this.valueId=event.target.name;
        console.log('event.......'+event+'value.....'+this.value +'valueId....'+this.valueId);
        updatePick({recordUpdateId: this.valueId,verificaSalesSupport:this.value});
        this.refreshApexAll();
        // .then( () => {
        //     this.refreshApexAll();
        // });
    }
    openDocument(event){
        console.log('---- OPEN DOCUMENT ----');
        console.log('event.target.name '+event.target.name);
        this.completeUrl = event.target.name;
        getDocumentToken({}).then( resultApex2 => {
            console.log('GET TOKEN '+resultApex2);
            var docUrl = this.completeUrl + resultApex2;
            var trimmedDocToken = resultApex2.slice(1,-1);
            var trimmedDocUrl = this.completeUrl + '?token=' + trimmedDocToken;
            console.log('TRIMMED DOC URL '+trimmedDocUrl);
            window.open(trimmedDocUrl, "_blank");
        } );
    }

 //   get valueUrl(){return this.value;}
    
    handleChange2(event) {//button notifica
            
           this.valueCheck = true;
            this.valueId=event.target.name;
        //    updateCheck({recordUpdateId: this.valueId,checkBok:this.valueCheck}).then( () => {
        //     console.log('entra nel then')
        //     refreshApex(this.refreshBlockA);
            
        //    });


           updateCheck({recordUpdateId: this.valueId,checkBok:this.valueCheck}).then( () => {
            
           const evt = new ShowToastEvent({
               
            title: 'Success',
            message: 'Notifica inviata a Inside Sales Territoriale ',
            variant: 'success',
            mode: 'sticky',
        });
        this.dispatchEvent(evt);
    });
    }
           
    refreshApexAll(){
        refreshApex(this.refreshBlock);
    }
    
     handleUploadFinished(event) {// button invio file e salva file
            // Get the list of uploaded files
            const uploadedFile = event.detail.files;
            var documentId  = uploadedFile[0].documentId; 
     
            if(uploadedFile.length>0){
            this.value=event.detail.files[0].name;
            this.valueId=event.target.name;
            this.fileId=uploadedFile[0].documentId;
            var theFile = event.detail.files[0];
           
            updateFile({recordUpdateId: this.valueId,fileName:this.value,fileId: this.fileId}).then( resultApex => {
                    console.log('*** *** *** UPDATE FILE THEN '+resultApex);
                           
                    this.refreshApexAll();
                });
            
           
            }
    
    
    }
    
    handleChangeVIS(event) {//picklist verifica inside sales
        this.value=event.detail.value;
        this.valueId=event.target.name;
        console.log('value è     '+ this.value);
        console.log('value è     '+ this.valueId);
        updatePickVIS({recordUpdateId: this.valueId,verificaInsideSales:this.value});
        // .then( () => {
        //     refreshApex(this.refreshBlockA);
        // });
    }
    
    onchangeButton(event){
        console.log('entra onchange')
        this.nameId=event.target.name;
        console.log('nameId    '+ this.nameId)
        console.log('doc.getElem    '+ this.template.querySelector('[data-id="' +this.nameId +'"]'))
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.visibility='visible';
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.display='inline';
        
        
    }
   

   
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
        console.log('query test     '+this.template.querySelector('[data-id="' +this.nameId +'"]') )
       this.template.querySelector('[data-id="' +this.nameId +'"]').style.visibility='hidden';
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.display='none';
  
    }


    //checks Anagrafica_Completa__c
    checkAnagComp() {
        console.log('checkAnagComp');
        console.log('RECORD ID '+this.recordId);
        clickBttnNDG({oppId: this.recordId}).then(results => {
            console.log('RECORD results '+results);
            
                this.messageNDG = results           
            
            this.openModal();
        })
    }

    renderedCallback(){
        // this.refreshApexAll();
    }

    get acceptedFormats() {
        return ['.pdf', '.png','.xls', '.xlsx', '.p7m'];
    }

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


connectedCallback(){
    console.log('CONNECTED CALLBACK');
    isVerificaInsideSalesVisible({}).then( resultApex => {
        console.log('IS VISIBLE? '+resultApex);
        this.isVerInsSalesVisible = resultApex;
        if(resultApex == true){
            this.noteVisbile= false;
            this.salvabuttonhidden=false;
            this.labelComment = 'Inserire nota supplementare, max 500 caratteri.';
            this.placeComment = 'type here...';
        }
      else{
          this.labelComment = 'Nota del Sales Support.';
          this.placeComment = ' ';
      }
    } );

   isVisibleNotificaInsideSalesToritorial({}).then( resultApex => {
        console.log('IS VISIBLE? '+resultApex);
        this.isNotificaTeritorial = resultApex;
    } ); 


    isComboboxDisabled({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('IS DISABLED? '+resultApex);
        if(resultApex == true){
            this.isComboboxDisabled = true;
           // this.template.querySelectorAll('lightning-combobox').addAttribute('disabled');
        } else {
            this.isComboboxDisabled = false;
          //  this.template.querySelectorAll('lightning-combobox').removeAttribute('disabled');
        }
    } );

    switchSystems({}).then( resultApex => {
        console.log('switchhh '+resultApex);
        if(resultApex == true){
            this.aprovaVisibile = false;
        } else {
            this.aprovaVisibile = true;
        }
    });

    checkErogazioneServizi({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('erogazionii '+resultApex);
            this.isErogazioneServizi = resultApex;
    });

    checkRecordTypeRO({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('recType '+resultApex);
        if(resultApex == true){
            this.isRecTypeRO = true;
            this.noteVisbile = true;
        } else {
            this.isRecTypeRO = false;
        }
    });

    isSalesSupportEasyPlus({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('isSalesSupportEasyPlus '+resultApex);
        
            this.stopFidimed = resultApex;
    });

    isSalesFidimed({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('isSalesFidimed '+resultApex);
        if(resultApex == true){
            this.isNotFidimed = true;
        this.fidimedAndErogazione= true;
        } else {
            this.isNotFidimed = false;
            this.fidimedAndErogazione=this.isErogazioneServizi;
        } 
    });

}

}