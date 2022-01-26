({
	
		
	doInit: function(component, event, helper){       
        component.set("v.showLoadingSpinner", true); 
        
        var recordId =  component.get("v.recordId");
        console.log('recordId: '+ recordId);
        
        var actionCheck = component.get('c.checkCampiRichiedi');
        actionCheck.setParams({
            "oppId" : recordId
        })
        
        actionCheck.setCallback(this, function (response) {
          
            var response = response.getReturnValue();
            
            console.log('response' + JSON.stringify(response));
            
            if(response.ok==false){
              
                    console.log('elsi fushave');
                    
                    component.set("v.message",response.responseMessage);
                     component.set("v.arerules",true);
                
            }
            else{
                component.set("v.arecheck",true);
            }
           
            
        }
                                
                                );
        $A.enqueueAction(actionCheck);
    },

    
   
})