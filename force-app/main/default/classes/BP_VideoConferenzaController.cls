public without sharing class BP_VideoConferenzaController {
    
    @AuraEnabled
    public static List<BP_VideoConferenzaController.bookVideoConfWrapper> getAllContacts(Id oppId, Id accountId,String tipoLineaCredito){
        
        List<BP_VideoConferenzaController.bookVideoConfWrapper> firmatarioConLst = BP_QR_Contact.getFirmatarioContact(oppId,accountId,tipoLineaCredito);
        system.debug('firmatarioConLst--->'+firmatarioConLst.size());
        return firmatarioConLst;
        
    }
    
    @AuraEnabled
    public static void interruptRequestCall(String oppId){
        
        BP_DigitalAssignmntElevaAPIController.interruptRequest(oppId);
    }
    
    @AuraEnabled
    public static void bookVideoConferenceCall(String oppId,boolean isResubmit){
        
        BP_digitalAssignmentWrapper obj = new BP_digitalAssignmentWrapper();
        Map<Id,List<Document__c>> contactIdDocumentMap = new Map<Id,List<Document__c>>(); 
        Set<Id> conSet = new Set<Id>();
        
        List<Contact> conList = new List<Contact>();
        List<BP_digitalAssignmentWrapper.Users> userList = new List<BP_digitalAssignmentWrapper.Users>();
        Set<Id> contactIdSet = new Set<Id>();
        List<VideoConferenza__c> newVideoConfLst = new List<VideoConferenza__c>();
        Map<Id,Id> contactAndVideoConfMap = new Map<Id,Id>();
        String pluginDocumentId = '';
        String pluginCFId = '';
        
        Opportunity oppTOSend = [Select Id,AccountId,Owner.Email,Inside_Sales_di_Riferimento__r.Email, Email_Sales_Support__c,Tipo_Linea_di_Credito__c,
                                 StatusOnboarding__c from Opportunity WHERE Id =:oppId Limit 1];
        
        List<BP_VideoConferenzaController.bookVideoConfWrapper> conWrapList = BP_QR_Contact.getFirmatarioContact(oppTOSend.Id,oppTOSend.AccountId,oppTOSend.Tipo_Linea_di_Credito__c);
        for(BP_VideoConferenzaController.bookVideoConfWrapper oWrap : conWrapList){
            if(! conSet.contains(oWrap.contact.Id)){
                conList.add(oWrap.contact);
                conSet.add(oWrap.contact.Id);
            }
        }
        
        Quote oppQuote = [Select Id,OpportunityId,processGuid__c  from Quote where OpportunityId =: oppId Limit 1];
        
        
        for(Contact oCon : conList) {
            
            newVideoConfLst.add(new VideoConferenza__c(Contact__c = oCon.Id,Opportunity__c = oppTOSend.Id));
            contactIdSet.add(oCon.Id);
        }
        
        List<Document__c> documentLst = [ Select id,Contact__c,GUI__c,IDTipoDocumentoFormula__c from Document__c 
        where Contact__c IN:contactIdSet AND (IDTipoDocumentoFormula__c = 'SME_004' OR IDTipoDocumentoFormula__c = 'SME_002')];
        /* for(Document__c oDoc :  ) 
        {
           /* if(oDoc.IDTipoDocumentoFormula__c == 'SME_002' ){
                pluginDocumentId = oDoc.GUI__c;
            }
            else if(oDoc.IDTipoDocumentoFormula__c == 'SME_004'){
                pluginCFId = oDoc.GUI__c;  
            }
        }*/
        
        //Creating new VideoConferenza__c records
        if(isResubmit || oppTOSend.StatusOnboarding__c == 'Richiesta KO per problemi tecnici')
        {
            newVideoConfLst = [Select Id,Contact__c,Opportunity__c from VideoConferenza__c where Contact__c IN:contactIdSet AND Opportunity__c =: oppTOSend.Id];
        }
        else
        {
            if(! newVideoConfLst.isEmpty())
            {
                insert newVideoConfLst;
            }
        }
        for(VideoConferenza__c oVideo : newVideoConfLst)
        {
            contactAndVideoConfMap.put(oVideo.Contact__c,oVideo.Id);
        }
        
        
        for(contact oCo : conList) {
            
            BP_digitalAssignmentWrapper.Users oUser = new BP_digitalAssignmentWrapper.Users();
            BP_digitalAssignmentWrapper.Docs oDoc = new BP_digitalAssignmentWrapper.Docs();
            BP_digitalAssignmentWrapper.DocId oId = new BP_digitalAssignmentWrapper.DocId();
            
            oUser.type = 'FID';
            oUser.sendMail = 'true';
            oUser.name = oCo.FirstName;
            oUser.surname = oCo.LastName;
            oUser.email = oCo.Email;
            oUser.phoneNumber = oCo.Prefisso_Internazionale__c+oCo.MobilePhone;
            oUser.taxCode = oCo.Oplon_Codice_Fiscale__c;
            oUser.idSalesforce = contactAndVideoConfMap.get(oCo.Id);
            oUser.contactId = oCo.Id;
            if(oCo.FinServ__Gender__c == 'Male')
            {
                oUser.gender = 'M';
            }
            else if(oCo.FinServ__Gender__c == 'Female')
            {
                oUser.gender = 'F';
            }
            oUser.dateOfBirth = String.valueOf(oCo.Data_di_Nascita__c);
            oUser.cityOfBirth = oCo.Localita__c;
            oUser.provinceOfBirth = oCo.Sigla_Provincia_Nascita__c;
            oUser.stateOfBirth = oCo.Stato_Nascita__c;
            oUser.address = oCo.Indirizzo_Residenza_Esteso__c;
            oUser.city = oCo.Localita_Residenza__c;
            oUser.province = oCo.Provincia__c;
            oUser.state = oCo.Residenza__c;
            
            //Setting up Id array
            if(oCo.Tipo_Documento__c == 'I')
            {
                oId.docType = 'CI';
            }
            else if(oCo.Tipo_Documento__c == 'S')
            {
                oId.docType = 'PASS';
            }
            oId.idNumber = oCo.Numero_Documento__c;
            oId.idReleaseDate = String.valueOf(oCo.Data_Rilascio__c);
            oId.idExpiryDate= String.valueOf(oCo.Data_Scadenza__c);
            oId.idEmittingAuthority= oCo.Luogo_Rilascio__c;
            for(Document__c doc : documentLst){
                if(oCO.Id == doc.Contact__c){
                    if(doc.IDTipoDocumentoFormula__c == 'SME_002'){
                        oId.pluginDocumentId= doc.GUI__c;
                    }else{
                        oDoc.pluginCfId = doc.GUI__c;
                    }
                }
            }
            
            
            oDoc.identityDoc =  oId;
            
            
            oUser.docs = oDoc;
            
            userList.add(oUser);
        }
        
        obj.opportunityId = oppTOSend.Id;
        obj.quoteId = oppQuote.Id;
        obj.processGuid = oppQuote.processGuid__c;
        obj.expirationTime = '10';
        obj.refPartnerEmail = oppTOSend.Owner.Email;
        obj.refSalesEmail = oppTOSend.Inside_Sales_di_Riferimento__r.Email;
        obj.salesSupportEmail= oppTOSend.Email_Sales_Support__c;
        obj.users = userList;
        
        String requestStr = System.JSON.serialize(obj);
        
        BP_DigitalAssignmntElevaAPIController.bookVideoConference(oppId,requestStr);
    }
    
    public class bookVideoConfWrapper{
        
        @AuraEnabled public Contact contact;
        @AuraEnabled public boolean isFidejussori;
        @AuraEnabled public boolean hasSME002;
        @AuraEnabled public boolean hasSME004;
        
        public bookVideoConfWrapper(Contact oCon, boolean isFide, boolean SME002, boolean SME004){
            
            this.contact = oCon;
            this.isFidejussori = isFide;
            this.hasSME002 = SME002;
            this.hasSME004 = SME004;
            
        }
    }
    
}