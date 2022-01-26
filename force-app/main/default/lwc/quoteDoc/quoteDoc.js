import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api,track,wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import updatePickVIS  from '@salesforce/apex/fileUploaderDAO.updatePickVIS';
import updatePick from '@salesforce/apex/fileUploaderDAO.updatePick';
import updareText from '@salesforce/apex/fileUploaderDAO.updateNote';
import updateFile  from '@salesforce/apex/fileUploaderDAO.updateFile';
import updateCheck from '@salesforce/apex/fileUploaderDAO.updateCheck';
import getRecordListDocumentAllQuote from '@salesforce/apex/fileUploaderDAO.getRecordListDocumentAllQuote';
import getDocumentToken from '@salesforce/apex/ElevaRestApiController.getDocumentToken';
import isVerificaInsideSalesVisible from '@salesforce/apex/fileUploaderDAO.isVerificaInsideSalesVisible';
import isComboboxDisabled from '@salesforce/apex/fileUploaderDAO.isComboboxDisabled';
import isComboboxContrato from '@salesforce/apex/fileUploaderDAO.isComboboxContrato';
import richiediNdg from '@salesforce/apex/fileUploaderDAO.richiediNdg';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPicklistValues from '@salesforce/apex/Utils.getPicklistValues';
import clickBttnNDG from '@salesforce/apex/fileUploaderDAO.clickBttnNDG';
import getQuoteList from '@salesforce/apex/fileUploaderDAO.getQuoteList';
import checkErogazioneServizi from '@salesforce/apex/fileUploaderDAO.checkErogazioneServizi';
import checkRecordTypeRO from '@salesforce/apex/fileUploaderDAO.checkRecordTypeRO';
import isSalesSupportEasyPlus from '@salesforce/apex/fileUploaderDAO.isSalesSupportEasyPlus';
import isSalesFidimed from '@salesforce/apex/fileUploaderDAO.isSalesFidimed';
import isFirma from '@salesforce/apex/fileUploaderDAO.isFirma';
import isVerificatoContrato from '@salesforce/apex/fileUploaderDAO.isVerificatoContrato';

