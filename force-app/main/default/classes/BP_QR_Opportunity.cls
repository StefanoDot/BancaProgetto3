public with sharing class BP_QR_Opportunity {
    @AuraEnabled
    public static List<Opportunity> getPriceValue(Id oppId) {
        List<Opportunity> listPricesOpp = new List<Opportunity>();
        listPricesOpp = [SELECT id, Name, Pricing__c FROM Opportunity WHERE Id = :oppId ];
        return listPricesOpp;
    }
}