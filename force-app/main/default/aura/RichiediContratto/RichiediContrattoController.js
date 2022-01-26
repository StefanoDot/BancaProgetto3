({
    doInit: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let actionCheck = component.get('c.checkCambioStipula');

        component.set("v.showLoadingSpinner", true);

        actionCheck.setParams({
            "oppId": recordId
        });

        actionCheck.setCallback(this, function (response) {
            let toastEvent = $A.get("e.force:showToast");
            let closeQuickAction = $A.get("e.force:closeQuickAction");
            let responseValue = response.getReturnValue();

            if (responseValue.ok === false) {
                if (responseValue.error === true) {
                    closeQuickAction.fire();

                    toastEvent.setParams({
                        "mode": "sticky",
                        "title": "Per richedere il contratto occorre:",
                        "message": responseValue.responseMessage,
                        "type": "error"
                    });
                    toastEvent.fire();
                } else {

                    component.set("v.showLoadingSpinner", false);
                    component.set("v.title", responseValue.title);
                    component.set("v.message", responseValue.responseMessage);
                    component.set("v.areFields", true);
                }
            } else {
                component.set("v.showLoadingSpinner", false);

                if (responseValue.imediatelyManual === true) {
                    component.set("v.onlyManual", true);
                    component.set("v.isManuale", true);
                    component.set("v.title", responseValue.title);
                    component.set("v.message", responseValue.responseMessage);
                } else {
                    component.set("v.secondWindow", false);
                    component.set("v.isDigitale", responseValue.error);
                    component.set("v.contact", responseValue.con);
                    component.set("v.title", responseValue.title);
                    component.set("v.message", responseValue.responseMessage);

                    let conditionsMap = [];
                    let responseMap = responseValue.condizioni;

                    for (let key in responseMap) {
                        conditionsMap.push({value: responseMap[key], key: key});
                    }

                    component.set("v.myMap", conditionsMap);
                }
            }
        });
        $A.enqueueAction(actionCheck);
    },

    digitalFirm: function (component, event, helper) {
        component.set("v.secondWindow", true);
        component.set("v.isManuale", false);
        component.set("v.tipoFirma", 'Hai selezionato Firma Digitale.');
    },

    manualFirm: function (component, event, helper) {
        component.set("v.secondWindow", true);
        component.set("v.isManuale", true);
        component.set("v.tipoFirma", 'Hai selezionato Firma Manuale.');
    },

    yesButton: function (component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled', true);
        let recordId = component.get("v.recordId");
        let isManuale = component.get("v.isManuale");

        let actionCheck = component.get('c.decideTipoFirma');
        actionCheck.setParams({
            "recordId": recordId,
            "isManuale": isManuale
        })

        actionCheck.setCallback(component, function (response) {
            let responseValue = response.getReturnValue();
            let toastEvent = $A.get("e.force:showToast");
            if (responseValue.ok === true) {
                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Success!",
                    "message": responseValue.responseMessage,
                    "type": "success"
                });
                toastEvent.fire();
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(actionCheck);
    },

    refresh: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

    navigateToRecord: function (component, event, helper) {
        let cont = component.get("v.contact");
        let navEvent = $A.get("e.force:navigateToSObject");

        navEvent.setParams({
            recordId: cont.Id,
            slideDevName: "detail"
        });
        navEvent.fire();
    },

    goBack: function (component, event, helper) {
        component.set("v.secondWindow", false);
    }

})