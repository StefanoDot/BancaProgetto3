global class BatchDeleteCalloutLogger implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('BatchDeleteCalloutLogger.start --- Start');
        // njr ne muaj

        System.debug('BatchDeleteCalloutLogger.start --- End');
        return Database.getQueryLocator([SELECT Id, CreatedDate FROM Callout_Logger__c WHERE CreatedDate < :Date.today().addDays(-30) ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Callout_Logger__c> integrationLogs) {
        System.debug('BatchDeleteCalloutLogger.execute --- Start');
        
        try {
            if( integrationLogs != null && integrationLogs.size() > 0 ) {
                delete integrationLogs;
            }
            
        } catch (DmlException dmlException) {
            System.debug('BatchDeleteCalloutLogger Error' + dmlException.getMessage());
            throw dmlException;
        }
        
        System.debug('BatchDeleteCalloutLogger.execute --- End');
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('BatchDeleteCalloutLogger.finish --- Start');
        
        System.debug('BatchDeleteCalloutLogger.finish --- End');    
    }   
}