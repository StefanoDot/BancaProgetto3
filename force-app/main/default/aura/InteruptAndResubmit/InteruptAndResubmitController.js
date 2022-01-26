({
	handleRecordUpdate : function(component, event, helper) {
        
		var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") 
        {
            var opportunity = component.get("v.Opportunity");
            
            
            if( opportunity.StatusVideoconferenza__c == "Interrotta")
            {
                component.set("v.showInterrupt", false);
            }
            else if( opportunity.StatusOnboarding__c == "Richiesta" || opportunity.StatusOnboarding__c == "KO" || opportunity.StatusOnboarding__c == "OK")
            {
                component.set("v.showInterrupt", true);
            }
            
            if( opportunity.StatusOnboarding__c == "KO")
            {
                component.set("v.showResubmit", true);
            }
            else if( opportunity.StatusOnboarding__c == "OK" || opportunity.StatusOnboarding__c == "Richiesta" || opportunity.StatusVideoconferenza__c == "Interrotta")
            {
                component.set("v.showResubmit", false);
            }
        }
	},
    handleAbort: function(component, event, helper){
        
        var opportunity = component.get("v.Opportunity");
        
        var action = component.get("c.interruptRequestCall");
        action.setParams({
            oppId : opportunity.Id
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            component.set("v.showSpinner",false);

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
    handleResubmit: function(component, event, helper) {        
        component.set("v.isOpen", true);
        component.set("v.modalHeading","Risottometti richiesta Riconoscimento");
        component.set("v.bodyHeading","Sei sicuro di proseguire con la risottomissione della richiesta di riconoscimento? <br/><br/> - La richiesta verrà risottomessa solo per i firmatari/fidejussori il cui censimento su Rapido è andato KO");
        component.set("v.showFtrBtn",true);
    },
    openModel : function(component, event, helper) {
        
        component.set("v.isOpen", true);
        
    },
    closeModel: function(component, event, helper) {
        
        component.set("v.isOpen", false);
    },
    handleYes: function(component, event, helper) {
        
        component.set("v.showSpinner",true);
        component.set("v.isOpen", false);
        var opportunity = component.get("v.Opportunity");
        
        var action = component.get("c.bookVideoConferenceCall");
        action.setParams({
            oppId : opportunity.Id,
            isResubmit : true
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
})