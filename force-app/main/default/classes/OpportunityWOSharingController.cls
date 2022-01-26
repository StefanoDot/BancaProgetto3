public without sharing class OpportunityWOSharingController {
    
    public static void decideScenario(List<Opportunity> newOppList){
        Set<Id> accId = new Set<Id>();
        Map<Id, List<Opportunity>> mapAccOpp =new Map<Id, List<Opportunity>>();
        Map<Id, List<String>> accOppTipoLineMap =new Map<Id, List<String>>();
        Map<Id, List<String>> accOppStageMap =new Map<Id, List<String>>();
        
        List<Account> updateAccount = new List<Account>();

        for(Opportunity opp: newOppList)
        {
            accId.add(opp.AccountId);
        }

    List<Opportunity> scenarioList=[select id,Tipo_Linea_di_Credito__c ,StageName, name, AccountId from Opportunity where AccountId in:accId and StageName <> 'Chiusa/Persa' and StageName <> 'Erogata'];

        for(Opportunity q: scenarioList)
        {
            if(mapAccOpp.containsKey(q.AccountId))
            {
                mapAccOpp.get(q.AccountId).add(q);
                	
                accOppTipoLineMap.get(q.AccountId).add(q.Tipo_Linea_di_Credito__c);
                accOppStageMap.get(q.AccountId).add(q.StageName);
            }
            else
            {
                mapAccOpp.put(q.AccountId, new List<Opportunity>());
                mapAccOpp.get(q.AccountId).add(q);
                
                accOppTipoLineMap.put(q.AccountId, new List<String>());
                accOppTipoLineMap.get(q.AccountId).add(q.Tipo_Linea_di_Credito__c);
                
                accOppStageMap.put(q.AccountId, new List<String>());
                accOppStageMap.get(q.AccountId).add(q.StageName);
                
            }
        }

        for (Id id : mapAccOpp.keySet())
        {
            String scenario = '';
            
            if( ( (accOppTipoLineMap.get(Id)).contains('Mutuo') || (accOppTipoLineMap.get(Id)).contains('Progetto EasyPlus')) &&  (accOppTipoLineMap.get(Id)).contains('Crediti Fiscali') )
            {
                //both
                scenario = 'B';

            }
            else if ( ((accOppTipoLineMap.get(Id)).contains('Mutuo') || (accOppTipoLineMap.get(Id)).contains('Progetto EasyPlus')) &&  ! (accOppTipoLineMap.get(Id)).contains('Crediti Fiscali')){
                //lending
                scenario = 'C';

            }
            else if ( ! ((accOppTipoLineMap.get(Id)).contains('Mutuo') || (accOppTipoLineMap.get(Id)).contains('Progetto EasyPlus')) &&   (accOppTipoLineMap.get(Id)).contains('Crediti Fiscali')){
                //crediti
                scenario = 'A';

            }
                
            Account newAcc= new Account();
            newAcc.Id=id;
			newAcc.Scenario__c = scenario;
           
            updateAccount.add(newAcc);
        }
        
        update updateAccount;
    }
    

}