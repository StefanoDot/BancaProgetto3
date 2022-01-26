global class  BatchDataFineMutuo implements Database.Batchable<sObject>,Database.AllowsCallouts{   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('BatchDataFineMutuo.start --- Start');
        //Diten e fundit te muajti ne 8 mengjes
        
        System.debug('query ' + Database.getQueryLocator('select id, Name, Data_fine_mutuo_Formula__c from Quote where Data_fine_mutuo_Formula__c <= TODAY'));
        System.debug('BatchDataFineMutuo.start --- End');
        
        return Database.getQueryLocator('select id, Name, Data_fine_mutuo_Formula__c, AccountId from Quote where Data_fine_mutuo_Formula__c <= TODAY');
    }
    
    global void execute(Database.BatchableContext BC, List<Quote> quoteList){
        System.debug('BatchDataFineMutuo.execute --- Start scope'+quoteList);
        System.debug('BatchDataFineMutuo.execute --- Start scope size'+quoteList.size());
        
        List<Id> SetAccountId = new List<Id>();
        
        for (Quote q: quoteList) { 
            SetAccountId.add(q.AccountId);
        }
        
        List<Quote> FullListQuote = [Select id, AccountId, name, Data_fine_mutuo_Formula__c from Quote where AccountId IN:SetAccountId];
        
        System.debug('FullListQuote' + FullListQuote);
        System.debug('FullListQuote.size'+FullListQuote.size());
        
        for(Quote qq : FullListQuote){
            System.debug('Emri '+ qq.name);
        }
        
        Map<Id, List<Quote>> mapQuoteOpp =  new Map<Id,List<Quote>>();
        
        List<Account> accList =[SELECT id, Tipo_Anagrafica__c, OwnerId FROM Account WHERE Id in:SetAccountId];
        
        For(Quote  q :FullListQuote ) {
            if(mapQuoteOpp.containsKey(q.AccountId)) {
                mapQuoteOpp.get(q.AccountId).add(q);
            }
            else 
            {
                mapQuoteOpp.put(q.AccountId, new List<Quote>());
                mapQuoteOpp.get(q.AccountId).add(q);
            }
        }
        System.debug('mapQuoteOpp'+mapQuoteOpp);
        
        Set<id> accToBeClosedId = new Set<Id>();
        
        for (Id id : mapQuoteOpp.keySet())
        {
            boolean isValid = false;
            
            for(Quote quote: mapQuoteOpp.get(id)){
                if(quote.Data_fine_mutuo_Formula__c > date.TODAY() ){
                    isValid = true;
                    System.debug('qa behet ketu');
                } 
            }
            if(isValid==false){       
                System.debug('qe mbarum ketu dmth medemek');
                accToBeClosedId.add(id);
            }
        }
        
        Default_User__mdt mdt = [ SELECT username__c, DeveloperName  FROM Default_User__mdt WHERE DeveloperName='Admin'];
        System.debug('mdt batch ' + mdt);
        User adminName = [SELECT id, name, Username FROM User WHERE Username = :mdt.username__c];
        System.debug('adminName ' + adminName);
        List<Account> accFinal = new List<Account>();
        
        for(Account acc: [SELECT id, Tipo_Anagrafica__c, OwnerId FROM Account WHERE Id in:accToBeClosedId]){
            if(acc.Tipo_Anagrafica__c != 'Ex Cliente'){
                System.debug('acc.Tipo_Anagrafica__c ' + acc.Tipo_Anagrafica__c);
                
                acc.Tipo_Anagrafica__c = 'Ex Cliente';
                acc.OwnerId = adminName.id;
                accFinal.add(acc);
                System.debug('acc.OwnerId ' + acc.OwnerId);
            }
        }
        
        System.debug('accFinal '+accFinal);
        update accFinal;
        
        System.debug('BatchDataFineMutuo.execute --- End');  
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('BatchDataFineMutuo.finish --- Start');
        System.debug('BatchDataFineMutuo.finish --- End');
    }
}