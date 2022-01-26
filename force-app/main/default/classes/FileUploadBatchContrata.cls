global class FileUploadBatchContrata implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 

    
    String fileId;
    String filename;  
    String processGuid;
    String documentId;    
    String ObjectID;
    String fidejussioneNameId;
    String fidejussioneFileId;    
    
    global FileUploadBatchContrata(
    String fileId,
    String filename,   
    String processGuid,
    String documentId,
    String ObjectID,
    String fidejussioneNameId,
    String fidejussioneFileId
    ){
    this.fileId=fileId; 
    this.filename=filename;
    this.processGuid=processGuid;       
    this.documentId=documentId;        
    this.ObjectID = ObjectID;
    this.fidejussioneNameId = fidejussioneNameId;
    this.fidejussioneFileId = fidejussioneFileId;
                     
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String idDocument=this.documentId;
         String query='select id, Name, Account__c, Id_File__c, Url_Documento__c, Url_Servizio_Esterno__c, IDTipoDocumentoFormula__c from Document__c where id=:idDocument';
         return Database.getQueryLocator( query);

     }
     global void execute(Database.BatchableContext BC, List<Document__c> docList){
        //system.debug('FileUploadBatch execute: '+this);
        system.debug('FileUploadBatch fileId:'+fileId);
        system.debug('FileUploadBatch fidejussioneFileId:'+fidejussioneFileId);
         for(Document__c dock : docList){
            String contentVersionId =fileUploaderDAO.getContentVersion(fileId);
            String fidejussioneID = fileUploaderDAO.getContentVersion(fidejussioneFileId);
        
         	ElevaRestApiController.contrattoFirmatooCartagio(contentVersionId,  filename, processGuid,documentId,ObjectID , dock.IDTipoDocumentoFormula__c, fidejussioneNameId, fidejussioneID );
        }
        /*ContentDocument cd =new ContentDocument(id=fileid);
        ContentDocument cd2 =new ContentDocument(id=fidejussioneFileId);
         delete cd;
         delete cd2;*/
     }
    global void finish(Database.BatchableContext BC){
    }
}