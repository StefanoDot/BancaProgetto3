({
    addObjInfoToList: function (component, oppAndAccDocumentTypeList) {
        let uniqueDocTypeObjects = new Map();
        let self = this;

        for (let i = 0; i < oppAndAccDocumentTypeList.length; i++) {
            let docType = oppAndAccDocumentTypeList[i];
            docType['objTextCondition'] = false;
            docType['objText'] = '';
            let objectName = docType.ObjectName__c;

            if (!uniqueDocTypeObjects.has(objectName)) {
                docType['objTextCondition'] = true;
                docType['objText'] = self.setObjectText(docType, '', '');
                uniqueDocTypeObjects.set(objectName, true);
            }
        }
        return oppAndAccDocumentTypeList;
    },

    addObjInfoToContact: function (component, contactName, contactDocumentTypes) {
        let uniqueContactDocTypeObjects = new Map();
        let self = this;

        for (let i = 0; i < contactDocumentTypes.length; i++) {
            let docType = contactDocumentTypes[i];
            docType['objTextCondition'] = false;
            docType['objText'] = '';
            let objectName = docType.ObjectName__c;
            if (!uniqueContactDocTypeObjects.has(objectName)) {
                docType['objTextCondition'] = true;
                docType['objText'] = self.setObjectText(docType, contactName, '');
                uniqueContactDocTypeObjects.set(objectName, true);
            } else {

            }
        }
        return contactDocumentTypes;
    },

    addObjInfoToQuote: function (component, quoteName, quoteDocumentTypes) {
        let uniqueContactDocTypeObjects = new Map();
        let self = this;

        for (let i = 0; i < quoteDocumentTypes.length; i++) {
            let docType = quoteDocumentTypes[i];
            docType['objTextCondition'] = false;
            docType['objText'] = '';
            let objectName = docType.ObjectName__c;
            if (!uniqueContactDocTypeObjects.has(objectName)) {
                docType['objTextCondition'] = true;
                docType['objText'] = self.setObjectText(docType, '', quoteName);
                uniqueContactDocTypeObjects.set(objectName, true);
            } else {

            }
        }
        return quoteDocumentTypes;
    },

    setObjectText: function (docType, contactName, quoteName) {
        switch (docType.ObjectName__c) {
            case 'Account' :
                return 'Per l\'Anagrafica:';
            case 'Opportunity' :
                return 'Per l\'Opportunita:';
            case 'Contact' :
                return 'Per Contact '+ contactName + ':';
            case 'Quote' :
                return 'Per la Linea di Credito '+ quoteName + ':';
            default: 'NO';
        }
    }

});