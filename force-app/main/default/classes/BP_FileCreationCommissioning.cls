public with sharing class BP_FileCreationCommissioning {
    
    public static ContentDocumentLink createFile (BP_CommissioningController.CommissioningFileWrapper oWrapCommissioning){
        
        
        ContentVersion cVersion = new ContentVersion();
        
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = oWrapCommissioning.fileName + '.txt';	//File name with extention  //textfile.txt
        cVersion.Origin = 'C';	//C-Content Origin. H-Chatter Origin.
       // cVersion.OwnerId = oWrapCommissioning.ownerId;	//Owner of the file
        cVersion.Title = 'Test file';	//Name of the file
        cVersion.VersionData = Blob.valueOf(oWrapCommissioning.fileBody) ;//File content	
        
        insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        
        ContentVersion conVer = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id];
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        
        cDocLink.ContentDocumentId = conVer.ContentDocumentId;	//Add ContentDocumentId
        cDocLink.LinkedEntityId = oWrapCommissioning.opportunityId; //Add  parentId
        cDocLink.ShareType = 'V'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers'; //AllUsers, InternalUsers, SharedUsers
        insert cDocLink; 
        return cDocLink;
    }
    
}