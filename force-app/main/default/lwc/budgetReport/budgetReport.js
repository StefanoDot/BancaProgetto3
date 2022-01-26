import { LightningElement, api, wire, track } from 'lwc';
import budgetData from '@salesforce/apex/BP_BudgetReportPartner.BP_BudgetReportPartnerCalculateSum';
import budgetErogate from '@salesforce/apex/BP_BudgetReportPartner.BP_BudgetReportPartnerExistingImport';

export default class BudgetReport extends LightningElement {
    @track valueBudget = [];
    @track monthName = [];
    @track valueErogato = [];
    finalStringValue = '';
    finalErogatoValue = '';
    monthsString = '';
    
    resultGraphic(){
        budgetData().then(result => {
           console.log('Entra report bdg: ' + JSON.stringify(result));
           console.log('Entra report bdg: ' + result.Gennaio);
           let monthResult = result;
           for(const [key, value] of Object.entries(monthResult)) {

               this.monthName.push(key);
               this.valueBudget.push(value);
            console.log(`${key}: ${value}`);
          }
          console.log('monthName '+ this.monthName);
          console.log('valueBudget ' + this.valueBudget);
          console.log('finalStringValue ' + this.finalStringValue);
          this.finalStringValue = this.valueBudget.map(String);
          this.monthsString = this.monthName.map(String);
        }).catch(error => {
            console.log(error);
        });
    }
    
    resultGraphicErogato(){
        budgetErogate().then(result => { 
            console.log('Entra report erogato: ' + JSON.stringify(result));
            let monthResultErogato = result;
            for(const [key, value] of Object.entries(monthResultErogato)) {
                this.valueErogato.push(value);
                console.log('valueErogato ' + this.valueErogato);
            }
            this.finalErogatoValue = this.valueErogato.map(String);
            console.log('finalErogatoValue ' + this.finalErogatoValue);
        });    
    }

    connectedCallback(){
        this.resultGraphic();
        this.resultGraphicErogato();
    }

}