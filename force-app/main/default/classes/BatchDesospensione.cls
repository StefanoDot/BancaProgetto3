global class  BatchDesospensione implements Database.Batchable<sObject>,Database.AllowsCallouts{  
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('BatchDesospensione.start --- Start');
        //cdo dite
        
        System.debug('query ' + Database.getQueryLocator('Select id,StageName,Is_Suspended__c from Opportunity where StageName=\'PEF Pre-Istruttoria\' or StageName=\'PEF Istruttoria\''));
        
        return Database.getQueryLocator('Select id,StageName,Is_Suspended__c from Opportunity where StageName=\'PEF Pre-Istruttoria\' or StageName=\'PEF Istruttoria\'');
        
    }
    
    global void execute(Database.BatchableContext BC,  List<Opportunity> oppList){
        System.debug('BatchDesospensione.execute --- Start scope'+oppList);
        System.debug('BatchDesospensione.execute --- Start scope'+oppList.size());
     
    
        list<Id> listQuote = new list<Id>();
        list<Id> listGaranzia = new list<Id>();
        List<Id> opp = new List<Id>();
        List<Opportunity> oppi = [Select id, Numero_Pratica__c, Doc_Mail_User__c from Opportunity where Id in : oppList];
       
        For(Quote q : [Select Id From Quote where OpportunityId in: oppList]){
            listQuote.add(q.Id);
            
        }
        
        For(Garanzia__c g : [Select Id, Opportunit__c from Garanzia__c where Opportunit__c in: oppList  ]){
            listGaranzia.add(g.Id);
        }
        ElevaRestApiController.desospensioneOppBatch(oppi[0].Id,oppi[0].Numero_Pratica__c,listQuote,listGaranzia, oppi[0].Doc_Mail_User__c);


        System.debug('BatchDesospensione.execute --- End');
        
    }
    
    global void finish(Database.BatchableContext BC){
         System.debug('BatchDesospensione.finish --- Start');
        System.debug('BatchDesospensione.finish --- End');
        
        
    }
}