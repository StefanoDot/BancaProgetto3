({
    subscribe: function (component, event, helper) {
        console.log('in subscribe');
        const empApi = component.find('empApi');
        const channel = component.get('v.channel');
        const replayId = -1;
        const callback = function (message) {
            console.log('Event Received : ' + JSON.stringify(message));
            helper.onReceiveNotification(component, message);
        };
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
            console.log('Subscribed to channel ' + channel);
            component.set('v.subscription', newSubscription);
        }));
    },
    unsubscribe: function (component, event, helper) {
        const empApi = component.find('empApi');
        const channel = component.get('v.subscription').channel;
        const callback = function (message) {
            console.log('Unsubscribed from channel ' + message.channel);
        };
        empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
    },
    onReceiveNotification: function (component, message) {
        var notification= message.data.payload.Is_Refresh__c;
        var currentRecId= message.data.payload.Record_Id__c;
        console.log('notification and caseId ----->',notification ,' currentRecId -',currentRecId);
        console.log('rec id --------> ',component.get("v.recordId"));
        if(currentRecId === component.get("v.recordId")){
            console.log('inside if');
            setTimeout(
                $A.getCallback(function() {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ATTENZIONE !",
                        "type": "warning",
                        "mode":"dismissible",
                        "duration":"10000",
                        "message": $A.get("$Label.c.Contact_Tipo_Document_Warning")
                    });
                    toastEvent.fire();
                    
                    
                }), 5000);
        }
        
        
    },
    displayToast: function (component, type,title, message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})