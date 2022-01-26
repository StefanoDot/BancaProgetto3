public with sharing class BP_LC_AnticipoPEF{
    @AuraEnabled
    public static Opportunity getOpportunityDetails(String opportunityId){
        Set<String> profileList = new Set<String>{ 'Sales Support', 'Sales Support Easy Plus', 'Sales Support Supervisor', 'System Administrator' };
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        List<Opportunity> oppsList =  [SELECT Id, StageName, Tipo_di_opportunit__c, Creazione_Rete_Azienda__c FROM Opportunity WHERE Id =: opportunityId AND StageName = 'Completamento Documenti' AND Creazione_Rete_Azienda__c = true AND (Tipo_Linea_di_Credito__c = 'Mutuo' OR Tipo_Linea_di_Credito__c = 'Progetto EasyPlus') LIMIT 1];
        Opportunity opp;
        if(!oppsList.isEmpty() && profileList.contains(profileName)){
            opp = oppsList[0];
        }
        return opp;
    }
    @AuraEnabled
    public static void BP_OUT_Anticipo(String opportunityId){
        BP_OUT_AnticipoPef.BP_CallOUT_AnticipoPef(opportunityId);
    }
}