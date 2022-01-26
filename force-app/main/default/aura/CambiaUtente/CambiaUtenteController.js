({
	pickUser: function (component, event, helper) {
         var recordId =  component.get("v.recordId");
        component.set('v.accId', recordId);
           
        console.log('recordIdmmm: '+ recordId);


        var action = component.get("c.getUsers");
          action.setParams({
            "recordId" : recordId,      
        })
        action.setCallback(this, function(response){
             var toastEvent = $A.get("e.force:showToast");
            var mbylle = $A.get("e.force:closeQuickAction");
            var response = response.getReturnValue();
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
                 component.set("v.userList" , response.listUsers); 
                   component.set('v.accId', recordId);
console.log('bbbbbbb ');
                }
            
        });
        
        $A.enqueueAction(action);
    },
    
 onChange1: function (component, event, helper) {
  var recordId = event.getSource().get("v.value");  
    console.log(recordId);
      component.set('v.selectedValueId', recordId);
      var actionCheck = component.get('c.nomeUtente');
      actionCheck.setParams({
            "recordId" : recordId,      
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
                    "message":"Error",
                    "type":"error"
                });  
                toastEvent.fire();
            }
            else{
                console.log('vjen ketu');
               component.set("v.user",false);

                component.set("v.shfaq",true);
                component.set("v.selectedValue",response.nomeUtente); 
            }                
        });
        $A.enqueueAction(actionCheck);



    },
     yesButton:function(component, event, helper){
        var recordId = component.get("v.selectedValueId");        
         var AccountId = component.get("v.accId");        

        console.log(recordId);
                 console.log(AccountId);

        let button = event.getSource();
        button.set('v.disabled',true);
        component.set("v.pressed",true);
        console.log('po qetuuuuuuuu');

        
        var actionCheck = component.get('c.changeUtente');
        
        console.log('po qetu');

        actionCheck.setParams({
            "recordId" : recordId,
            "AccountId" : AccountId      
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
    },
     
    cambia:function(component, event, helper){
         component.set("v.user",true);
       component.set("v.shfaq",false);
    }
})