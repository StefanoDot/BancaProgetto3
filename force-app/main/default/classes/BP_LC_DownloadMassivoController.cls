/**
 * Created by mocan on 26/08/2021.
 */

public with sharing class BP_LC_DownloadMassivoController {


    @AuraEnabled
    public static String getDocumentTokenFromEleva() {
        return ElevaRestApiController.getDocumentToken();
    }

    @AuraEnabled(Cacheable=true)
    public static List<Id> getContactListForDownloadMassivo(String accountId) {
        List<Id> contactList = new List<Id>();

        for (Contact contact : [
                SELECT Id, AccountId, Name, Fidejussore__c, Ruolo_in_Azienda__c, (SELECT Id FROM Documenti__r)
                FROM Contact
                WHERE AccountId = : accountId
        ]) {
            contactList.add(contact.id);
        }

        return contactList;
    }

}