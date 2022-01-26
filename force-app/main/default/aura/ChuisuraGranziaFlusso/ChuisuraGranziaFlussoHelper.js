({
	updateCheck11_helper : function(c,e,h) {
   
	var recordId =  c.get("v.recordId");
     var action = c.get('c.ChuisaGaranzia');
        action.setParams({
            "recordId" : recordId
            });
    action.setCallback(c,function(response) {
          console.log('response.getReturnValue(): ' + response.getReturnValue()); 

            var response = response.getReturnValue();
        	 var toastEvent = $A.get("e.force:showToast");
            if(response.error==false){
              if(response.ok==true){
            
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
                    "message": response.responseMessage,
                    "type":"error"
                    });
                 toastEvent.fire();
            }
          }
          
                
            else {
                       
                       toastEvent.setParams({
                      "mode": "sticky",                             
                "title": "Success!",
                "message": "Garanzia Chiusa!",
                "type":"success"
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