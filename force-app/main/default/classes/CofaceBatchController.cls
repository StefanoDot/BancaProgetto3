global class  CofaceBatchController implements Database.Batchable<sObject>,Database.AllowsCallouts{  
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceBatchController.start --- Start');
        //cdo dite
        Integer limitSize = Integer.valueOf(System.Label.CofaceBatchLimit);
        System.debug('query ' + Database.getQueryLocator('Select id, Partita_Iva__c, Ricezione_dati_Coface__c From Account '));
        
        return Database.getQueryLocator('Select id, Partita_Iva__c, Ricezione_dati_Coface__c From Account where  IsPartner =false  and CreatedDate >2021-03-01T01:14:28.275+01:00  and  Ricezione_dati_Coface__c=\'Presa in carico\' LIMIT :limitSize');
 
    }
    
    global void execute(Database.BatchableContext BC,  List<Account> accList){
        System.debug('CofaceBatchController.execute --- Start scope'+accList);
        System.debug('CofaceBatchController.execute --- Start scope'+accList.size());
        
       List<String> partitaIva = new List<String>();
        
        for (Account acc: accList) { 
            partitaIva.add(acc.Partita_Iva__c);
        }
        
        System.debug('partitaIva' +partitaIva);
        ElevaRestApiController.cofaceFlusso2(partitaIva);

        System.debug('CofaceBatchController.execute --- End');
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('CofaceBatchController.finish --- Start');

        CofaceDocumentBatch documentBatch= new CofaceDocumentBatch();
        Id batchId = Database.executeBatch(documentBatch, 1);
        
        System.debug('CofaceBatchController.finish --- End');
        
        
    }
}