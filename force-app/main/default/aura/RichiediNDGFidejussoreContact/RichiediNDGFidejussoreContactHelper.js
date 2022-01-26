({
	updateCheck11_helper : function(c,e,h) {
   
	var recordId =  c.get("v.recordId");
	c.set("v.showLoadingSpinner", true); 
     var action = c.get('c.checkDueFidejussioneNDGbuttoneContact');
        action.setParams({
            "recordId" : recordId
            });
                console.log("recordId"+recordId);

    action.setCallback(c,function(response) {
          console.log('response.getReturnValue(): ' + response.getReturnValue()); 
          	c.set("v.showLoadingSpinner", false); 
            var response = response.getReturnValue();
        	 var toastEvent = $A.get("e.force:showToast");
            if (response.ok==true){
                toastEvent.setParams({                      
                "mode": "sticky",                             
                "title": "Success!",
                "message": "Chiamata effettuata correttamente !",
                "type":"success"
                });
         		toastEvent.fire();
            }
                
            else{
                       
                       toastEvent.setParams({
                      "mode": "sticky",
                                
                    "title": "Error!",
                    "message": response.responseMessage+". Contattare il Sales Support",
                    "type":"error"
                    });
                 toastEvent.fire();
            }
          //console.log('response.state: ' + state); 
          
            
            $A.get("e.force:closeQuickAction").fire();

                $A.get("e.force:refreshView").fire();
        }
    );
    $A.enqueueAction(action);
        
        
        
        
    
    }
    
    
    
})