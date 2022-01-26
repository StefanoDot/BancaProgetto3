global class  CofaceDocumentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{   

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
        
        System.debug('query ' + Database.getQueryLocator('select id, Name, Account__c, Id_File__c,Url_Servizio_Esterno__c, Url_Documento__c from Document__c where DocumentTypeNameFormula__c=\'Analisi Coface\' and Account__c=\'0011w00000q8lb3AAA\''));
       
        return Database.getQueryLocator('select id, Name, Account__c, Id_File__c, Url_Documento__c, Url_Servizio_Esterno__c from Document__c where DocumentTypeNameFormula__c=\'Analisi Coface\' and Url_Documento__c=null and Url_Servizio_Esterno__c!= null and Account__r.Ricezione_dati_Coface__c=\'OK\'');
        
        //     return Database.getQueryLocator('select id, Name, Account__c, Id_File__c,Url_Servizio_Esterno__c, Url_Documento__c from Document__c where DocumentTypeNameFormula__c=\'Analisi Coface\' and Account__c=\'0011w00000q95ydAAA\'');

    }
    
    global void execute(Database.BatchableContext BC, List<Document__c> docList){
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docList);
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docList.size());
        
         for (Document__c doc: docList) { 
             system.debug('doc.Id_File__c' + doc.Id_File__c);
              fileUploaderDAO.updateFile(doc.Id, doc.Url_Servizio_Esterno__c, doc.Id_File__c,'aggiungi');
        }
        
        System.debug('CofaceDocumentBatch.execute --- End');
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.finish --- Start');
        
    }
}