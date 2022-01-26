/*********************************************************************************************************************
 * Name of Class :  ImportMembriWithAccountsBatch 
 * Purpose       :  Batch apex class 
 *********************************************************************************************************************
 * Author     ||      Date             ||      Change                 ||         Description of change
 * Mukesh	  ||      [22-Apr-2021]    ||      Initial Development    ||
 *********************************************************************************************************************/

global with sharing class BP_ImprtMembriWithAcctLeadsBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    String query='';
    Id masterCampId;
    Set<Id> dupImpMembrSet = new Set<Id>();
    
    global BP_ImprtMembriWithAcctLeadsBatch(Id campId,Set<Id> impMembrSet) 
    {
        masterCampId = campId;
        dupImpMembrSet = impMembrSet;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        query = 'SELECT Id, Name, Campaign__c, Account__c,Lead__c, Oplon_Codice_Fiscale__c, First_Name__c, Last_Name__c, Email__c,Company__c FROM Import_Membri__c '; 
        query+= ' WHERE Id IN:dupImpMembrSet AND Campaign__c =: masterCampId AND ( Account__c != null OR Lead__c != null ) ';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Import_Membri__c> scope){
		
        List<CampaignMember> newCampaignMemberLst = new List<CampaignMember>();
        
        for(Import_Membri__c oImpMem : scope)
        {
            CampaignMember oCampMembr = new CampaignMember();
            oCampMembr.CampaignId = masterCampId;
            
            if(! String.isEmpty(oImpMem.Account__c)){
                oCampMembr.AccountId = oImpMem.Account__c;
            }
            else if(! String.isEmpty(oImpMem.Lead__c)){
                oCampMembr.LeadId = oImpMem.Lead__c;
            }            
            newCampaignMemberLst.add(oCampMembr);
            
        }
        //Inserting Campaign Member records 
        if(! newCampaignMemberLst.isEmpty())
        {
            Database.insert(newCampaignMemberLst,false);
        }
        //deleting processed Import Membri
       	if(! scope.isEmpty()) 
        {
        	delete scope;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}