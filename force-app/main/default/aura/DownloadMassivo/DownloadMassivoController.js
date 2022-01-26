({
    doInit: function(component, event, helper){       
                component.set("v.showLoadingSpinner", true); 

       var recordId =  component.get("v.recordId");
       console.log('recordId: '+ recordId);
       var actionCheck = component.get('c.checkCount');
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
              component.set("v.activo",false);
               
           }                
       });
       $A.enqueueAction(actionCheck);
   },
   
   navigateToUrl : function(c, e, h) { 
    window.open('https://bancaprogetto-preprod.documentale.online/ar/documents/bpdocpreview/AllegatiContrattoSME/1d81c66f-6d68-4f7a-9618-10be24985ca8', "_blank");

      /* console.log('log 1 ');
      c.set("v.activo",true);
      console.log('log 2 ');
       h.NavigateToUrl_helper(c,e,h);
       console.log('log end');
    */
   },
})