({
    fetchLeads: function(component, event, helper){
        var action = component.get("c.getAllLeads"); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.data", response.getReturnValue());
                component.set("v.selectedLeads", "[]");
                component.set("v.showSpinner", false);
            }
            else{
                component.set("v.showSpinner", false);
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = 'Some Error has Occured.';
                }
                else if(state === "ERROR"){
                    errorMessage = action.getError()[0].message;
                }
                this.showToast(component, event, helper, errorMessage, "Error!", "error");
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function(component, event, helper, errorMessage, title, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": errorMessage,
            "type": type
        });
        toastEvent.fire();
    },
    convertSelectedLeads :function(component, event, helper){
        var action = component.get("c.convertLeadsToAccounts");
        action.setParams({ 
            leadsToBeConverted : component.get("v.selectedLeads")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                //component.set("v.showSpinner", false);
                this.showToast(component, event, helper, 'Selected Leads have been Converted', "Success!", "success");
                $A.get('e.force:refreshView').fire();
            }
            else{
                component.set("v.showSpinner", false);
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = 'Some Error has Occured.';
                }
                else if(state === "ERROR"){
                    var errors = response.getError();
                    if(errors){
                        if(errors[0] && errors[0].pageErrors[0].message){
                            errorMessage = errors[0].pageErrors[0].message;
                        }
                    } 
                    else{
                        errorMessage = 'Unknown Error has Occured.';
                    }
                }
                this.showToast(component, event, helper, errorMessage, "Error!", "error");
            }
        });
        $A.enqueueAction(action);
    },
    getFilteredLeads: function(component, event, helper){
        var action = component.get("c.fetchFilteredLeads");
        action.setParams({ 
            searchedKeyword: component.get("v.searchKeyword"),
            selectedField: component.get("v.selectedField")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.selectedLeads", "[]");
                component.set("v.data", response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else{
                component.set("v.showSpinner", false);
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = 'Some Error has Occured.';
                }
                else if(state === "ERROR"){
                    errorMessage = action.getError()[0].message;
                }
                this.showToast(component, event, helper, errorMessage, "Error!", "error");
            }
        });
        $A.enqueueAction(action);
    }
})