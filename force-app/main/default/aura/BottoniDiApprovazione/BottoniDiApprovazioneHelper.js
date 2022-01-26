({
	update_helper : function(component, event, helper, buttonName) {
        
	var QuoteId =  component.get("v.recordId");
    var action = component.get("c.updateButtonFondo");
        
        action.setParams({
            "quoteId" : QuoteId,
            "ButtonName" : buttonName
     });

    action.setCallback(component,
        function(response) {
           var state = response.getState();
           var toastEvent = $A.get("e.force:showToast");

            if (state === 'SUCCESS'){
                 toastEvent.setParams({
                      "duration":"20",
                      "mode": "sticky",
                      "title": "Success!",
        			  "message": "The record has been updated successfully.",
                      "type":"success"
        });
         toastEvent.fire();
                          }
            else {
                toastEvent.setParams({
                      "mode": "sticky",
                      "duration":"5000",
                      "title": "Error!",
        			  "message": "The record has not been updated successfully.",
        			  "type":"error"
        });
                
                 toastEvent.fire();
            }
            
            $A.get("e.force:closeQuickAction").fire();
            location.reload();
        }
    );
        
    $A.enqueueAction(action);
    }

})