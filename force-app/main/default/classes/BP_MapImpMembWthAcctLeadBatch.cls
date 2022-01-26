/*********************************************************************************************************************
 * Name of Class :  MapImpMembWthAcctLeadBatch 
 * Purpose       :  Batch apex class 
 *********************************************************************************************************************
 * Author     ||      Date             ||      Change                 	||         Description of change
 * Mukesh	  ||      [21-Apr-2021]    ||      Initial Development    	||
 * Mukesh	  ||      [08-July-2021]   || 	   Mapping with Lead	   	|| Mapping with fiscal code 
 *********************************************************************************************************************/

global with sharing class BP_MapImpMembWthAcctLeadBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    String query='';    
    Set<Id> impMembriIdSet = new Set<Id>();
    
    global BP_MapImpMembWthAcctLeadBatch(Set<Id> importMembriIdSet) 
    {
        impMembriIdSet = importMembriIdSet;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        query = 'SELECT Id,Oplon_Codice_Fiscale__c, Account__c, Lead__c FROM Import_Membri__c Where Id IN :impMembriIdSet'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Import_Membri__c> scope){
		
        Set<String> fiscalCodeSet = new Set<String>();        
        Map<String,Id> FsclAndAccIdMap = new Map<String,Id>();
        Map<String,Id> FsclAndLeadIdMap = new Map<String,Id>();
        List<Import_Membri__c> updatedImpMemList = new List<Import_Membri__c>();        
        
        for(Import_Membri__c oImpMem : scope)
        {
            fiscalCodeSet.add(oImpMem.Oplon_Codice_Fiscale__c);
        }
        List<Account> accountList = [Select Id,Codice_Fiscale__c from Account where Codice_Fiscale__c IN :fiscalCodeSet];
        List<Lead> leadList = [Select Id,Codice_Fiscale__c from Lead where Codice_Fiscale__c IN :fiscalCodeSet];
        
        for(Account acc : accountList)
        {
            FsclAndAccIdMap.put(acc.Codice_Fiscale__c,acc.Id);
        }
        for(Lead oLead : leadList)
        {
            FsclAndLeadIdMap.put(oLead.Codice_Fiscale__c,oLead.Id);
        }
                
        for(Import_Membri__c oImpMem : scope)
        {
            if(FsclAndAccIdMap.containsKey(oImpMem.Oplon_Codice_Fiscale__c))
            {
                oImpMem.Account__c = FsclAndAccIdMap.get(oImpMem.Oplon_Codice_Fiscale__c);
            	updatedImpMemList.add(oImpMem);
            }
            else if(FsclAndLeadIdMap.containsKey(oImpMem.Oplon_Codice_Fiscale__c))
            {
                oImpMem.Lead__c = FsclAndLeadIdMap.get(oImpMem.Oplon_Codice_Fiscale__c);
                updatedImpMemList.add(oImpMem);
            }
            
        }

        if(! updatedImpMemList.isEmpty())
        {
            update updatedImpMemList;
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}