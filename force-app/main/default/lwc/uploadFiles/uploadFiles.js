/**
 * Created by mocan on 23/06/2021.
 */

import {LightningElement, api} from "lwc";

export default class UploadFiles extends LightningElement {

    @api recordId;
    @api documentTypeId;
    @api isUploadDisabled;


    /** list of accepted formats for file upload **/
    get acceptedFormats() {
        return ['.pdf', '.png', '.xls', '.xlsx', '.zip','.p7m'];
    }

    /** After the file is successfully uploaded, sends an event
     with relevant information for the parent component **/
    handleUploadFinished(event) {
        let uploadedFile = event.detail.files;
        let fileName = event.detail.files[0].name;
        let fileId = uploadedFile[0].documentId;
        let documentTypeId = event.target.name;

        let uploadFinishedEvent = new CustomEvent("uploadfinished",
            {
                detail:
                    {
                        uploadedFile: uploadedFile,
                        fileName: fileName,
                        fileId: fileId,
                        documentTypeId: documentTypeId
                    }
            });

        this.dispatchEvent(uploadFinishedEvent);
    }

}