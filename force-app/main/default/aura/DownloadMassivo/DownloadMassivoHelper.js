({
	NavigateToUrl_helper : function(c,e,h) {
    let button = e.getSource();
    button.set('v.activo',true);
	var recordId =  c.get("v.recordId");
  console.log('recordId ' + recordId);
     var action = c.get('c.Downloadmassivo');
        action.setParams({
            "recordId" : recordId
            
            });
    action.setCallback(c,function(response) {
          console.log('response.getReturnValue(): ' + response.getReturnValue()); 

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
                    "message": response.responseMessage,
                    "type":"error"
                    });
                 toastEvent.fire();
            }
          //console.log('response.state: ' + state); 
          
            
            $A.get("e.force:closeQuickAction").fire();
        }
    );
    $A.enqueueAction(action);
  
    
    }
    
    
    
})