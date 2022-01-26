public with sharing class ElevaRestApiHelper {
    @AuraEnabled
    public static Map<String,List<Contact>> getFidejussoreForQuote(List<Quote> quoteId) {
        
        Set<Id> garanziaIdSet = new Set<Id>();
        Set<Id> cointestazioneSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactsPersonaFisicaList = new List<Contact>();
        List<Contact> contactsPersonaGiuridicaList = new List<Contact>();
        Set<Id> personaGiuridicaSet = new Set<Id>();
        Map<String,List<Contact>> fidejussoreMap = new Map<String,List<Contact>>();
        String legalStr = 'Legale Rappresentante';
        
        List<Garanzia__c> garanziaList = [SELECT Id,Linea_di_Credito__c,Cointestazione__c,Tipo_di_Garanzia__c,Tipo_di_Fidejussione__c 
                                          from Garanzia__c WHERE Linea_di_Credito__c IN :quoteId AND Tipo_di_Garanzia__c = 'Fidejussione'];

        for(Garanzia__c oGarazia : garanziaList){
            if(oGarazia.Tipo_di_Fidejussione__c == 'Cointestazione'){
                cointestazioneSet.add(oGarazia.Cointestazione__c);
            }
            else{
                garanziaIdSet.add(oGarazia.Id);
            }
        }
        List<Fidejussione__c> fidejussioneLst = [Select Id,Cointestazione__c,Garanzia__c,Persona_Fisica__c,Tipo_fidejussione__c,Persona_Giuridica__c from Fidejussione__c 
                                                 WHERE Cointestazione__c IN :cointestazioneSet OR Garanzia__c IN :garanziaIdSet];
        for(Fidejussione__c oFide : fidejussioneLst){
            if(String.isNotEmpty(oFide.Persona_Giuridica__c)){
                personaGiuridicaSet.add(oFide.Persona_Giuridica__c);
            }
            else if(String.isNotEmpty(oFide.Persona_Fisica__c)){
                contactIdSet.add(oFide.Persona_Fisica__c);
            }
        }
        
        contactsPersonaFisicaList = [SELECT Id,AccountId,Firmatario__c,FinServ__EmailVerified__c,FinServ__MobileVerified__c,NDG__c,Tipo_Documento__c, Stato_Nascita__c,Data_Scadenza__c,
                                     Fidejussore__c,Localita__c,Localita_Residenza__c,Phone,MobilePhone,Name,FirstName,LastName,Comune_di_Nascita__c, FinServ__Gender__c,Luogo_Rilascio__c,
                                     Sigla_Provincia_Nascita__c, Data_di_Nascita__c, Oplon_Codice_Fiscale__c, Indirizzo_Residenza_Esteso__c, Provincia__c,Sigla_Provincia__c,Account.Cellulare__c, 
                                     Comune__c, Cap__c, Email, Ruolo_in_Azienda__c, Account.Name, Account.Email__c,Account.Indirizzo_Sede_Legale_Esteso__c,Residenza__c,Numero_Documento__c,Data_Rilascio__c, 
                                     Account.Cap__c, Account.Comune__c, Account.Sigla_Provincia__c, Account.Capitale_Sociale__c,Prefisso_Internazionale__c,
                                     Account.Codice_Fiscale__c, Account.Phone FROM Contact WHERE Id IN: contactIdSet];
        
        contactsPersonaGiuridicaList = [SELECT Id,AccountId,Firmatario__c,FinServ__EmailVerified__c,FinServ__MobileVerified__c,NDG__c,Tipo_Documento__c,Stato_Nascita__c,Data_Scadenza__c,
                                        Fidejussore__c,Localita__c,Localita_Residenza__c,Phone,MobilePhone,Name,FirstName,LastName,Comune_di_Nascita__c, FinServ__Gender__c, Luogo_Rilascio__c,
                                        Sigla_Provincia_Nascita__c, Data_di_Nascita__c, Oplon_Codice_Fiscale__c, Indirizzo_Residenza_Esteso__c, Provincia__c,Sigla_Provincia__c,Account.Cellulare__c, 
                                        Comune__c, Cap__c, Email, Ruolo_in_Azienda__c, Account.Name,  Account.Email__c,Account.Indirizzo_Sede_Legale_Esteso__c,Numero_Documento__c,Data_Rilascio__c, Residenza__c,
                                        Account.Cap__c, Account.Comune__c, Account.Sigla_Provincia__c, Account.Capitale_Sociale__c,Prefisso_Internazionale__c,
                                        Account.Codice_Fiscale__c, Account.Phone FROM Contact WHERE AccountId IN: personaGiuridicaSet AND Ruolo_in_Azienda__c INCLUDES(:legalStr)];
        
        fidejussoreMap.put('Persona Fisica',contactsPersonaFisicaList);
        fidejussoreMap.put('Persona Giuridica',contactsPersonaGiuridicaList);
        System.debug('fidejussoreMap ' + fidejussoreMap);
        return fidejussoreMap;
    }
    @AuraEnabled
    public static List<Contact> getAllFidejussori(String OppId){
        
        List<Contact> allFidejusoriLst = new List<Contact>();
       // Quote creditLine = [Select Id from Quote WHERE OpportunityId =:OppId AND Status != 'Annullata' Limit 1];
        List<Quote> creditLine = [Select Id from Quote WHERE OpportunityId =:OppId AND Status != 'Annullata'];

      
        Map<String,List<Contact>> fidejussoreMap = getFidejussoreForQuote(creditLine);
  
        if( ! (fidejussoreMap.get('Persona Fisica')).isEmpty()){
            
            allFidejusoriLst.addAll(fidejussoreMap.get('Persona Fisica'));
        }
        if( ! (fidejussoreMap.get('Persona Giuridica')).isEmpty()){
            
            allFidejusoriLst.addAll(fidejussoreMap.get('Persona Giuridica'));
        }
        return allFidejusoriLst;
    }
    @AuraEnabled
    public static Map<String,List<Contact>> getFidejussoreWithOppId(String OppId) {
        List<Quote> creditLine = [Select Id from Quote WHERE OpportunityId =:OppId AND Status != 'Annullata'];
       // Quote creditLine = [Select Id from Quote WHERE OpportunityId =:OppId Limit 1];
        return getFidejussoreForQuote(creditLine);
        
    }

}