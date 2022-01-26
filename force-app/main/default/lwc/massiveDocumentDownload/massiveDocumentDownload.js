/**
 * Created by mocan on 26/08/2021.
 */

import {LightningElement, api, track, wire} from 'lwc';
import getDocumentTokenFromEleva from '@salesforce/apex/BP_LC_DownloadMassivoController.getDocumentTokenFromEleva';
import getContactListForDownloadMassivo from '@salesforce/apex/BP_LC_DownloadMassivoController.getContactListForDownloadMassivo';


export default class MassiveDocumentDownload extends LightningElement {
    @api recordId;
    @api accountId;

    @track contactList;

    isDisabled = false
    connectionString = 'https://bancaprogetto.documentale.online/ar/documents/massiveDownload?filter=';

    //wire that gets all the contacts of that opportunity or account
    @wire(getContactListForDownloadMassivo,{
        accountId: '$accountId'
    }) contacts ({error, data}) {
        if (data) {
            this.contactList = data;
        } else if (error) {
            console.log('Error Retrieving Contacts');
        }
    }

    navigateToUrl() {
        console.log('* navigateToUrl *');
        console.log('contact  '+this.contactList);
        console.log('contact  '+this.accountId);
        console.log('contact  '+this.recordId);
        let filter = {
            filter : {
                Id_Referente_Salesforce: this.contactList,
                Id_Anagrafica_Salesforce: [this.accountId],
                Id_Opportunita_Salesforce: [this.recordId]
            }
        }
        let escapedFilter = escape(JSON.stringify(filter));
        let completedUrl = this.connectionString + escapedFilter;
        console.log('completedUrl  ');
        console.log('completedUrl = ' + JSON.stringify(completedUrl));
        getDocumentTokenFromEleva().then(result => {
            let trimmedDocToken = result.slice(1, -1);
            let trimmedDocUrl = completedUrl + "&TOKEN=" + trimmedDocToken;
            console.log('token  '+trimmedDocToken);
            window.open(trimmedDocUrl, "_blank");
        })
    }
}