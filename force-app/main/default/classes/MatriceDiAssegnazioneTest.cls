/**
 * Created by ACAPUTO00 on 05/03/2020.
 */

@isTest
public with sharing class MatriceDiAssegnazioneTest {

    @isTest static void testUtils() {
        Matrice_di_Assegnazione__c mda = new Matrice_di_Assegnazione__c(
                Name = 'SAN MARTINO SICCOMARIO',
                Codice_Provincia__c = 'PV',
                CAP__c = '27028',
                Regione__c = 'Lombardia',
                Provincia__c = 'Pavia'
        );
        Matrice_di_Assegnazione__c mda2 = new Matrice_di_Assegnazione__c(
                Name = 'SAN MARTINO SICCOMARIO',
                Codice_Provincia__c = 'PV',
                Cap__c = '',
                Regione__c = 'Lombardia',
                Provincia__c = 'Pavia'
        );
        insert mda;
        insert mda2;
        Test.startTest();
        List<Matrice_di_Assegnazione__c> mdaList = MatriceDiAssegnazioneDAO.getMatriceDiAssegnazione(new List<String>{'CAP__C','Codice_Provincia__c'});
        MatriceDiAssegnazioneService.createCAPMap(mdaList);
        MatriceDiAssegnazioneService.createStateMap(mdaList);
        Test.stopTest();
    }

}