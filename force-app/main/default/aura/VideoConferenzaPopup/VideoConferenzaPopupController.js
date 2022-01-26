({
    handleRecordUpdate : function(component, event, helper) {
    },
    handleYes: function(component, event, helper) {
        
        component.set("v.showSpinner",true);
        component.set("v.isOpen", false);
        var opportunity = component.get("v.Opportunity");
        
        var action = component.get("c.bookVideoConferenceCall");
        action.setParams({
            oppId : opportunity.Id,
            isResubmit : false
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            component.set("v.showSpinner",false);
            console.log('the state is '+state);
            if (component.isValid() && state === "SUCCESS"){
                                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Successo !",
                    "type": "success",
                    "mode": "dismissible",
                    "message": $A.get("$Label.c.Digital_Request_Success")
                });
                toastEvent.fire();
                window.location.reload();
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Fallimento !",
                    "type": "error",
                    "mode": "dismissible",
                    "message": $A.get("$Label.c.Digital_Request_Failure")
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    openModel : function(component, event, helper) {
        
        component.set("v.isOpen", true);
        component.set("v.showSpinner",true);
        
        //Calling apex method to get Firmatario & Fidejussori - Start
        var opportunity = component.get("v.Opportunity");
            console.log('opportunity.Tipo_Linea_di_Credito__c---->'+opportunity.Tipo_Linea_di_Credito__c);
            var action = component.get("c.getAllContacts");
            action.setParams({
                oppId : opportunity.Id,
                accountId : opportunity.AccountId,
                tipoLineaCredito : opportunity.Tipo_Linea_di_Credito__c
            });
            action.setCallback(this, function(result){
                
				var allContactList = [];
                var allFirmaLst = [];
                var allFideLst = [];
                
                var noEmailMobile = [];
                var noNDG = [];
                var noEmailMobNDG = [];
                var noTipoDocumento = [];
                var state = result.getState();
                var tempAllFieldsCheck = false;
                var noFirmatario = false;
                var allEmailList = [];
                var allMobileList = [];
                
                var noSME002Lst = [];
                var noSME004Lst = [];
                var tempFirmaList = [];
                
                if (component.isValid() && state === "SUCCESS"){
                    var allFirmaFideLst = result.getReturnValue();
                    component.set("v.showSpinner",false);
                    if(allFirmaFideLst.length == 0)
                    {
                        noFirmatario = true;
                        component.set("v.noFirmaContactError","  Per procedere bisogna identificare almeno un firmatario tra i Referenti.");                                       
                    }
                    else if(allFirmaFideLst.length > 0)
                    {                        
                        for (var i=0; i < allFirmaFideLst.length; i++) {
                            
                            if((allFirmaFideLst[i].contact.Firmatario__c && ! allFirmaFideLst[i].contact.Fidejussore__c) || (allFirmaFideLst[i].contact.Firmatario__c && allFirmaFideLst[i].contact.Fidejussore__c && allFirmaFideLst[i].contact.AccountId === opportunity.AccountId))
                            {
                                if( ! tempFirmaList.includes(allFirmaFideLst[i].contact.Id)){
                                    allFirmaLst.push(allFirmaFideLst[i].contact);
                                    tempFirmaList.push(allFirmaFideLst[i].contact.Id);
                                }
                            }
                            if(allFirmaFideLst[i].isFidejussori)
                            {
                                if( ! allFirmaFideLst[i].hasSME002){
                                    
                                    console.log('hasSME002--->'+allFirmaFideLst[i].contact.Id);
                                    console.log('hasSME002--->'+allFirmaFideLst[i].hasSME002);
                                    
                                    noSME002Lst.push(allFirmaFideLst[i].contact);
                                }
                                if( ! allFirmaFideLst[i].hasSME004){
                                    noSME004Lst.push(allFirmaFideLst[i].contact);
                                    console.log('noSME004Lst--->'+allFirmaFideLst[i].contact.Id);
                                }
                                allFideLst.push(allFirmaFideLst[i].contact)
                            }
                            
                            if( ! allFirmaFideLst[i].contact.FinServ__EmailVerified__c || ! allFirmaFideLst[i].contact.FinServ__MobileVerified__c )
                            {
                                if( ! allFirmaFideLst[i].contact.NDG__c )
                                {
                                    noEmailMobNDG.push(allFirmaFideLst[i].contact);
                                }
                                else
                                {
                                    noEmailMobile.push(allFirmaFideLst[i].contact);
                                }
                            }
                            if( allFirmaFideLst[i].contact.FinServ__EmailVerified__c && allFirmaFideLst[i].contact.FinServ__MobileVerified__c && ! allFirmaFideLst[i].contact.NDG__c )
                            {
                                noNDG.push(allFirmaFideLst[i].contact);
                            }
                            if( allFirmaFideLst[i].contact.Tipo_Documento__c != 'I' &&  allFirmaFideLst[i].contact.Tipo_Documento__c != 'S' )
                            {
                                noTipoDocumento.push(allFirmaFideLst[i].contact);
                            }
                            //All Fields Check
                            if( ! allFirmaFideLst[i].contact.LastName || ! allFirmaFideLst[i].contact.FirstName || ! allFirmaFideLst[i].contact.Localita__c || ! allFirmaFideLst[i].contact.Data_di_Nascita__c || 
                              	! allFirmaFideLst[i].contact.Oplon_Codice_Fiscale__c || ! allFirmaFideLst[i].contact.Localita_Residenza__c || ! allFirmaFideLst[i].contact.Sigla_Provincia__c || ! allFirmaFideLst[i].contact.Indirizzo_Residenza_Esteso__c ||
                              ! allFirmaFideLst[i].contact.Cap__c || ! allFirmaFideLst[i].contact.Email || ! allFirmaFideLst[i].contact.MobilePhone || ! allFirmaFideLst[i].contact.FinServ__Gender__c || ! allFirmaFideLst[i].contact.Stato_Nascita__c)
                            {
                                tempAllFieldsCheck = true;
                            }
							allContactList.push(allFirmaFideLst[i].contact);
							component.set("v.allContacts",allContactList);

                        }
                        component.set("v.noEmailMobileLst",noEmailMobile);
                        component.set("v.noNDGELst",noNDG);
                        component.set("v.noEmailMobNDGLst",noEmailMobNDG);
                        component.set("v.noTipoDocumento",noTipoDocumento);
                        
                    }
                    component.set("v.allFirmatarioContacts",allFirmaLst);
                    component.set("v.allFidejussoriContacts",allFideLst);

                    if( noEmailMobile.length == 0 && noNDG.length == 0 && noEmailMobNDG.length == 0 && noTipoDocumento.length == 0 && ! noFirmatario)
                    {
                        console.log('tempAllFieldsCheck---->'+tempAllFieldsCheck);
                        if(tempAllFieldsCheck)
                        {
                            component.set("v.showAllErrorFields",tempAllFieldsCheck);
                            component.set("v.modalHeading","Compilare campi mancanti");
                            component.set("v.bodyHeading","Per procedere bisogna compilare i campi mancanti:");
                        }
                        else
                        {
                            var duplicateEmailContact = [];
                            var duplicateMobileContact = [];
                            console.log('length--->'+allFirmaFideLst.length);
                            for (var i=0; i < allFirmaFideLst.length; i++) {
                                
                                for (var j=0; j < allFirmaFideLst.length; j++) {
                                    if (i !== j && allFirmaFideLst[i].contact.Id !== allFirmaFideLst[j].contact.Id) {
                                        // check if elements' values are equal
                                        if (allFirmaFideLst[i].contact.Email === allFirmaFideLst[j].contact.Email) {
                                            duplicateEmailContact.push(allFirmaFideLst[i].contact);
                                            console.log('allFirmaFideLst[i].contact.Email-->'+allFirmaFideLst[i].contact.Email);
                                            console.log('allFirmaFideLst[j].contact.Email-->'+allFirmaFideLst[j].contact.Email);
                                            console.log('email-->'+allFirmaFideLst[i].contact.Id);
                                        }
                                        if (allFirmaFideLst[i].contact.MobilePhone === allFirmaFideLst[j].contact.MobilePhone) {
                                            duplicateMobileContact.push(allFirmaFideLst[i].contact);
                                            console.log('allFirmaFideLst[i].contact.Email-->'+allFirmaFideLst[i].contact.MobilePhone);
                                            console.log('allFirmaFideLst[j].contact.Email-->'+allFirmaFideLst[j].contact.MobilePhone);
                                             console.log('mobile-->'+allFirmaFideLst[i].contact.Id);
                                        }
                                    }
                                }
                            }
                            
                            if( duplicateEmailContact.length == 0 &&  duplicateMobileContact.length == 0){
                                
                                if(noSME002Lst.length == 0 && noSME004Lst.length == 0){
                                    
                                    component.set("v.bookVideoConferenceScrn",true);
                                    component.set("v.bodyHeading","Sei sicuro di prenotare il Riconoscimento in Videoconferenza per i seguenti referenti?");
                                    component.set("v.showFtrBtn",true);
                                }
                                else
                                {
                                    component.set("v.bodyHeading","");
                                    component.set("v.showSMEError",true);
                                    component.set("v.noSME002List",noSME002Lst); 
                                    component.set("v.noSME004List",noSME004Lst); 
                                }
                            }
                            else{
                                    component.set("v.bodyHeading","");
                                    component.set("v.showDuplicateChkScrn",true);
                                    component.set("v.duplicateEmailList",duplicateEmailContact);
                                    component.set("v.duplicateMobileList",duplicateMobileContact);
                            }
                        }
                    }
                    
                }
            });
            $A.enqueueAction(action);
        //Calling apex method to get Firmatario & Fidejussori - End
    },
    closeModel: function(component, event, helper) {
        
        component.set("v.isOpen", false);
    },
    
})