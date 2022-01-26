({
    checkCertificatoNotarileDocs: function(component, event, helper) {
        console.log('* checkCertificatoNotarileDocsssss *');
        let oppId = component.get("v.recordId");
        let checkCertificatoNotarileDocs = component.get('c.getCertificatoNotarileDocs');
        
        checkCertificatoNotarileDocs.setParams({
            "oppId": oppId
        })
        
        checkCertificatoNotarileDocs.setCallback(this, function (response) {
            console.log('response = ' + response);
            console.log('response.getState() = ' + response.getState());
            if (response.getState() === 'SUCCESS') {
                component.set('v.certificatoNotarileDocsAreValid', response.getReturnValue());
            } else {
                console.log('error');
            }
        });
        
        $A.enqueueAction(checkCertificatoNotarileDocs);
    },
    
    showNotification: function (sourceComponent, variant, message, sticky) {
        const mode = sticky ? 'sticky' : 'dismissable';
        let eventDetails = {
            title: labels[variant],
            message: message,
            variant: variant,
            mode: mode
        };
        if (sourceComponent.dispatchEvent) { //The source component is a LWC
            sourceComponent.dispatchEvent(new ShowToastEvent(eventDetails));
        }
        
        else if (sourceComponent.showToast) { //The source component is a notificationLibrary Aura component
            sourceComponent.showToast(eventDetails);
        }
            else {
                if (console) {
                    console.error('Invalid source component');
                }
            }
    },
    
    getAllFideContacts: function(component, event, helper){
        
        var allFidejussoriList = new Map();
        var allPersonaFisLst = [];
        var allPersonaGiudiLst = [];
        
        var tempAllFieldsCheck = false;
        let recordId = component.get("v.recordId");
        console.log('recordId muk - '+recordId);
        let action = component.get('c.getAllFidejussori');
        action.setParams({
            "oppId": recordId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                allFidejussoriList = response.getReturnValue();
                allPersonaFisLst = allFidejussoriList['Persona Fisica'];
                allPersonaGiudiLst = allFidejussoriList['Persona Giuridica'];
                
                component.set('v.allPersonaFiscaLst',allPersonaFisLst);
                component.set('v.allPersonaGiuridicaLst',allPersonaGiudiLst);
                
                for (var i=0; i < allPersonaFisLst.length; i++) {
                    if( ! allPersonaFisLst[i].LastName || ! allPersonaFisLst[i].FirstName || ! allPersonaFisLst[i].Comune_di_Nascita__c || ! allPersonaFisLst[i].Sigla_Provincia_Nascita__c || 
                       ! allPersonaFisLst[i].Data_di_Nascita__c || ! allPersonaFisLst[i].Oplon_Codice_Fiscale__c || ! allPersonaFisLst[i].Indirizzo_Residenza_Esteso__c || ! allPersonaFisLst[i].Provincia__c
                       || ! allPersonaFisLst[i].Comune__c || ! allPersonaFisLst[i].Cap__c || ! allPersonaFisLst[i].Email )
                    {
                        component.set('v.allPersonaFisFieldChk',true);
                    }
                }
                for (var i=0; i < allPersonaGiudiLst.length; i++) {
                    if( ! allPersonaGiudiLst[i].LastName || ! allPersonaGiudiLst[i].FirstName || ! allPersonaGiudiLst[i].Comune_di_Nascita__c || ! allPersonaGiudiLst[i].Sigla_Provincia_Nascita__c || 
                       ! allPersonaGiudiLst[i].Data_di_Nascita__c || ! allPersonaGiudiLst[i].Oplon_Codice_Fiscale__c || ! allPersonaGiudiLst[i].Indirizzo_Residenza_Esteso__c || ! allPersonaGiudiLst[i].Provincia__c
                       || ! allPersonaGiudiLst[i].Comune__c || ! allPersonaGiudiLst[i].Cap__c || ! allPersonaGiudiLst[i].Account.Email__c  
                       || ! allPersonaGiudiLst[i].Account.Indirizzo_Sede_Legale_Esteso__c || ! allPersonaGiudiLst[i].Account.Cap__c || ! allPersonaGiudiLst[i].Account.Comune__c || ! allPersonaGiudiLst[i].Account.Sigla_Provincia__c 
                       || ! allPersonaGiudiLst[i].Account.Capitale_Sociale__c || ! allPersonaGiudiLst[i].Account.Codice_Fiscale__c || ! allPersonaGiudiLst[i].Account.Phone || ! allPersonaGiudiLst[i].Account.Cellulare__c  || ! allPersonaGiudiLst[i].Ruolo_in_Azienda__c)
                    {
                        component.set('v.allPersonaGiuFieldChk',true);
                    }
                }
                if(component.get('v.allPersonaGiuFieldChk') || component.get('v.allPersonaFisFieldChk')){
                    component.set('v.showFidejusoriBlock',true);
                }
                
            }
        }
                          );
        $A.enqueueAction(action);
    }
})