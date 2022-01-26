global class  BatchDocTypeforAccountfalse implements Database.Batchable<sObject>,Database.AllowsCallouts{   
     
  	public List<Id> dtIds = new List<Id>();

    global BatchDocTypeforAccountfalse(
  List<id> dtIds
	        
    ){
	this.dtIds=dtIds;                       
 list<DocumentType__c> custom = [SELECT id, name from DocumentType__c where id in: dtIds];                                
    }

      global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
       System.debug('accIds ' + dtIds);
       // System.debug('query ' + Database.getQueryLocator('select id, Name, Account__c, Id_File__c from Document__c'));
        return Database.getQueryLocator('select id, Name,Fidejussore__c  from Account ');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> acci){
        //System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        //System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
        List<Document__c> docList = new List<Document__c> ();
          
        list<DocumentType__c> custom = [SELECT id, name,ObjectName__c,Referente_Fidejussore__c from DocumentType__c where id in: dtIds];     
                          System.debug('DocumentTypeController.acci '+ acci);

 for(DocumentType__c c :custom){
         for (Account acc: acci) {
             if(c.ObjectName__c=='Account' && c.Referente_Fidejussore__c==false){
              if (acc.Fidejussore__c == false){
                 docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = c.Id ));
                 
             }
             }
              if(c.ObjectName__c=='Account' && c.Referente_Fidejussore__c==true){
              if(acc.Fidejussore__c == true){
                    docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = c.Id ));
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