import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityFields from '@salesforce/apex/BP_QR_Opportunity.getPriceValue';
import { getRecord } from 'lightning/uiRecordApi';
import OPPORTUNITY_PRICING_FIELD from '@salesforce/schema/Opportunity.Pricing__c';
import OPPORTUNITY_STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_Tipo_Linea_Di_Credito_FIELD from '@salesforce/schema/Opportunity.Tipo_Linea_di_Credito__c';
import { getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

export default class RecordPopUpMessages extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track valuePricing;
    @track wiredOppResult;
    @track currentUserProfile;
    @track stageOpty;
    @track productOpty;

    fields = OPPORTUNITY_PRICING_FIELD;

    @wire(getRecord, { recordId: USER_ID, fields: ['User.Profile.Name'] })
    UserProfile(result) {
        let data = result.data;
        this.currentUserProfile = getFieldValue(data, 'User.Profile.Name');
    };

    @wire(getRecord, { recordId: '$recordId', fields: OPPORTUNITY_STAGENAME_FIELD })
    grabStageOpty(result) {
        let data = result.data;
        this.stageOpty = getFieldValue(data, OPPORTUNITY_STAGENAME_FIELD);
    };

    @wire(getRecord, { recordId: '$recordId', fields: OPPORTUNITY_Tipo_Linea_Di_Credito_FIELD })
    grabProductOpty(result) {
        let data = result.data;
        this.productOpty = getFieldValue(data, OPPORTUNITY_Tipo_Linea_Di_Credito_FIELD);
        if(this.stageOpty == 'PEF Pre-Istruttoria' && this.productOpty == 'Crediti Fiscali')
        {
            const showWarning = new ShowToastEvent({
                title: 'Attenzione',
                message: 'Abbiamo preso in carico la richiesta, si prega di aggiornare la pagina fra qualche minuto.',
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(showWarning);
        }
    };

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord(result){
        console.log('Qui esegue il wire');
        
        let data = result.data;
        let error = result.error;
        
        let oldValue = this.wiredOppResult === undefined ? 0 : this.wiredOppResult;
        console.log('oldValue ' + oldValue);

        this.valuePricing = getFieldValue(data, OPPORTUNITY_PRICING_FIELD);
        console.log('valuePricing: ' + this.valuePricing);

        let profiloUtente = this.currentUserProfile;
        let currentStageOpty = this.stageOpty;

        if (data && oldValue != 0) { 
            if ((profiloUtente == 'Commerciale factoring CF' || profiloUtente == 'System Administrator') && currentStageOpty == 'Pre-Analisi e Pricing') {
                if (this.valuePricing != oldValue && this.valuePricing != undefined && this.valuePricing >= 95 && this.valuePricing <= 100) {
                    console.log('Mostra warning se il valore di pricing è tra 95 e 100');
                    const showWarning = new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Attenzione, Prezzo in deroga. Sei sicuro di voler procedere?',
                        variant: 'warning'
                    });
                    this.dispatchEvent(showWarning);
                }
            }
        }
        this.wiredOppResult = this.valuePricing;
    }
}