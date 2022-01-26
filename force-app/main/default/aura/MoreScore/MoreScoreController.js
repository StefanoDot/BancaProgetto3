({
    doInit: function(component, event, helper){       
        component.set("v.showLoadingSpinner", true); 
        var recordId =  component.get("v.recordId");
        console.log('recordId: '+ recordId);
        var actionCheck = component.get('c.moreScore');
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
                console.log('vjen ketu');
                component.set("v.showLoadingSpinner", false); 
                component.set("v.shfaq",true);
                component.set("v.ricezioni", response.Ricezioni);
                component.set("v.morescore", response.Morescore);
                component.set("v.errorericezioni", response.ErroreRicezioni);
                
                component.set("v.message",response.responseMessage);
            }                
        });
        $A.enqueueAction(actionCheck);
    },
    
    yesButton:function(component, event, helper){
        console.log('yesiii');
        component.set("v.showLoadingSpinner", true); 
        component.set("v.shfaq",false);
        let button = event.getSource();
        button.set('v.disabled',true);
        component.set("v.pressed",true);
        component.set("v.pritt",'Se hai già appena richiesto il morescore, attendi qualche minuto e ricarica la pagina per i visualizzare i dati aggiornati!');
        
        var ricezioni =  component.get("v.ricezioni");        
        var morescore =  component.get("v.morescore");     
        var errorericezioni =  component.get("v.errorericezioni"); 
        var recordId =  component.get("v.recordId");     

        
        
                console.log('po qetuuuuuuuu');

        
        var actionCheck = component.get('c.aggiornaMoreScore');
        
        console.log('po qetu');

        actionCheck.setParams({
            "recordId" : recordId,
            "ricezioni" : ricezioni,
            "morescore" : morescore,
            "errorericezioni" : errorericezioni            
        })
        
        actionCheck.setCallback(component,function(response) {
            var response = response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
           // console.log('response' + JSON.stringify(response));
            if (response.ok==true){
                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Success!",
                    "message": 'Chiamata effetuata corretamente!',
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
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(actionCheck);
    },
    
    refresh:function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();  
    }
})