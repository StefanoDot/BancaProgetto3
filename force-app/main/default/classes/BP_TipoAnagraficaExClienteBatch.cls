/*********************************************************************************************************************
 * Name of Class :  BP_TipoAnagraficaExClienteBatch 
 * Purpose       :  Batch apex class 
 *********************************************************************************************************************
 * Author     ||      Date             ||      Change                 	||         Description of change
 * Mukesh	  ||      [10-Aug-2021]    ||      Initial Development    	||
 *********************************************************************************************************************/

global with sharing class BP_TipoAnagraficaExClienteBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    String query='';  
    String OPPORTUNITY_EROGATA= 'Erogata';
    String ACCOUNT_EXCLIENTE= 'Ex Cliente';
    Map<Id,List<Opportunity>> accOppLstMap = new Map<Id,List<Opportunity>>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(! Test.isRunningTest()){
            query = 'Select Id,StageName,CloseDate,AccountId,Account.Count_of_Opportunities__c  from Opportunity where StageName =:OPPORTUNITY_EROGATA ';
            query += ' AND CloseDate < TODAY AND Account.Tipo_Anagrafica__c != :ACCOUNT_EXCLIENTE';
        }
        else{
            query = 'Select Id,StageName,CloseDate,AccountId,Account.Count_of_Opportunities__c  from Opportunity where StageName =:OPPORTUNITY_EROGATA ';
            query += ' AND Account.Tipo_Anagrafica__c != :ACCOUNT_EXCLIENTE';
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
		
        List<Account> updateAccList = new List<Account>();
        for(Opportunity opp : scope)
        {
            if(accOppLstMap.containsKey(opp.AccountId))
            {
                List<Opportunity> tempOppList = accOppLstMap.get(opp.AccountId);
                tempOppList.add(opp);
				accOppLstMap.put(opp.AccountId,tempOppList);               
            }
            else
            {
                List<Opportunity> tempOppList = new List<Opportunity>();
                tempOppList.add(opp);
				accOppLstMap.put(opp.AccountId,tempOppList);  
            }
        }
        
        for(Id accId : accOppLstMap.keySet())
        {
            List<Opportunity> tempOppList = accOppLstMap.get(accId);
            if(accOppLstMap.get(accId).size() == tempOppList[0].Account.Count_of_Opportunities__c)
            {
                Account ac = new Account();
                ac.Id = accId;
                ac.Tipo_Anagrafica__c = 'Ex Cliente';
                
                updateAccList.add(ac);
            }
        }
        
        if(! updateAccList.isEmpty())
        {
            update updateAccList;
        }
        
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}