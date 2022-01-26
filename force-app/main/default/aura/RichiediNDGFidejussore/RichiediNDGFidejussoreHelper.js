({
	updateCheck11_helper : function(c,e,h) {
             	c.set("v.showLoadingSpinner", true); 
   
	var recordId =  c.get("v.recordId");
     var action = c.get('c.checkDueFidejussioneNDGbuttone');
        action.setParams({
            "recordId" : recordId
            });
        
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
                    "message": response.responseMessage+" Contattare il Sales Support",
                    "type":"error"
                    });
                 toastEvent.fire();
            }
            
            $A.get("e.force:closeQuickAction").fire();

                $A.get("e.force:refreshView").fire();
        }
    );
    $A.enqueueAction(action);
        
        
        
        
    
    },
    
    updateCheck12_helper : function(c,e,h) {
   

             	c.set("v.showLoadingSpinner", true); 
   
	var recordId =  c.get("v.recordId");
     var action = c.get('c.campiMancantiCedacri');
        action.setParams({
            "recordId" : recordId
            });
        
    action.setCallback(c,function(response) {
          console.log('response.getReturnValue(): ' + response.getReturnValue()); 
                    	c.set("v.showLoadingSpinner", false); 
          
            var response = response.getReturnValue();
        	 var toastEvent = $A.get("e.force:showToast");
            if (response.ok==true){
                toastEvent.setParams({                      
                "mode": "sticky",                             
                "title": "Success!",
                "message": "Tutti il campi sono valorizata!",
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
            
            $A.get("e.force:closeQuickAction").fire();

                $A.get("e.force:refreshView").fire();
        }
    );
    $A.enqueueAction(action);
}
    
    
    
    
})