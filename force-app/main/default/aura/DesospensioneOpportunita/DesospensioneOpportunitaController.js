({
	 doInit: function(component, event, helper){       
                 component.set("v.showLoadingSpinner", true); 

        var recordId =  component.get("v.recordId");
        console.log('recordId: '+ recordId);
        var actionCheck = component.get('c.checkCount');
        console.log('vjen ketu');
        actionCheck.setParams({
            "recordId" : recordId
        })
        
        actionCheck.setCallback(this, function (response) {
            var toastEvent = $A.get("e.force:showToast");
            var mbylle = $A.get("e.force:closeQuickAction");
            var response = response.getReturnValue();
            
            console.log('response' + JSON.stringify(response));
            
            if(response.ok==false){
                mbylle.fire();
                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Error!",
                    "message": response.responseMessage,
                    "type":"error"
                });  
                toastEvent.fire();
            }
            else{
               component.set("v.activo",false);
                 component.set("v.showLoadingSpinner", false); 

                component.set("v.message",'Sei sicuro/a di fare la desospensione di questa opportunita?');
            }                
        });
        $A.enqueueAction(actionCheck);
    },
    
	updateCheck11 : function(c, e, h) {
       c.set("v.activo",true);
		h.updateCheck11_helper(c,e,h);
	},
})