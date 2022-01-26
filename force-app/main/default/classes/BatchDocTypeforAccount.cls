global class BatchDocTypeforAccount implements database.Batchable <DocumentType__c> {
    
  	public List<Id> dtIds = new List<Id>();

    global BatchDocTypeforAccount(
  List<id> dtIds
	        
    ){
	this.dtIds=dtIds;                       
                               
    }

     Global Iterable<DocumentType__c> start(Database.BatchableContext bc){
      list<DocumentType__c> custom = [SELECT id, name from DocumentType__c where id in: dtIds];  
                  System.debug('DocumentTypeController.custom '+ custom);

      return custom;  
    }
    
    global void execute(Database.BatchableContext BC, List<DocumentType__c> custom){
        //System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        //System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
        List<Document__c> docList = new List<Document__c> ();
                List<Account> acci = [select id, Fidejussore__c , name from Account where Fidejussore__c =true ];
                List<Contact> conti = [select id, Fidejussore__c , name from Contact where Fidejussore__c =true ];
                          System.debug('DocumentTypeController.acci '+ acci);

 for(DocumentType__c c :custom){
         for (Account acc: acci) { 
             if(acc.Fidejussore__c == true){
                    docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = c.Id ));
                    }
             
             
                }
     for(Contact con:conti ){
          if(con.Fidejussore__c == true){
                    docList.add(new Document__c(
                            Contact__c = con.Id,
                            DocumentType__c= c.Id ));
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