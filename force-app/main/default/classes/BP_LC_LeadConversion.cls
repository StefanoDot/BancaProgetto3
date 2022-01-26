public with sharing class BP_LC_LeadConversion{
    @AuraEnabled
    public static List<Lead> getAllLeads(){
        List<Lead> leadRecords = [SELECT Id, Ragione_Sociale_Lead__c, Codice_Fiscale__c, Partita_IVA__c, Cognome_Referente__c, Nome_Referente__c, Telefono_Referente__c, Email_Referente__c, Comune__c, Provincia__c, Cap__c, Provenienca_Lead__c FROM Lead WHERE isConverted = false LIMIT 50000];
        return leadRecords;
    }
    @AuraEnabled
    public static List<Lead> fetchFilteredLeads(String searchedKeyword, String selectedField){
        String query = 'SELECT Id, Ragione_Sociale_Lead__c, Codice_Fiscale__c, Partita_IVA__c, Cognome_Referente__c, Nome_Referente__c, Telefono_Referente__c, Email_Referente__c, Comune__c, Provincia__c, Cap__c, Provenienca_Lead__c FROM Lead WHERE isConverted = false AND ' + selectedField + ' like \'%' + String.escapeSingleQuotes(searchedKeyword) + '%\' LIMIT 50000';
        return Database.query(query);
    }
    @AuraEnabled
    public static void convertLeadsToAccounts(List<Lead> leadsToBeConverted){
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        for(Lead leadRecord: leadsToBeConverted){
            Database.LeadConvert tempLC = new Database.LeadConvert();
            tempLC.setLeadId(leadRecord.Id);
            tempLC.setContactId(null);
            tempLC.setConvertedStatus(convertStatus.MasterLabel);
            tempLC.setDoNotCreateOpportunity(true);
            leadsToConvert.add(tempLC);
        }
        List<Database.LeadConvertResult> lCResults = Database.convertLead(leadsToConvert);
    }
}