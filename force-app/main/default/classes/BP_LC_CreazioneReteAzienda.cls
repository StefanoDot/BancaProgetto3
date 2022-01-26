public with sharing class BP_LC_CreazioneReteAzienda{
    
    @AuraEnabled
    public static void BP_OUT_CRA(String opportunityId){
        BP_OUT_CreazioneReteAzienda.BP_CallOUT_CreazioneReteAzienda(opportunityId);
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityDetails(String opportunityId){
        Set<String> profileList = new Set<String>{ 'Sales Support', 'Sales Support Easy Plus', 'Sales Support Supervisor', 'System Administrator' };
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        List<Opportunity> oppsList =  [SELECT Id, StageName, Tipo_di_opportunit__c, Creazione_Rete_Azienda__c FROM Opportunity WHERE Id =: opportunityId AND StageName = 'Completamento Documenti' LIMIT 1];
        Opportunity opp;
        if(!oppsList.isEmpty() && profileList.contains(profileName)){
            opp = oppsList[0];
        }
        return opp;
    }
    
    @AuraEnabled
    public static List<JSONData> contactValidation(String opportunityId){
        System.debug('opportunityId????' + opportunityId);
        Boolean dittaIndividuale = false;
        Boolean legaleTitolare = false;
        Set<String> ruolo = new Set<String>{ 'Titolare Effettivo', 'Legale Rappresentante' };
        Set<String> ruoloQuery = new Set<String>{ 'Titolare Effettivo', 'Legale Rappresentante', 'Titolare Effettivo;Legale Rappresentante'};
        List<Opportunity> oppList = [SELECT Id, Account.Name, Account.AccountNumber, Account.Tipo_di_Azienda__c FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        List<JSONData> jsonRecords = new List<JSONData>();
        System.debug('oppList????' + oppList);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        if(!oppList.isEmpty()){
            System.debug('We are in if1????'); 
            if(String.isNotEmpty(oppList[0].AccountId)){
                if (oppList[0].Account.Tipo_di_Azienda__c == 'DI') {
                    dittaIndividuale = true;
                }
                List<Contact> conList = [SELECT Id, AccountId, Account.AccountNumber, Firmatario__c, Interessato__c, Esecutore__c, Account.Name, Name, NDG__c, Ruolo_in_Azienda__c FROM Contact WHERE AccountId =: oppList[0].AccountId AND Ruolo_in_Azienda__c  =: ruoloQuery];
                Boolean flag = true;
                for(Contact con: conList){
                    List<String> contactTypes = new List<String>();
                    if(String.isNotEmpty(con.Ruolo_in_Azienda__c)){
                        contactTypes = con.Ruolo_in_Azienda__c.split(';');
                        if (dittaIndividuale == true) {
                            if (contactTypes.contains('Titolare Effettivo') && contactTypes.contains('Legale Rappresentante')) {
                                legaleTitolare = true;
                            }
                        }
                    }
                    if(flag){
                        if(String.isEmpty(con.Account.AccountNumber)){
                            JSONData jsonRecord = new JSONData();
                            jsonRecord.contactName = con.Account.Name;
                            jsonRecord.url = baseUrl + '/' + con.AccountId;
                            jsonRecord.validationFlag = true; 
                            if (dittaIndividuale == true) {
                                jsonRecord.dittaIndividualeValidation = dittaIndividuale;
                            }
                            jsonRecords.add(jsonRecord);
                            flag = false;
                        }
                    }
                    if((String.isEmpty(con.NDG__c) && (ruolo.contains(con.Ruolo_in_Azienda__c) || con.Firmatario__c || con.Interessato__c || con.Esecutore__c)) || (String.isEmpty(con.NDG__c) && (contactTypes.contains('Titolare Effettivo') || contactTypes.contains('Legale Rappresentante') || con.Firmatario__c || con.Interessato__c || con.Esecutore__c))){
                        JSONData jsonRecord = new JSONData();
                        jsonRecord.contactName = con.Name;
                        jsonRecord.url = baseUrl + '/' + con.Id;
                        jsonRecord.validationFlag = true;
                        if (dittaIndividuale == true) {
                            jsonRecord.legaleTitolareValidation = legaleTitolare;
                        }
                        jsonRecords.add(jsonRecord);
                    }
                }
                if(jsonRecords.isEmpty()){
                    flag = true;
                    for(Contact con: conList){
                        if(flag){
                            if(String.isNotEmpty(con.Account.AccountNumber)){
                                JSONData jsonRecord = new JSONData();
                                jsonRecord.contactName = con.Account.Name;
                                jsonRecord.url = baseUrl + '/' + con.AccountId;
                                jsonRecord.validationFlag = false; 
                                jsonRecords.add(jsonRecord);
                                if (dittaIndividuale == true) {
                                    jsonRecord.dittaIndividualeValidation = dittaIndividuale;
                                }
                                flag = false;
                            }
                        }
                        JSONData jsonRecord = new JSONData();
                        jsonRecord.contactName = con.Name;
                        jsonRecord.url = baseUrl + '/' + con.Id;
                        jsonRecord.validationFlag = false;
                        if (dittaIndividuale == true) {
                            jsonRecord.legaleTitolareValidation = legaleTitolare;
                        }
                        jsonRecords.add(jsonRecord);
                    }
                }
            }
        }
        System.debug('jsonRecords????' + jsonRecords);
        return jsonRecords;
    }
    
    public class JSONData{
        @AuraEnabled
        public String contactName { get; set; }
        @AuraEnabled
        public String url { get; set; }
        @AuraEnabled
        public Boolean validationFlag { get; set; }
        @AuraEnabled
        public Boolean dittaIndividualeValidation { get; set; }
        @AuraEnabled
        public Boolean legaleTitolareValidation { get; set; }
    }
    
}