public class QueueableCofaceDocumentGeneration implements Queueable, Database.AllowsCallouts {
    
    private List<Id> listCreaPDF;
    
    public QueueableCofaceDocumentGeneration(List<id> records) {
        this.listCreaPDF = records;
    }
     
    public void execute(QueueableContext context) {
        
        system.debug('QueueableCofaceDocumentGeneration.execute --- Start listCreaPDF ' + listCreaPDF);
        
        AccountsController.attachPDFSync(listCreaPDF); 
        
        List<Document__c> docList = ([select id, Name, Account__c, Id_File__c, Url_Documento__c, Url_Servizio_Esterno__c from Document__c where DocumentTypeNameFormula__c='Analisi Coface' and Url_Documento__c=null and Url_Servizio_Esterno__c!= null and Account__r.Ricezione_dati_Coface__c='OK' and Account__c IN: listCreaPDF]);
        
        
      
          //system.debug('docList tttttttttttttttt' + docList);
       // system.debug('docList[0].id' + docList[0].id);
        //system.debug('docList[0].Id_File__c' + docList[0].Id_File__c);
        //system.debug('docList[0].Name' + docList[0].Name);
        
            
        if(!Test.isRunningTest()){  
        QueueableCofaceStoreDocument updateJob = new QueueableCofaceStoreDocument(docList);
        
            System.enqueueJob(updateJob);
        
        }
        
        
        system.debug('QueueableCofaceDocumentGeneration.execute --- End');
    }
}