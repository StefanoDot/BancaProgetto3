@isTest
public class fileUploadBatchTest {
    @isTest static void testFileUpload(){
        
        List<ContentVersion> cntVersion = new List<ContentVersion>();
        List<Document__c> docList = new List<Document__c>();
        
        DocumentType__c dt = ObjectFactory.insertNewDocumentType('Account');
        //insert dt;

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'Analisi Coface.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = 'Analisi Coface.pdf';
        cVersion.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        cntVersion.add(cVersion);
        insert cntVersion;
        
        ContentVersion c =[SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id IN:cntVersion limit 1];
        
        
        Document__c doc = new Document__c();
        doc.Id_File__c=c.ContentDocumentId;
        doc.Url_Servizio_Esterno__c=c.Title;
        Datetime uploadDate = Datetime.now();
        doc.Data_Caricamento__c = uploadDate;
        doc.DocumentType__c=dt.id;
        docList.add(doc);
        insert docList;
        
        Document__c d = [select id, name, Id_File__c from Document__c limit 1];
        
        test.startTest();
        FileUploadBatch myBatchObject = new FileUploadBatch(
            d.Id_File__c, 
            'test',
            (string)d.Id,
             'test',
              d.Id_File__c,
              d.Id_File__c,
              Datetime.now(),
              d.Id_File__c,
              'test',
              '12345678912',
               '12345678',
               Datetime.now(),
               'test',
               d.Id_File__c,
               'test',
               'test',
               'test@test.com',
               'test',
               'test',
               'test',
               'test',
               'test');                                      
        Id batchId = Database.executeBatch(myBatchObject, 1);
        test.stopTest(); 
    }
    
}