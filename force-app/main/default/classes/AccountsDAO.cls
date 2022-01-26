/**
 * Created by Matteo Tornielli on 22/03/2019.
 */

public without sharing class AccountsDAO {

    public static List<Account> searchAccount(List<String> queriedFields, String name, String partitaIva, String codiceFiscale, String telefono) {
        System.debug('AccountsDAO searchAccount - Start '+'queriedFields: '+queriedFields+' name: '+name+
         'partitaIva: '+partitaIva+' codiceFiscale: '+codiceFiscale+' telefono: '+telefono);

        String query = 'SELECT ';
        for(String field: queriedFields) {
            query += field+', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account WHERE ';
        if(name != null) {
            query += 'Name LIKE :name OR ';
        }
        if(partitaIva != null) {
            query += 'Partita_Iva__c = :partitaIva OR ';
        }
        if(codiceFiscale != null) {
            query += 'Codice_Fiscale__c = :codiceFiscale OR ';
        }
        if(telefono != null) {
            query += 'Phone = :telefono OR ';
        }

        query = query.substring(0, query.length()-3);
        query += ' ORDER BY Name';
        system.debug(query);
        system.debug(name);
        system.debug(partitaIva);
        system.debug(codiceFiscale);
        system.debug(telefono);
        List<Account> accounts = (List<Account>) Database.query(query);
        system.debug(accounts);
        if(accounts != null && !accounts.isEmpty()) {
            System.debug('AccountsDAO searchAccount - End '+'accounts: '+accounts);
            return accounts;
        } else {
            System.debug('AccountsDAO searchAccount - End ');
            return new List<Account>();
        }
    }

    public static List<Account> getAccountFromIds(List<String> queriedFields, Set<String> accountIds) {
        System.debug('AccountsDAO getAccountFromIds - Start '+'queriedFields: '+queriedFields+' accountIds: '+accountIds);

        String query = 'SELECT ';
        for(String field: queriedFields) {
            query += field+', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account WHERE Id in :accountIds';
        List<Account> accounts = (List<Account>) Database.query(query);
        if(accounts != null && !accounts.isEmpty()) {
            System.debug('AccountsDAO getAccountFromIds - End '+'accounts: '+accounts);
            return accounts;
        } else {
            System.debug('AccountsDAO getAccountFromIds - End '+'accounts: '+accounts);
            return new List<Account>();
        }
    }

    public static List<Account> filterAccountsByRecordType(List<Account> accounts, String recordTypeName){
        System.debug('AccountsDAO filterAccountsByRecordType - Start '+'accounts: '+accounts+' recordTypeName: '+recordTypeName);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        System.debug('AccountsDAO filterAccountsByRecordType recordTypeId: '+recordTypeId);
        List<Account> newAccounts = new List<Account>();
        for(Account acc : accounts){
            if(acc.RecordTypeId != recordTypeId){
                newAccounts.add(acc);
            }
        }
        System.debug('AccountsDAO filterAccountsByRecordType - End '+'newAccounts: '+newAccounts);
        return newAccounts;
    }

}