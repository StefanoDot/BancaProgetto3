/**
 * Created by Matteo Tornielli on 21/03/2019.
 */

public without sharing class MatriceDiAssegnazioneDAO {

    public static List<Matrice_Di_Assegnazione__c> getMatriceDiAssegnazione(List<String> queriedFields) {
        system.debug('MatriceDiAssegnazioneDAO getMatriceDiAssegnazione - Start');
        system.debug('queriedFields: ' + queriedFields);
        String query = 'SELECT ';
        for(String field: queriedFields) {
            query += field+', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Matrice_Di_Assegnazione__c';
        List<Matrice_Di_Assegnazione__c> matrice = (List<Matrice_Di_Assegnazione__c>) Database.query(query);
        if(matrice != null && !matrice.isEmpty()) {
            system.debug('return: ' + matrice);
            system.debug('MatriceDiAssegnazioneDAO getMatriceDiAssegnazione - End');
            return matrice;
        } else {
            system.debug('return new List<Matrice_Di_Assegnazione__c>');
            system.debug('MatriceDiAssegnazioneDAO getMatriceDiAssegnazione - End');
            return new List<Matrice_Di_Assegnazione__c>();
        }
        
    }
}