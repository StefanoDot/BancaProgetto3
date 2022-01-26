global class  BatchDocOpportunity implements Database.Batchable<sObject>,Database.AllowsCallouts{   

	public List<DocumentType__c> accIds = new List<DocumentType__c>();  

  	global BatchDocOpportunity (){
         List<DocumentType__c> docType = [SELECT Id, ObjectName__c , Referente_Fidejussore__c, Opportunita_Mutuo__c, Opportunita_EasyPlus__c FROM DocumentType__c];
      this.accIds.addAll(docType);
  }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
       System.debug('accIds ' + accIds);
       // System.debug('query ' + Database.getQueryLocator('select id, Name, Account__c, Id_File__c from Document__c'));
        return Database.getQueryLocator('select id, Name, Tipo_Linea_di_Credito__c  from Opportunity ');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> docListe){
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
       
        List<Document__c> docList = new List<Document__c> ();
        
         for (Opportunity opp: docListe) { 
             
                for (DocumentType__c doc : accIds) {
                    if( doc.ObjectName__c=='Opportunity' ){
                        docList.add(new Document__c(
                            Opportunity__c = opp.Id,
                            DocumentType__c = doc.Id
                        ));
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