export default class QuoteDoc extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track checkForState= false;
    @track recordListDocumentAllBlock = [];
    @track isVerInsSalesVisible=false;
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
    @track fileId;
    @track isModalOpen = false;
    @track completeUrl = '';
    @track selectedOption= '';
    @track defauldRecorType;
    @track options=[];
    @track messageNDG = '';
    @track docBlockName = '';
    @track noteVisbile= true;
    @track testNoteVisbile;
    @track salvabuttonhidden= true;
    @track labelComment = ' ';
    @track placeComment = ' ';
    @track isErogazioneServizi;
    @track isRecTypeRO;
    @track isDocEasyPlus=false;
    @track stopFidimed=false;
    @track isNotFidimed;
    @track fidimedAndErogazione;
    @track disableContrato=true;
    @track uploadContrato=true;
    @track comboContrato=true;
    @track testaldora='huu';

    refreshBlock;
    @track quoteAldora;


    @wire(getRecord, { recordId: '$recordId', fields: ['AccountId'] })
    record;

    @wire(getQuoteList,{
        record: '$recordId',
        objectApiName:'$objectApiName'
      }) quotes

    renderedCallback() {
        this.refreshApexAll()
    }

    @wire(getRecordListDocumentAllQuote,{
        record: '$recordId' , 
        objectApiName:'$objectApiName',
        block:'$docBlockName'  
    } ) 
    ButtonView({ error, data }, state){
        if(this.objectApiName != 'Quote' && this.objectApiName){
            this.checkForState=true;
        }
        state = (this.objectApiName == 'Opportunity' ) && state ? state : this.objectApiName
        if(data &&  state != 'Opportunity' ) {
        //   console.log('data',Array.isArray(data));
        //   console.log('data',data);
          this.refreshBlock = data;
          data = JSON.parse(JSON.stringify(data));
          for (const [key, value] of Object.entries(data)) {
            //   console.log(key)
                    //   console.log('EEEERRRRRRIIIII',value)         
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
                          wo['errorStoreDoc'];
                          wo['isContrato'];
                          console.log('midle', wo.DocumentTypeNameFormula__c)
                        if(i == 0) {
                            wo.titleCondition = true;
                        }

                        console.log('this.test ' + this.isRecTypeRO + ' ye shohim ' + wo.titleCondition);

                          if(wo.DocumentTypeNameFormula__c =='Modulo Richiesta Finanziamento'){
                              wo.boolViewModuloRichiesta=true;
                          }
                          if(wo.Errore_Store_Document__c!=null){
                            wo.errorStoreDoc=wo.Errore_Store_Document__c;
                        }
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

                  if(wo.IDTipoDocumentoFormula__c == 'SME_100'){
                    wo.isContrato=true;

              }
                      });

                    this.recordListDocumentAllBlock.push(value);
          }
  
        } else if (error) {
          console.log('error',error);
        }      
    }

    getQuoteDoc(event) {
        // console.log('recordId',this.recordId)
        // console.log('objectApiName', this.objectApiName)
        // console.log('docList', this.docList)
        // console.log('event', event.target.value)
        // console.log('docBlockName',JSON.stringify(this.docBlockName))
        if(event.target.value) {
            this.quoteAldora=event.target.value;
            getRecordListDocumentAllQuote({
                record: this.recordId , 
                objectApiName:this.objectApiName,
                block:this.docBlockName,
                selectedCont: event.target.value,
            }).then(response => {
                console.log('responseeeee',response)
                
                this.test();
                this.recordListDocumentAllBlock = []
                this.ButtonView({error: undefined, data: response}, true)
                this.refreshApexAll()
                
                // console.log('this.recordListDocumentAllBlockA',this.recordListDocumentAllBlockA)
            })
        }  
    }

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
  
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.messageNDG = '';
        this.isModalOpen = false;
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
            message: 'Notifica inviata a inside sales territoriale ',
            variant: 'success',
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
          //  alert("No. of files uploaded : " + uploadedFile.length);
            // console.log('testQuery e   '+JSON.stringify(this.recordDocument))
            // console.log('get chiama query   '+this.testQuery.data.fields.Account.value.fields.Name.value)
            // console.log('testIndex   '+JSON.stringify(this.recordDocument))
            if(uploadedFile.length>0){
            this.value=event.detail.files[0].name;
            this.valueId=event.target.name;
            this.fileId=uploadedFile[0].documentId;
            var theFile = event.detail.files[0];
          /*  var reader = new FileReader();
            reader.onloadend = function(event){
                console.log("loaded");
            }
            reader.readAsArrayBuffer(theFile);
            console.log("result "+reader.result);*/
            updateFile({recordUpdateId: this.valueId,fileName:this.value,fileId: this.fileId}).then( resultApex => {
                    console.log('*** *** *** UPDATE FILE THEN '+resultApex);
            //     refreshApex(this.refreshBlockA);
            //     refreshApex(this.refreshBlockB);
            //     refreshApex(this.refreshBlockC);
            //     refreshApex(this.refreshBlockD);
            //     refreshApex(this.refreshBlockE);
            //     refreshApex(this.refreshBlockF);
            //     refreshApex(this.refreshBlockG);
            //     refreshApex(this.refreshBlockH);                      
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
       console.log('note',this.note)
       for(let up of this.note){
           if (up.name==this.nameId){
            var commentoSalesSupport =up.value;
           }
           
       }
       console.log('recordUpdateId',recordUpdateId,'commentoSalesSupport',commentoSalesSupport)
        updareText({recordUpdateId: recordUpdateId,commentoSalesSupport:commentoSalesSupport});
        console.log('query test     '+this.template.querySelector('[data-id="' +this.nameId +'"]') )
       this.template.querySelector('[data-id="' +this.nameId +'"]').style.visibility='hidden';
        this.template.querySelector('[data-id="' +this.nameId +'"]').style.display='none';
  
    }

    getNDG(event) {
        console.log('RICHIEDI NDG');
        console.log('RECORD ID '+this.recordId);
        richiediNdg({oppId: this.recordId}).then( resultApex => {
            console.log('RICHIEDI NDG '+resultApex);
            if(resultApex == 'False'){
                this.messageNDG = "L'anagrafica non è completa"
            } else {
                this.closeModal();
            }
        } );

    }
    //checks Anagrafica_Completa__c
    checkAnagComp() {
        console.log('checkAnagComp');
        console.log('RECORD ID '+this.recordId);
        clickBttnNDG({oppId: this.recordId}).then(results => {
            console.log('RECORD results '+results);
            if(results == false){
                this.messageNDG = "Impossibile richiedere NDG causa dati Cedacri Mancanti, Contattare il Sales Support."           
            } 
            this.openModal();
        })
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

        isComboboxContrato({}).then( resultApex => {
            console.log('IS DISABLED? '+resultApex);
            if(resultApex == true){
                this.comboContrato = true;
               // this.template.querySelectorAll('lightning-combobox').addAttribute('disabled');
            } else {
                this.comboContrato = false;
              //  this.template.querySelectorAll('lightning-combobox').removeAttribute('disabled');
            }
        } );
    
    checkErogazioneServizi({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('erogazionii '+resultApex);
            this.isErogazioneServizi = resultApex;
    });

    checkRecordTypeRO({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('recType '+resultApex);
        if(resultApex == true){
        this.isRecTypeRO = true;
        this.testNoteVisbile= true;

        console.log('this.noteVisbile eeeeeeeeeeee ' + this.noteVisbile);
        } else {
            this.isRecTypeRO = false;
            this.testNoteVisbile=this.noteVisbile;
        }
    });

    isSalesSupportEasyPlus({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('isProfileFidimed '+resultApex);
        
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

    console.log('FIRMAAAAA  this.recordId: ' +  this.recordId + ' this.objectApiName: ' + this.objectApiName);
    isFirma({recordId: this.recordId, objectApiName: this.objectApiName}).then( resultApex => {
        console.log('isFirma '+resultApex);
        if(resultApex == true){
            this.disableContrato=false;
        } else {
            this.disableContrato=true;
        } 
    });

    if(this.objectApiName=='Quote'){
        console.log('aaao ');
    isVerificatoContrato({recordId: this.recordId, objectApiName: this.objectApiName,  quoteId: this.quoteAldora}).then( resultApex => {
        console.log('isFirma Aldora '+resultApex);
        console.log('testtttttttttttttttttttttt ' + this.quoteAldora);
        if(resultApex == true){
            this.uploadContrato=false;
        } else {
            this.uploadContrato=true;
        } 
    });
}
}

test(){
    isVerificatoContrato({recordId: this.recordId, objectApiName: this.objectApiName,  quoteId: this.quoteAldora}).then( resultApex => {
        console.log('isFirma '+resultApex);
        console.log('testtttttttttttttttttttttt ' + this.quoteAldora);
        if(resultApex == true){
            this.uploadContrato=false;
        } else {
            this.uploadContrato=true;
        } 
    });
}


}