global class  batchForTakingAcc implements Database.Batchable<sObject>,Database.AllowsCallouts{  
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('batchForTakingAcc.start-Start');
  
        
        System.debug('query ' + Database.getQueryLocator('Select id from Account where ForTakingAccInBatch__c=\'Test\''));
        
        return Database.getQueryLocator('Select id,Codice_Fiscale__c,userMail__c,updateOplonUserEmail__c,Anagrafica_Id_Oplon__c from Account where ForTakingAccInBatch__c=\'Test\'');
        
    }
    
    global void execute(Database.BatchableContext BC,  List<Account> accList){
        System.debug('batchForTakingAcc.execute --- Start scope'+Acclist);
        System.debug('batchForTakingAcc.execute --- Start scope'+Acclist.size());
     
       System.debug('AccountsController getAnagraphicDetails - Start accList'+Acclist);
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        serializeCredential = JSON.serialize(elevaCredentials, true);
        
        System.debug('Eleva Credential flusso 1.1 ' + serializeCredential);

        String userMail=Utils.getSalesDiRiferimentoAreaMail(accList);
        System.debug('see parameter for callout  '+accList[0].Codice_Fiscale__c+'  '+ accList[0].Id+'  '+  userMail+'  '+  accList[0].updateOplonUserEmail__c);
            ElevaRestApiController.getAnagraphicDetailsForBatch(accList[0].Codice_Fiscale__c, accList[0].Id, userMail, accList[0].updateOplonUserEmail__c, accList[0].Anagrafica_Id_Oplon__c);
     
        System.debug('AccountsController getAnagraphicDetails - End');     
    }
    
    
    global void finish(Database.BatchableContext BC){
         System.debug('batchForTakingAcc.finish --- Start');
        System.debug('batchForTakingAcc.finish --- End');
        
        
    }
}