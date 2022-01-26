({
    doInit: function(component, event, helper) {
       var action = component.get('c.profileUser');
        action.setCallback(this, function (response) {
          var response = response.getReturnValue();
            
           if(response.ok==true){
            console.log('response' + JSON.stringify(response));
            component.set('v.fake',true);
            }
        });
            
        
        $A.enqueueAction(action);
    },
    
    SwitchUser: function(component, event, helper){       
        component.set("v.openmodale",true);
    },
    
    turnOn: function(component, event, helper){       
        component.set("v.openmodale2",true); 
        var actionCheck = component.get('c.switchUsers');
        var objectName= 'on';
        actionCheck.setParams({
            "CaDo" : objectName
        })
        component.set('v.openmodale2',false); 
        $A.enqueueAction(actionCheck);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "sticky",
            "title": "Error!",
            "message": 'Chiamata effetuata corretamente!',
            "type":"success"
        });  
        toastEvent.fire();
    },
    
    turnOff: function(component, event, helper){   
        var actionCheck = component.get('c.switchUsers');
        var objectName= 'off';
        actionCheck.setParams({
            "CaDo" : objectName
        })
        component.set('v.openmodale2',false); 
        $A.enqueueAction(actionCheck);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "sticky",
            "title": "Error!",
            "message": 'Chiamata effetuata corretamente!',
            "type":"success"
        });  
        toastEvent.fire();
    },
    
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('editDialog');
        var cmpBack = component.find('overlay');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set('v.openmodale',false);
        component.set('v.openmodale2',false);        
    },
    
    theEnter: function(component, event, helper){
        console.log('do vish' );
        var myAttri = component.get('v.myAttribute');
        console.log('ca dooooo' + myAttri);
        
        if (myAttri == 'Aldora'){
            component.set('v.openmodale',false);
            component.set('v.openmodale2',true);
            component.set('v.myAttribute',[]);
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": "sticky",
                "title": "Error!",
                "message": 'Password Errato!',
                "type":"error"
            });  
            toastEvent.fire();
           // component.set('v.openmodale',false);
            component.set('v.myAttribute',[]);
        }
    },
})