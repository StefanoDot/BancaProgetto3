public with sharing class BP_OUT_AnticipoPef{
    @AuraEnabled
    public static void BP_CallOUT_AnticipoPef(String opportunityId){
        List<Opportunity> oppList = [SELECT Id, Account.Name, Account.AccountNumber, Account.Codice_Fiscale__c, Account.Oplon_Natura_Giuridica__c, (SELECT Id, Provincia_Destinazione_Investimento__c, Status, ExpirationDate, Ammontare_Deliberato__c, Periodicita__c, Durata_Deliberata__c, Finalit_Investimento_Cedacri__c, Categoria_Prodotto_Cedacri__c, Ammontare_aggiornato__c, Durata_in_mesi__c FROM Quotes WHERE Status = 'In Corso') FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        List<InnerJSON> innerJsonList = new List<InnerJSON>();
        JSONData json = new JSONData();
        if(!oppList.isEmpty()){
            Opportunity opp = oppList[0];
            json.nDG = oppList[0].Account.AccountNumber;
            json.codiceFiscale = oppList[0].Account.Codice_Fiscale__c;
            json.ragioneSociale = oppList[0].Account.Name;
            json.naturaGiuridica = oppList[0].Account.Oplon_Natura_Giuridica__c;    
            if(opp.quotes.size() > 0){
                for(Quote q: oppList[0].quotes){
                    InnerJSON innerJsonRecord = new InnerJSON();
                    innerJsonRecord.chiaveFido = q.Id;
                    innerJsonRecord.provDestInv = q.Provincia_Destinazione_Investimento__c;
                    innerJsonRecord.scadenza = q.ExpirationDate;
                    innerJsonRecord.importo = q.Ammontare_aggiornato__c;
                    innerJsonRecord.periodicita = q.Periodicita__c;
                    innerJsonRecord.importoAffidato = q.Ammontare_aggiornato__c;
                    innerJsonRecord.durataMesi = q.Durata_in_mesi__c;
                    innerJsonRecord.finalitInvestimentoCedacri = q.Finalit_Investimento_Cedacri__c;
                    innerJsonRecord.categoriaProdottoCedacri = q.Categoria_Prodotto_Cedacri__c;
                    innerJsonList.add(innerJsonRecord);
                }
                json.fidoList = innerJsonList;
                /* ElevaCredentials__mdt elevaMoonCredentials = ElevaCredentials__mdt.getInstance('ElevaMoon');
                if(elevaMoonCredentials != null){
                    String root = elevaMoonCredentials.root__c;
                    String endpoint = root + 'smelending/advance-pef-process';
                    String body = System.JSON.serialize(json); */
                    Map<String, String> elevaParams = new Map<String, String>{
                        'endpoint' => 'smelending/advance-pef-process',
                        'method' => 'POST',
                        'body' => System.JSON.serialize(json),
                        'nameString' => 'Pef Process ',
                        'erroreString' => 'Errore invocazione servizio: ', 
                        'recordId' => opportunityId
                    };
                    Utils.FidejussoreResponse res = BP_ElevaRestApiRequest.elevaCredentialsResponseMap(elevaParams);





                   /* System.debug('body?????' + body);
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
                    System.debug('response?????' + response.getBody()); */
                //}
            }
        }
    }
    public class JSONData{
        public String nDG { get; set; }
        public String codiceFiscale { get; set; }
        public String ragioneSociale { get; set; }
        public String naturaGiuridica { get; set; }
        public List<InnerJSON> fidoList { get; set; }
    }
    public class InnerJSON{
        public String chiaveFido { get; set; }
        public String provDestInv { get; set; }
        public Date scadenza { get; set; }
        public Decimal importo { get; set; }
        public String periodicita { get; set; }
        public Decimal importoAffidato { get; set; }
        public Decimal durataMesi { get; set; }
        public String finalitInvestimentoCedacri { get; set; }
        public String categoriaProdottoCedacri { get; set; }
    }
}