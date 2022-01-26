/**
 * Created by Matteo Tornielli on 21/03/2019.
 */

public without sharing class MatriceDiAssegnazioneService {

    public static Map<String, Matrice_Di_Assegnazione__c> createCAPMap(List<Matrice_Di_Assegnazione__c> matriceList) {
        system.debug('MatriceDiAssegnazioneService createCAPMap - Start');
        system.debug('matriceList' + matriceList);
        Map<String, Matrice_Di_Assegnazione__c> capMap = new Map<String, Matrice_Di_Assegnazione__c>();
        for(Matrice_Di_Assegnazione__c m: matriceList) {
            capMap.put(m.CAP__c, m);
        }
        system.debug('return: ' + capMap);
        system.debug('MatriceDiAssegnazioneService createCAPMap - End');
        return capMap;
    }

    public static Map<String, Matrice_Di_Assegnazione__c> createStateMap(List<Matrice_Di_Assegnazione__c> matriceList) {
        
        system.debug('MatriceDiAssegnazioneService createStateMap - Start');
        system.debug('matriceList' + matriceList);

        Map<String, Matrice_Di_Assegnazione__c> stateMap = new Map<String, Matrice_Di_Assegnazione__c>();

        for(Matrice_Di_Assegnazione__c m: matriceList) {
            if(String.isEmpty(m.Cap__c)) {
                if (!stateMap.containsKey(m.Codice_Provincia__c)) {
                    stateMap.put(m.Codice_Provincia__c, m);
                } else {
                    String state = m.Codice_Provincia__c;
                    m.Codice_Provincia__c = 'duplicate';
                    stateMap.put(state, m);
                }
            }
        }

        system.debug('return: ' + stateMap);
        system.debug('MatriceDiAssegnazioneService createStateMap - End');
        
        return stateMap;
    }
}