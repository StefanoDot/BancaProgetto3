public without sharing class BP_ConfirmImportController {
    
    @AuraEnabled
    public static List<impMemListWrapper> getImpCampDuplicates(Id campaignRecId)
    {
        List<impMemListWrapper> impMemList = new List<impMemListWrapper>();
        for(Import_Membri__c impObj : [Select Id,First_Name__c, Last_Name__c,Email__c,Oplon_Codice_Fiscale__c,Account__c,Account__r.Name,
                                       Lead__c,Lead__r.Name,Campaign__c  from Import_Membri__c where 
                                       Campaign__c  =: campaignRecId and ( Account__c != null OR Lead__c != null)])
        {
            String sObjectName = '';
            if(! String.isEmpty(impObj.Account__c)){
                sObjectName = 'Account';
            }
            else if(! String.isEmpty(impObj.Lead__c)){
                sObjectName = 'Lead';
            }
            impMemList.add(new impMemListWrapper(false,impObj,sObjectName));
        }
        return impMemList;
    }
    @AuraEnabled
    public static Boolean addCampignMembers(Id campaignRecId,List<Import_Membri__c> importMembrList,boolean isNoDuplicate)
    {
        system.debug('importMembrList size ---> '+importMembrList.size());
        Savepoint sp = Database.setSavepoint();
        boolean isDone = false;
        try{
            Set<Id> importMembrIdSet = new Set<Id>();
            if(isNoDuplicate)
            {
                BP_ImportMembriWithLeadsBatch leadJob= new BP_ImportMembriWithLeadsBatch(campaignRecId);
                Database.executeBatch(leadJob, 100);
            }
            else
            {
                for(Import_Membri__c oImpMem : importMembrList)
                {
                    importMembrIdSet.add(oImpMem.Id);
                }
                if( String.isNotBlank(campaignRecId) && !importMembrIdSet.isEmpty())
                {
                    BP_ImportMembriWithLeadsBatch leadJob= new BP_ImportMembriWithLeadsBatch(campaignRecId);
                    Database.executeBatch(leadJob, 100);
                    
                    BP_ImprtMembriWithAcctLeadsBatch contactJob= new BP_ImprtMembriWithAcctLeadsBatch(campaignRecId,importMembrIdSet);
                    Database.executeBatch(contactJob, 100);
                }
                
            }
            /*
            List<Campaign> updatedCampaign = new List<Campaign>();
            updatedCampaign.add(new Campaign(Id = campaignRecId,Import_Done__c = true));
            if(! updatedCampaign.isEmpty())
            {
                update updatedCampaign;
            }
			*/
            isDone = true;
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            system.debug('the error is '+e.getLineNumber()+'			'+e.getMessage()+'		'+e.getStackTraceString());
            isDone = false;
        }
        
        return isDone;
    }
    /* wrapper class */  
    public class impMemListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Import_Membri__c impMemObj{get;set;}
        @AuraEnabled public String duplicateSobject {get;set;}
        public impMemListWrapper(boolean isChecked, Import_Membri__c impMemObj,String duplicateSobject){
            this.isChecked = isChecked;
            this.impMemObj = impMemObj;
            this.duplicateSobject = duplicateSobject;
        }
    }
    
}