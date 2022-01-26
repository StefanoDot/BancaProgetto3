public class QueueableCofaceStoreDocument implements Queueable, Database.AllowsCallouts {
    
    private List<Document__c> docList;
    
    public QueueableCofaceStoreDocument(List<Document__c> records) {
        this.docList = records;
    }
    
    
    public void execute(QueueableContext context) {
        
        system.debug('QueueableCofaceStoreDocument.execute --- Start docList ' + docList);
        
 for (Document__c doc: docList) { 
             system.debug('doc.Id_File__c' + doc.Id_File__c);
              fileUploaderDAO.updateFile(doc.Id, doc.Url_Servizio_Esterno__c, doc.Id_File__c,'aggiungi');
        }
        

        system.debug('QueueableCofaceStoreDocument.execute --- End');
    }
}