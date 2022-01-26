global class  BatchDocAccCrea implements Database.Batchable<sObject>,Database.AllowsCallouts{   

	public List<DocumentType__c> accIds = new List<DocumentType__c>();  

  	global BatchDocAccCrea (){
         List<DocumentType__c> docType = [SELECT Id, ObjectName__c , Referente_Fidejussore__c FROM DocumentType__c  where  Opportunita_Mutuo__c=true];
      this.accIds.addAll(docType);
  }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
       System.debug('accIds ' + accIds);
       // System.debug('query ' + Database.getQueryLocator('select id, Name, Account__c, Id_File__c from Document__c'));
        return Database.getQueryLocator('select id, Name,Fidejussore__c  from Account ');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> docListe){
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
       
        List<Document__c> docList = new List<Document__c> ();
        
         for (Account acc: docListe) { 
             if(acc.Fidejussore__c == true){
                for (DocumentType__c doc : accIds) {
                    if( doc.ObjectName__c=='Account'){
                        docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = doc.Id ));
                    }
                }
            }   
            
            else if (acc.Fidejussore__c == false){
                
                for (DocumentType__c doc : accIds) {
                    if( doc.ObjectName__c=='Account' && doc.Referente_Fidejussore__c==false){
                        docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = doc.Id ));
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