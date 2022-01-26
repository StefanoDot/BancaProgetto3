global class FileUploadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 

    
    String fileId;
    String filename;
    String documentId;        
    String documentFamily;
    String objectId; 
    String accountId;
    Datetime uploadDate;       
    String documentTypeId;
    String docName;
    String taxCode; 
    String contractNumber; 
    Datetime stipulationDate;
    String description;
    String idOplon;
    String stage;
    String objectType;
    String userEmail;
    String contactTaxCode;
    String nominativoReferente;
    String contactIdSalesforce;
    String action;
    String gui;     
    
    global FileUploadBatch(
        String fileId,
        String filename,
        String documentId,       
        String documentFamily,
        String objectId,
        String accountId,
        Datetime uploadDate,       
        String documentTypeId,
        String docName, 
        String taxCode, 
        String contractNumber,
        Datetime stipulationDate,
        String description,
        String idOplon, 
        String stage,
        String objectType, 
        String userEmail,
        String contactTaxCode,
        String nominativoReferente,
        String contactIdSalesforce,
        String action,
        String gui
	        
    ){
        this.fileId=fileId; 
        this.filename=filename;
        this.documentId=documentId;         
        this.documentFamily=documentFamily;
        this.objectId=objectId;
        this.accountId=accountId; 
        this.uploadDate=uploadDate;       
        this.documentTypeId=documentTypeId;
        this.docName=docName; 
        this.taxCode=taxCode;
        this.contractNumber= contractNumber;
        this.stipulationDate=stipulationDate;
        this.description=description;
        this.idOplon=idOplon;
        this.stage=stage;
        this.objectType=objectType; 
        this.userEmail=userEmail;
        this.contactTaxCode=contactTaxCode;
        this.nominativoReferente=nominativoReferente;
        this.contactIdSalesforce=contactIdSalesforce;
        this.action = action;
        this.gui = gui;      
                               
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String idDocument=this.documentId;
         String query='select id, Name, Account__c, Id_File__c, Url_Documento__c, File_Name__c, Url_Servizio_Esterno__c, IDTipoDocumentoFormula__c from Document__c where id=:idDocument';
         return Database.getQueryLocator( query);

     }
     global void execute(Database.BatchableContext BC, List<Document__c> docList){
        //system.debug('FileUploadBatch execute: '+this);
        system.debug('FileUploadBatch fileId:'+fileId);
         for(Document__c dock : docList){
            String contentVersionId =fileUploaderDAO.getContentVersion(fileId);
             
             ElevaRestApiController.storeDocument( contentVersionId,  filename,  documentId,  documentFamily,  objectId,  accountId,  uploadDate,
                                                  documentTypeId,  docName,  taxCode,  contractNumber,  stipulationDate,  description,  idOplon,  stage, 
                                                  objectType,  userEmail,contactTaxCode,nominativoReferente,contactIdSalesforce,action,gui, dock.File_Name__c);
         }
         if(action != 'elimina')
         {
             ContentDocument cd =new ContentDocument(id=fileid);
             delete cd;
         }
     }
    global void finish(Database.BatchableContext BC){
    }
}