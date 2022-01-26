/**
 * Created by albi on 20/04/2019.
 */
({
    onInit: function(cmp, evt, helper){

        //init file types
        let fileTypes = cmp.get("v.acceptLightningPageBuilderInput");
        cmp.set("v.accept", fileTypes.split(';').map(function(x){return x.trim()}));

         //init opportunity fields to query
         //inserire tutti i campi che vanno letti da opportunità (solo le checkbox)
        cmp.set("v.fieldsOpp", [cmp.get("v.oppMultipicklistApiName"),
            'Id','AccountId','Societ_Appartiene_a_Gruppo__c','X01_Richiesta_di_Finanziamento__c',
            'X02_Doc_CF_Legale_Rappr_Procuratore__c','X03_Doc_CF_Legale_Titolare_Effettivo__c',
            'X04_Privacy__c','X06_Fideiussione_Persona_Fisica__c','X07_Fideiussione_Persona_Giuridica__c',
            'X05_Allegato_4_Garanzia_Diretta__c','X08_Ultimi_due_Bilanci__c','X09_Quadro_Affidamenti_Bancari__c',
            'X10_Moduli_5_Clienti_5_Fornitori__c','X11_Proposta_Commerciale__c','X12_Relazione_di_Visita__c',
            'X13_Atto_Costitutivo__c','X14_Statuto_Vigente_della_Societ__c', 'Necessaria_Fideiussione__c', 'StageName']);

         cmp.set("v.loadOpp", true);

         let loadOpp = cmp.get("v.loadOpp");
                 console.log('LOAD OPP '+loadOpp);

        //init account fields to query
        /*cmp.set("v.fieldsAcc", [cmp.get("v.accMultipicklistApiName"),
            'Richiesta_Finanziamento__c','Adeguata_Verifica__c','Titolare_Effettivo__c',
            'Classificazione_Trasparenza__c','Doc_CF_Legale_Rappresentante_Procuratore__c','Doc_CF_Legale_Titolare_Effettivo__c',
            'Privacy__c','Privacy_Marketing__c','Privacy_Eventi__c','Privacy_Informato__c','Data_Adempimenti_Normativi__c']);
        */
        //set userId
        cmp.set("v.userId", $A.get("$SObjectType.CurrentUser.Id" ));
    },


    recalculateMultipicklists: function(cmp){
        //SETTING MULTIPICKLIST-DEPENDENT ATTRIBUTES - ACCOUNT
        let multipickFieldName = cmp.get("v.accMultipicklistApiName");
        let multipicklist = cmp.get("v.simpleRecordAcc." + multipickFieldName); //<-set multipicklist once available
        if(multipicklist){
            multipicklist.split(';').forEach(function(x){
               cmp.set("v." + x, true);
               console.log(x);
               console.log(cmp.get("v." + x));
            });
        }
        console.log(cmp.get("v.simpleRecordAcc." + multipickFieldName));

        //SETTING MULTIPICKLIST-DEPENDENT ATTRIBUTES - OPPORTUNITY
        multipickFieldName = cmp.get("v.oppMultipicklistApiName");
        multipicklist = cmp.get("v.simpleRecordOpp." + multipickFieldName); //<-set multipicklist once available
        if(multipicklist){
            multipicklist.split(';').forEach(function(x){
               cmp.set("v." + x, true);
               console.log(x);
               console.log(cmp.get("v." + x));
            });
        }
        console.log(cmp.get("v.simpleRecordOpp." + multipickFieldName));
    },

    handleUploadFinished: function(cmp, evt, helper){

        let simpleOpp = cmp.get("v.simpleRecordOpp.StageName");
                console.log('SIMPLE RECORD OPP '+JSON.stringify(simpleOpp));

        let fieldsOpp = cmp.get("v.fieldsOpp.StageName");
                console.log('FIELDS OPP '+JSON.stringify(fieldsOpp));

        let opp = cmp.get("v.simpleRecordOpp");
        //let acc = cmp.get("v.simpleRecordAcc");

        let documentType = evt.getSource().getLocalId();

        let oppHasChanged = false;
        //let accHasChanged = false;

        switch(documentType){
            /*
            case 'RichiestaFinanziamento':
                acc.Richiesta_Finanziamento__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'Adeguataverifica':
                acc.Adeguata_Verifica__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'TitolareEffettivo':
                acc.Titolare_Effettivo__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'ClassificazioneTrasparenza':
                acc.Classificazione_Trasparenza__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'DocCFLegaleRappresentanteProcuratore':
                acc.Doc_CF_Legale_Rappresentante_Procuratore__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'DocCFLegaleTitolareEffettivo':
                acc.Doc_CF_Legale_Titolare_Effettivo__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'Privacy':
                acc.Privacy__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'PrivacyMarketing':
                acc.Privacy_Marketing__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'PrivacyEventi':
                acc.Privacy_Eventi__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            case 'PrivacyInformato':
                acc.Privacy_Informato__c = true;
                acc.Data_Adempimenti_Normativi__c = new Date();
                accHasChanged = true;
                break;
            */
            case 'RichiestaFinanziamento':
                opp.X01_Richiesta_di_Finanziamento__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'DocCFLegaleRappresentanteProcuratore':
                opp.X02_Doc_CF_Legale_Rappr_Procuratore__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'DocCFLegaleTitolareEffettivo':
                opp.X03_Doc_CF_Legale_Titolare_Effettivo__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'Privacy':
                opp.X04_Privacy__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'FidPFDocument':
                opp.X06_Fideiussione_Persona_Fisica__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'FidPGDocument':
                opp.X07_Fideiussione_Persona_Giuridica__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'GenericDocument':
                opp.X05_Allegato_4_Garanzia_Diretta__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'LastTwoB':
                opp.X09_Quadro_Affidamenti_Bancari__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'QuadroAffidamBancari':
                opp.X09_Quadro_Affidamenti_Bancari__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'ModuliPrincipali':
                opp.X10_Moduli_5_Clienti_5_Fornitori__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'PropostaCommerciale':
                opp.X11_Proposta_Commerciale__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'RelazioneDiVisita':
                opp.X12_Relazione_di_Visita__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'AttoCostitutivo':
                opp.X13_Atto_Costitutivo__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;
            case 'StatutoVigente':
                opp.X14_Statuto_Vigente_della_Societ__c = true;
                //TODO campo Data qual è?
                oppHasChanged = true;
                break;

            default:
                let idParts =  documentType.split('-$-');
                console.log('idParts', idParts);
                let isAccount = idParts[0] === 'acc';
                let picklistValue = idParts[1];

                if(isAccount){
                    let multipickFieldName = cmp.get("v.accMultipicklistApiName");
                    let multipicklist = acc[multipickFieldName] ? acc[multipickFieldName].split(';') : [];
                    if(!multipicklist.includes(picklistValue)){
                        multipicklist.push(picklistValue);
                        acc[multipickFieldName] = multipicklist.join(';');
                        accHasChanged = true;
                    }
                }
                else{
                    let multipickFieldName = cmp.get("v.oppMultipicklistApiName");
                    let multipicklist = opp[multipickFieldName] ? opp[multipickFieldName].split(';') : [];
                    if(!multipicklist.includes(picklistValue)){
                        multipicklist.push(picklistValue);
                        opp[multipickFieldName] = multipicklist.join(';');
                        oppHasChanged = true;
                    }
                }
        }

        if(oppHasChanged){
            cmp.set("v.simpleRecordOpp", opp);
            this.handleSaveRecord(cmp, helper, 'recordHandlerOpp');
        }
        if(accHasChanged){
            cmp.set("v.simpleRecordAcc", acc);
            this.handleSaveRecord(cmp, helper, 'recordHandlerAcc');
        }

    },


        handleSaveRecord: function(cmp, helper, recordDataId) {
        cmp.find(recordDataId).saveRecord($A.getCallback(function(saveResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated evt handler)
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log(JSON.stringify(saveResult));
                cmp.find(recordDataId).reloadRecord(true);
                //helper.recalculateMultipicklists(cmp);
                // handle cmp related logic in evt handler
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));

    },

    recordUpdated : function(cmp, evt, helper) {
        var changeType = evt.getParams().changeType;

        let recordDataId = evt.getSource().getLocalId();

        console.log(recordDataId);

        if (changeType === "ERROR") {
            console.log('record updated - error', JSON.stringify(evt.getParams()));
            console.log(cmp.get("v.error"));
            }
        else if (changeType === "LOADED") { /* handle record load */
            console.log('record updated - loaded', JSON.stringify(evt.getParams()));
            //cmp.find(recordDataId).reloadRecord(true);
            helper.recalculateMultipicklists(cmp);

        }
        else if (changeType === "REMOVED") { /* handle record removal */
            console.log('record updated - removed', JSON.stringify(evt.getParams()));
        }
        else if (changeType === "CHANGED") {
            console.log('record updated - changed', JSON.stringify(evt.getParams()));
          /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */
          cmp.find(recordDataId).reloadRecord(true);
        }
    }
})