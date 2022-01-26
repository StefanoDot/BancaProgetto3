({
    doInit: function(component, event, helper){
        helper.fetchDetails(component, event, helper);
	},
    sendAPICall: function(component, event, helper){
        component.set("v.loaded", true);
        helper.sendAPICallHelepr(component, event, helper);
	},
    closeModel: function(component, event, helper){
        component.set("v.isModalOpen", false);
    },
    callAPI: function(component, event, helper){
        component.set("v.isModalOpen", false);
        component.set("v.loaded", true);
        helper.aPICaller(component, event, helper);
    }
})