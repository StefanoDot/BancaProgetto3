public with sharing class FirmaDigitaleHandler {
   
   @AuraEnabled(cacheable = true)
    public static List<Contact> getListaReferentiFirmatari(Id record){
        system.debug(' FirmaDigitaleHandler  getListaReferentiFirmatari - Start');
        system.debug('record: '+ record);
        List<Id> AccountId= getIdAccount(record);
        List<Contact> listaReferentiFirmatari= new  List<contact>();
        listaReferentiFirmatari=[SELECT AccountId,name,Email,Phone ,FinServ__EmailVerified__c,FinServ__MobileVerified__c FROM Contact 
        WHERE AccountId IN :AccountId AND FinServ__EmailVerified__c=true AND FinServ__MobileVerified__c=true ];
        system.debug('Return - listaReferentiFirmatari: '+ listaReferentiFirmatari);
        system.debug(' FirmaDigitaleHandler  getListaReferentiFirmatari - End');
        return listaReferentiFirmatari;
    }

 @AuraEnabled(cacheable = true)
    public static List<Contact> getViewDati(String accountId){
        system.debug(' FirmaDigitaleHandler getViewDati - Start');
        System.debug('dati ref     '+accountId);
        List<Contact> datiRef= new  List<contact>();
        datiRef=[SELECT name,Email,Phone ,FinServ__EmailVerified__c,FinServ__MobileVerified__c FROM Contact WHERE Id=:accountId];
        System.debug('Return - dati ref     '+datiref);
        system.debug(' FirmaDigitaleHandler getViewDati - End');
    return datiRef;
    }


        @AuraEnabled(cacheable = true)
        public  static List<Id> getIdAccount (Id record){
            List<Id> IdAccount=new List<Id>();
            List<Opportunity> listaRecord=new List<Opportunity>();
            listaRecord=[SELECT AccountId FROM Opportunity WHERE Id=:record];
            for(Opportunity opp:listaRecord){

                IdAccount.add(opp.AccountId);
            }

            
            return IdAccount;
        }



}