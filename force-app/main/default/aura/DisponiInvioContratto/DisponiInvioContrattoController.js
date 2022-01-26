/**
 * Created by ACAPUTO00 on 18/03/2020.
 */
({

    doInit: function (component, event, helper) {
        },

         handleRecordUpdated: function (component, event, helper) {
            },

    handleDisponiInvioContratto: function(component, event, helper){

            var disponiInvioContrattoAction = component.get("c.disponiInvioContratto");
            disponiInvioContrattoAction.setParam("oppId", component.get("v.recordId"));
            disponiInvioContrattoAction.setCallback(this, function (response) {
                console.log('RESPONSE '+response.getReturnValue());
                component.set("v.message",response.getReturnValue());
            });
            $A.enqueueAction(disponiInvioContrattoAction);

        }

})