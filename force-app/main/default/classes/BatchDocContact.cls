global class  BatchDocContact implements Database.Batchable<sObject>,Database.AllowsCallouts{   

	public List<DocumentType__c> accIds = new List<DocumentType__c>();  

  	global BatchDocContact (){
         List<DocumentType__c> docType = [SELECT Id, ObjectName__c , Referente_Fidejussore__c FROM DocumentType__c];
      this.accIds.addAll(docType);
  }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.start --- Start');
       System.debug('accIds ' + accIds);
       // System.debug('query ' + Database.getQueryLocator('select id, Name, Account__c, Id_File__c from Document__c'));
        return Database.getQueryLocator('select id, Name,Fidejussore__c , Ruolo_in_Azienda__c from Contact ');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> docListe){
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe);
        System.debug('CofaceDocumentBatch.execute --- Start scope'+docListe.size());
       
      
        List<Document__c> docList = new List<Document__c> ();
        for (Contact con : docListe) {
            if( con.Fidejussore__c == true){
                for (DocumentType__c doc : accIds) {
                    if(doc.ObjectName__c=='Contact'){
                        //      System.debug(' DocumentType__c doc is ' + doc);
                        
                        //    system.debug('**** FOR doc '+doc);
                        
                        docList.add(new Document__c(
                            Contact__c = con.Id,
                            DocumentType__c = doc.Id
                        ));
                    }
                }
            }
            
            else  if(con.Fidejussore__c==false && ((con.Ruolo_in_Azienda__c=='Titolare Effettivo') ||(con.Ruolo_in_Azienda__c=='Legale Rappresentante') || (con.Ruolo_in_Azienda__c=='Titolare Effettivo;Legale Rappresentante') )){
                for (DocumentType__c doc : accIds) {
                    if(doc.ObjectName__c=='Contact' && doc.Referente_Fidejussore__c==false){
                        //     System.debug(' DocumentType__c doc is ' + doc);
                        
                        //    system.debug('**** FOR doc '+doc);
                        
                        docList.add(new Document__c(
                            Contact__c = con.Id,
                            DocumentType__c = doc.Id
                        ));
                    }
                }
            }
            
        }
        system.debug('ContactController.AfterInsertAddDoc - End   docList: ' + docList);
        
        insert docList;
        
       
        System.debug('CofaceDocumentBatch.execute --- End');
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('CofaceDocumentBatch.finish --- Start');
        
    }
}