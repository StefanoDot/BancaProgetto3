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
                this.showToast(component, event, helper, 'error', 'Error!', errorMessage);
            }  
        });  
        $A.enqueueAction(action); 
	},
    sendAPICallHelepr: function(component, event, helper){
		var recordId = component.get("v.recordId");
        var action = component.get("c.BP_OUT_Anticipo");
        action.setParams({ opportunityId : recordId });
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if(state === 'SUCCESS') {  
                var result = response.getReturnValue();
                component.set("v.loaded", false);
                var msg = $A.get("$Label.c.AnticipoPEF_Call_OUT_Message");
                this.showToast(component, event, helper, 'success', 'Success!', msg);
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
                this.showToast(component, event, helper, 'error', 'Error!', errorMessage);
            }  
        });  
        $A.enqueueAction(action); 
	},
    showToast: function(component, event, helper, type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})