/**
* Created by Matteo Tornielli on 22/03/2019.checkDueFidejussioneNDGbuttone
*/

public without sharing class Utils {

    public class FidejussoreResponse{
        @AuraEnabled
        public Boolean ok{set;get;}
        @AuraEnabled
        public String responseMessage{set;get;}
        @AuraEnabled
        public List<Cointestazione__c> inshallah{set; get;}
        @AuraEnabled
        public Boolean error{set;get;}
        @AuraEnabled
        public String Ricezioni{set;get;}
        @AuraEnabled
        public String Morescore{set;get;}
        @AuraEnabled
        public String ErroreRicezioni{set;get;}
        @AuraEnabled
        public String nomeUtente{set;get;}
        @AuraEnabled
        public List<User> listUsers{set; get;}
        @AuraEnabled
        public List<User> listUsersCrediti{set; get;}
        @AuraEnabled
        public String nonVerificati{set;get;}
        @AuraEnabled
        public Boolean isEasyPlus{set;get;}
        @AuraEnabled
        public String statusCode{set;get;}
    }

    public class MandatoryDocumentTypesStatus {
        @AuraEnabled
        public List<DocumentType__c> emptyOppAndAccDocTypes {set; get;}
        @AuraEnabled
        public Map<String, List<DocumentType__c>> emptyContactDocTypes {set; get;}
        @AuraEnabled
        public Map<String, List<DocumentType__c>> emptyQuoteDocTypes {set; get;}
        @AuraEnabled
        public List<DocumentType__c> notVerifiedOppAndAccDocTypes {set; get;}
        @AuraEnabled
        public Map<String, List<DocumentType__c>> notVerifiedContactDocTypes {set; get;}
        @AuraEnabled
        public Map<String, List<DocumentType__c>> notVerifiedQuoteDocTypes {set; get;}
        @AuraEnabled
        public List<DocumentType__c> optionalDocuments { set; get; }
    }
    
    @AuraEnabled
    public static FidejussoreResponse RecuperoDatiReferenti(Id recordId) {
        System.debug('Utils.RecuperoDatiReferenti - Start recordId '+ recordId);
        String oppId = recordId;
        FidejussoreResponse response=new FidejussoreResponse();
        response.ok=true;
        
        List<Contact> cont = [Select id, AccountId,Oplon_Codice_Fiscale__c from Contact where Id =: recordId];
        string AccountId = cont[0].AccountId;
        response= ElevaRestApiController.recuperoDatiReferenti(cont[0].Id, cont[0].Oplon_Codice_Fiscale__c,cont[0].AccountId);
        System.debug('response ' + response);
        System.debug('response.ok' +response.ok);
        System.debug('Utils.RecuperoDatiReferenti - End response '+ response);
        return response;  
    }   
    
    @AuraEnabled
    public static FidejussoreResponse DesospensioneOpp(Id recordId) {
        System.debug('Utils.DesospensioneOpp - Start recordId '+recordId);
        String oppId = recordId;
        FidejussoreResponse response=new FidejussoreResponse();
        //response.ok=true;
        list<Id> listQuote = new list<Id>();
        list<Id> listGaranzia = new list<Id>();
        
        List<Opportunity> oppi = [Select id, Numero_Pratica__c, Doc_Mail_User__c from Opportunity where Id =: recordId];
        For(Quote q : [Select Id, Status From Quote where OpportunityId =: recordId AND Status!='Annullata']){
            listQuote.add(q.Id);
            
        }
        
        For(Garanzia__c g : [Select Id, Opportunit__c from Garanzia__c where Opportunit__c =: recordId  ]){
            listGaranzia.add(g.Id);
        }
        system.debug('recordId: ' + recordId+ 'listQuote: ' + listQuote + 'listGaranzia' +listGaranzia);
        response= ElevaRestApiController.desospensioneOpp(oppi[0].Numero_Pratica__c,listQuote,listGaranzia, recordId,oppi[0].Doc_Mail_User__c);
        System.debug('eeee' +response);
        System.debug('oooooo'+ response.ok);
        
        System.debug('oooooo'+ response.responseMessage);
        if(response.ok==true){
            System.debug('belaaa');
            
            Opportunity opp = new Opportunity();
            opp.Id = oppi[0].Id;
            opp.Is_Suspended__c=false;
            Update opp;
        }
        System.debug('response' + response);
        System.debug('response.ok' +response.ok);
        
        System.debug('Utils.DesospensioneOpp - End response '+response);
        
        return response;  
    }   
    
    
    @AuraEnabled
    public static FidejussoreResponse creaCointestazioneCallout(Id recordId) {
        System.debug('Utils.creaCointestazioneCallout - Start recordId'+recordId);
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        FidejussoreResponse response=new FidejussoreResponse();
        response.ok=true;
        List<Id> contactIdList = new List<Id>();
        List<Id> accountIdList = new List<Id>();
        
        List<String> subjectIdList = new List<String>();
        
        
        List<Cointestazione__c> coint = [Select id,Tipo_di_Cointestazione__c from Cointestazione__c where id =:recordId ];
        String defaultUserMail1 ='';
        List<Default_User__mdt> defaultUser1 = new List<Default_User__mdt>();
        defaultUser1=[select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, username__c  from Default_User__mdt where DeveloperName ='Integration_Default_Dot_Email'];
        if(defaultUser1.size()==1){
            defaultUserMail1=defaultUser1[0].username__c;
            
        }  
        
        Id user = userInfo.getUserId();
        System.debug('user ' + user);
        List<User> userMail = [Select id, ManagerId, Email, Manager.Email from User where Id =: user];
        
        String Email ;
        if(userMail[0].ManagerId <>null){
            System.debug('kushti i menxhaerit');
            
            if(userMail[0].Manager.Email.ContainsIgnoreCase('dunegroup.it')){
                Email= defaultUserMail1;  
            }else {
                Email=userMail[0]. Manager.Email;   
            }      
        }else {
            
            if(userMail[0].Email.ContainsIgnoreCase('dunegroup.it')){
                Email= defaultUserMail1;  
            }else {
                Email=userMail[0].Email;
            }
        }
        system.debug('email ' + Email);
        
        for(Fidejussione__c  a : [Select Id ,Cointestazione__r.Tipo_di_Cointestazione__c, Cointestazione__c,Persona_Giuridica__c, Persona_Fisica__c ,PersonaFisicaOplon__c,   Persona_Fisica__r.NDG__c, NDG__c from Fidejussione__c  where Cointestazione__c =: recordId]){
            
            if( a.Cointestazione__r.Tipo_di_Cointestazione__c =='Contact'){
                contactIdList.add(a.Persona_Fisica__c);
            }
            if( a.Cointestazione__r.Tipo_di_Cointestazione__c =='Account'){
                accountIdList.add(a.Persona_Giuridica__c);
            }
            subjectIdList.add(a.NDG__c);
            
        }
        
        System.debug('contactIdList'+contactIdList);
        if(metadata.size()==1){
            if(metadata[0].Status__c == 'Active'){
                if(coint[0].Tipo_di_Cointestazione__c== 'Contact'  && !contactIdList.isEmpty() && !subjectIdList.isEmpty()){
                    response= ElevaRestApiController.cointestazioneOnCedacriCallout(recordId,contactIdList, subjectIdList,Email,'contact');
                    
                }
                else if(coint[0].Tipo_di_Cointestazione__c== 'Account' && !accountIdList.isEmpty() && !subjectIdList.isEmpty() ){
                    response= ElevaRestApiController.cointestazioneOnCedacriCallout(recordId,accountIdList, subjectIdList,Email,'account');
                    
                }
            }
            else{
                response.responseMessage='ATTENZIONE! La funzionalità di richiesta NDG e stata disabilitata. Contattare l\'amministratore di sistema.';
                response.ok=false;
            }}
        
        System.debug('Utils.creaCointestazioneCallout - Start response'+response);
        return response;  
    }
    
    /*

@AuraEnabled
public static Boolean creaCointestazione(Id recordId) {
system.debug('Utils.creaCointestazione-Start oppId: '+recordId);
List<Id> contactIdList = new List<Id>();
List<String> subjectIdList = new List<String>();

Id user = userInfo.getUserId();
System.debug('user' + user);
List<User> userMail = [Select id, ManagerId, Email, Manager.Email from User where Id =: user];

String Email ;
if(userMail[0].ManagerId <>null){
Email=userMail[0]. Manager.Email;
}
else Email =userMail[0].Email;

System.debug('Email' +Email);        
for(Fidejussione__c  a : [Select Id , Cointestazione__c,Persona_Fisica__c ,Persona_Fisica__r.PersonaFisicaOplon__c, NDG__c from Fidejussione__c  where Cointestazione__c =: recordId]){
contactIdList.add(a.Persona_Fisica__c);
subjectIdList.add(a.Persona_Fisica__r.PersonaFisicaOplon__c);

}

System.debug('contactIdList'+contactIdList);
ElevaRestApiController.cointestazioneOnCedacri(recordId,contactIdList, subjectIdList,Email);

return true;         
}
*/
    
    @AuraEnabled
    public static FidejussoreResponse checkDueFidejussioneNDGbuttone(Id recordId) {
        system.debug('Utils.checkDueFidejussioneNDGbuttone-Start recordId: '+recordId);
        FidejussoreResponse response=new FidejussoreResponse();
        response.ok=true;
        response.responseMessage='';
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        
        List<Account> acc = [Select Id, Name,Tipo_di_Azienda__c,Cittadinanza__c,Lingua__c,Italia__c,Tipo_Via__c,Nome_Via__c,Provincia__c,Comune__c,Cap__c,Phone,Cellulare__c,Email__c,
                             Fax,Codice_Fiscale__c,Ind_Marketing__c, Agenzia__c,Client_Manager__c,Numero_Civico__c,Codice_Estero__c,SAE__c,RAE__c,Ateco_2007__c,Numero_CCIAA_REA__c,
                             Data_Iscrizione_Legale__c,Provincia_Iscrizione_Legale__c,Res_Valutaria__c,Appellativo__c,Convenzione__c, fidejussore_completo__c,Ricezione_NDG_Cedacri__c,
                             erogazione_dei_servizi__c,Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualit_Servizio__c,Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c,
                             userMail__c
                             from Account where Id =: recordId];
        
        if(acc.isEmpty()){
            return response;
        }
        if(acc[0].Nome_Via__c!=null && acc[0].Nome_Via__c.length() >= 24){
            response.responseMessage='Attenzione! Nome Via non valido per il censimento in Cedacri.Deve essere solo 24 characteri';
            response.ok=false;
            return response;
        }
        system.debug('Utils.checkDueFidejussioneNDGbuttone  acc: '+acc);
        list <Account> accounts= AccountsController.notifyMissingFieldsServiceFidejusione(acc);
        System.debug('before ' + accounts );
        
        System.debug('Inside 3--' + accounts[0].fidejussore_completo__c );
        System.debug('Inside 4--' + accounts[0].campi_mancanti_fidejussione__c );
        
        if(accounts[0].fidejussore_completo__c == false) {
            System.debug('Inside 1');
            update accounts;
            System.debug('After update--' + accounts);
            response.ok=false;
            if(accounts[0].campi_mancanti_fidejussione__c!=null){                
                String message= accounts[0].campi_mancanti_fidejussione__c.remove('Account:');
                response.responseMessage='Occorre valorizzare i seguenti campi:' +message.remove('<br/>');
            }
            if(!test.isRunningTest()){  
                return response;
            }
        }
        if(metadata.size()==1){
            if(metadata[0].Status__c == 'Active'){
                
                response= ElevaRestApiController.fidejussoreOnCedacri('account',recordId,acc[0].userMail__c);
            }
            else{
                response.responseMessage='ATTENZIONE! La funzionalità di richiesta NDG e stata disabilitata. Contattare l\'amministratore di sistema.';
                response.ok=false;
            }}
        System.debug('response' + response);
        try{
            System.debug('Inside 2');
            accounts[0].Errore_Ricezione_NDG_Cedacri__c=null;
            
            if(response.ok==false && !accounts.isempty()) 
            {	
                accounts[0].Errore_Ricezione_NDG_Cedacri__c= response.responseMessage;
            }
            update accounts;
            
        }catch(Exception e){
            
            response.ok=false;
            response.responseMessage= e.getMessage();
            return response;
        }
        System.debug('Utils.checkDueFidejussioneNDGbuttone-End response' + response);
        
        return response;
        
    }
    
    @AuraEnabled
    public static FidejussoreResponse checkDueFidejussioneNDGbuttoneContact(Id recordId) {
        system.debug('fileUploaderController.checkDueFidejussioneNDGbuttoneContact-Start recordId: '+recordId);
        FidejussoreResponse response=new FidejussoreResponse();
        
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        
        List<Contact> acc = [Select  Id, AccountId,Agenzia__c,Appellativo__c, CAE__c, Cap__c, Cittadinanza__c, Client_Manager__c, Comune_di_Nascita__c,
                             Comune__c, Convenzione__c, Data_di_Nascita__c,Data_Rilascio__c, Data_Scadenza__c, Dati_Identificativi_Cliente_Potenziale__c,
                             Dipendente__c, Email, FinServ__Gender__c, FirstName,Indicativo_Marketing__c, Lingua__c,
                             LastName, Localita_Residenza__c, Localita__c, Luogo_Rilascio__c, MobilePhone,Nome_Via__c,Numero_Civico__c, Numero_Documento__c,
                             Oplon_Codice_Fiscale__c, Phone,Professione__c, Provincia__c,RAE__c, Residenza__c, ResValutaria__c,Esecutore__c,Firmatario__c,Fidejussore__c,percentuale_di_riferimento_socio__c,Altre_Cariche_Flag__c,
                             SAE__c, Sigla_Provincia_Nascita__c, Stato_di_Nascita__c, Stato_Nascita__c, Stato_Residenza_Estero__c,TAE__c, Tipo_Documento__c,Tipo_Via__c, TitNon_Acc__c ,
                             Ricerche_di_Mercato__c, Erogazione_dei_Servizi__c,Marketing_Banca__c, Profilazione_Banca__c, 
                             Valutazione_Qualita_Servizio__c, Dati_Particolari__c, Consenso_Sic__c,CreatedBy.Profile.Name ,CreatedBy.Email 
                             from Contact where Id =: recordId];
        
        String usermail ;
        if (acc[0].CreatedBy.Profile.Name != 'Integrator'){
            system.debug('bismilah');
            usermail=acc[0].CreatedBy.Email ;
            
        }
        system.debug('e ketuuuuuu'+usermail);
        
        
        if(acc.isempty()){
            return response;
        }
        if(acc[0].Nome_Via__c!=null && acc[0].Nome_Via__c.length() >= 24){
            response.responseMessage='Attenzione! Nome Via non valido per il censimento in Cedacri.Deve essere solo 24 characteri';
            response.ok=false;
            return response;
        }
        system.debug('fileUploaderController.clickBttnNDG-End accParent: '+acc);
        list <Contact > contacts= ContactController.notifyMissingFieldsServiceFidejusione(acc);
        
        if(contacts[0].fidejussore_completo__c == false) {
            
            response.ok=false;
            response.responseMessage=contacts[0].campi_mancanti_fidejussione__c;
            if(contacts[0].campi_mancanti_fidejussione__c!=null){
                String message= contacts[0].campi_mancanti_fidejussione__c.remove('Contact:');
                response.responseMessage='Occorre valorizzare i seguenti campi:' +message.remove('<br/>');
            }
            
            update contacts;
            //return false;
            return response;
            
            
        } 
        else{
            if(metadata.size()==1){
                if(metadata[0].Status__c == 'Active'){
                    system.debug('he');
                    response= ElevaRestApiController.fidejussoreOnCedacri('contact',recordId,usermail );
                }
                else{
                    response.responseMessage='ATTENZIONE! La funzionalità di richiesta NDG e stata disabilitata. Contattare l\'amministratore di sistema.';
                    response.ok=false;
                }}
            contacts[0].Errore_Ricezione_NDG_Cedacri__c=null;
            if(response.ok==false && !contacts.isempty()) 
            {	
                contacts[0].Errore_Ricezione_NDG_Cedacri__c= response.responseMessage;
            }
            update contacts;
            system.debug('fileUploaderController.checkDueFidejussioneNDGbuttoneContact-End');
            return response;  
            
        }    
    }
    
    
    
    @AuraEnabled
    public static FidejussoreResponse campiMancantiCedacri(Id recordId) {
        FidejussoreResponse response=new FidejussoreResponse();
        system.debug('fileUploaderController.campiMancantiCedacri-Start recordId: '+recordId);
        
        List<Account> acc = [Select Id, Name,Tipo_di_Azienda__c,Cittadinanza__c,Lingua__c,Italia__c,Tipo_Via__c,Nome_Via__c,Provincia__c,Comune__c,Cap__c,Phone,Cellulare__c,Email__c,
                             Fax,Codice_Fiscale__c,Ind_Marketing__c, Agenzia__c,Client_Manager__c,Numero_Civico__c,Codice_Estero__c,SAE__c,RAE__c,Ateco_2007__c,Numero_CCIAA_REA__c,
                             Data_Iscrizione_Legale__c,Provincia_Iscrizione_Legale__c,Res_Valutaria__c,Appellativo__c,Convenzione__c, fidejussore_completo__c,Ricezione_NDG_Cedacri__c,
                             erogazione_dei_servizi__c,Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualit_Servizio__c,Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c
                             from Account where Id =: recordId];
        
        
        system.debug('fileUploaderController.clickBttnNDG-End accParent: '+acc);
        list <Account> accounts= AccountsController.notifyMissingFieldsService(acc);
        List<Account> halli = [Select Id ,Campi_Cedacri_Mancanti__c , Anagrafica_Completa__c from Account where Id =: accounts[0].Id];
        
        if(halli[0].Anagrafica_Completa__c == 'False') {
            
            response.ok=false;
            if(halli[0].Campi_Cedacri_Mancanti__c!=null){
                String message= halli[0].Campi_Cedacri_Mancanti__c.remove('<br>');
                String message2= message.remove('<b>');
                String message3= message2.remove('</b>');
                
                response.responseMessage='Occorre valorizzare i seguenti campi:' +message3.remove('<br/>');
            }
            return response;
        } 
        else{            
            response.ok=true;
            system.debug('fileUploaderController.campiMancantiCedacri-end');
            return response;
        }
    }
    
    @AuraEnabled
    public static FidejussoreResponse AnullataQuote(Id quoteId) {
        System.debug('Utils.AnullataQuote - Start quoteId'+quoteId);
        FidejussoreResponse response=new FidejussoreResponse();
        response.ok=true;
        response.error=true;
        
        string RecordTypeRO; 
        Utils_Constants constants = new Utils_Constants();
        List<RecordType> LineaRO = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :constants.RECORD_TYPE_LINEA_RO AND SobjectType = 'Quote'];
        RecordTypeRO = LineaRO.get(0).Id;
        
        list<Quote> Pl_list = new list<Quote>();
        pl_list = [select id,Status,RecordTypeId,Id_Linea_Oplon__c,Id_Analisi_Linea_Oplon__c, Opportunity.Doc_Mail_User__c from Quote where Id =:quoteId];
        System.debug('pl_list'+pl_list);
        Quote p =new Quote();
        p.id=pl_list[0].id;
        p.Status='Annullata'; 
        if(pl_list[0].Id_Linea_Oplon__c ==  null || pl_list[0].Id_Analisi_Linea_Oplon__c == null){
            response.error=true;
            
            
            update p;
            System.debug('Utils.updateCheck - End   p: '+p);
            System.debug('id'+pl_list[0].id+'Id_Linea_Oplon__c'+pl_list[0].Id_Linea_Oplon__c+'Opportunity.Doc_Mail_User__c'+pl_list[0].Opportunity.Doc_Mail_User__c);
        }
        else if(pl_list[0].Id_Linea_Oplon__c !=  null && pl_list[0].Id_Analisi_Linea_Oplon__c != null){
            
            
            
            System.debug('Utils.updateCheck - End   p: '+p);
            System.debug('id'+pl_list[0].id+'Id_Linea_Oplon__c'+pl_list[0].Id_Linea_Oplon__c+'Opportunity.Doc_Mail_User__c'+pl_list[0].Opportunity.Doc_Mail_User__c);
            response= ElevaRestApiController.chuisuraGaranziaLineaSFcallout(pl_list[0].id,pl_list[0].Id_Linea_Oplon__c,pl_list[0].Opportunity.Doc_Mail_User__c);
            System.debug('ja sa eshte responsi' + response);
            System.debug('response.ok' +response.ok);
            response.error=false;
            System.debug('response.ok' +response.error);
            if(response.ok == true){
                update p;}
            
        }
        System.debug('Utils.AnullataQuote - End response'+response);
        
        return response;  
    }
    
    /*  
@AuraEnabled
public static void updateCheck(String quoteId){
System.debug('Utils.updateCheck - Start');
string RecordTypeRO; 
Utils_Constants constants = new Utils_Constants();
List<RecordType> LineaRO = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :constants.RECORD_TYPE_LINEA_RO AND SobjectType = 'Quote'];
RecordTypeRO = LineaRO.get(0).Id;

list<Quote> Pl_list = new list<Quote>();
pl_list = [select id,Status,RecordTypeId,Id_Linea_Oplon__c,Opportunity.Doc_Mail_User__c from Quote where Id =:quoteId];
System.debug('pl_list'+pl_list);
Quote p =new Quote();
p.id=pl_list[0].id;
p.Status='Annullata'; 
p.RecordTypeId=RecordTypeRO;
update p;
System.debug('Utils.updateCheck - End   p: '+p);
System.debug('id'+pl_list[0].id+'Id_Linea_Oplon__c'+pl_list[0].Id_Linea_Oplon__c+'Opportunity.Doc_Mail_User__c'+pl_list[0].Opportunity.Doc_Mail_User__c);

ElevaRestApiController.chuisuraGaranziaLineaSF(pl_list[0].id,pl_list[0].Id_Linea_Oplon__c,pl_list[0].Opportunity.Doc_Mail_User__c);

}  */
    
    
    @AuraEnabled
    public static FidejussoreResponse ChuisaGaranzia(Id recordId) {
        
        FidejussoreResponse response=new FidejussoreResponse();
        response.ok=true;
        response.error=true;
        System.debug('Utils.ChuisaGaranzia - Start' +recordId);
        
        list<Garanzia__c> Pl_list = new list<Garanzia__c>();
        pl_list = [select id, Stato_Garanzia__c,RecordTypeId, Id_Garanzia_Oplon__c,Id_Analisi_Garanzia_Oplon__c,Record_Type_Only__c,Opportunit__r.Doc_Mail_User__c from Garanzia__c  where Id =:recordId];
        System.debug('pl_list'+pl_list);
        Garanzia__c p =new Garanzia__c();
        p.id=pl_list[0].id;
        p.Stato_Garanzia__c='Chiusa'; 
        p.RecordTypeId =pl_list[0].Record_Type_Only__c;
        if(pl_list[0].Id_Garanzia_Oplon__c ==  null || pl_list[0].Id_Analisi_Garanzia_Oplon__c == null){
            response.error=true;
            
            update p;
            System.debug('Utils.ChuisaGaranzia p: '+p);
            System.debug('id'+pl_list[0].id+'Id_Linea_Oplon__c'+pl_list[0].Id_Garanzia_Oplon__c+'Opportunity.Doc_Mail_User__c'+pl_list[0].Opportunit__r.Doc_Mail_User__c);
        }
        else if(pl_list[0].Id_Garanzia_Oplon__c !=  null && pl_list[0].Id_Analisi_Garanzia_Oplon__c != null){
            
            response= ElevaRestApiController.chuisuraGaranziaLineaSFcallout(pl_list[0].id,pl_list[0].Id_Garanzia_Oplon__c,pl_list[0].Opportunit__r.Doc_Mail_User__c);
            System.debug('response' + response);
            response.error=false;
            System.debug('response.ok' +response.error);
            System.debug('response.ok' +response.ok);
            if(response.ok == true){
                update p;}
            System.debug('Utils.ChuisaGaranzia - End');
        }
        return response;  
    }
    
    
    /* 
@AuraEnabled
public static void ChuisaGaranzia(String recordId){
System.debug('Utils.ChuisaGaranzia - Start');

list<Garanzia__c> Pl_list = new list<Garanzia__c>();
pl_list = [select id, Stato_Garanzia__c,Id_Garanzia_Oplon__c, Opportunit__r.Doc_Mail_User__c from Garanzia__c  where Id =:recordId];
System.debug('pl_list'+pl_list);
Garanzia__c p =new Garanzia__c();
p.id=pl_list[0].id;
p.Stato_Garanzia__c='Chiusa'; 

update p;
System.debug('id'+pl_list[0].id+'Id_Linea_Oplon__c'+pl_list[0].Id_Garanzia_Oplon__c+'Opportunity.Doc_Mail_User__c'+pl_list[0].Opportunit__r.Doc_Mail_User__c);

ElevaRestApiController.chuisuraGaranziaLineaSF(pl_list[0].id,pl_list[0].Id_Garanzia_Oplon__c,pl_list[0].Opportunit__r.Doc_Mail_User__c);

}
*/
    
    @AuraEnabled
    public static void updateButtonFondo(String quoteId, String ButtonName){
        System.debug('Utils.updateButtonFondo - Start quoteId ' +quoteId+' ButtonName ' +ButtonName );
        list<Garanzia__c> Pl_list = new list<Garanzia__c>();
        pl_list = [select id,Verifica_fondo__c,RecordTypeId,Esito_simulazione__c,Esito_congelamento__c from Garanzia__c where Id =:quoteId];
        System.debug('pl_list'+pl_list);
        Garanzia__c p =new Garanzia__c();
        p.id=pl_list[0].id;
        System.debug('p.Verifica_fondo__c' +pl_list[0].Verifica_fondo__c);
        System.debug('p.Esito_simulazione__c' +pl_list[0].Esito_simulazione__c);
        System.debug('p.Esito_congelamento__c ' +pl_list[0].Esito_congelamento__c );
        
        if (ButtonName=='Verifica'){
            p.Verifica_fondo__c='In Verifica'; 
            if(pl_list[0].Esito_simulazione__c !='Non Necessaria'){
                p.Esito_simulazione__c ='Da Simulare';
            }
            if(pl_list[0].Esito_congelamento__c !='Non Necessaria'){
                p.Esito_congelamento__c	='Da Congelare';
            }
        }
        else if  (ButtonName=='Simulazione'){
            p.Esito_simulazione__c ='In simulazione';
            
        }
        else if (ButtonName=='Congelamento'){
            p.Esito_congelamento__c	='In congelamento';
            
        }
        update p;
        System.debug('Utils.updateButtonFondo - End   p: '+p);
    }
    
    /* 
DELETED THE METHODS updateVerifcaFondo, updateCongelamentoFondo, updateSimulazioneFondo BECAUSE THEY ARE IMPLEMENTED IN updateButtonFondo. 
*/
    
    
    public static Map<String, sObject> creteMapKeyObject(List<sObject> items, String keyField) {
        system.debug('Utils.creteMapKeyObject - Start items'+items+' keyField '+keyField);
        
        
        Map<String, sObject> newMap = new Map<String, sObject>();
        for(sObject item: items) {
            newMap.put((String)item.get(keyField), item);
        }
        system.debug('return newMap: ' + newMap);
        system.debug('Utils.creteMapKeyObject - End');
        return newMap;
    }
    
    public static Set<String> creteSetIds(List<sObject> items, String field) {
        system.debug('Utils.creteSetIds - Start items'+items+' field '+field);
        
        Set<String> newSet = new Set<String>();
        for(sObject item: items) {
            newSet.add((String)item.get(field));
        }
        system.debug('return: newSet ' + newSet);
        system.debug('Utils.creteSetIds - End');
        return newSet;
    }
    
    public static Map<String, List<sObject>> creteMapKeyObjectList(List<sObject> items, String keyField) {
        system.debug('Utils.creteMapKeyObjectList - Start items: ' + items + 'keyField: ' + keyField);
        
        Map<String, List<sObject>> newMap = new Map<String, List<sObject>>();
        for(sObject item: items) {
            if(newMap.containsKey((String)item.get(keyField))) {
                List<sObject> tmpList = newMap.get((String)item.get(keyField));
                tmpList.add(item);
            } else {
                List<sObject> tmpList = new List<sObject>();
                tmpList.add(item);
                newMap.put((String)item.get(keyField), tmpList);
            }
        }
        system.debug('return: newMap ' + newMap);
        system.debug('Utils.creteMapKeyObjectList - End');
        return newMap;
    }
    public static String getCurrentUserMail(){
        system.debug('Utils.getCurrentUserMail - Start');
        set<String> userIdSet= new set<String>{UserInfo.getUserId() };
            list<String> stringQuery=new list<String>{'Email'};
                list<User> users=UsersDAO.getUsersFromIds(stringQuery, userIdSet);
        
        String mail= users[0].Email;
        if(mail.contains('dunegroup.it'))
            return 'jacopo.flore@dunegroup.it';
        system.debug('Utils.getCurrentUserMail - End ' );
        
        return mail;
    }
    @AuraEnabled(cacheable = true)
    public static List <Option> getPicklistValues(sObject objInfo, string picklistFieldApi) {
        System.debug('Utils.getPicklistValues - Start objInfo'+objInfo+' picklistFieldApi '+picklistFieldApi);
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
        map <String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list <Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
        list <Option> objWrapper = new list <Option> ();
        
        for (Schema.PicklistEntry a: values) {
            Option option = new Option();
            option.label = a.getLabel();
            option.value = a.getValue();
            objWrapper.add(option);
        }
        System.debug('Utils.getPicklistValues - End  objWrapper: '+objWrapper);
        return objWrapper;
        
    }
    /*    @AuraEnabled(cacheable = true)
public static string RecuperaStato (string quoteId) {
System.debug('Utils.RecuperaStato - Start  quoteId: '+quoteId);

Garanzia__c  CrLine        = [SELECT Id, Verifica_fondo__c FROM Garanzia__c WHERE id =:quoteId];

System.debug('Utils.RecuperaStato - End  CrLine.Status: '+CrLine.Verifica_fondo__c);

return CrLine.Verifica_fondo__c;     
} */ 
    
    @AuraEnabled(cacheable = true)
    public static string AnnullaQuote (string quoteId) {
        system.debug('Utils.AnnullaQuote - Start : '+ quoteId);
        
        Quote  quoteToUpdate  = new Quote();
        string Esito='OK';
        try{
            list <Quote> CrLine  = [SELECT Status, Id FROM Quote WHERE id =:quoteId];
            if(CrLine.size() > 0){
                quoteToUpdate = CrLine.get(0);
                //  quoteToUpdate.id=CrLine[0].id;
                quoteToUpdate.Status='Annullata';
                update quoteToUpdate;
                
            }
        }
        
        catch(Exception e){
            Esito='KO';
            //  system.debug('ErorreAnuulaQuote : '+ e.getMessage());
        }
        System.debug('Utils.AnnullaQuote - End Esito:' +Esito);
        return Esito;     
    }    
    
    public static String getSalesDiRiferimentoAreaMail(List<Account> account){
        system.debug('Utils.getSalesDiRiferimentoAreaMail - Start account '+account);
        Set<String> userIdSet = new set<String>();
        // Set<String> mangerIdSet = new set<String>();
        List<String> stringQuery = new list<String>{'Email'};
            List<Id> accountId = new List<Id>();
        User us=[SELECT email,  Manager.email FROM User where  id=:userinfo.getuserid()];
        for(Account accId : account) {
            accountId.add(accId.id);
        }
        
        List<Account> salesDiRiferimento = [SELECT id, Inside_Sales_di_riferimento__c ,Manager_ID__c 
                                            FROM Account WHERE id in:accountId];
        
        
        for(Account acc : salesDiRiferimento) {
            userIdSet.add(acc.Inside_Sales_di_riferimento__c);
            //mangerIdSet.add(acc.Manager_ID__c);
        }
        
        List<User> users = UsersDAO.getUsersFromIds(stringQuery, userIdSet);
        //List<User> manager = UsersDAO.getUsersFromIds(stringQuery, mangerIdSet);
        if(!users.isEmpty() && !String.isBlank(users[0].Email)) {
            string mail= users[0].Email;
            if(mail.contains('dunegroup.it'))
                return 'jacopo.flore@dunegroup.it';
            else
                return mail;
        } else{
            if(us!=null && us.Manager!=null)
            {    
                string mail= us.Manager.Email;
                if(mail.contains('dunegroup.it'))
                    return 'jacopo.flore@dunegroup.it';
                else
                    return mail;
            }
        }
        
        system.debug('Utils.getSalesDiRiferimentoAreaMail - End');
        if(us.email.contains('dunegroup.it'))
            return 'jacopo.flore@dunegroup.it';
        return us.email;   
    }
    
    // wrapper class
    public with sharing class Option {
        @AuraEnabled public string label {get;set;}
        @AuraEnabled public string value {get;set;}
    }
    
    public static String getSalesDiRiferimentoAreaMailTest(List<Id> account){
        system.debug('Utils.getSalesDiRiferimentoAreaMailTest - Start account '+account);
        Set<String> userIdSet = new set<String>();
        // Set<String> mangerIdSet = new set<String>();
        List<String> stringQuery = new list<String>{'Email'};
            List<Id> accountId = new List<Id>();
        User us=[SELECT email,  Manager.email FROM User where  id=:userinfo.getuserid()];
        
        List<Account> salesDiRiferimento = [SELECT id, Inside_Sales_di_riferimento__c ,Manager_ID__c , Inside_Sales_di_riferimento__r.Email
                                            FROM Account WHERE id in:account];
        for(Account acc : salesDiRiferimento) {
            userIdSet.add(acc.Inside_Sales_di_riferimento__c);
            System.debug('Acc' +acc.Inside_Sales_di_riferimento__r.Email);
            //mangerIdSet.add(acc.Manager_ID__c);
        }
        
        List<User> users = UsersDAO.getUsersFromIds(stringQuery, userIdSet);
        //List<User> manager = UsersDAO.getUsersFromIds(stringQuery, mangerIdSet);
        String finalEmail;
        if(!users.isEmpty() && !String.isBlank(users[0].Email)) {
            
            string mail= users[0].Email;
            System.debug('mail' +mail);
            
            if(mail.contains('dunegroup.it')){
                
                finalEmail= 'jacopo.flore@dunegroup.it';
            }
            else{
                
                finalEmail= mail;}
            
        } else{
            
            if(us!=null && us.Manager!=null)
            {    
                string mail= us.Manager.Email;
                if(mail.contains('dunegroup.it')){
                    finalEmail= 'jacopo.flore@dunegroup.it';}
                else{
                    finalEmail= mail;}
            }
        }
        System.debug('us.email' +us.email);
        if(us.email.contains('dunegroup.it'))
            finalEmail= 'jacopo.flore@dunegroup.it';
        finalEmail= us.email; 
        
        System.debug('Utils.getSalesDiRiferimentoAreaMailTest End finalEmail ' + finalEmail);
        return finalEmail;
        
    }
    
    @AuraEnabled(cacheable = true)
    public static FidejussoreResponse  checkDublicateCointestazione( Id recordId){
        system.debug('Utils.checkDublicateCointestazione Start recordId '+recordId);
        FidejussoreResponse response=new FidejussoreResponse();
        //    response.ok=true;
        
        List<String> ourCoint = new List<String>();
        List<String> guridiCon = new List<String>();
        Set<String> ndgSet = new Set<String>();
        List<String> ndgList = New List<String>();
        List<Fidejussione__c> sizeFid = [Select id, Persona_Fisica__r.NDG__c, NDG__c, Persona_Giuridica__r.AccountNumber from Fidejussione__c where Cointestazione__c =: recordId];
        
        if(sizeFid.size()<2){
            response.ok=false;
            response.responseMessage = 'Hai meno di due Fidejussori';
            system.debug('response'+response);
            return response;
        }
        else{
            For(Fidejussione__c  fid : sizeFid ){
                system.debug('po ketu sizeFid '+sizeFid);
                ndgSet.add(fid.NDG__c);
                ndgList.add(fid.NDG__c);
                
                //   system.debug('setii'+ndgSet);
                //  system.debug('Lista'+ndgList);
                
                If(sizeFid.size()>=2 && ndgSet.size()== ndgList.size()){  
                    system.debug('sew ben vakiii');
                    if(fid.Persona_Fisica__c!=null)
                        ourCoint.add(fid.Persona_Fisica__r.NDG__c);
                    
                    if(fid.Persona_Giuridica__c!=null)
                        guridiCon.add(fid.Persona_Giuridica__r.AccountNumber);
                    
                }
                else{
                    system.debug('a vjen zemra');
                    response.ok=false;
                    response.responseMessage = 'Controlla i Fidejussori, non puoi avere duplicati!';
                    system.debug('response'+response);
                    return response;
                    
                }
            }
        }
        ourCoint.sort();
        guridiCon.sort();
        
        system.debug('ourCoint '+ ourCoint);
        system.debug('guridiCon '+ guridiCon);
        
        List<Cointestazione__c> coint = [Select Id, Name ,Tipo_di_Cointestazione__c, ( Select id , Persona_Fisica__r.NDG__c,Persona_Giuridica__r.AccountNumber from Fidejussioni__r) from Cointestazione__c  where id <>: recordId and NDG_Cointestazione__c<> null ];
        system.debug('coint '+ coint);
        
        List<Cointestazione__c> dublicates = new List<Cointestazione__c>();
        
        For(Cointestazione__c  c : coint ){
            
            Boolean Giuridica=false;
            Boolean yes=false;
            
            List<String> ourFid = new List<String>();
            List<String> fidGiuridica = new List<String>(); 
            //      system.debug('c.Fidejussioni__r '+c.Fidejussioni__r);
            
            for(Fidejussione__c  fid : c.Fidejussioni__r){
                
                if(c.Tipo_di_Cointestazione__c=='Contact' && c.Tipo_di_Cointestazione__c<> null){  
                    ourFid.add(fid.Persona_Fisica__r.NDG__c);
                }
                
                else if(c.Tipo_di_Cointestazione__c=='Account'&& c.Tipo_di_Cointestazione__c<> null){
                    fidGiuridica.add(fid.Persona_Giuridica__r.AccountNumber);
                }
            }
            
            if(ourFid.size()>0){
                
                ourFid.sort();
                //   system.debug('ourFid' + ourFid);
                yes =  ourFid.equals(ourCoint);
                //    system.debug('yes '+yes);
            }
            
            if(fidGiuridica.size()>0){
                
                //   system.debug('fidGiuridica  '+fidGiuridica);
                fidGiuridica.sort();
                Giuridica = fidGiuridica.equals(guridiCon);
                //  system.debug('Giuridica '+Giuridica);
            }
            
            if(yes || Giuridica){
                dublicates.add(c);
                response.ok=true;
                response.inshallah=dublicates;
            }
        }
        system.debug('Utils.checkDublicateCointestazione End response '+response);
        
        return response;
    }
    
    @AuraEnabled 
    public static void deleteCoin(Id recordId){
        system.debug('Utils.deleteCoin Start recordId' + recordId);
        
        Cointestazione__c coin = [SELECT Id FROM Cointestazione__c WHERE id =: recordId];
        
        delete coin;    
        system.debug('Utils.deleteCoin End');
    }
    
    @AuraEnabled
    public static Boolean switchSystems(){
        system.debug('Utils.switchSystems Start');
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        if(metadata.size()==1){
            if(metadata[0].Status__c == 'Active'){
                return true;
            }}
        system.debug('Utils.switchSystems END');
        return false;
    }
    
    
    public static String getDocUserMail(String docId){
        system.debug('Utils.getDocUserMail Start docId'+docId);
        String defaultUserMail ='';
        List<Default_User__mdt> defaultUser = new List<Default_User__mdt>();
        defaultUser=[select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, username__c  from Default_User__mdt where DeveloperName ='Integration_Default_Dot_Email'];
        if(defaultUser.size()==1){
            defaultUserMail=defaultUser[0].username__c;
            
        }
        boolean isUser= false;
        Document__c accc = [SELECT Account__c, Contact__c, Opportunity__c, 
                            Quote__c, Opportunity__r.Inside_Sales_di_riferimento__r.Email,
                            Quote__r.Opportunity.Inside_Sales_di_riferimento__r.Email, 
                            Contact__r.Account.Inside_Sales_di_riferimento__r.Email, 
                            Account__r.Inside_Sales_di_riferimento__r.Email from Document__c WHERE Id=:docId];
        
        
        String userMailFinal='';
        
        if (accc.Account__c <> null){
            
            if(accc.Account__r.Inside_Sales_di_riferimento__r.Email<> null ){
                if(accc.Account__r.Inside_Sales_di_riferimento__r.Email.ContainsIgnoreCase('dunegroup.it')){
                    userMailFinal= defaultUserMail;  
                } else {
                    userMailFinal=accc.Account__r.Inside_Sales_di_riferimento__r.Email;               
                }
            } else {
                isUser= true;
            }
        }
        
        else if (accc.Contact__c <> null){
            
            if(accc.Contact__r.Account.Inside_Sales_di_riferimento__r.Email<> null ){
                if(accc.Contact__r.Account.Inside_Sales_di_riferimento__r.Email.ContainsIgnoreCase('dunegroup.it')){
                    userMailFinal= defaultUserMail;  
                }else {
                    userMailFinal=accc.Contact__r.Account.Inside_Sales_di_riferimento__r.Email;   
                }
            }else { 
                isUser= true;
            }
            
        }
        else if (accc.Opportunity__c <> null){
            
            if(accc.Opportunity__r.Inside_Sales_di_riferimento__r.Email<> null ){
                
                if(accc.Opportunity__r.Inside_Sales_di_riferimento__r.Email.ContainsIgnoreCase('dunegroup.it')){
                    userMailFinal= defaultUserMail;  
                }  else {
                    userMailFinal=accc.Opportunity__r.Inside_Sales_di_riferimento__r.Email;
                    
                }
            } else{
                isUser= true;
            }
        }
        
        else if (accc.Quote__c <> null){
            
            if(accc.Quote__r.Opportunity.Inside_Sales_di_riferimento__r.Email <> null ){
                if(accc.Quote__r.Opportunity.Inside_Sales_di_riferimento__r.Email.ContainsIgnoreCase('dunegroup.it')){
                    userMailFinal= defaultUserMail;  
                } else {
                    userMailFinal=accc.Quote__r.Opportunity.Inside_Sales_di_riferimento__r.Email;  
                }
            } else { 
                isUser= true;
            }
        }
        if(isUser){
            Id user = userInfo.getUserId();
            System.debug('user ' + user);
            List<User> userMail = [Select id, ManagerId, Email, Manager.Email from User where Id =: user];
            
            if(userMail[0].ManagerId <>null){
                if(userMail[0].Manager.Email.ContainsIgnoreCase('dunegroup.it')){
                    userMailFinal= defaultUserMail;  
                }else {
                    userMailFinal=userMail[0]. Manager.Email;   
                }      
            }else {
                
                if(userMail[0].Email.ContainsIgnoreCase('dunegroup.it')){
                    userMailFinal= defaultUserMail;  
                }else {
                    userMailFinal=userMail[0].Email;
                }
            }
        }
        system.debug('email ' + userMailFinal);
        system.debug('userMailFinal' + userMailFinal);
        system.debug('Utils.getDocUserMail End');
        return userMailFinal;
        
    }
    @AuraEnabled 
    public static FidejussoreResponse checkCount(Id recordId){
        String oppId = recordId;
        FidejussoreResponse response=new FidejussoreResponse();
        //fileUploaderController.numerimi(recordId); commented because it broke Desospensione functionality nd is no longer required
        Utils_Constants constants = new Utils_Constants();
        response.responseMessage='';
        Set<Id> AccountId = new Set<Id>();
        
        list<Opportunity> opp = [select id,StageName,Creazione_Rete_Azienda__c ,AccountId,Tipo_Linea_di_Credito__c,Is_Suspended__c,Total_Mandatories_Docs__c,Total_Optional_Docs__c,Total_Uploaded_Docs__c,Totale_Verified_Docs_Verificati__c from Opportunity where Id =: oppId];
        AccountId.add(opp[0].AccountId);     
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id, AccountNumber,Privacy__c,Verifica_liste_negative__c FROM Account where Id in :AccountId]);
        System.debug('mapa acc' +AccountMap);
        
        Map<Id, List<Contact >> AccCont = new Map<Id, List<Contact>>();
        for(Account acc : [Select Id, (Select Id, Name,Interessato__c,Esecutore__c, Account.AccountNumber from Contacts ) from Account where Id IN:  AccountId]){
            List<Contact> cont = acc.Contacts;
            AccCont.put(acc.Id, cont);
        }
        System.debug('AccCont MAP' +AccCont);
        
        
        list<Opportunity> opps = [SELECT Id, name, (SELECT Id, Name, Percentuale_Spread__c, Percentuale_Commissioni_da_Istruttoria__c, Percentuale_rete_tasso__c, Percentuale_rete_istruttoria__c FROM Quotes) FROM Opportunity where Id =: oppId];
        map<Id,List<Quote>> OppQuoteMap = new map<Id,List<Quote>>();
        
        OppQuoteMap.put(opps[0].Id, opps[0].Quotes); 
        
        system.debug('mapaa quotess'+OppQuoteMap);
        
        
        
        if ((opp[0].StageName == constants.OPPORTUNITY_PEF_Pre_ISTRUTTORIA|| opp[0].StageName == constants.OPPORTUNITY_PEF_ISTRUTTORIA) && opp[0].Is_Suspended__c == true) {
            if ((opp[0].Totale_Verified_Docs_Verificati__c != opp[0].Total_Mandatories_Docs__c) ||
               (opp[0].Total_Uploaded_Docs__c != opp[0].Total_Mandatories_Docs__c)) {
                   response.ok = false;
                   response.responseMessage = response.responseMessage + '\n' + 'Devi convalidare il set documentale!';
               }
            else {
                response.ok = true;
            }
            
            //validimi Blocco_Check_to_PEF_Pre_Istruttoria_Acc
            if (AccountMap.get(opp[0].AccountId).AccountNumber == null){
                system.debug('kety kemi validimin e ndg acc');
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n' +'Occorre richiedere l\'NDG dell\'anagrafica!';    
            }
            //Validimi  Blocco_Check_to_PEF_Pre_Istruttoria_Priv
            if (AccountMap.get(opp[0].AccountId).Privacy__c <>true){
                system.debug('kety kemi validimin e privacy acc');
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n' +'È necessario convalidare la Privacy';    
            }
            //Validimi Blocco_PreIstruttoria
            if (AccountMap.get(opp[0].AccountId).Verifica_liste_negative__c =='KO'||AccountMap.get(opp[0].AccountId).Verifica_liste_negative__c ==null){
                system.debug('kety kemi validimin e liste negative acc');
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n' +'Controlla il campo Verifica liste negative.';    
            }
            //validimi Blocco_Check_to_PEF_Pre_Istruttoria_2
            if(opp[0].Creazione_Rete_Azienda__c<>true){
                system.debug('kety kemi validimin e creazione rete azienda opp');
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n' +'È necessario flaggare il campo Creazione rete azienda!';     
                
            }
            
            if(AccCont.get(opp[0].AccountId).size() >0 && AccountMap.get(opp[0].AccountId)<> null && AccCont.get(opp[0].AccountId)<> null ){
                Boolean flagInteresato= false;
                Boolean flagEsecutore= false;
                for(Contact Con :AccCont.get(opp[0].AccountId) ){
                    if(Con.Interessato__c ==true){
                        flagInteresato= true;
                    }
                    if(Con.Esecutore__c== true){
                        flagEsecutore= true;
                    }
                    
                }
                
                if (flagInteresato == false && flagEsecutore== false ){
                    system.debug('ketu jemi te te dyja interesato esecutore');
                    response.ok=false;
                    response.responseMessage= response.responseMessage + '\n' +'È necessario popolare sui referenti il flag interesato e esecutore';
                }                 
                else  if (flagInteresato == false ){
                    system.debug('ketu jemi interesato');
                    response.ok=false;
                    response.responseMessage=response.responseMessage+'\n' +'È necessario popolare sui referenti il flag interesato ';
                } 
                else   if ( flagEsecutore== false){
                    system.debug('ketu jemi esecutore');
                    response.ok=false;
                    response.responseMessage=response.responseMessage+'\n' +'È necessario popolare sui referenti il flag  e esecutore';
                }
            }  
            for(Quote q: OppQuoteMap.get(opps[0].id)){
                if( opp[0].Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                    
                    if(q.Percentuale_Spread__c==null || q.Percentuale_Commissioni_da_Istruttoria__c==null || q.Percentuale_rete_tasso__c==null || q.Percentuale_rete_istruttoria__c==null){
                        system.debug('easyplus per percentualet');
                        response.responseMessage=response.responseMessage+'\n' +'Nel caso di Progetto Easy Plus per passare in PEF Pre-Istruttoria occorre verificare che siano valorizzati correttamente, su tutte le linee di credito associate, i seguenti campi:  Percentuale Spread, Percentuale rete su tasso, Percentuale Commissioni da Istruttoria, Percentuale rete istruttoria.';
                    }
                }
            }
        }
        else{
            response.ok=false;
            response.responseMessage='l\'opportunità risulta in stato non sospeso. Non è possibile procedere con la desospensione.';
            
        }
        
        return response;  
    }

    @AuraEnabled
    public static MandatoryDocumentTypesStatus GetMissingMandatoryDocTypes (Id opportunityId) {
        MandatoryDocumentTypesStatus mandatoryDocTypesStatus = new MandatoryDocumentTypesStatus();
        List<DocumentType__c> emptyOppAndAccDocTypes = new List<DocumentType__c>();
        Map<String, List<DocumentType__c>> emptyContactDocTypes = new Map<String, List<DocumentType__c>>();
        Map<String, List<DocumentType__c>> emptyQuoteDocTypes = new Map<String, List<DocumentType__c>>();
        List<DocumentType__c> notVerifiedOppAndAccDocTypes = new List<DocumentType__c>();
        Map<String, List<DocumentType__c>> notVerifiedContactDocTypes = new Map<String, List<DocumentType__c>>();
        Map<String, List<DocumentType__c>> notVerifiedQuoteDocTypes = new Map<String, List<DocumentType__c>>();
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>([
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ]);
        Map<String, Map<String, DocumentType__c>> oppIdAndDocTypeIdMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);

        for (String oppId : oppIdAndDocTypeIdMap.keySet()) {
            Opportunity opportunity = opportunityMap.get(oppId);
            List<Document__c> documentsInOpp = oppIdAndDocumentsMap.get(oppId);
            Map<String, DocumentType__c> mandatoryDocTypes = oppIdAndDocTypeIdMap.get(oppId);
            List<Contact> contactList = [
                    SELECT Id, Name,
                    (SELECT Id, File_Name__c, DocumentType__c, DocumentTypeNameFormula__c, ObjectName__c,
                            Verifica_Sales_Support__c, Opportunity__c, Account__c, Quote__c, Contact__c,
                            Url_Documento__c FROM Documenti__r)
                    FROM Contact
                    WHERE AccountId =: opportunity.AccountId
                    AND Ruolo_in_Azienda__c IN ('Titolare Effettivo','Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')
            ];
            List<Quote> quoteList = [
                    SELECT Id, Name, Status,
                    (SELECT Id, File_Name__c, DocumentType__c, DocumentTypeNameFormula__c, ObjectName__c,
                            Verifica_Sales_Support__c, Opportunity__c, Account__c, Quote__c, Contact__c,
                            Url_Documento__c FROM Documenti__r)
                    FROM Quote
                    WHERE OpportunityId =: opportunity.Id
                    AND Status != 'Annullata'
            ];

            Map<String, List<Document__c>> contactDocsMap = new Map<String, List<Document__c>>();
            Map<String, List<Document__c>> quoteDocsMap = new Map<String, List<Document__c>>();
            for (String docTypeId : mandatoryDocTypes.keySet()) {
                DocumentType__c docType = mandatoryDocTypes.get(docTypeId);
                List<Document__c> docsInDocType = new List<Document__c>();

                if (docType.ObjectName__c == 'Contact') {
                    for (Contact contact : contactList) {
                        for (Document__c doc : contact.Documenti__r) {
                            if (doc.File_Name__c != null &&
                                    doc.Url_Documento__c != null &&
                                    (doc.Opportunity__c != null ||
                                            doc.Account__c != null ||
                                            doc.Contact__c != null ||
                                            doc.Quote__c != null)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    if (contactDocsMap.containsKey(contact.Name)) {
                                        List<Document__c> contactDocs = contactDocsMap.get(contact.Name);
                                        contactDocs.add(doc);
                                        contactDocsMap.put(contact.Name, contactDocs);
                                    } else {
                                        contactDocsMap.put(contact.Name, new List<Document__c>{doc});
                                    }
                                }
                            }
                        }

                        List<Document__c> otherFinalList = new List<Document__c>();
                        if (contactDocsMap.size() > 0) {
                            for (Document__c doc : contactDocsMap.get(contact.Name)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    otherFinalList.add(doc);
                                }
                            }
                        }

                        if (otherFinalList != null) {
                            if (otherFinalList.size() == 0) {
                                List<DocumentType__c> contactEmptyDocTypeList = emptyContactDocTypes.get(contact.Name);
                                if (contactEmptyDocTypeList != null && contactEmptyDocTypeList.size() > 0) {
                                    contactEmptyDocTypeList.add(docType);
                                    emptyContactDocTypes.put(contact.Name, contactEmptyDocTypeList);
                                } else {
                                    emptyContactDocTypes.put(contact.Name, new List<DocumentType__c>{docType});
                                }
                            } else {
                                for (Document__c document : contactDocsMap.get(contact.Name)) {
                                    List<DocumentType__c> contactNotVerifiedDocTypeList = notVerifiedContactDocTypes.get(contact.Name);
                                    if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                                        if (contactNotVerifiedDocTypeList!= null && contactNotVerifiedDocTypeList.size() > 0) {
                                            contactNotVerifiedDocTypeList.add(docType);
                                            notVerifiedContactDocTypes.put(contact.Name, contactNotVerifiedDocTypeList);
                                        } else {
                                            notVerifiedContactDocTypes.put(contact.Name, new List<DocumentType__c>{docType});
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                } else if (docType.ObjectName__c == 'Quote') {
                    if(!quoteList.isEmpty()){
                    for (Quote quote : quoteList) {
                        for (Document__c doc : quote.Documenti__r) {
                            if (doc.File_Name__c != null &&
                                    doc.Url_Documento__c != null &&
                                    (doc.Opportunity__c != null ||
                                            doc.Account__c != null ||
                                            doc.Contact__c != null ||
                                            doc.Quote__c != null)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    if (quoteDocsMap.containsKey(quote.Name)) {
                                        List<Document__c> quoteDocs = quoteDocsMap.get(quote.Name);
                                        quoteDocs.add(doc);
                                        quoteDocsMap.put(quote.Name, quoteDocs);
                                    } else {
                                        quoteDocsMap.put(quote.Name, new List<Document__c>{doc});
                                    }
                                }
                            }
                        }

                        List<Document__c> otherFinalList = new List<Document__c>();

                        if (quoteDocsMap.size() > 0) {
                            for (Document__c doc : quoteDocsMap.get(quote.Name)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    otherFinalList.add(doc);
                                }
                            }
                        }

                        if (otherFinalList != null) {
                            if (otherFinalList.size() == 0) {
                                List<DocumentType__c> quoteEmptyDocTypeList = emptyQuoteDocTypes.get(quote.Name);
                                if (quoteEmptyDocTypeList != null && quoteEmptyDocTypeList.size() > 0) {
                                    quoteEmptyDocTypeList.add(docType);
                                    emptyQuoteDocTypes.put(quote.Name, quoteEmptyDocTypeList);
                                } else {
                                    emptyQuoteDocTypes.put(quote.Name, new List<DocumentType__c>{docType});
                                }
                            } else {
                                for (Document__c document : quoteDocsMap.get(quote.Name)) {
                                    List<DocumentType__c> quoteNotVerifiedDocTypeList = notVerifiedQuoteDocTypes.get(quote.Name);
                                    if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                                        if (quoteNotVerifiedDocTypeList!= null && quoteNotVerifiedDocTypeList.size() > 0) {
                                            quoteNotVerifiedDocTypeList.add(docType);
                                            notVerifiedQuoteDocTypes.put(quote.Name, quoteNotVerifiedDocTypeList);
                                        } else {
                                            notVerifiedQuoteDocTypes.put(quote.Name, new List<DocumentType__c>{docType});
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                } else {
                    for (Document__c document : documentsInOpp) {
                        if (document.DocumentType__c == docType.Id && document.Url_Documento__c != null) {
                            docsInDocType.add(document);
                        }
                    }

                    if (docsInDocType.size() == 0) {
                        emptyOppAndAccDocTypes.add(docType);
                    } else {
                        for (Document__c document : docsInDocType) {
                            if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                                notVerifiedOppAndAccDocTypes.add(docType);
                                break;
                            }
                        }
                    }
                }
            }
        }
        mandatoryDocTypesStatus.emptyOppAndAccDocTypes = emptyOppAndAccDocTypes;
        mandatoryDocTypesStatus.notVerifiedOppAndAccDocTypes = notVerifiedOppAndAccDocTypes;
        mandatoryDocTypesStatus.emptyContactDocTypes = emptyContactDocTypes;
        mandatoryDocTypesStatus.notVerifiedContactDocTypes = notVerifiedContactDocTypes;
        mandatoryDocTypesStatus.emptyQuoteDocTypes = emptyQuoteDocTypes;
        mandatoryDocTypesStatus.notVerifiedQuoteDocTypes = notVerifiedQuoteDocTypes;

        return mandatoryDocTypesStatus;
    }

    @AuraEnabled
    public static MandatoryDocumentTypesStatus GetNotVerifiedDocumentTypes (Id opportunityId) {
        MandatoryDocumentTypesStatus mandatoryDocTypesStatus = new MandatoryDocumentTypesStatus();
        List<DocumentType__c> notVerifiedOppAndAccDocTypes = new List<DocumentType__c>();
        List<DocumentType__c> optionalDocumentsList = new List<DocumentType__c>();
        Map<String, List<DocumentType__c>> notVerifiedContactDocTypes = new Map<String, List<DocumentType__c>>();
        Map<String, List<DocumentType__c>> notVerifiedQuoteDocTypes = new Map<String, List<DocumentType__c>>();
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>([
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ]);
        Map<String, Map<String, DocumentType__c>> oppIdAndDocTypeIdMap = fileUploaderController.GetDocTypesMap(opportunityMap);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndAllDocumentsMap(opportunityMap);

        for (String oppId : oppIdAndDocTypeIdMap.keySet()) {
            Opportunity opportunity = opportunityMap.get(oppId);
            List<Document__c> documentsInOpp = oppIdAndDocumentsMap.get(oppId);
            Map<String, DocumentType__c> docTypesMap = oppIdAndDocTypeIdMap.get(oppId);
            List<Contact> contactList = [
                    SELECT Id, Name,
                    (SELECT Id, File_Name__c, DocumentType__c, DocumentType__r.Doc_Opzionale__c, DocumentTypeNameFormula__c, ObjectName__c,
                            Verifica_Sales_Support__c, Opportunity__c, Account__c, Quote__c, Contact__c,
                            Url_Documento__c FROM Documenti__r)
                    FROM Contact
                    WHERE AccountId =: opportunity.AccountId
                    AND Ruolo_in_Azienda__c IN ('Titolare Effettivo','Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante')
            ];
            List<Quote> quoteList = [
                    SELECT Id, Name,
                    (SELECT Id, File_Name__c, DocumentType__c, DocumentType__r.Doc_Opzionale__c, DocumentTypeNameFormula__c, ObjectName__c,
                            Verifica_Sales_Support__c, Opportunity__c, Account__c, Quote__c, Contact__c,
                            Url_Documento__c FROM Documenti__r)
                    FROM Quote
                    WHERE OpportunityId =: opportunity.Id
                    AND Status != 'Annullata'
            ];

            Map<String, List<Document__c>> contactDocsMap = new Map<String, List<Document__c>>();
            Map<String, List<Document__c>> quoteDocsMap = new Map<String, List<Document__c>>();
            for (String docTypeId : docTypesMap.keySet()) {
                DocumentType__c docType = docTypesMap.get(docTypeId);
                List<Document__c> docsInDocType = new List<Document__c>();
                if (docType.ObjectName__c == 'Contact') {
                    for (Contact contact : contactList) {
                        for (Document__c doc : contact.Documenti__r) {
                            if (doc.File_Name__c != null &&
                                    doc.Url_Documento__c != null &&
                                    (doc.Opportunity__c != null ||
                                            doc.Account__c != null ||
                                            doc.Contact__c != null ||
                                            doc.Quote__c != null)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    if (contactDocsMap.containsKey(contact.Name)) {
                                        List<Document__c> contactDocs = contactDocsMap.get(contact.Name);
                                        contactDocs.add(doc);
                                        contactDocsMap.put(contact.Name, contactDocs);
                                    } else {
                                        contactDocsMap.put(contact.Name, new List<Document__c>{doc});
                                    }
                                }
                            }
                        }

                        List<Document__c> otherFinalList = new List<Document__c>();
                        if (contactDocsMap.size() > 0) {
                            for (Document__c doc : contactDocsMap.get(contact.Name)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    otherFinalList.add(doc);
                                }
                            }
                        }

                        if (otherFinalList != null) {
                            if (otherFinalList.size() != 0) {
                                for (Document__c document : contactDocsMap.get(contact.Name)) {
                                    List<DocumentType__c> contactNotVerifiedDocTypeList = notVerifiedContactDocTypes.get(contact.Name);
                                    if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                                        if(docType.Doc_Opzionale__c){
                                            optionalDocumentsList.add(docType);
                                        }
                                        else{
                                            if (contactNotVerifiedDocTypeList!= null && contactNotVerifiedDocTypeList.size() > 0) {
                                                contactNotVerifiedDocTypeList.add(docType);
                                                notVerifiedContactDocTypes.put(contact.Name, contactNotVerifiedDocTypeList);
                                            } else {
                                                notVerifiedContactDocTypes.put(contact.Name, new List<DocumentType__c>{docType});
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                } else if (docType.ObjectName__c == 'Quote') {
                    for (Quote quote : quoteList) {
                        for (Document__c doc : quote.Documenti__r) {
                            if (doc.File_Name__c != null &&
                                    doc.Url_Documento__c != null &&
                                    (doc.Opportunity__c != null ||
                                            doc.Account__c != null ||
                                            doc.Contact__c != null ||
                                            doc.Quote__c != null)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    if (quoteDocsMap.containsKey(quote.Name)) {
                                        List<Document__c> quoteDocs = quoteDocsMap.get(quote.Name);
                                        quoteDocs.add(doc);
                                        quoteDocsMap.put(quote.Name, quoteDocs);
                                    } else {
                                        quoteDocsMap.put(quote.Name, new List<Document__c>{doc});
                                    }
                                }
                            }
                        }

                        List<Document__c> otherFinalList = new List<Document__c>();

                        if (quoteDocsMap.size() > 0) {
                            for (Document__c doc : quoteDocsMap.get(quote.Name)) {
                                if (doc.DocumentType__c == docTypeId) {
                                    otherFinalList.add(doc);
                                }
                            }
                        }

                        if (otherFinalList != null) {
                            if (otherFinalList.size() != 0) {
                                for (Document__c document : quoteDocsMap.get(quote.Name)) {
                                    List<DocumentType__c> quoteNotVerifiedDocTypeList = notVerifiedQuoteDocTypes.get(quote.Name);
                                    if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                                        if(docType.Doc_Opzionale__c){
                                            optionalDocumentsList.add(docType);
                                        }
                                        else{
                                            if (quoteNotVerifiedDocTypeList!= null && quoteNotVerifiedDocTypeList.size() > 0) {
                                                quoteNotVerifiedDocTypeList.add(docType);
                                                notVerifiedQuoteDocTypes.put(quote.Name, quoteNotVerifiedDocTypeList);
                                            } else {
                                                notVerifiedQuoteDocTypes.put(quote.Name, new List<DocumentType__c>{docType});
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    for (Document__c document : documentsInOpp) {
                        if (document.DocumentType__c == docType.Id && document.Url_Documento__c != null) {
                            docsInDocType.add(document);
                        }
                    }

                    if (docsInDocType.size() != 0) {
                        for (Document__c document : docsInDocType) {
                            if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                                if(docType.Doc_Opzionale__c){
                                    optionalDocumentsList.add(docType);
                                }
                                else{
                                    notVerifiedOppAndAccDocTypes.add(docType);
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }

        mandatoryDocTypesStatus.notVerifiedOppAndAccDocTypes = notVerifiedOppAndAccDocTypes;
        mandatoryDocTypesStatus.notVerifiedContactDocTypes = notVerifiedContactDocTypes;
        mandatoryDocTypesStatus.notVerifiedQuoteDocTypes = notVerifiedQuoteDocTypes;
        mandatoryDocTypesStatus.optionalDocuments = optionalDocumentsList;

        return mandatoryDocTypesStatus;
    }

    @AuraEnabled
    public static FidejussoreResponse getUsers(Id recordId)
    {
        FidejussoreResponse response=new FidejussoreResponse();
        system.debug(recordId);
        response.responseMessage='';
        response.ok=true;
        List<Opportunity> opp=[select id, StageName,AccountId from Opportunity where AccountId=:recordId];
        List<Account> acc = [select id, Inside_Sales_di_riferimento__c from Account where id=:recordId];
        String sales= acc[0].Inside_Sales_di_riferimento__c;
        system.debug(sales);
        system.debug(opp);
        Boolean stage= false;
        for(Opportunity oppi:opp){
            if(oppi.StageName<>'Primo Contatto'&&oppi.StageName<>'Prima Visita'&&oppi.StageName<>'Completamento Documenti'&&oppi.StageName<>'PEF Pre-Istruttoria'){
                system.debug('vijm ketu');
                stage=true;
            }
        }
        system.debug('sa jemi ketu'+stage);
        if(stage){
            response.ok = false;
            response.responseMessage= response.responseMessage+'\n' +'Non puoi cambiare il utente a questa fase di Opportunità';

        }
        if(acc[0].Inside_Sales_di_riferimento__c==null){
            response.ok = false;
            response.responseMessage= response.responseMessage+'\n' +'Inside sales di riferimento è vuoto';
        }
        if(response.ok==true){
            List<User> lstUsers = [SELECT Id,FirstName,LastName, Name FROM User where IsActive=true and Profile.Name='Inside Sales' and id!=:sales order by Name asc];
            response.listUsers=lstUsers;

        }
        return response;
    }
    
    @AuraEnabled
    public static FidejussoreResponse nomeUtente(Id recordId){
        FidejussoreResponse response=new FidejussoreResponse();
        
        List<User> name = [SELECT Id,FirstName,LastName, Name FROM User where id=:recordId];
        response.nomeUtente=name[0].Name;
        return response; 
        
    }
    
    
    
    @AuraEnabled
    public static FidejussoreResponse changeUtente(String recordId, String AccountId){
        FidejussoreResponse response=new FidejussoreResponse();
        response.responseMessage='';
        
        
        List<User> user = [SELECT Id, Name,AccountId,Email FROM User where id=:recordId];
        List<Account> acc =[select Id,Analysis_Id_Oplon__c,userMail__c, Anagrafica_Id_Oplon__c from Account where id=:AccountId ];
        List<String> opp = new List<String>();
        boolean check = false;
        string nonu = '';
        string finalii='';
        List<String> oppnonumero = new List<String>();
        List<String> stage = new List<String> {'Chiusa/Persa', 'Erogata'};
        for(Opportunity opi :[select id, Numero_Pratica__c, Name, AccountId from Opportunity where AccountId=:AccountId and StageName NOT IN:stage]){
            if(opi.Numero_Pratica__c == null){
                check=true;
                nonu = nonu +'\n ' + 'Manca il numero practica per questa opportunita '+ opi.Name;
                
            }
            
            opp.add(opi.Numero_Pratica__c);
        }
        if(check){
            finalii=finalii+nonu;
            response.responseMessage=finalii;
            return response; 
        }
        system.debug('opp'+opp);
        response=ElevaRestApiController.cambiaUtenti(opp, acc[0].userMail__c,user[0].Email,acc[0].Id, acc[0].Anagrafica_Id_Oplon__c, user[0].Id);
        
        return response; 
        
    }
       
    @AuraEnabled
    public static FidejussoreResponse profileDoc(Id recordId){
        FidejussoreResponse response=new FidejussoreResponse();
        
        List<String> profileIds = new List<String>();
        
        Boolean shfaqe=true;
        Opportunity opp = [SELECT id, AccountId FROM Opportunity where Id =: recordId];
        
        for(Profile pr : [SELECT Id FROM Profile WHERE Name != 'Agente' and Name !='Intermediario Finanziario' and Name !='Mediatore Creditizio']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        if(!profileIds.contains(currentProfileId)){
            shfaqe=false;
        }
        system.debug('si je m '+shfaqe);
        
        response.ok=shfaqe;
        response.nomeUtente =opp.AccountId;
        
        return response; 
        
    }
    
    public static void DesospensioneOppMasivoFuture(Id recordId) {
        System.debug('Utils.DesospensioneOpp - Start recordId '+recordId);
        String oppId = recordId;
        
        list<Id> listQuote = new list<Id>();
        list<Id> listGaranzia = new list<Id>();
        
        List<Opportunity> oppi = [Select id, Numero_Pratica__c, Doc_Mail_User__c from Opportunity where Id =: recordId];
        For(Quote q : [Select Id, Status From Quote where OpportunityId =: recordId AND status!='Annullata']){
            listQuote.add(q.Id);
            
        }       
        For(Garanzia__c g : [Select Id, Opportunit__c from Garanzia__c where Opportunit__c =: recordId  ]){
            listGaranzia.add(g.Id);
        }
        system.debug('recordId: ' + recordId+ 'listQuote: ' + listQuote + 'listGaranzia' +listGaranzia);
        ElevaRestApiController.desospensioneOppFutureMassivo(oppId,oppi[0].Numero_Pratica__c,listQuote,listGaranzia, oppi[0].Doc_Mail_User__c);
     
        System.debug('Utils.DesospensioneOpp - End response ');
        
    }     
    
   @AuraEnabled 
    public static void switchUsers(String CaDo){
        List<String> profileId= new List<String>();
        for(Profile p: [select id , Name from profile where 
                        Name<>'Chatter External User' 
                        and Name<>'Chatter Free User'
                        and Name<>'Chatter Moderator User'
                        and Name<>'Analytics Cloud Integration User'
                        and Name<>'Analytics Cloud Security User'
                        and Name<>'Contract Manager'
                        and Name<>'CPQ Integration User'
                        and  Name<>'Identity User'
                        and Name<>'Marketing User'
                        and Name<>'Minimum Access - Salesforce'
                        and  Name<>'Partner Community User'
                        and Name<>'Read Only'
                        and Name<>'Solution Manager'
                        and Name<>'Standard User'
                        and Name<>'System Administrator'
                        and Name<>'Migrazione'
                        and Name<>'Integrator'    
                        and Name<>'Integrator'                 
                        and Name<>'Mediatore Creditizio 2'
                        and Name<>'Maintance Deployments'
                        and Name <>'Amministratore del sistema'
                        and Name <>'Guest License User'
                        and Name <>'Banca Progetto Profile'
                        
                       ]){
                           profileId.add(p.Id);    
                           system.debug('profiliii'+p.Name);
                       }
          List<String> profId= new List<String>();
        for(Profile pr: [select id , Name from profile where Name='Migrazione' OR Name='Integrator'])  {
            profId.add(pr.Id);
        }
        System.debug('profileId' +profileId);
        
        List<User> updateUser = new List<User>();
        List<User> user = [SELECT Id,Profile.Name,profileMaintenance__c,IsActive, profileVero__c,Name,ProfileId  FROM User where ProfileId IN: profileId and IsActive=true];
        List<User> userProf = [SELECT Id,Profile.Name,profileMaintenance__c,IsActive, profileVero__c,Name,ProfileId  FROM User where ProfileId IN: profId and IsActive=true];	
        System.debug('userrrr' + user);
        
        
        if(CaDo=='off'){
            for(User u :user){
                system.debug('fikja');
                u.profileVero__c=u.ProfileId;
                u.ProfileId=u.profileMaintenance__c;
                updateUser.add(u);
            }
            for(User us : userProf){
                us.Bypass__c = true;
                updateUser.add(us);
            }
            
            System.debug('updateUser' +updateUser);
            update updateUser;
        }
        
        if(CaDo=='on'){
            for(User u :user){
                system.debug('ndezja');
                u.ProfileId=u.profileVero__c;
                updateUser.add(u);
            }
             for(User us : userProf){
                us.Bypass__c = false;
                updateUser.add(us);
            }
            update updateUser;     
        }
        system.debug('si perfundim'+updateUser);
    }
    
    @AuraEnabled
    public static FidejussoreResponse aggiorna(Id recordId,String objectName){
        system.debug('a vijm a s vijm aaa');
        FidejussoreResponse response=new FidejussoreResponse();
        String ndg;
        String type;  
        date documentDate;
        String documentType;  
        String documentIssuePlace;  
        String documentNumber;  
        String accountName; 
        String sae;  
        String rae;  
        String location; 
        String postalCode;  
        String municipality;  
        String Province;  
        String streetType;  
        String streetName;  
        String streetHomeNumber; 
        String erogazioneDeiServizic;  
        String marketingBancac;  
        String profilazioneBancac; 
        String valutazioneQualitaServizioc; 
        String ricercheDiMercatoC;  
        String datiParticolaric;  
        String consensoSic;
        Date dataScadenza;
        
        If(objectName=='Account'){
            List<Account> acc= [SELECT id, AccountNumber, Name, Oplon_Codice_Ateco__c, Cap__c,Provincia__c,Nome_Via__c,Tipo_Via__c,Tipo_di_Azienda__c,RAE__c,SAE__c,Numero_Civico__c,
                                erogazione_dei_servizi__c,Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualit_Servizio__c,Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c,Comune__c,Sigla_Provincia__c
                                from Account where id=:recordId];
            if(acc[0].Tipo_di_Azienda__c == 'DI'){
                type='NIC';}
            else{
                type='NC';
            }
            accountName=acc[0].Name;
            ndg=acc[0].AccountNumber;
            postalCode=acc[0].Cap__c;
            Province=acc[0].Sigla_Provincia__c;
            rae=acc[0].RAE__c;
            sae=acc[0].SAE__c;
            streetType=acc[0].Tipo_Via__c;
            streetName=acc[0].Nome_Via__c;
            streetHomeNumber=acc[0].Numero_Civico__c;
            erogazioneDeiServizic=acc[0].erogazione_dei_servizi__c;
            marketingBancac=acc[0].Marketing_Banca__c;
            profilazioneBancac=acc[0].Profilazione_Banca__c;
            valutazioneQualitaServizioc=acc[0].Valutazione_Qualit_Servizio__c;
            ricercheDiMercatoC=acc[0].Ricerche_di_Mercato__c;
            datiParticolaric=acc[0].Dati_Particolari__c;        
            consensoSic=acc[0].Consenso_Sic__c;
            municipality=acc[0].Comune__c;
            
        }
        If(objectName=='Contact'){
            List<Contact> con= [SELECT id,NDG__c,Numero_Documento__c, Localita__c,Cap__c,Provincia__c,Data_Rilascio__c,Tipo_Documento__c,Luogo_Rilascio__c,
                                SAE__c,Comune__c,Tipo_Via__c,Nome_Via__c,Numero_Civico__c,Erogazione_dei_Servizi__c,Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualita_Servizio__c,
                                Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c,RAE__c,Sigla_Provincia__c, Data_Scadenza__c
                                from Contact where id=:recordId];
            ndg=con[0].NDG__c;
            documentNumber=con[0].Numero_Documento__c;
            location=con[0].Localita__c;
            postalCode=con[0].Cap__c;
            Province=con[0].Sigla_Provincia__c;
            type='NPP';
            documentDate=con[0].Data_Rilascio__c; 
            documentType=con[0].Tipo_Documento__c;
            documentIssuePlace=con[0].Luogo_Rilascio__c;
            sae=con[0].SAE__c;
            rae=con[0].RAE__c;
            municipality=con[0].Comune__c;
            streetType=con[0].Tipo_Via__c;
            streetName=con[0].Nome_Via__c;
            streetHomeNumber=con[0].Numero_Civico__c;
            erogazioneDeiServizic=con[0].erogazione_dei_servizi__c;
            marketingBancac=con[0].Marketing_Banca__c;
            profilazioneBancac=con[0].Profilazione_Banca__c;
            valutazioneQualitaServizioc=con[0].Valutazione_Qualita_Servizio__c;
            ricercheDiMercatoC=con[0].Ricerche_di_Mercato__c;
            datiParticolaric=con[0].Dati_Particolari__c;  
            consensoSic=con[0].Consenso_Sic__c;
            dataScadenza=con[0].Data_Scadenza__c;
            
            
            
        }
        response=ElevaRestApiController.aggiornaCedacri(recordId,ndg,  type,  documentDate, documentType, documentIssuePlace,  documentNumber, accountName, sae,  rae, location,
                                                        postalCode,  municipality,  Province, streetType, streetName,  streetHomeNumber, erogazioneDeiServizic, marketingBancac, profilazioneBancac,
                                                        valutazioneQualitaServizioc, ricercheDiMercatoC, datiParticolaric, consensoSic, dataScadenza);
        
        
        
        system.debug('responsi okay'+response);
        
        If(objectName=='Account'&&response.ok==true){
            system.debug('po ktu vjen');
            Account acc = new Account();
            acc.id=recordId;
            acc.Aggiorna_Cedacri__c=false;
            update acc;
            system.debug('acc ' + acc);
        }
        else if(objectName=='Contact'&&response.ok==true){
            Contact con = new Contact();
            con.Id=recordId;
            con.Aggiorna_Cedacri__c=false;
            update con;
            system.debug('con ' + con);
        }
        
        return response;  
        
    }
    public static boolean checkUserBypassAccess(){
        
        boolean hasBypassAccess = false;
        List<User> userList = [Select Id,Bypass__c from user where Id =:System.UserInfo.getUserId() Limit 1];
        if(! userList.isEmpty())
        {
            hasBypassAccess = userList[0].Bypass__c;
        }
        return hasBypassAccess;
        
    }
     @AuraEnabled
    public static FidejussoreResponse profileUser(){
        
        FidejussoreResponse response = new FidejussoreResponse();
        
        List<String> userIds = new List<String>();
        
        Boolean show = true;
        
        for(User us : [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' OR Profile.Name = 'Amministratore del sistema'  ]){
            userIds.add(us.Id);
        }
        String currentUserId = UserInfo.getUserId();
        if(!userIds.contains(currentUserId)){
            show =false;
        }
        response.ok=show;
        return response; 
    }

    public static Map<String, Id> getRecordsTypeOpptyQuoteMap(){

        Map<String, Id> recordsMap = new Map<String, Id>();
        List<RecordType> recordsList = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' OR SobjectType = 'Quote'];
        for (RecordType rt : recordsList){
            recordsMap.put(rt.DeveloperName, rt.Id);
        }
        return recordsMap;
     }
     public static Map<String, Id> getRecordsTypeOpptyMap(){
 
        Map<String, Id> recordsMap = new Map<String, Id>();
        List<RecordType> recordsList = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity'];
        for (RecordType rt : recordsList){
            recordsMap.put(rt.DeveloperName, rt.Id);
        }
        return recordsMap;
     }

     public static Map<String, Id> getRecordsTypeQuoteMap(){
 
         Map<String, Id> recordsMap = new Map<String, Id>();
         List<RecordType> recordsList = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote'];
         for (RecordType rt : recordsList){
             recordsMap.put(rt.DeveloperName, rt.Id);
         }
         return recordsMap;
      }
      

  public static String generateRandomString(Integer len) {
      final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
      String randStr = '';
      while (randStr.length() < len) {
         Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
         randStr += chars.substring(idx, idx+1);
      }
      return randStr; 
  }
  public static string generateSignature(String appLanguage, String xChannel, String method,String nonce) {
  // String nonce = String.valueOf(Crypto.getRandomInteger());
   String secretKey = '4bBb6orIYub0vc6Ns15Pr5GuaSEQzMMgeAmj6A1qYlcMifHp0wzqanrhLmmm7kXt47y08jKu8QSelFVa+d4RXQ==';
   String completedString = appLanguage + 'APP-ID' + xChannel + nonce + method;
   System.debug('stringHmac  '+ completedString);
   String signature = generateHmacSHA256Signature(completedString, EncodingUtil.base64Decode(secretKey));
   System.debug('Signature : ' + signature);
   return signature;
   }

   private static String generateHmacSHA256Signature(String saltValue, Blob secretKeyValue) {
       String algorithmName = 'HmacSHA256';
       Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(saltValue), secretKeyValue);
       return EncodingUtil.base64Encode(hmacData);
   }
   public static set<String> getProfileIds(Set<String> profileNames){
       
       Set<String> profileIdSet = new Set<String>();
       for(Profile pr : [SELECT Id FROM Profile WHERE Name IN:profileNames]){
           profileIdSet.add(pr.Id);
       }
       return profileIdSet;
   }
}