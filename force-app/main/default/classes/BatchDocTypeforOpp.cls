global class BatchDocTypeforOpp implements Database.Batchable<sObject>,Database.AllowsCallouts{   
    
  	public List<Id> dtIds = new List<Id>();

    global BatchDocTypeforOpp(
  List<id> dtIds
	        
    ){
	this.dtIds=dtIds;                       
                               
    list<DocumentType__c> custom = [SELECT id, name from DocumentType__c where id in: dtIds];                                
    }

      global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
       System.debug('accIds ' + dtIds);
       // System.debug('query ' + Database.getQueryLocator('select id, Name, Account__c, Id_File__c from Document__c'));
        return Database.getQueryLocator('select id, Name,Tipo_Linea_di_Credito__c  from Opportunity ');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppi){
        //System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        //System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
        List<Document__c> docList = new List<Document__c> ();
                
               list<DocumentType__c> custom = [SELECT id, name, ObjectName__c, Opportunita_Mutuo__c, Opportunita_EasyPlus__c from DocumentType__c where id in: dtIds];     
                          System.debug('DocumentTypeController.oppi '+ oppi);

 for(DocumentType__c c :custom){
     for(Opportunity con:oppi ){
         if(c.ObjectName__c=='Opportunity' && c.Opportunita_Mutuo__c==true){
            System.debug('jemi ketu te opp dhe qe eshte mutuo ');

          if(con.Tipo_Linea_di_Credito__c=='Mutuo'){
                    docList.add(new Document__c(
                            Opportunity__c = con.Id,
                            DocumentType__c= c.Id ));
                    }
         }
         
          if(c.ObjectName__c=='Opportunity' && c.Opportunita_EasyPlus__c==true){
              System.debug('jemi ketu te opp dhe qe eshte easy plus ');
         if(con.Tipo_Linea_di_Credito__c=='Progetto EasyPlus'){
                    docList.add(new Document__c(
                            Opportunity__c = con.Id,
                            DocumentType__c= c.Id ));
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