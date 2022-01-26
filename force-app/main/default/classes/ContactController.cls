/**
* Created by ACAPUTO00 on 07/02/2020.
*/

public without sharing class ContactController extends TriggerHandler {

    /** Triggered after a Contact is inesrted into the database **/
    public override void afterInsert() {
        //AfterInsertAddDoc(Trigger.new); commented because automated doc creation is no longer a valid feature
        UpdateOppCountersAfterContactInsert(Trigger.new);
    }

    /** Triggered after a Contact is deleted FROM the database **/
    public override void beforeDelete() {
    }

    /** Triggered after a Contact is deleted FROM the database **/
    public override void afterDelete() {
        UpdateOppCountersAfterContactDeleted(Trigger.old);
    }

    public override void beforeUpdate()
    {
        System.debug('ContactController.beforeUpdate - Start');
        
        List<Contact> listCompleteField = new List<Contact>();
        List<Contact> listCheckVia = new List<Contact>();
        List<Contact> notifyMissingFieldsList = new List<Contact>();
        List<Contact> interesatoListUpdatePrivacyFields = new List<Contact>();
        List<Contact> listUpdatePrivacyFields = new List<Contact>();
        List<Contact> fidejussoreListUpdatePrivacyFields = new List<Contact>();
        
        Set<Id> AccountIdList = new Set<Id>();        
        
        for(Contact cont: (List<Contact>) Trigger.new)
        {
            Boolean check = false;
            Utils_Constants constants = new Utils_Constants();
            Contact oldCont = (Contact)Trigger.oldMap.get(cont.id);
            //Da passare in PROD task 2005
            cont.Localita_Residenza__c = cont.Comune__c;
            cont.Localita__c = cont.Comune_di_Nascita__c;
            if(cont.Residenza__c == 'ITALIA'){
                cont.Stato_Residenza_Estero__c = 'ITALIA';
                }else if (cont.Residenza__c == 'ESTERO'){
                cont.Stato_Residenza_Estero__c = 'ESTERO';
                }else {
                    cont.Stato_Residenza_Estero__c = '';
                } // //fin qui
            if(cont.Ruolo_in_Azienda__c != oldCont.Ruolo_in_Azienda__c || cont.Oplon_Titolare_Effettivo__c != oldCont.Oplon_Titolare_Effettivo__c
               || cont.FinServ__Gender__c != null)
            {
                listCompleteField.add(cont);
            }
            if(cont.Nome_Via__c != null && cont.Nome_Via__c != oldCont.Nome_Via__c 
               && String.isBlank(cont.Tipo_Via__c))
            {
                listCheckVia.add(cont);
            }
            if(cont.Fidejussore__c == true && oldCont.Fidejussore__c == false && cont.NDG__c == null )   
            {                  
                notifyMissingFieldsList.add(cont);
                
            } 
            
            if(cont.Interessato__c <> oldCont.Interessato__c && cont.Interessato__c==true &&  cont.Fidejussore__c==false ){
                interesatoListUpdatePrivacyFields.add(cont);
                AccountIdList.add(cont.AccountId);
                
            }
            if(((cont.Ruolo_in_Azienda__c <> oldCont.Ruolo_in_Azienda__c && cont.Ruolo_in_Azienda__c<>null) 
                || (cont.Esecutore__c <> oldCont.Esecutore__c && cont.Esecutore__c == true)
                || (cont.percentuale_di_riferimento_socio__c <> oldCont.percentuale_di_riferimento_socio__c && cont.percentuale_di_riferimento_socio__c>0) 
                || (cont.Firmatario__c <> oldCont.Firmatario__c && cont.Firmatario__c==true) 
                || (cont.Oplon_Titolare_Effettivo__c <> oldCont.Oplon_Titolare_Effettivo__c && cont.Oplon_Titolare_Effettivo__c==true))
               && cont.Interessato__c==false) 
            {check = true;
             listUpdatePrivacyFields.add(cont);
            }
            if(cont.Fidejussore__c <> oldCont.Fidejussore__c && cont.Fidejussore__c==true && check==false){
                
                fidejussoreListUpdatePrivacyFields.add(cont);
            }
               if((cont.Tipo_Documento__c !=  oldCont.Tipo_Documento__c||cont.Numero_Documento__c !=  oldCont.Numero_Documento__c||cont.Data_Rilascio__c !=  oldCont.Data_Rilascio__c||
               cont.Luogo_Rilascio__c !=  oldCont.Luogo_Rilascio__c||cont.Data_Scadenza__c !=  oldCont.Data_Scadenza__c||cont.Erogazione_dei_Servizi__c !=  oldCont.Erogazione_dei_Servizi__c
               ||cont.Ricerche_di_Mercato__c !=  oldCont.Ricerche_di_Mercato__c||cont.Dati_Particolari__c !=  oldCont.Dati_Particolari__c||cont.Consenso_Sic__c !=  oldCont.Consenso_Sic__c||
              cont.Valutazione_Qualita_Servizio__c !=  oldCont.Valutazione_Qualita_Servizio__c||cont.Profilazione_Banca__c !=  oldCont.Profilazione_Banca__c||
               cont.Marketing_Banca__c !=  oldCont.Marketing_Banca__c||cont.SAE__c !=  oldCont.SAE__c||cont.RAE__c !=  oldCont.RAE__c ||cont.Localita__c !=  oldCont.Localita__c||cont.Cap__c !=  oldCont.Cap__c
                  ||cont.Provincia__c !=  oldCont.Provincia__c||cont.Comune__c !=  oldCont.Comune__c||cont.Tipo_Via__c !=  oldCont.Tipo_Via__c||cont.Nome_Via__c !=  oldCont.Nome_Via__c
                  ||cont.Numero_Civico__c !=  oldCont.Numero_Civico__c)&&cont.NDG__c<>null)   
            {                  
                cont.Aggiorna_Cedacri__c=true;
            }
        }
        if(!interesatoListUpdatePrivacyFields.isempty()){
            ContactController.UpdatePrivacyCampiInteresato(interesatoListUpdatePrivacyFields,AccountIdList);
        }
        if(!listUpdatePrivacyFields.isempty()){
            ContactController.UpdatePrivacyCampi(listUpdatePrivacyFields);
        }
        if(!notifyMissingFieldsList.isempty()){
            ContactController.notifyMissingFieldsServiceFidejusioneBeforeUpdate(notifyMissingFieldsList);    
        }
        
        if(!listCompleteField.isempty()){
            ContactController.completeField(listCompleteField,(Map<id,Contact>)Trigger.oldMap);
        }
        if(!listCheckVia.isempty()){
            ContactController.checkVia(listCheckVia,  (Map<id,Contact>)Trigger.oldMap);
        }
        
        System.debug('ContactController.beforeUpdate - End');
        
    }
    public override void afterUpdate() {
        List<Contact> listCheckComune = new List<Contact>();
        List<Contact> listDocumentazioneFidejusore = new List<Contact>();
        List<Contact> listRichiestaCRFidejusore = new List<Contact>();
		List<Id> contactsToAlert = new List<Id>();
        
        for(Contact contact: (List<Contact>) Trigger.new) {
            Contact oldCont = (Contact)Trigger.oldMap.get(contact.Id);

            if (contact.Comune__c != oldCont.Comune__c
               && contact.Comune__c != null
               && contact.Comune__c != '') {
                listCheckComune.add(contact);
            }

            if ((contact.Fidejussore__c == true && oldCont.Fidejussore__c == false ) || (contact.Ruolo_in_Azienda__c != null && oldCont.Ruolo_in_Azienda__c == null)) {
                listDocumentazioneFidejusore.add(contact);
            }

            if ((contact.Fidejussore__c == true && oldCont.Fidejussore__c == false ) && (contact.Fidejussore__c <> oldCont.Fidejussore__c) && contact.NDG__c <> null) {
                listRichiestaCRFidejusore.add(contact);
            }
            if (contact.Firmatario__c && ! oldCont.Firmatario__c)  
            {
                if( String.isEmpty(contact.Tipo_Documento__c))
                {
                    contactsToAlert.add(contact.Id);
                }
                else if( contact.Tipo_Documento__c != 'I' && contact.Tipo_Documento__c != 'S')
                {
                    contactsToAlert.add(contact.Id);
                }
                
            }
        }  
        
        if (!listCheckComune.isEmpty()) {
            ContactController.checkComune(listCheckComune, (Map<Id,Contact>) Trigger.oldMap);
        }

        if (!listDocumentazioneFidejusore.isEmpty()) {
            ContactController.DocumentazioneFidejusore(listDocumentazioneFidejusore, (Map<Id,Contact>) Trigger.oldMap);
        }

        if (!listRichiestaCRFidejusore.isEmpty()) {
            ContactController.RichiestaCRFidejusore(listRichiestaCRFidejusore);
        }
        if (! contactsToAlert.isEmpty()) {
            ContactController.publishPlatformEvnt(contactsToAlert);
        }

        UpdateOppCountersAfterContactUpdate(Trigger.new, (Map<Id, Contact>) Trigger.oldMap);
    }

    public override void beforeInsert()
    {
        System.debug('ContactController.beforeInsert - Start');
        
        ContactController.completeField(Trigger.new, (Map<id,Contact>)Trigger.oldMap);
        ContactController.checkVia(Trigger.new,  (Map<id,Contact>)Trigger.oldMap);
        ContactController.BeforeInsert(Trigger.new);
        
        System.debug('ContactController.beforeInsert - End');
        
    }
    
    
    public static void UpdatePrivacyCampiInteresato(List<Contact> toBeProcessed, Set<Id> accId) {
        system.debug('ContactController.UpdatePrivacyCampiInteresato - Start  toBeProcessed'+toBeProcessed+'accId'+accId);
        
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id, Name ,Marketing_Banca__c,
                                                            erogazione_dei_servizi__c, Valutazione_Qualit_Servizio__c, Profilazione_Banca__c,Ricerche_di_Mercato__c,
                                                            Dati_Particolari__c,Consenso_Sic__c
                                                            FROM Account where Id in :accId]);
        
        For(Contact cont : toBeProcessed){
            
            Account acc = AccountMap.get(cont.AccountId);
            if(acc!=null){
                
                cont.Erogazione_dei_Servizi__c=acc.erogazione_dei_servizi__c;
                cont.Marketing_Banca__c=acc.Marketing_Banca__c;
                cont.Profilazione_Banca__c=acc.Profilazione_Banca__c;
                cont.Valutazione_Qualita_Servizio__c=acc.Valutazione_Qualit_Servizio__c;
                cont.Ricerche_di_Mercato__c = acc.Ricerche_di_Mercato__c;
                cont.Dati_Particolari__c= acc.Dati_Particolari__c;
                cont.Consenso_Sic__c= acc.Consenso_Sic__c;
                
            }
            
        }
        system.debug('ContactController.UpdatePrivacyCampiInteresato - End');
        
    }
     public static void RichiestaCRFidejusore(List<Contact> toBeProcessed){
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        
        serializeCredential = JSON.serialize(elevaCredentials, true);
        System.debug('Eleva Credential flusso 1.1 ' + serializeCredential);
        System.debug('AccountsController GetMoreScore - Start');
        

        
        for (Contact acc : toBeProcessed) {
           
            ElevaRestApiController.CRreferentiTrigger(acc.NDG__c, acc.Id,serializeCredential);
       
        }
        System.debug('AccountsController GetMoreScore - End');
        
     }
    
    public static void UpdatePrivacyCampi(List<Contact> toBeProcessed) {
        system.debug('ContactController.UpdatePrivacyCampi - Start toBeProcessed'+toBeProcessed);
        
        For(Contact cont : toBeProcessed){
            
            cont.Erogazione_dei_Servizi__c='SI';
            cont.Marketing_Banca__c='NO';
            cont.Profilazione_Banca__c='NO';
            cont.Valutazione_Qualita_Servizio__c='NO';
            cont.Ricerche_di_Mercato__c = 'NO';
            cont.Dati_Particolari__c= 'NO';
            cont.Consenso_Sic__c= 'NO';
            
        }
        system.debug('ContactController.UpdatePrivacyCampi - End');
        
    }
    
    public static void fidejussoreUpdatePrivacyCampi(List<Contact> toBeProcessed) {
        system.debug('ContactController.fidejussoreUpdatePrivacyCampi - Start toBeProcessed'+toBeProcessed);
        
        For(Contact cont : toBeProcessed){
            cont.Dati_Particolari__c= 'NO';
            cont.Consenso_Sic__c= 'NO';
            
        }
        system.debug('ContactController.fidejussoreUpdatePrivacyCampi - End');
        
    }
    
    public static void BeforeInsert(List<Contact> toBeProcessed){
        
        system.debug('ContactController.BeforeInsert - Start toBeProcessed'+toBeProcessed);
        
        Utils_Constants constants = new Utils_Constants();
        String recordTypeIdOld = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Insermento_Ref_Manuale').getRecordTypeId();
        String recordTypeIdnew = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Manual').getRecordTypeId();           
        
        /*List<RecordType> recordTypesInserimento = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName =: 'Insermento_Ref_Manuale'];
        List<RecordType> recordTypesManuale = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName =: 'Referente_Manual'];
        
        if(recordTypesInserimento.size()>0 && recordTypesManuale.size()>0 ){
            recordTypeIdOld = recordTypesInserimento.get(0).Id;
            recordTypeIdnew = recordTypesManuale.get(0).Id;
            
        }*/
        SySTEM.debug('recordTypeIdOld'+recordTypeIdOld);
        SySTEM.debug('recordTypeIdnew'+recordTypeIdnew);
        
        Set<Id> accIDs = new Set<Id>();
        for( Contact cont : toBeProcessed )
        {
            if( cont.Interessato__c == true )
            {
                accIDs.add( cont.AccountId);
            }
        }
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id, Name ,Marketing_Banca__c,
                                                            erogazione_dei_servizi__c, Valutazione_Qualit_Servizio__c, Profilazione_Banca__c,Ricerche_di_Mercato__c,
                                                            Dati_Particolari__c,Consenso_Sic__c
                                                            FROM Account where Id in :accIDs]);
        
        for(Contact cont :toBeProcessed ){
            Boolean check = false;
            if(cont.Interessato__c==true){
                Account acc = AccountMap.get(cont.AccountId);
                if(acc!=null){
                    
                    cont.Erogazione_dei_Servizi__c=acc.erogazione_dei_servizi__c;
                    cont.Marketing_Banca__c=acc.Marketing_Banca__c;
                    cont.Profilazione_Banca__c=acc.Profilazione_Banca__c;
                    cont.Valutazione_Qualita_Servizio__c=acc.Valutazione_Qualit_Servizio__c;
                    cont.Ricerche_di_Mercato__c = acc.Ricerche_di_Mercato__c;
                    cont.Dati_Particolari__c= acc.Dati_Particolari__c;
                    cont.Consenso_Sic__c= acc.Consenso_Sic__c; 
                }
            }
            
            if(((cont.Ruolo_in_Azienda__c<>null) 
                || (cont.Esecutore__c == true)
                || (cont.percentuale_di_riferimento_socio__c>0) 
                || (cont.Firmatario__c==true) 
                || (cont.Oplon_Titolare_Effettivo__c==true))
               && cont.Interessato__c==false) 
            {
                check = true;        
                cont.Erogazione_dei_Servizi__c='SI';
                cont.Marketing_Banca__c='NO';
                cont.Profilazione_Banca__c='NO';
                cont.Valutazione_Qualita_Servizio__c='NO';
                cont.Ricerche_di_Mercato__c = 'NO';
                cont.Dati_Particolari__c= 'NO';
                cont.Consenso_Sic__c= 'NO';
            }
            //Da passare in Prod task 4119
            if(cont.FinServ__Gender__c == 'Female'){
                cont.Appellativo__c = 'EGREGIA';
            }else if(cont.FinServ__Gender__c == 'Male'){
                cont.Appellativo__c = 'EGREGIO';
            } else {
                cont.Appellativo__c = 'EGREGIO/A';
            }
             //fin qui
            if(cont.Fidejussore__c==true && check==false){
                cont.Dati_Particolari__c= 'NO';
                cont.Consenso_Sic__c= 'NO';
            }
            
            if(cont.RecordTypeId == recordTypeIdOld ){
                cont.RecordTypeId =recordTypeIdnew;
            }
        }
        system.debug('ContactController.BeforeInsert - End');
        
    }
    
    
    public static list<Contact> notifyMissingFieldsServiceFidejusione(List<Contact> toBeProcessed){
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusione start toBeProcessed: ' +toBeProcessed);
        List<Id> listAccountId = new List<Id>();
        
        for (Contact acc : toBeProcessed) {
            listAccountId.add(acc.Id);
            
        }
        
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Referente_Oplon'];
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
            System.debug('AccountsController notifyMissingFieldsServiceFidejusione RecTid: ' +recordTypeId);
        }*/
        List<String> contactFieldList = new List<String>{
            'Phone',  'MobilePhone',
                'AccountId','Agenzia__c', 'Appellativo__c', 'CAE__c', 'Cap__c', 'Cittadinanza__c', 'Client_Manager__c', 'Comune_di_Nascita__c',
                'Comune__c', 'Convenzione__c', 'Data_di_Nascita__c', 'Data_Rilascio__c', 'Data_Scadenza__c', 'Dati_Identificativi_Cliente_Potenziale__c',
                'Dipendente__c', 'Email', 'FinServ__Gender__c', 'FirstName','Indicativo_Marketing__c', 'Lingua__c',
                'LastName', 'Localita_Residenza__c', 'Localita__c', 'Luogo_Rilascio__c', 'Nome_Via__c', 'Numero_Civico__c', 'Numero_Documento__c',
                'Oplon_Codice_Fiscale__c',  'Professione__c', 'Provincia__c', 'RAE__c', 'Residenza__c', 'ResValutaria__c','Esecutore__c','Firmatario__c','Fidejussore__c','percentuale_di_riferimento_socio__c','Altre_Cariche_Flag__c',
                'SAE__c', 'Sigla_Provincia_Nascita__c', 'Stato_di_Nascita__c', 'Stato_Nascita__c', 'Stato_Residenza_Estero__c', 'TAE__c', 'Tipo_Documento__c',
                'Tipo_Via__c', 'TitNon_Acc__c', 'Ricerche_di_Mercato__c', 'Erogazione_dei_Servizi__c', 'Marketing_Banca__c', 'Profilazione_Banca__c', 'Valutazione_Qualita_Servizio__c', 'Dati_Particolari__c', 'Consenso_Sic__c'
                };
                    
                    List<Contact> toBeUpdated = new List<Contact>();
        
        Utils_Constants costants =new Utils_Constants();
        String CONTACT_LEGALE_RAPPRESENTANTE= costants.CONTACT_LEGALE_RAPPRESENTANTE;
        String CONTACT_TITOLARE_EFFETTIVO= costants.CONTACT_TITOLARE_EFFETTIVO;
        String contactFieldsString = String.join(contactFieldList, ',');
        String queryContactString = 'SELECT ' + contactFieldsString + ' FROM Contact WHERE  Id IN :listAccountId';     
        List<Contact> listContact = (List<Contact>) (Database.query(queryContactString));
        
        
        
        for (Contact cont : toBeProcessed) {
            string contController='N';
            String contactMissingFields = '';
            Boolean testCont=false;
            Boolean testCont2=false;
            for (String contF : contactFieldList) {
                
                
                if (contF=='Phone' && (cont.get(contF) != null  && cont.get(contF) != '')){   
                    testCont=true;
                }
                
                if(contF=='MobilePhone' && (cont.get(contF) != null  && cont.get(contF) != '')){
                    testCont2=true;
                }
                
                if (contF == 'Sigla_Provincia_Nascita__c' || contF == 'Comune_di_Nascita__c' || contF == 'Localita__c') {
                    if (cont.Stato_Nascita__c == 'Italia') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (contF == 'Stato_di_Nascita__c') {
                    if (cont.Stato_Nascita__c == 'Estero') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (contF == 'Tipo_Via__c' || contF == 'Provincia__c' || contF == 'Comune__c' || contF == 'Cap__c') {
                    if (cont.Residenza__c == 'Italia') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (contF == 'Stato_Residenza_Estero__c') {
                    if (cont.Residenza__c == 'Estero') {
                        if(cont.get('Nazione__c') == null){
                            System.debug('Nazione null');
                            String fieldLabel2 = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('Nazione__c').getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel2 + ', ';
                            System.debug('contactMissingFields    '+contactMissingFields);
                            contController='Y';
                        }
                        System.debug('STato estero entra'+ cont.get('Nazione__c'));
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (cont.get(contF) == null || cont.get(contF) == '') {
                    system.debug('contF'+contF);
                    if(contF=='MobilePhone' && testCont==false){
                        contactMissingFields = contactMissingFields + 'Telefono oppure '; 
                    }
                    
                    if((contF=='Phone' && testCont2==false) || (contF=='MobilePhone' && testCont==true)){
                        continue;
                    }
                    
                    
                    String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                    if(fieldLabel == 'Mobile Phone'){
                        contactMissingFields = contactMissingFields + 'Cellulare, '; 
                        continue;
                    }
                    system.debug('fieldLabel'+fieldLabel);
                    contactMissingFields = contactMissingFields + fieldLabel + ', ';
                    contController='Y';
                    
                }
            }
            If(contactMissingFields != ''){
                contactMissingFields = 'Contact:<br/> '+contactMissingFields;
                contactMissingFields = contactMissingFields.removeEnd(', ');
                contactMissingFields = contactMissingFields + '<br/>';
            }
            
            System.debug('ContactController notifyMissingFieldsServiceFidejusione contactMissingFields: ' +contactMissingFields);
            
            String accId = cont.Id;
            Contact accToBeUpdated = new Contact(Id = accId);
            accToBeUpdated.campi_mancanti_fidejussione__c = contactMissingFields;
            if(accToBeUpdated.campi_mancanti_fidejussione__c=='')
            {
                accToBeUpdated.fidejussore_completo__c= true;
            }
            else
            {
                accToBeUpdated.fidejussore_completo__c= false;
            }
            toBeUpdated.add(accToBeUpdated);
        }
        /*JF 19/09/2020 ad aggiornare deve essere il metodo chiamante
update toBeUpdated;*/
        
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusione - End  Account:' + toBeUpdated);
        return toBeUpdated;
    }
    
    public static void checkComune(List<Contact> toBeProcessed, Map<Id, Contact> mapOldContacts) {
        
        system.debug('ContactController.checkComune - Start  toBeProcessed'+toBeProcessed+' mapOldContacts ' + mapOldContacts);
        // system.debug('newContacts: '+newContacts+'mapOldContacts: '+ mapOldContacts);
        
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Referente_Oplon'];
        //   system.debug('List<RecordType> recordTypes: '+ recordTypes);
        if (recordTypes.size() > 0) {
            
            
            
            recordTypeId = recordTypes.get(0).Id;
        }*/
        
        /*Molino Luca 03/08/2020
List<Contact> toBeProcessed = new List<Contact>();
for (Contact cont : newContacts) {
if (cont.Comune__c != mapOldContacts.get(cont.Id).Comune__c && cont.Comune__c != null && cont.Comune__c != '' && cont.RecordTypeId == recordTypeId) {
toBeProcessed.add(cont);
}
}*/
        
        system.debug('**** **** **** TO BE PROCESSED size ' + toBeProcessed.size());
        
        if (toBeProcessed.size() > 0) {
            checkComuneService(toBeProcessed, recordTypeId);
        }
        
        system.debug('ContactController.checkComune - End');
        
    }

    /** Obsolete Method, to be deleted in the future **/
//    public static void AfterInsertAddDoc(List<Contact> newConList){
//        system.debug('ContactController.AfterInsertAddDoc - Start  newConList '+newConList);
//        List<DocumentType__c> docType = [SELECT Id, ObjectName__c,Referente_Fidejussore__c FROM DocumentType__c where  Opportunita_Mutuo__c=true and ObjectName__c='Contact' ];
//        //    system.debug(' docType at Acc contr'+docType);
//        System.debug('Limits.getLimitQueries() 0.1 = ' + Limits.getLimitQueries());
//        System.debug('Limits.getQueries() 0.1 = ' + Limits.getQueries());
//        List<Document__c> docList = new List<Document__c> ();
//        for (Contact con : newConList) {
//            if( con.Fidejussore__c == true){
//                for (DocumentType__c doc : docType) {
//                    if(doc.ObjectName__c=='Contact'){
//                        docList.add(new Document__c(
//                            Contact__c = con.Id,
//                            DocumentType__c = doc.Id
//                        ));
//                    }
//                }
//            }
//
//            else  if(con.Fidejussore__c==false && ((con.Ruolo_in_Azienda__c=='Titolare Effettivo') ||(con.Ruolo_in_Azienda__c=='Legale Rappresentante') || (con.Ruolo_in_Azienda__c=='Titolare Effettivo;Legale Rappresentante') )){
//                for (DocumentType__c doc : docType) {
//                    if(doc.ObjectName__c=='Contact' && doc.Referente_Fidejussore__c==false){
//                        docList.add(new Document__c(
//                            Contact__c = con.Id,
//                            DocumentType__c = doc.Id
//                        ));
//                    }
//                }
//            }
//
//        }
//        system.debug('ContactController.AfterInsertAddDoc - End   docList: ' + docList);
//        System.debug('Limits.getLimitQueries() 0.2 = ' + Limits.getLimitQueries());
//        System.debug('Limits.getQueries() 0.2 = ' + Limits.getQueries());
//        insert docList;
//
//        System.debug('Limits.getLimitQueries() 0.3 = ' + Limits.getLimitQueries());
//        System.debug('Limits.getQueries() 0.3 = ' + Limits.getQueries());
//    }
    
    public static void DocumentazioneFidejusore(List<Contact> newContacts, Map<Id, Contact> mapOldContacts){
        system.debug('ContactController.DocumentazioneFidejusore - Start newContacts '+newContacts+' mapOldContacts '+ mapOldContacts);
        
        
        Set<Id> stAccIds = new Set<Id>(); //Suppose this set has Account Ids 
        List<DocumentType__c> docType = [SELECT Id, ObjectName__c,Referente_Fidejussore__c FROM DocumentType__c where  Opportunita_Mutuo__c=true and ObjectName__c='Contact'];        
        List<Document__c> docList = new List<Document__c> ();        
        Map<Id,Integer> ContactIdWithDocumentCount = new Map<Id,Integer>();
        Map<Id,Integer> ContactIdWithDocumentFidejusoreCountInt = new Map<Id,Integer>();        
        
        for(Contact con : newContacts){ 
            stAccIds.add(con.Id);
        }
        for(Contact acc : [SELECT Id,Name,(SELECT Id,DocumentType__r.Referente_Fidejussore__c  FROM Documenti__r where DocumentType__r.Referente_Fidejussore__c= true ) FROM Contact WHERE Id In :stAccIds])
            
        { ContactIdWithDocumentFidejusoreCountInt.put(acc.Id,acc.Documenti__r.size()); }
        
        for(Contact acc : [SELECT Id,Name,(SELECT Id,DocumentType__r.Referente_Fidejussore__c  FROM Documenti__r ) FROM Contact WHERE Id In :stAccIds])
            
        {  ContactIdWithDocumentCount.put(acc.Id,acc.Documenti__r.size()); }
        
        
        
        for(Contact con : newContacts) {
            if(con.Fidejussore__c == true &&
               mapOldContacts.get(con.id).Fidejussore__c == false ) {
                   
                   if(ContactIdWithDocumentFidejusoreCountInt.get(con.id)==0 && ContactIdWithDocumentCount.get(con.id) !=0 ){
                       
                       for (DocumentType__c doc : docType) {
                           if(doc.ObjectName__c=='Contact' && doc.Referente_Fidejussore__c== true ){
                               docList.add(new Document__c(
                                   Contact__c = con.Id,
                                   DocumentType__c = doc.Id
                               ));
                           }
                       }                   
                   }
                   
                   else  if(ContactIdWithDocumentCount.get(con.id) ==0 ){                   
                       
                       for (DocumentType__c doc : docType) {
                           if(doc.ObjectName__c=='Contact' ){
                               
                               docList.add(new Document__c(
                                   Contact__c = con.Id,
                                   DocumentType__c = doc.Id
                               ));
                           }
                       }                  
                   }             
               }
            
            else if(((con.Ruolo_in_Azienda__c=='Titolare Effettivo') ||(con.Ruolo_in_Azienda__c=='Legale Rappresentante') || (con.Ruolo_in_Azienda__c=='Titolare Effettivo;Legale Rappresentante') ) &&
                    mapOldContacts.get(con.id).Ruolo_in_Azienda__c == null ) {
                        
                        if(ContactIdWithDocumentCount.get(con.id) ==0 ){                   
                            
                            for (DocumentType__c doc : docType) {
                                if(doc.ObjectName__c=='Contact' && doc.Referente_Fidejussore__c== false ){
                                    
                                    docList.add(new Document__c(
                                        Contact__c = con.Id,
                                        DocumentType__c = doc.Id
                                    ));
                                }
                            }      
                        } 
                    } 
        }
        system.debug('ContactController.DocumentazioneFidejusore - End   docList: '+ docList);
        
        insert docList;
        
    }    
    
    public static void checkComuneService(List<Contact> toBeProcessed, String recordTypeId) {
        system.debug('ContactController.checkComuneService - Start toBeProcessed '+toBeProcessed+' recordTypeId'+ recordTypeId);
        List<Account> toBeUpdated = new List<Account>();
        
        List<Id> listAccountId = new List<Id>();
        Map<String, List<Contact>> mapAccCont = new Map<String, List<Contact>>();
        List<String> ComuneTrimmedUpperList = new List<String>();
        
        Set<Id> accountIdSet = new Set<Id>();
        
        for (Contact cont : toBeProcessed) {
            accountIdSet.add(cont.AccountId);
        }
        
        List<Account> accountsToBeProcessed = new List<Account>();
        accountsToBeProcessed = [SELECT Id, Comune__c, Name FROM Account WHERE Id IN :accountIdSet];
        system.debug('accountsToBeProcessed: '+ accountsToBeProcessed);
        for (Account acc : accountsToBeProcessed) {
            listAccountId.add(acc.Id);
            String accComuneTrimmedUpper = acc.Comune__c.trim().toUpperCase();
            ComuneTrimmedUpperList.add(accComuneTrimmedUpper);
            List<Contact> listCont = new List<Contact>();
            mapAccCont.put(acc.Id, listCont);
        }
        
        system.debug('ComuneTrimmedUpperList: '+ ComuneTrimmedUpperList);
        
        String queryContactString = 'SELECT Id, AccountId, Comune__c, Name FROM Contact WHERE RecordTypeId = :recordTypeId AND AccountId IN :listAccountId';
        List<Contact> listContact = (List<Contact>) (Database.query(queryContactString));
        
        for (Contact cont : listContact) {
            List<Contact> listContTemp = mapAccCont.get(cont.AccountId);
            String contComuneTrimmedUpper;
            if(cont.Comune__c!=null)
                contComuneTrimmedUpper= cont.Comune__c.trim().toUpperCase();
            ComuneTrimmedUpperList.add(contComuneTrimmedUpper);
            listContTemp.add(cont);
            mapAccCont.put(cont.AccountId, listContTemp);
        }
        
        
        List<Matrice_di_Assegnazione__c> matriceDiAssegnazione = [SELECT Id, Name FROM Matrice_di_Assegnazione__c Where Name =:ComuneTrimmedUpperList];
        
        if(matriceDiAssegnazione.size() > 0){
            
            List<String> matriceDiAssegnazioneComuni = new List<String>();
            
            for(Matrice_di_Assegnazione__c mda : matriceDiAssegnazione){
                matriceDiAssegnazioneComuni.add(mda.Name);
            }  
            for (Account acc : accountsToBeProcessed) {
                String finalMessage = '';
                
                String accComuneTrimmedUpper = acc.Comune__c.trim().toUpperCase();
                
                if (!matriceDiAssegnazioneComuni.contains(accComuneTrimmedUpper)) {
                    finalMessage = finalMessage + 'Account ' + acc.Name + ':<br/>';
                    finalMessage = finalMessage + 'Comune: ' + acc.Comune__c;
                }
                
                finalMessage = finalMessage + '<br/>';
                
                for (Contact cont : mapAccCont.get(acc.Id)) {
                    
                    if (cont.Comune__c != null && cont.Comune__c != '') {
                        
                        String contComuneTrimmedUpper = cont.Comune__c.trim().toUpperCase();
                        
                        if (!matriceDiAssegnazioneComuni.contains(contComuneTrimmedUpper)) {
                            finalMessage = finalMessage + 'Contact ' + cont.Name + ':<br/>';
                            finalMessage = finalMessage + 'Comune: ' + cont.Comune__c;
                        }
                        
                        finalMessage = finalMessage + '<br/>';
                        
                    }
                    
                }
                
                acc.Comune_Dicitura_Errata__c = finalMessage;
                toBeUpdated.add(acc);
                
            }
            
            if (!Test.isRunningTest()) {
                system.debug('update toBeUpdated: ' + toBeUpdated+ 'size'+toBeUpdated.size() );
                update toBeUpdated;
            }
            
        }
        system.debug('ContactController.checkComuneService - End toBeUpdated'+toBeUpdated);
        
        
    }

    public static void UpdateOppCountersAfterContactDeleted(List<Contact> oldContactList) {
        List<Id> accountIdList = GetAccountIdsFromContacts(oldContactList, new Map<Id, Contact>());
        Map<String, Opportunity> opportunityMap = GetOpportunityMapFromAccountIdList(accountIdList);
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(opportunityMap);
        OpportunityController.bypassTrigger=true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger=false;
    }

    public static void UpdateOppCountersAfterContactInsert(List<Contact> newContactList) {
        List<Id> accountIdList = GetAccountIdsFromContacts(newContactList, new Map<Id, Contact>());
        Map<String, Opportunity> opportunityMap = GetOpportunityMapFromAccountIdList(accountIdList);
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(opportunityMap);
        OpportunityController.bypassTrigger=true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger=false;
    }

    public static void UpdateOppCountersAfterContactUpdate(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        List<Id> accountIdList = GetAccountIdsFromContacts(newContactList, oldContactMap);
        Map<String, Opportunity> opportunityMap = GetOpportunityMapFromAccountIdList(accountIdList);
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(opportunityMap);
       // OpportunityController.bypassTrigger=true;
        update oppsToUpdate;
        //OpportunityController.bypassTrigger=false;
    }

    private static List<Id> GetAccountIdsFromContacts(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        List<Id> accountIdList = new List<Id>();
        List<String> contactRoles = new List<String>{'Titolare Effettivo', 'Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante'};

        for (Contact newContact : newContactList) {
            Contact oldContact = oldContactMap.get(newContact.Id);

            if (oldContact != null) {
                if (oldContact.AccountId != null &&
                        oldContact.AccountId != newContact.AccountId &&
                        contactRoles.contains(oldContact.Ruolo_in_Azienda__c)) {
                    accountIdList.add(oldContact.AccountId);
                }
            }

            if (newContact.AccountId != null &&
                    !accountIdList.contains(newContact.AccountId) &&
                    contactRoles.contains(newContact.Ruolo_in_Azienda__c)) {
                accountIdList.add(newContact.AccountId);
            }

            //Check corner case in which a contact role is changed
            if (oldContact != null && (oldContact.AccountId == newContact.AccountId &&
                    contactRoles.contains(oldContact.Ruolo_in_Azienda__c) &&
                    !contactRoles.contains(newContact.Ruolo_in_Azienda__c) &&
                    !accountIdList.contains(newContact.AccountId))) {
                accountIdList.add(newContact.AccountId);
            }
        }

        return accountIdList;
    }

    public static Map<String, Opportunity> GetOpportunityMapFromAccountIdList(List<Id> accountIdList) {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();

        for (Opportunity opp : [
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                WHERE AccountId IN :accountIdList
        ]) {
            opportunityMap.put(opp.Id, opp);
        }

        return opportunityMap;
    }

    public static List<Opportunity> GetUpdatedOpportunityCounters(Map<String, Opportunity> opportunityMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = fileUploaderController.MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = fileUploaderController.computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);

        for (Id oppId : oppIdAndDocStatusMap.keySet()) {
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(oppId);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(oppId);
            Opportunity newOpp = new Opportunity ();

            newOpp.Id = oppId;
            newOpp.Total_Mandatories_Docs__c = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), mandatoryContactDocs, mandatoryQuoteDocs);
            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
            newOpp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
            oppsToUpdate.add(newOpp);
        }

        return oppsToUpdate;
    }

    public static void completeField(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
        
        system.debug('ContactController.completeField - Start newContacts: '+newContacts+'mapOldContacts: '+ mapOldContacts);
        
        Utils_Constants constants = new Utils_Constants();
        
        for (Contact cont : newContacts) {
            if (cont.Ruolo_in_Azienda__c != null && cont.Ruolo_in_Azienda__c.contains(constants.CONTACT_TITOLARE_EFFETTIVO) && cont.Oplon_Titolare_Effettivo__c != true)
            {
                cont.Oplon_Titolare_Effettivo__c = true;
            }
            
            if(cont.Ruolo_in_Azienda__c == null && cont.Oplon_Titolare_Effettivo__c == true)
                cont.Oplon_Titolare_Effettivo__c = false;
            else if (cont.Ruolo_in_Azienda__c != null && !cont.Ruolo_in_Azienda__c.contains(constants.CONTACT_TITOLARE_EFFETTIVO) && cont.Oplon_Titolare_Effettivo__c == true)
            {
                cont.Oplon_Titolare_Effettivo__c = false;
            }
            
            
            if(cont.FinServ__Gender__c==constants.GENDER_FEMALE)
                cont.TitNon_Acc__c=constants.TIT_NO_ACC_F;
            else if(cont.FinServ__Gender__c==constants.GENDER_MALE)
                cont.TitNon_Acc__c=constants.TIT_NO_ACC_M;
            
            if ((String.isBlank(cont.Oplon_Altre_Cariche__c) )){
                
                cont.Altre_Cariche_Flag__c = false;
            }
            
            else if (!(String.isBlank(cont.Oplon_Altre_Cariche__c))){
                
                cont.Altre_Cariche_Flag__c = true;
            }
        }
        system.debug('ContactController.completeField - End');
        
    }
    public static void checkVia(List<Contact> newContList, Map<Id, Contact> oldContMap){
        system.debug('ContactController.checkVia - Start newContList '+newContList+' oldContMap '+oldContMap);
        List<Utils.Option> tipoVia = Utils.getPicklistValues(new Contact(), 'Tipo_Via__c');
        
        for(Contact ctn : newContList) {
            if(oldContMap == null && ctn.Nome_Via__c != null) {
                for(Utils.Option tpv: tipoVia) {
                    if(ctn.Nome_Via__c.startsWith(tpv.value+' ')) {
                        ctn.Tipo_Via__c = tpv.value;
                        ctn.Nome_Via__c = ctn.Nome_Via__c.replaceFirst(tpv.value+' ', '');
                        continue;
                    } 
                }
            } else if(ctn.Nome_Via__c != null && ctn.Nome_Via__c != oldContMap.get(ctn.id).Nome_Via__c 
                      && String.isBlank(ctn.Tipo_Via__c)) {
                          for(Utils.Option tpv: tipoVia) {
                              if(ctn.Nome_Via__c.startsWith(tpv.value+' ')) {
                                  ctn.Tipo_Via__c = tpv.value;
                                  ctn.Nome_Via__c = ctn.Nome_Via__c.replaceFirst(tpv.value+' ', '');
                                  continue;
                              } 
                          }
                      }
        }
        system.debug('ContactController.checkVia - End');
        
    }
    
    public static void notifyMissingFieldsServiceFidejusioneBeforeUpdate(List<Contact> toBeProcessed){
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusioneBeforeUpdate start toBeProcessed: ' +toBeProcessed);
        List<Id> listAccountId = new List<Id>();
        
        for (Contact acc : toBeProcessed) {
            listAccountId.add(acc.Id);
            
        }
        
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Referente_Oplon'];
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
            System.debug('AccountsController notifyMissingFieldsService RecTid: ' +recordTypeId);
        }*/
        List<String> contactFieldList = new List<String>{
            'Phone','MobilePhone',
                'AccountId','Agenzia__c', 'Appellativo__c', 'CAE__c', 'Cap__c', 'Cittadinanza__c', 'Client_Manager__c', 'Comune_di_Nascita__c',
                'Comune__c', 'Convenzione__c', 'Data_di_Nascita__c', 'Data_Rilascio__c', 'Data_Scadenza__c', 'Dati_Identificativi_Cliente_Potenziale__c',
                'Dipendente__c', 'Email', 'FinServ__Gender__c', 'FirstName','Indicativo_Marketing__c', 'Lingua__c',
                'LastName', 'Localita_Residenza__c', 'Localita__c', 'Luogo_Rilascio__c',  'Nome_Via__c', 'Numero_Civico__c', 'Numero_Documento__c',
                'Oplon_Codice_Fiscale__c',  'Professione__c', 'Provincia__c', 'RAE__c', 'Residenza__c', 'ResValutaria__c','Esecutore__c','Firmatario__c','Fidejussore__c','percentuale_di_riferimento_socio__c','Altre_Cariche_Flag__c',
                'SAE__c', 'Sigla_Provincia_Nascita__c', 'Stato_di_Nascita__c', 'Stato_Nascita__c', 'Stato_Residenza_Estero__c', 'TAE__c', 'Tipo_Documento__c',
                'Tipo_Via__c', 'TitNon_Acc__c'
                };
                    
                    
                    
                    
                    List<Contact> toBeUpdated = new List<Contact>();
        
        
        Utils_Constants costants =new Utils_Constants();
        String CONTACT_LEGALE_RAPPRESENTANTE= costants.CONTACT_LEGALE_RAPPRESENTANTE;
        String CONTACT_TITOLARE_EFFETTIVO= costants.CONTACT_TITOLARE_EFFETTIVO;
        String contactFieldsString = String.join(contactFieldList, ',');
        String queryContactString = 'SELECT ' + contactFieldsString + ' FROM Contact WHERE  Id IN :listAccountId';     
        List<Contact> listContact = (List<Contact>) (Database.query(queryContactString));
        
        
        
        for (Contact cont : toBeProcessed) {
            string contController='N';
            String contactMissingFields = '';
            Boolean testCont=false;
            Boolean testCont2=false;
            for (String contF : contactFieldList) {
                if (contF=='Phone' && (cont.get(contF) != null  && cont.get(contF) != '')){   
                    testCont=true;
                }
                
                if(contF=='MobilePhone' && (cont.get(contF) != null  && cont.get(contF) != '')){
                    testCont2=true;
                }
                
                if (contF == 'Sigla_Provincia_Nascita__c' || contF == 'Comune_di_Nascita__c' || contF == 'Localita__c') {
                    if (cont.Stato_Nascita__c == 'Italia') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (contF == 'Stato_di_Nascita__c') {
                    if (cont.Stato_Nascita__c == 'Estero') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (contF == 'Tipo_Via__c' || contF == 'Provincia__c' || contF == 'Comune__c' || contF == 'Cap__c') {
                    if (cont.Residenza__c == 'Italia') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (contF == 'Stato_Residenza_Estero__c') {
                    if (cont.Residenza__c == 'Estero') {
                        if (cont.get(contF) == null || cont.get(contF) == '') {
                            String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                            contactMissingFields = contactMissingFields + fieldLabel + ', ';
                            contController='Y';
                        }
                    }
                }
                
                else if (cont.get(contF) == null || cont.get(contF) == '') {
                    system.debug('contF'+contF);
                    if(contF=='MobilePhone' && testCont==false){
                        contactMissingFields = contactMissingFields + 'Telefono oppure '; 
                    }
                    
                    if((contF=='Phone' && testCont2==false) || (contF=='MobilePhone' && testCont==true)){
                        continue;
                    }
                    
                    
                    String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                    if(fieldLabel == 'Mobile Phone'){
                        contactMissingFields = contactMissingFields + 'Cellulare, '; 
                        continue;
                    }
                    system.debug('fieldLabel'+fieldLabel);
                    contactMissingFields = contactMissingFields + fieldLabel + ', ';
                    contController='Y';
                }
            }
            If(contactMissingFields != ''){
                contactMissingFields = 'Contact:<br/> '+contactMissingFields;
                contactMissingFields = contactMissingFields.removeEnd(', ');
                contactMissingFields = contactMissingFields + '<br/>';
            }
            
            System.debug('ContactController notifyMissingFieldsServiceFidejusioneBeforeUpdate contactMissingFields: ' +contactMissingFields);
            
            
            cont.campi_mancanti_fidejussione__c = contactMissingFields;
            if(cont.campi_mancanti_fidejussione__c=='')
            {
                cont.fidejussore_completo__c= true;
            }
            else
            {
                cont.fidejussore_completo__c= false;
            }
            toBeUpdated.add(cont);
        }
        /*JF 19/09/2020 ad aggiornare deve essere il metodo chiamante
update toBeUpdated;*/
        
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusioneBeforeUpdate - End  toBeUpdated:' + toBeUpdated);
        
    }
    public static void publishPlatformEvnt(List<Id> recordIdLst){
        
        List<Refresh_Lightning__e> refreshEvents = new List<Refresh_Lightning__e>();
        
        for(Id record : recordIdLst)
        {
        	refreshEvents.add(new Refresh_Lightning__e(Is_Alert__c=true, Is_Refresh__c=false, Record_Id__c = record));
        }
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(refreshEvents);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }       
        }
    }
    
    
    
    
    
}