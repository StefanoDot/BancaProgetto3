({
    check_helper : function(c,e,h) {
        
        var recordId =  c.get("v.recordId");
        var actionCheck = c.get('c.checkDublicateCointestazione');
        actionCheck.setParams({
            "recordId" : recordId
        });
        
        actionCheck.setCallback(c,function(response) {
             var toastEvent = $A.get("e.force:showToast");
            var mbylle = $A.get("e.force:closeQuickAction");
            var response = response.getReturnValue();
            console.log('response.ok '+ response.ok);
            
            if (response.ok==true){
                c.set("v.fake",false);   
                c.set('v.message', response.inshallah);     
            }
             else if (response.ok==false){
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
                c.set("v.fake",true);       
            }
        }
                               );
        $A.enqueueAction(actionCheck); 
    },
    
    
    updateCheck11_helper : function(c,e,h) {
        
        var recordId =  c.get("v.recordId");
        var action = c.get('c.creaCointestazioneCallout');
        action.setParams({
            "recordId" : recordId
        });
        
        action.setCallback(c,function(response) {
            
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
            $A.get("e.force:closeQuickAction").fire();
            
            $A.get("e.force:refreshView").fire();
        }
                          );
        $A.enqueueAction(action);
        
    },
    
    deleteCointestestazione_helper: function(component, QuoteId){
        var action = component.get("c.deleteCoin");
        action.setParams({
            "recordId": QuoteId
        });
        $A.enqueueAction(action);
        
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Cointestazione__c"
        });
        homeEvent.fire();     
        
       $A.get("e.force:refreshView").fire();

    },   
})