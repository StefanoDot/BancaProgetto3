({
    doInit: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let actionCheck = component.get('c.profileDoc');
        actionCheck.setParams({
            "recordId": recordId
        }),
        
        actionCheck.setCallback(this, function (response) {
            let responseValue = response.getReturnValue();

            if (responseValue.ok === true) {
                component.set("v.visibile", true);
            }
        });
        $A.enqueueAction(actionCheck);
    },
    passDataToMassiveDownload: function (component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED")
            {
                let opportunity = component.get("v.opportunityRecord");
                console.log("before backend "  +JSON.stringify(opportunity));
                component.set("v.accountId",opportunity.AccountId);
            }
        
        
    },
    getMissingMandatoryDocTypes: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get('c.GetMissingMandatoryDocTypes');
        let buttonName = event.getSource().get('v.name');

        component.set("v.showLoadingSpinner", true);

        if (buttonName === 'docMancantiBtn') {
            component.set('v.openMancantiModal', true)
        } else if (buttonName === 'docNonVerificatiBtn') {
            component.set('v.openNonVerificatiModal', true)
        }

        action.setParams({
            'opportunityId' : recordId,
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showLoadingSpinner", false);
                let responseValue = response.getReturnValue();
                let emptyOppAndAccDocTypes = responseValue.emptyOppAndAccDocTypes;
                let notVerifiedOppAndAccDocTypes = responseValue.notVerifiedOppAndAccDocTypes
                let emptyContactDocTypesMap = new Map();
                let notVerifiedContactDocTypesMap = new Map();
                let emptyQuoteDocTypesMap = new Map();
                let notVerifiedQuoteDocTypesMap = new Map();

                for (let [contactName, contactDocTypes] of Object.entries(JSON.parse(JSON.stringify(responseValue.emptyContactDocTypes)))) {
                    emptyContactDocTypesMap.set(contactName, contactDocTypes);
                }

                for (let [contactName, contactDocTypes] of Object.entries(JSON.parse(JSON.stringify(responseValue.notVerifiedContactDocTypes)))) {
                    notVerifiedContactDocTypesMap.set(contactName, contactDocTypes);
                }

                for (let [quoteName, quoteDocTypes] of Object.entries(JSON.parse(JSON.stringify(responseValue.emptyQuoteDocTypes)))) {
                    emptyQuoteDocTypesMap.set(quoteName, quoteDocTypes);
                }

                for (let [quoteName, quoteDocTypes] of Object.entries(JSON.parse(JSON.stringify(responseValue.notVerifiedQuoteDocTypes)))) {
                    notVerifiedQuoteDocTypesMap.set(quoteName, quoteDocTypes);
                }

                console.log('emptyQuoteDocTypesMap = ' + emptyQuoteDocTypesMap);
                console.log('notVerifiedQuoteDocTypesMap = ' + emptyQuoteDocTypesMap);

                if (emptyOppAndAccDocTypes.length === 0) {
                    component.set("v.oppAndAccDocTypesAreUploaded", true);
                } else {
                    helper.addObjInfoToList(component, emptyOppAndAccDocTypes);
                    component.set("v.emptyOppAndAccDocTypes", emptyOppAndAccDocTypes);
                }

                if (notVerifiedOppAndAccDocTypes.length === 0) {
                    component.set("v.oppAndAccDocTypesAreVerified", true);
                } else {
                    helper.addObjInfoToList(component, notVerifiedOppAndAccDocTypes);
                    component.set("v.notVerifiedOppAndAccDocTypes", notVerifiedOppAndAccDocTypes);
                }

                if (emptyContactDocTypesMap.size === 0) {
                    component.set("v.contactDocTypesAreUploaded", true);
                } else {
                    let updatedEmptyDocTypesInContact = [];
                    for (const [contactName, emptyDocTypesInContact] of emptyContactDocTypesMap) {
                        let resultList = helper.addObjInfoToContact(component, contactName, emptyDocTypesInContact);
                        for (let i = 0; i < resultList.length; i++) {
                            let docType = resultList[i];
                            updatedEmptyDocTypesInContact.push(docType);
                        }
                    }
                    component.set("v.emptyContactDocTypes", updatedEmptyDocTypesInContact);
               }

                if (notVerifiedContactDocTypesMap.size === 0) {
                    component.set("v.contactDocTypesAreVerified", true);
                } else {
                    let updatedNotVerifiedDocTypesInContact = [];
                    for (const [contactName, notVerifiedContactDocTypes] of notVerifiedContactDocTypesMap) {
                        let resultList = helper.addObjInfoToContact(component, contactName, notVerifiedContactDocTypes);
                        for (let i = 0; i < resultList.length; i++) {
                            let docType = resultList[i];
                            updatedNotVerifiedDocTypesInContact.push(docType);
                        }
                    }
                    component.set("v.notVerifiedContactDocTypes", updatedNotVerifiedDocTypesInContact);
                }

                if (emptyQuoteDocTypesMap.size === 0) {
                    component.set("v.quoteDocTypesAreUploaded", true);
                } else {
                    let updatedEmptyDocTypesInQuote = [];
                    for (const [quoteName, emptyDocTypesInQuote] of emptyQuoteDocTypesMap) {
                        let resultList = helper.addObjInfoToQuote(component, quoteName, emptyDocTypesInQuote);
                        for (let i = 0; i < resultList.length; i++) {
                            let docType = resultList[i];
                            updatedEmptyDocTypesInQuote.push(docType);
                        }
                    }
                    component.set("v.emptyQuoteDocTypes", updatedEmptyDocTypesInQuote);
                }

                if (notVerifiedQuoteDocTypesMap.size === 0) {
                    component.set("v.quoteDocTypesAreVerified", true);
                } else {
                    let updatedNotVerifiedDocTypesInQuote = [];

                    for (const [quoteName, notVerifiedQuoteDocTypes] of notVerifiedQuoteDocTypesMap) {
                        let resultList = helper.addObjInfoToQuote(component, quoteName, notVerifiedQuoteDocTypes);

                        for (let i = 0; i < resultList.length; i++) {
                            let docType = resultList[i];
                            updatedNotVerifiedDocTypesInQuote.push(docType);
                        }
                    }
                    component.set("v.notVerifiedQuoteDocTypes", updatedNotVerifiedDocTypesInQuote);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getNonVerifiedDocTypes: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get('c.GetNotVerifiedDocumentTypes');

        component.set("v.showLoadingSpinner", true);
        component.set('v.openNonVerificatiModal', true)

        action.setParams({
            'opportunityId' : recordId,
        })
        action.setCallback(this, function (response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.showLoadingSpinner", false);
                let responseValue = response.getReturnValue();
                console.log('response ' + JSON.stringify(responseValue));
                let notVerifiedOppAndAccDocTypes = responseValue.notVerifiedOppAndAccDocTypes;
                let optionalList = responseValue.optionalDocuments;
                if(optionalList.length > 0){
                    component.set("v.isOptionalDocuments", true);
                    component.set("v.optionalDocumentsList", optionalList);
                }
                let notVerifiedContactDocTypesMap = new Map();
                let notVerifiedQuoteDocTypesMap = new Map();

                for (let [contactName, contactDocTypes] of Object.entries(JSON.parse(JSON.stringify(responseValue.notVerifiedContactDocTypes)))) {
                    notVerifiedContactDocTypesMap.set(contactName, contactDocTypes);
                }

                for (let [quoteName, quoteDocTypes] of Object.entries(JSON.parse(JSON.stringify(responseValue.notVerifiedQuoteDocTypes)))) {
                    notVerifiedQuoteDocTypesMap.set(quoteName, quoteDocTypes);
                }

                if (notVerifiedOppAndAccDocTypes.length === 0) {
                    component.set("v.oppAndAccDocTypesAreVerified", true);
                } else {
                    helper.addObjInfoToList(component, notVerifiedOppAndAccDocTypes);
                    component.set("v.notVerifiedOppAndAccDocTypes", notVerifiedOppAndAccDocTypes);
                }

                if (notVerifiedContactDocTypesMap.size === 0) {
                    component.set("v.contactDocTypesAreVerified", true);
                } else {
                    let updatedNotVerifiedDocTypesInContact = [];
                    for (const [contactName, notVerifiedContactDocTypes] of notVerifiedContactDocTypesMap) {
                        let resultList = helper.addObjInfoToContact(component, contactName, notVerifiedContactDocTypes);
                        for (let i = 0; i < resultList.length; i++) {
                            let docType = resultList[i];
                            updatedNotVerifiedDocTypesInContact.push(docType);
                        }
                    }
                    component.set("v.notVerifiedContactDocTypes", updatedNotVerifiedDocTypesInContact);
                }

                if (notVerifiedQuoteDocTypesMap.size === 0) {
                    console.log('notVerifiedQuoteDocTypesMap size = 0');
                    component.set("v.quoteDocTypesAreVerified", true);
                } else {
                    console.log('notVerifiedQuoteDocTypesMap size NOT 0');
                    let updatedNotVerifiedDocTypesInQuote = [];

                    for (const [quoteName, notVerifiedQuoteDocTypes] of notVerifiedQuoteDocTypesMap) {
                        console.log('quoteName = ' + quoteName);
                        console.log('notVerifiedQuoteDocTypes = ' + notVerifiedQuoteDocTypes);
                        let resultList = helper.addObjInfoToQuote(component, quoteName, notVerifiedQuoteDocTypes);

                        for (let i = 0; i < resultList.length; i++) {
                            let docType = resultList[i];
                            updatedNotVerifiedDocTypesInQuote.push(docType);
                        }
                    }
                    component.set("v.notVerifiedQuoteDocTypes", updatedNotVerifiedDocTypesInQuote);
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeMancantiModal: function (component, event, helper) {
        let cmpTarget = component.find('editDialog');
        let cmpBack = component.find('overlay');

        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');

        component.set('v.openMancantiModal', false);
    },

    closeNonVerificatiModal: function (component, event, helper) {
        let cmpTarget = component.find('editDialog');
        let cmpBack = component.find('overlay');

        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');

        component.set('v.openNonVerificatiModal', false);
    }
   
})