({
    doInit: function (component, event, helper) {
        console.log('* doInit *');
        console.log('calling checkCertificatoNotarileDocs')
        helper.checkCertificatoNotarileDocs(component, event, helper);
        helper.getAllFideContacts(component, event, helper);
        console.log('HAjde te marte dreqi---->');
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") 
        {
            var opportunity = component.get("v.record");
            console.log('opportunity ' + JSON.stringify(opportunity.fields));
            console.log('opportunity.Tipo_Linea_di_Credito__c---->'+opportunity.fields.Tipo_Linea_di_Credito__c.value);
            console.log('opportunity.accID---->'+opportunity.fields.AccountId.value);
            var action = component.get("c.isFirmatarioContact");
            action.setParams({
                oppId : opportunity.fields.Id.value,
                accountId : opportunity.fields.AccountId.value,
                tipoLineaCredito : opportunity.fields.Tipo_Linea_di_Credito__c.value,
            })
            action.setCallback(this, function(result){
                
                var allFirmaLst = [];
                var allFideLst = [];
                var state = result.getState();
                var noFirmatario = false;
				var allContactsList = [];
                var tempFirmaList = [];
                
                if (component.isValid() && state === "SUCCESS"){
                    var firmatarioConLst = result.getReturnValue();
                    
                 if(firmatarioConLst.length > 0)
                    {                        
                        for (var i=0; i < firmatarioConLst.length; i++) {
                            if((firmatarioConLst[i].contact.Firmatario__c && ! firmatarioConLst[i].isFidejussori) || (firmatarioConLst[i].contact.Firmatario__c && firmatarioConLst[i].isFidejussori && firmatarioConLst[i].contact.AccountId === opportunity.fields.AccountId.value))
                            {
                                if( ! tempFirmaList.includes(firmatarioConLst[i].contact.Id)){
                                    allFirmaLst.push(firmatarioConLst[i].contact);
                                    tempFirmaList.push(firmatarioConLst[i].contact.Id);
                                }
                            }
                            if(firmatarioConLst[i].isFidejussori)
                            {                                
                                allFideLst.push(firmatarioConLst[i].contact)
                            }
							allContactsList.push(firmatarioConLst[i].contact);
                        } 
                    }
						component.set("v.allContacts",allContactsList);

                        component.set("v.allFirmatarioContacts",allFirmaLst);
                        component.set("v.allFidejussoriContacts",allFideLst);
                        console.log('allFideLst---->'+allFideLst);
                        console.log('allFirmLst---->'+JSON.stringify(allFirmaLst));
                }
                });
                $A.enqueueAction(action);
            }
    },

    updatestage: function (component, event, helper) {
        console.log('* updatestage *');

        component.set("v.showLoadingSpinner", true);
        let button = event.getSource();
        button.set('v.disabled', true);
        component.set("v.butonof", true);
        let recordId = component.get("v.recordId");
        console.log('recordId butoni: ' + recordId);

        component.set("v.isOpen", true);


        let actionCheck = component.get('c.rissotemettere');
        actionCheck.setParams({
            "recordId": recordId
        })

        actionCheck.setCallback(component, function (response) {
            let toastEvent = $A.get("e.force:showToast");
            let mbylle = component.set("v.isOpen", false);
            let check = component.set("v.check", false);
            let responseValue = response.getReturnValue();
            console.log('response' + JSON.stringify(responseValue));

            if (responseValue.ok == true) {
                window.location.reload();
                console.log('po ktutruee ke');


            } else {
                console.log('po ktu ca ke');

                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Esiste un problemo",
                    "message": responseValue.responseMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }

            $A.get("e.force:refreshView").fire();

        });

        $A.enqueueAction(actionCheck);

    },

    onClickRissotomettereContratto: function (component, event, helper) {
        console.log('* onClickRissotomettereContratto 1,2,3,4,5*');
        console.log('* onClickRissotomettereContratto 1,2,3,4,5*',component);
        console.log('* onClickRissotomettereContratto 1,2,3,4,5*',event);
        console.log('* onClickRissotomettereContratto 1,2,3,4,5*',helper);
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"

        component.set("v.isOpen", true);
        component.set("v.switch", true);
    },

    onClickCampiMancanti: function (component, event, helper) {
        console.log(' onClickCampiMancanti ');

        component.set("v.showLoadingSpinner", true);
        component.set("v.isOpen1", true);
        component.set("v.switch", true);
        let recordId = component.get("v.recordId");
        console.log('recordId: ' + recordId);

        let actionCheck = component.get('c.checkCampiRichiedi');
        actionCheck.setParams({
            "oppId": recordId
        })

        actionCheck.setCallback(this, function (response) {
            let responseValue = response.getReturnValue();
            console.log('response' + JSON.stringify(responseValue));

            if (responseValue.ok === false) {
                component.set("v.message", responseValue.responseMessage);
                component.set("v.arerules", true);
            } else {
                component.set("v.arecheck", true);
            }
        });
        $A.enqueueAction(actionCheck);
    },

    onClickRichiediContratto: function (component, event, helper) {
        console.log('* onClickRichiediContratto *');

        let recordId = component.get("v.recordId");
        let record = component.get("v.record");
        var personaFiscaStat = component.get("v.allPersonaFisFieldChk");
        var personaGiurdicaStat = component.get("v.allPersonaGiuFieldChk");
        let certificatoNotarileDocsAreValid = component.get('v.certificatoNotarileDocsAreValid');
        const ntfLib = component.find('notifLib');
        const ntfSvc = component.find('notify');
        console.log('recordId: ' + recordId);
        console.log('record: ' + record);
        console.log('notificationSrc: ' + ntfLib);
        console.log('notificationSrc: ' + ntfSvc);
        console.log('certificatoNotarileDocsAreValid: ' + certificatoNotarileDocsAreValid);

       // if (certificatoNotarileDocsAreValid) {
            component.set("v.showLoadingSpinner", true);
            component.set("v.isOpen2", true);
            component.set("v.isOpen3", true);
            component.set("v.switch", true);

            let actionCheck = component.get('c.checkCambioStipula');
            actionCheck.setParams({
                "oppId": recordId
            })

            actionCheck.setCallback(this, function (response) {
                    let toastEvent = $A.get("e.force:showToast");
                    let mbylle = $A.get("e.force:closeQuickAction");
                    let responseValue = response.getReturnValue();

                    console.log('response' + JSON.stringify(responseValue));
					
                    if (responseValue.ok === false) {
                        if (responseValue.error === true) {

                            mbylle.fire();

                            toastEvent.setParams({
                                "mode": "sticky",
                                "title": "Per richedere il contratto occorre:",
                                "message": responseValue.responseMessage,
                                "type": "error"
                            });
                            toastEvent.fire();
                            component.set("v.isOpen3", false);

                        } else {
                            console.log('elsi fushave');

                            component.set("v.showLoadingSpinner", false);
                            component.set("v.title1", responseValue.title);
                            component.set("v.message1", responseValue.responseMessage);
                            component.set("v.areFields", true);
                            component.set("v.showFidejusoriBlock", true);
                        }
                    } else {
                        component.set("v.showLoadingSpinner", false);
                        if( personaFiscaStat || personaGiurdicaStat){
                            component.set("v.showFidejusoriBlock", true);
                        }
                        else{
                            if (responseValue.imediatelyManual === true) {
                                component.set("v.onlyManual", true);
                                component.set("v.isManuale", true);
                                component.set("v.title1", responseValue.title);
                                component.set("v.message1", responseValue.responseMessage);
                            } else {
                                component.set("v.secondWindow", false);
                                component.set("v.isDigitale", responseValue.error);
                                component.set("v.contact", responseValue.con);
                                component.set("v.title1", responseValue.title);
                                component.set("v.message1", responseValue.responseMessage);
                                
                                
                                let conditionsMap = [];
                                let responseMap = responseValue.condizioni;
                                console.log('responseMap' + JSON.stringify(responseMap));
                                
                                for (let key in responseMap) {
                                    conditionsMap.push({value: responseMap[key], key: key});
                                }
                                
                                console.log('conditionsMap' + JSON.stringify(conditionsMap));
                                component.set("v.myMap", conditionsMap);
                                
                            }
                        }
                    }
                }
            );
            $A.enqueueAction(actionCheck);
        
       // } else {
           // ntfSvc.error(ntfLib, 'Non è possibile avanzare l\'opportunità. È necessario convalidare il set documentale.', 'Validare il set Documentale');
       // }
    },

    digitalFirm: function (component, event, helper) {
        console.log('* digitalFirm *');

        component.set("v.secondWindow", true);
        component.set("v.isManuale", false);
        component.set("v.tipoFirma", 'Hai selezionato Firma Digitale.');

    },

    manualFirm: function (component, event, helper) {
        console.log('* manualFirm *');

        component.set("v.secondWindow", true);
        component.set("v.isManuale", true);
        component.set("v.tipoFirma", 'Hai selezionato Firma Manuale.');
    },

    yesButton: function (component, event, helper) {
        console.log('* yesButton *');

        let button = event.getSource();
        button.set('v.disabled', true);
        let recordId = component.get("v.recordId");
        let isManuale = component.get("v.isManuale");

        let actionCheck = component.get('c.decideTipoFirma');
        actionCheck.setParams({
            "recordId": recordId,
            "isManuale": isManuale
        })

        actionCheck.setCallback(component, function (response) {
            let responseValue = response.getReturnValue();
            let mbylle = $A.get("e.force:closeQuickAction");

            console.log('response' + responseValue);
            let toastEvent = $A.get("e.force:showToast");
            if (responseValue.ok == true) {
                mbylle.fire();
                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Success!",
                    "message": responseValue.responseMessage,
                    "type": "success"
                });
                toastEvent.fire();
                component.set("v.isOpen3", false);
                $A.get("e.force:refreshView").fire();

            }

            $A.get("e.force:refreshView").fire();


        });

        $A.enqueueAction(actionCheck);

    },


    navigateToRecord: function (component, event, helper) {
        console.log('* navigateToRecord *');

        let cont = component.get("v.contact");

        let navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            recordId: cont.Id,
            slideDevName: "detail"
        });
        navEvent.fire();
    },

    goBack1: function (component, event, helper) {
        console.log('* goBack1 *');

        component.set("v.secondWindow", false);
    },


    closeModel: function (component, event, helper) {
        console.log('* closeModel *');

        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
        component.set("v.isOpen1", false);
        component.set("v.isOpen2", false);
        component.set("v.isOpen3", false);

        $A.get("e.force:refreshView").fire();
    },

    goBack: function (component, event, helper) {
        console.log('* goBack *');

        component.set("v.isOpen", false);
        $A.get("e.force:refreshView").fire();
    },

})