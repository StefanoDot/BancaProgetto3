public with sharing class BP_OUT_CreazioneReteAzienda{
    public static void BP_CallOUT_CreazioneReteAzienda(String opportunityId){
        List<Opportunity> oppList = [SELECT Id, Account.Name, Account.AccountNumber FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        //Set<String> contactTypes = new Set<String>{ 'Legale Rappresentante', 'Titolare Effettivo' };
        JSONData json = new JSONData();
        System.debug('oppList[0]????' +  oppList[0].AccountId);
        if(!oppList.isEmpty()){
            Opportunity opp = oppList[0];
            System.debug('opp????' + opp);
            System.debug('oppList[0].AccountId????' + oppList[0].Account.AccountNumber);
            if(String.isNotEmpty(opp.AccountId)){
                List<String> legalRepresentativesZList = new List<String>();
                List<String> beneficialOwnersJList = new List<String>();
                List<String> partnershipsTList = new List<String>();
                String ndgDIContactList ;
                json.opportunityId = opp.Id;
                json.ndgAccount = opp.Account.AccountNumber;
                List<Account> accList = [SELECT Id, Oplon_Natura_Giuridica__c, Tipo_di_Azienda__c, (SELECT Id, AccountId, NDG__c, Ruolo_in_Azienda__c FROM Contacts) FROM Account WHERE Id =: oppList[0].AccountId LIMIT 1];
                for(Account acc: accList){
                    if(String.isNotEmpty(acc.Oplon_Natura_Giuridica__c) && acc.Oplon_Natura_Giuridica__c == 'SC'){
                        if(acc.contacts.size() > 0){
                            for(Contact con: acc.contacts){
                                List<String> contactTypes = new List<String>();
                                if(String.isNotEmpty(con.Ruolo_in_Azienda__c)){
                                    contactTypes = con.Ruolo_in_Azienda__c.split(';');
                                }
                                if(contactTypes.contains('Legale Rappresentante')){
                                    legalRepresentativesZList.add(con.NDG__c);
                                }
                                if(contactTypes.contains('Titolare Effettivo')){
                                    beneficialOwnersJList.add(con.NDG__c);
                                }
                            }
                        }
                    }
                    else if(String.isNotEmpty(acc.Oplon_Natura_Giuridica__c) && acc.Oplon_Natura_Giuridica__c == 'SP'){
                        if(acc.contacts.size() > 0){
                            for(Contact con: acc.contacts){
                                List<String> contactTypes = new List<String>();
                                if(String.isNotEmpty(con.Ruolo_in_Azienda__c)){
                                    contactTypes = con.Ruolo_in_Azienda__c.split(';');
                                }
                                if(contactTypes.contains('Legale Rappresentante')){
                                    partnershipsTList.add(con.NDG__c);
                                }
                                if(contactTypes.contains('Titolare Effettivo')){
                                    beneficialOwnersJList.add(con.NDG__c);
                                }
                            }
                        }
                    }
                    else if(String.isNotEmpty(acc.Oplon_Natura_Giuridica__c) && acc.Oplon_Natura_Giuridica__c == 'AL' && String.isNotBlank(acc.Tipo_di_Azienda__c) && acc.Tipo_di_Azienda__c == 'DI'){
                        if(acc.contacts.size() > 0){
                            for(Contact con: acc.contacts){
                                List<String> contactTypes = new List<String>();
                                if(String.isNotEmpty(con.Ruolo_in_Azienda__c)){
                                    contactTypes = con.Ruolo_in_Azienda__c.split(';');
                                }
                                if(contactTypes.contains('Legale Rappresentante')){
                                    ndgDIContactList = con.NDG__c;
                                }
                                if(contactTypes.contains('Titolare Effettivo')){
                                    beneficialOwnersJList.add(con.NDG__c);
                                }
                            }
                        }
                    }
                }
                json.legalRepresentativesZ = legalRepresentativesZList;
                json.beneficialOwnersJ = beneficialOwnersJList;
                json.partnershipsT = partnershipsTList;
                json.ndgDIContact = ndgDIContactList;


                Map<String, String> elevaParams = new Map<String, String>{
                    'endpoint' => 'smelending/create-company-network',
                    'method' => 'POST',
                    'body' => System.JSON.serialize(json),
                    'nameString' => 'Create company network ',
                    'erroreString' => 'Errore invocazione servizio: ', 
                    'recordId' => opportunityId
                };
                Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);
               
              /*  ElevaCredentials__mdt elevaMoonCredentials = ElevaCredentials__mdt.getInstance('ElevaMoon');
                if(elevaMoonCredentials != null){
                    String root = elevaMoonCredentials.root__c;
                    String endpoint = root + 'smelending/create-company-network';
                    String body = System.JSON.serialize(json);
                    System.debug('body?????' + body);
                    System.debug('endpoint????' + endpoint);
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endpoint);
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Accept', 'application/json');
                    req.setHeader('x-channel', elevaMoonCredentials.x_channel__c);
                    req.setHeader('x-caller_id', elevaMoonCredentials.x_caller_id__c);
                    req.setHeader('x-hmac', elevaMoonCredentials.x_hmac__c);
                    req.setHeader('x-app_language', elevaMoonCredentials.x_app_language__c);
                    req.setHeader('x-api-key', elevaMoonCredentials.x_api_key__c);
                    req.setTimeout(100000);
                    req.setbody(body);
                    Http http = new Http();
                    HTTPResponse response = http.send(req);
                    System.debug('response?????' + response.getBody());
                } */
            }
        }
    }
    public class JSONData{
        public String opportunityId { get; set; }
        public String ndgAccount { get; set; }
        public String ndgDIContact { get; set; }
        List<String> legalRepresentativesZ { get; set; }
        List<String> beneficialOwnersJ { get; set; }
        List<String> partnershipsT { get; set; }
    }
}