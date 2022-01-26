({
	fetchDetails: function(component, event, helper){
		var recordId = component.get("v.recordId");
        var action = component.get("c.getOpportunityDetails");
        action.setParams({ opportunityId : recordId });
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if(state === 'SUCCESS') {  
                var result = response.getReturnValue();
                component.set("v.result", result);
                component.set("v.loaded", false);
            }  
            else{  
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = 'Some Error has Occured.';
                }
                else if(state === "ERROR"){
                    errorMessage = action.getError()[0].message;
                }
                component.set("v.loaded", false);
                this.showToast(component, event, helper, 'error', 'Error!', errorMessage, "dismissable");
            }  
        });  
        $A.enqueueAction(action); 
	},
    sendAPICallHelepr: function(component, event, helper){
		var recordId = component.get("v.recordId");
        var action = component.get("c.contactValidation");
        action.setParams({ opportunityId : recordId }); 
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if(state === 'SUCCESS') {  
                var result = response.getReturnValue();
                console.log('result????' + JSON.stringify(result));
                for (i = 0; i < result.length; i++) {
                    if (result[i].dittaIndividualeValidation == true) {
                        component.set("v.isDittaIndividuale", true);
                    }
                    if (result[i].legaleTitolareValidation == true) {
                        component.set("v.isLegaleTitolare", true);
                    }
                }
                component.set("v.contactRecords", result);
                if(result.length > 0 && result[0].validationFlag){
                    component.set("v.loaded", false);
                    var msg = $A.get("$Label.c.CreazioneReteAzienda_Error_Message");
                    msg += '\n';
                    for(var i = 0; i < result.length; i++){
                        msg += '-' + ' ' + result[i].contactName;// + ' (' +  result[i].url + ')';
                        msg += '\n';
                    }
                    this.showToast(component, event, helper, 'error', 'Error!', msg, "sticky");
                }
                else{
                    component.set("v.loaded", false);
                    var contactAndAccounts = [];
                    for(var i = 0; i < result.length; i++){
                        contactAndAccounts.push('-' +  result[i].contactName);
                    }
                    component.set("v.accountAndContactNames", contactAndAccounts);
                    component.set("v.isModalOpen", true);
                    //this.aPICaller(component, event, helper);
                }
            }  
            else{  
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = 'Some Error has Occured.';
                }
                else if(state === "ERROR"){
                    errorMessage = action.getError()[0].message;
                }
                component.set("v.loaded", false);
                this.showToast(component, event, helper, 'error', 'Error!', errorMessage, "dismissable");
            }  
        });  
        $A.enqueueAction(action); 
	},
    showToast: function(component, event, helper, type, title, message, mode){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    aPICaller: function(component, event, helper){
		var recordId = component.get("v.recordId");
        var action = component.get("c.BP_OUT_CRA");
        action.setParams({ opportunityId : recordId });
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if(state === 'SUCCESS') {  
                var result = response.getReturnValue();
                console.log('result****' + result);
                component.set("v.loaded", false);
                var msg = $A.get("$Label.c.AnticipoPEF_Call_OUT_Message");
                this.showToast(component, event, helper, 'success', 'Success!', msg, "dismissable");
            }  
            else{  
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = 'Some Error has Occured.';
                }
                else if(state === "ERROR"){
                    errorMessage = action.getError()[0].message;
                }
                component.set("v.loaded", false);
                this.showToast(component, event, helper, 'error', 'Error!', errorMessage, "dismissable");
            }  
        });  
        $A.enqueueAction(action); 
	}
})