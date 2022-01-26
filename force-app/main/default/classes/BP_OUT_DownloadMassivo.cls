public class BP_OUT_DownloadMassivo {
    @AuraEnabled
    public static Utils.FidejussoreResponse  Downloadmassivo(String recordId){
        
        Utils.FidejussoreResponse response=new Utils.FidejussoreResponse();
        response.ok=true;
        List<Opportunity> Oppi = [Select Id,accountId From Opportunity where Id =: recordId];

        String accountId = oppi[0].AccountId;
       
        List <Contact> ContactList = new List<Contact>([Select Id, AccountId From Contact Where AccountId =: accountId]);

        //response = ElevaRestApiController.DownloadDocs(opp[0].Id, accountId,ContactList);
        System.debug('response ' + response);
        System.debug('response.ok' +response.ok);
        System.debug('ElevaRestApiController.DownloadDocs - End response '+ response);
        return response;  
    }
}