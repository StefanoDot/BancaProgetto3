/**
 * Created by Matteo Tornielli on 22/03/2019.
 */

public with sharing class AccountsWithSharingDAO {

    public static List<Account> searchAccount(List<String> queriedFields, String name, String partitaIva, String codiceFiscale, String telefono) {
        System.debug('AccountsWithSharingDAO searchAccount - Start '+'queriedFields: '+queriedFields+' name: '+name+
        ' partitaIva: '+partitaIva+' codiceFiscale: '+codiceFiscale+' telefono: '+telefono);
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
        system.debug(query);
        List<Account> accounts = (List<Account>) Database.query(query);
        if(accounts != null && !accounts.isEmpty()) {
            System.debug('AccountsWithSharingDAO searchAccount - End accounts: '+accounts);
            return accounts;
        } else {
            System.debug('AccountsWithSharingDAO searchAccount - End accounts: '+accounts);
            return new List<Account>();
        }
    }
}