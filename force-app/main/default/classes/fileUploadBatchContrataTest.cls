@isTest 
public class fileUploadBatchContrataTest {
      @isTest static void testFileUpload(){
        
        List<ContentVersion> cntVersion = new List<ContentVersion>();
        Account acc = ObjectFactory.generateAccount();
          insert acc;
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        Contact cont = new Contact();
        cont.LastName = 'test';
        cont.RecordTypeId = recordTypeIdRefOpl;
        cont.Fidejussore__c = true;
        cont.Email = 'aldora@gmail.com';
        cont.Phone = '123456789';
        cont.NDG__c = '12345';
        cont.Ruolo_in_Azienda__c = 'Titolare Effettivo';
        cont.AccountId = acc.Id;
        cont.firmatario__c = true;
          insert cont;
        
        DocumentType__c dt = ObjectFactory.insertNewDocumentType('Account');

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
        doc.Name = 'Doc';
        doc.Url_Servizio_Esterno__c=c.Title;
        Datetime uploadDate = Datetime.now();
        doc.Data_Caricamento__c = uploadDate;
        doc.DocumentType__c=dt.id;
      
        insert doc;
          
        ContentVersion cVer = new ContentVersion();
        cVer.ContentLocation = 'S';
        cVer.PathOnClient = 'Analisi Coface.pdf';
        cVer.Origin = 'H';
        cVer.Title = 'Analisi Coface.pdf';
        cVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cVer;
        DocumentType__c docT = ObjectFactory.insertNewDocumentType('Quote');
        ContentVersion cv =[SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id =: cVer.id];
        Document__c d = new Document__c();
        d.Name = 'DocFide';
        d.DocumentType__c = docT.Id;
        d.Commento_Sales_Support__c = 'Elevaaaa';
        d.Id_File__c=cv.ContentDocumentId;
        insert d;

        
        Document__c docu = [select id, name, Id_File__c from Document__c where Name = 'Doc'];
        Document__c docuFide = [select id, name, Id_File__c from Document__c where Name = 'DocFide'];
		Contact ct = [select Id, Name from Contact limit 1];
        String fidejussioneNameId = docuFide.Name;
        String fidejussioneFileId = docuFide.Id_File__c;
        String fileId = docu.Id_File__c;
        test.startTest();
        FileUploadBatchContrata myBatchObject = new FileUploadBatchContrata(fileId, 'test','test',d.Id, 'eha', fidejussioneNameId, fidejussioneFileId);                                      
        Id batchId = Database.executeBatch(myBatchObject, 1);
        test.stopTest(); 
    }
    

}