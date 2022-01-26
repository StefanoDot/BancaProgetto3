public without sharing class BP_QR_Contact {
    @AuraEnabled
    public static List<BP_VideoConferenzaController.bookVideoConfWrapper> getFirmatarioContact(Id OppId,Id accountId,String tipoLineaCredito){
        List<Contact> allContactList = new List<Contact>();
        List<BP_VideoConferenzaController.bookVideoConfWrapper> allFirmaWrapperLst = new List<BP_VideoConferenzaController.bookVideoConfWrapper>();
        List<BP_VideoConferenzaController.bookVideoConfWrapper> tempFirmaWrapperLst = new List<BP_VideoConferenzaController.bookVideoConfWrapper>();
        List<BP_VideoConferenzaController.bookVideoConfWrapper> allWrapperLst = new List<BP_VideoConferenzaController.bookVideoConfWrapper>();
        Set<Id> FirmaContactIdSet = new Set<Id>();
        List<BP_VideoConferenzaController.bookVideoConfWrapper> wrapperLst = new List<BP_VideoConferenzaController.bookVideoConfWrapper>();
            
        allContactList = [Select Id,Name,AccountId,Firmatario__c,FinServ__EmailVerified__c,FinServ__MobileVerified__c,NDG__c,LastName,Tipo_Documento__c,
                          Fidejussore__c,Numero_Documento__c,Data_Rilascio__c,Data_Scadenza__c,Luogo_Rilascio__c,
                          FirstName, Localita__c, Data_di_Nascita__c, Oplon_Codice_Fiscale__c , Localita_Residenza__c, Sigla_Provincia__c,Prefisso_Internazionale__c,
                          Sigla_Provincia_Nascita__c,Provincia__c, Residenza__c, Indirizzo_Residenza_Esteso__c , Cap__c, Email, FinServ__Gender__c,
                          Stato_Nascita__c,Phone,MobilePhone from Contact where Firmatario__c = true  AND AccountId = :accountId];
                          System.debug('allContactList  '+allContactList.size());
        for(Contact oCon : allContactList)
        {
            allFirmaWrapperLst.add( new BP_VideoConferenzaController.bookVideoConfWrapper(oCon,false,false,false));
        }
        system.debug('allFirmaWrapperLst--->'+allFirmaWrapperLst.size());
        if(tipoLineaCredito == 'Mutuo'){
            List<Contact> fidejussoriLst = ElevaRestApiHelper.getAllFidejussori(OppId);
            Set<Id> ContactIdSet = new Set<Id>();
            Set<String> documentContactSet = new Set<String>();
            system.debug('fidejussoriLst--->'+fidejussoriLst.size());
            if( ! fidejussoriLst.isEmpty()){
                for(Contact oCon : fidejussoriLst)
                {
                    ContactIdSet.add(oCon.Id);
                }
            }
            for(Document__c oDoc : [Select Id,IDTipoDocumentoFormula__c,Url_Documento__c,Contact__c from Document__c where Contact__c IN:ContactIdSet AND ( IDTipoDocumentoFormula__c ='SME_004' OR IDTipoDocumentoFormula__c ='SME_002') AND Url_Documento__c != null ]){
                if(oDoc.IDTipoDocumentoFormula__c == 'SME_004'){
                    documentContactSet.add( String.valueOf(oDoc.Contact__c) + 'SME_004');
                }
                if(oDoc.IDTipoDocumentoFormula__c == 'SME_002'){
                    documentContactSet.add( String.valueOf(oDoc.Contact__c) + 'SME_002');
                }
            }
            for(Contact oCon : fidejussoriLst)
            {
                if( ( documentContactSet.contains(oCon.Id + 'SME_002') && documentContactSet.contains(oCon.Id + 'SME_004'))){
                    wrapperLst.add( new BP_VideoConferenzaController.bookVideoConfWrapper(oCon,true,true,true));
                }
                else if(documentContactSet.contains(oCon.Id + 'SME_002') && ( ! documentContactSet.contains(oCon.Id + 'SME_004'))){
                    wrapperLst.add( new BP_VideoConferenzaController.bookVideoConfWrapper(oCon,true,true,false));
                }
                else if(documentContactSet.contains(oCon.Id + 'SME_004') && (! documentContactSet.contains(oCon.Id + 'SME_002') )){
                    wrapperLst.add( new BP_VideoConferenzaController.bookVideoConfWrapper(oCon,true,false,true));
                }
                else{
                    wrapperLst.add( new BP_VideoConferenzaController.bookVideoConfWrapper(oCon,true,false,false));
                }
            }      
        }
        if(!wrapperLst.isEmpty()){
            for(BP_VideoConferenzaController.bookVideoConfWrapper oFirma : allFirmaWrapperLst){
                for(BP_VideoConferenzaController.bookVideoConfWrapper oFide : wrapperLst){
                    if( oFirma.Contact.Id != oFide.Contact.Id && ! FirmaContactIdSet.contains(oFirma.Contact.Id)){
                        
                        tempFirmaWrapperLst.add(oFirma);
                        FirmaContactIdSet.add(oFirma.Contact.Id);
                        system.debug('FirmaContactIdSet---> '+ FirmaContactIdSet);
                    }
                }
            }
        }
        //adding all the fidejussori's
        allWrapperLst.addAll(wrapperLst);
        system.debug('allWrapperLst--->'+allWrapperLst);
        system.debug('tempFirmaWrapperLst--->'+tempFirmaWrapperLst);
        if(tempFirmaWrapperLst.isEmpty()){
            allWrapperLst.addAll(allFirmaWrapperLst);
        }else{
            allWrapperLst.addAll(tempFirmaWrapperLst);
        }
        //adding all the firmatario's
        system.debug('allWrapperLst finale--->'+allWrapperLst);
        Map<Id, BP_VideoConferenzaController.bookVideoConfWrapper> contMap = new Map <Id, BP_VideoConferenzaController.bookVideoConfWrapper>();
        for (BP_VideoConferenzaController.bookVideoConfWrapper contactFinale : allWrapperLst) {
            contMap.put(contactFinale.contact.id, contactFinale);
        }
        return contMap.values();
    }
    
}