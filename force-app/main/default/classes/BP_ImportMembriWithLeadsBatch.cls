/*********************************************************************************************************************
* Name of Class :  BP_ImportMembriWithLeadsBatch 
* Purpose       :  Batch apex class 
*********************************************************************************************************************
* Author      ||      Date             ||      Change                 ||         Description of change
* Mukesh	  ||      [22-Apr-2021]    ||      Initial Development    ||
*********************************************************************************************************************/

global with sharing class BP_ImportMembriWithLeadsBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    String query='';
    Id masterCampId;
    
    global BP_ImportMembriWithLeadsBatch(Id campId) 
    {
        masterCampId = campId;
        system.debug('the camp is '+masterCampId);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        query = 'SELECT Id, Name, Campaign__c, Account__c,Lead__c, Oplon_Codice_Fiscale__c, First_Name__c, Last_Name__c,Mobile__c,State_Province__c, ';
        query+= 'Country__c,Street__c,City__c,Zip_Postal_Code__c,Email__c,Company__c,Comune__c,Provincia__c,Cap__c,Provenienza_Lead__c,Partita_Iva__c,Ragione_Sociale_Lead__c FROM Import_Membri__c '; 
        query+= ' WHERE Campaign__c =: masterCampId AND Account__c = null AND Lead__c = null';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Import_Membri__c> scope){
        
        boolean hasError = false;
        List<Lead> newLeadsLst = new List<Lead>();
        List<CampaignMember> newCampaignMemberLst = new List<CampaignMember>();
        Database.SaveResult[] srList;
        
        for(Import_Membri__c oImpMem : scope)
        {
            Lead oLead = new Lead();
            oLead.Email = oImpMem.Email__c;
            oLead.Company = oImpMem.Company__c;
            oLead.Codice_Fiscale__c = oImpMem.Oplon_Codice_Fiscale__c;
            oLead.Status = 'Nuovo';
            oLead.FirstName = oImpMem.First_Name__c;
            oLead.LastName = oImpMem.Last_Name__c;
            oLead.MobilePhone = oImpMem.Mobile__c;
            oLead.State = oImpMem.State_Province__c;
            oLead.Country = oImpMem.Country__c;
            oLead.Street = oImpMem.Street__c;
            oLead.City = oImpMem.City__c;
            oLead.PostalCode = oImpMem.Zip_Postal_Code__c;
            oLead.Comune__c = oImpMem.Comune__c;
            oLead.Provincia__c = oImpMem.Provincia__c;
            oLead.Cap__c = oImpMem.Cap__c;
            oLead.Provenienca_Lead__c = oImpMem.Provenienza_Lead__c;
            oLead.Partita_IVA__c = oImpMem.Partita_Iva__c;
            oLead.Ragione_Sociale_Lead__c = oImpMem.Ragione_Sociale_Lead__c;
            
            newLeadsLst.add(oLead);
        }
        //Inserting Lead records 
        if(! newLeadsLst.isEmpty())
        {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            srList = Database.insert(newLeadsLst, dml);
            
        }
        //Inserting Campaign member records for successfully created Lead records and attaching to Parent Campaign
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                
                CampaignMember oCampMembr = new CampaignMember();
                oCampMembr.CampaignId = masterCampId;
                oCampMembr.LeadId = sr.getId();
                newCampaignMemberLst.add(oCampMembr);
            }
            else{
                hasError = true;
            }
        }
        //Inserting Campaign Member records 
        if(! newCampaignMemberLst.isEmpty())
        {
            insert newCampaignMemberLst;
        }
        
        //deleting processed Import Membri
        if(! scope.isEmpty() && ! hasError ) 
        {
            delete scope;
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}