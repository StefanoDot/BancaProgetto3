({
	doInit: function(component, event, helper) {

        var QuoteId =  component.get("v.recordId");
        console.log('QuoteId: '+ QuoteId);
        
      
   },
    
	updateCheck11 : function(c, e, h) {
        let button = e.getSource();
    button.set('v.disabled',true);
		h.updateCheck11_helper(c,e,h);
	},
})