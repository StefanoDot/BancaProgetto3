global class  BatchDocQuote implements Database.Batchable<sObject>,Database.AllowsCallouts{   

	public List<DocumentType__c> accIds = new List<DocumentType__c>();  

  	global BatchDocQuote (){
         List<DocumentType__c> docType = [SELECT Id, ObjectName__c , Referente_Fidejussore__c, Opportunita_Mutuo__c, Opportunita_EasyPlus__c FROM DocumentType__c];
      this.accIds.addAll(docType);
  }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
       System.debug('accIds ' + accIds);
        return Database.getQueryLocator('select id, Name, Tipo_Linea_di_Credito__c  from Quote');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Quote> docListe){
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
       
        List<Document__c> docList = new List<Document__c> ();
        
         for (Quote quote: docListe) {
             
                if(quote.Tipo_Linea_di_Credito__c=='Mutuo'){
                
                for (DocumentType__c doc : accIds) {
                    if( doc.ObjectName__c=='Quote' && doc.Opportunita_Mutuo__c==true){
                        docList.add(new Document__c(
                            Quote__c = quote.Id,
                            DocumentType__c = doc.Id
                        ));
                    }
                }
            }
            else if (quote.Tipo_Linea_di_Credito__c=='Progetto EasyPlus')
            {
              
                for (DocumentType__c doc : accIds) {
                    if( doc.ObjectName__c=='Quote' && doc.Opportunita_EasyPlus__c==true ){
                        docList.add(new Document__c(
                            Quote__c = quote.Id,
                            DocumentType__c = doc.Id
                        ));
                    }
                }
            }
             
               
            }
           
        
                system.debug('AccountController.AfterInsertAddDoc - End   docList:'+docList);
        insert docList;
        
        System.debug('CofaceDocumentBatch.execute --- End');
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.finish --- Start');
        
    }
}