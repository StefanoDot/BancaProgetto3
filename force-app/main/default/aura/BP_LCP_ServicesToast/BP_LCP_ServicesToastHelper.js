({
	getCampaignNames: function(component, event, helper){
        var action = component.get("c.getAllCampaignNames");
        action.setParams({ 
            opportunityId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != ''){
                    var strLength = response.getReturnValue().length;
                    var campaignNames = response.getReturnValue();
                    campaignNames = campaignNames.slice(0, -2) + '.';
                    var message = $A.get("$Label.c.Campaign_Names_Warning_Msg") + ' ' + campaignNames;
                    this.showToast(component, event, helper, message, 'Warning !', 'warning');
                }
            }
            else{
                component.set("v.showSpinner", false);
                var errorMessage = '';
                if(state === "INCOMPLETE"){
                    errorMessage = $A.get("$Label.c.Error_Message");
                }
                else if(state === "ERROR"){
                    var errors = response.getError();
                    if(errors){
                        if(errors[0] && errors[0].pageErrors[0].message){
                            errorMessage = errors[0].pageErrors[0].message;
                        }
                    } 
                    else{
                        errorMessage = $A.get("$Label.c.Error_Message");
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
    showToast: function(component, event, helper, message, title, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "sticky"
        });
        toastEvent.fire();
    }
})