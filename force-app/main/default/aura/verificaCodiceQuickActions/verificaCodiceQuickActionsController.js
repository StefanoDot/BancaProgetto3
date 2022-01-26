({
    onClickCancel : function(component, event, helper) {
        console.log(  ' close aura'   )
        $A.get("e.force:closeQuickAction").fire();
        // const closeQA = new CustomEvent('close');
        // // Dispatches the event.
        // this.dispatchEvent(closeQA);
    }
})