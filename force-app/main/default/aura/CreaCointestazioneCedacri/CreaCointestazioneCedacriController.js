({
    doInit: function(component, event, helper) {
        
        var QuoteId =  component.get("v.recordId");
        console.log('QuoteId: '+ QuoteId);
        
         var action = component.get('c.switchSystems');
        
          action.setCallback(component,function(response) {
          console.log('response.switch: ' + response.getReturnValue()); 
          
            var response = response.getReturnValue();

            if (response == true){
           		component.set("v.switch", true); 
                component.set("v.buttonDisable", true); 
            }
           });
        
                helper.check_helper(component,event,helper);
        
         $A.enqueueAction(action);
    },
    
    
    updateCheck11 : function(c, e, h) {
      c.set("v.buttonDisable", false); 
        h.updateCheck11_helper(c,e,h);
    },
    
    
    navigateToRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var coin = component.get("v.message")[idx];
        
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            recordId: coin.Id,
            slideDevName: "detail"
        });
        console.log('navEvent ' +navEvent);
        navEvent.fire(); 
    },
    
    
    deleteCointestestazione: function(component, event, helper) {
        var QuoteId =  component.get("v.recordId");
        helper.deleteCointestestazione_helper(component,QuoteId);
        $A.get("e.force:refreshView").fire();
    },
    
    
    modificaCointestestazione: function(component, event, helper) {
      
  var relatedListEvent = $A.get("e.force:navigateToRelatedList");
  relatedListEvent.setParams({
      "relatedListId": "Fidejussioni__r",
      "parentRecordId": component.get("v.recordId")
  });
  relatedListEvent.fire();

        
        
        
        
        
        
        
        
        
        
        
        
       
    }
})