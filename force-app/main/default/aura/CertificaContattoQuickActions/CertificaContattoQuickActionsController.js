({
    onClickCancel : function(component, event, helper) {
        console.log(  ' close aura'   )
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get("v.recordId"),
              "slideDevName": "Detail"
            });
            navEvt.fire();
         // $A.get("e.force:closeQuickAction").fire();
         // $A.get('e.force:refreshView').fire();
        // const closeQA = new CustomEvent('close');
        // // Dispatches the event.
        // this.dispatchEvent(closeQA);
    },
    refreshView: function(component, event) {
        // refresh the view
        console.log('REFRESH VIEW');
        $A.get('e.force:refreshView').fire();

    /*   var navEvt = $A.get("e.force:navigateToSObject");
           navEvt.setParams({
             "recordId": "0031w00000RgoHaAAJ"});
           navEvt.fire();*/

    }
})