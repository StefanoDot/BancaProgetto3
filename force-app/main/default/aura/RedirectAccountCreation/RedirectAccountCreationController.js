({
	createRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Account"
                });
                createRecordEvent.fire();
        /*
        console.log('COMPONENT');
         var vfOrigin = "https://" + component.get("v.vfHost");
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                debugger;
                // Not the expected origin: Reject the message!
                return;
            }
            // Handle the message
            debugger
            var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Account"
                });
                createRecordEvent.fire();
            console.log(event.data);
        }, false);
        */
        
        
    }
})