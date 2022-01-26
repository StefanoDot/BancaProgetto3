({
    doInit: function(component, event, helper) {
        
        var QuoteId =  component.get("v.recordId");
        console.log('recordId butoni: '+ QuoteId);
        component.set("v.fake",true);
        var ndg = component.get("v.simpleRecord.NDG__c");
        var cedacri =component.get("v.simpleRecord.Aggiorna_Cedacri__c");
        console.log('contactnumber'+ ndg);
        if (ndg==null||cedacri==false){
            component.set("v.disable", false); 
        }
        console.log('disable'+component.get("v.disable"));
        var action = component.get('c.switchSystems');
        
        action.setCallback(component,function(response) {
            console.log('response.getReturnValue(): ' + response.getReturnValue()); 
            
            var response = response.getReturnValue();
            
            if (response == true){
                component.set("v.switch", true); 
            }
        });
        $A.enqueueAction(action);
        
    },
    AggiornaCedacri: function(component, event, helper){       
        component.set("v.openmodal",true);  
       
    },
   aggiornaDati: function(component, event, helper){       
        component.set("v.openmodal",true); 
         let button = event.getSource();
        button.set('v.disabled',true);
        component.set("v.pressed",true);
        component.set("v.showTheSpinner", true); 
        var recordId =  component.get("v.recordId");
        var actionCheck = component.get('c.aggiorna');
        var objectName= 'Contact';
        actionCheck.setParams({
            "recordId" : recordId,
            "objectName":objectName
        })
        
        actionCheck.setCallback(this, function (response) {
            var toastEvent = $A.get("e.force:showToast");
            var response = response.getReturnValue();
            
            console.log('response' + JSON.stringify(response));
            
            if(response.ok==false){
                component.set('v.openmodal',false);
                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Error!",
                    "message": response.responseMessage,
                    "type":"error"
                });  
                toastEvent.fire();
            }
            else{
                component.set('v.openmodal',false);
                 toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Success!",
                    "message": 'Chiamata effetuata corretamente!',
                    "type":"success"
                });
                toastEvent.fire();
            }                
        });
        $A.enqueueAction(actionCheck);
    },
    updateCheck11 : function(c, e, h) {
        h.updateCheck11_helper(c,e,h);
    },
    
    updateCheck12 : function(c, e, h) {
        h.updateCheck12_helper(c,e,h);
    },
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('editDialog');
        var cmpBack = component.find('overlay');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set('v.openmodal',false);        
    },
    refresh:function(component, event, helper){
        var cmpTarget = component.find('editDialog');
        var cmpBack = component.find('overlay');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set('v.openmodal',false);
    },
    callCertificaContatti : function(component, event, helper) {
        component.set('v.isCertificaContatti',true);
        var cmpTarget = component.find('certificaDialog');
        var cmpBack = component.find('overlay');
        $A.util.addClass(cmpBack,'slds-backdrop--open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
    },
    closeCertifica : function(component, event, helper) {
        var cmpTarget = component.find('certificaDialog');
        var cmpBack = component.find('overlay');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set('v.isCertificaContatti',false);
    },
    valueChange : function(component, event, helper) {
        console.log(  ' close aura'   )
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get("v.recordId"),
              "slideDevName": "Detail"
            });
            navEvt.fire();
    },
    refreshView: function(component, event) {
        console.log('REFRESH VIEW');
        $A.get('e.force:refreshView').fire();
    }
})