public class BP_ImportMembriTriggerHandler extends TriggerHandler{
	
    public override void afterInsert()
    {
        mapAccountToMembri((Map<id,Import_Membri__c>)Trigger.newMap);
        //updateImportMembriCampStatus((List<Import_Membri__c>)Trigger.new);
    }
    
    public static void mapAccountToMembri(Map<Id,Import_Membri__c> newImportMembriMap){
                
        Set<Id> importMembriIdSet = new Set<Id>();
        
        for(Id oImpMem : newImportMembriMap.keySet())
        {
            if(String.isNotBlank(newImportMembriMap.get(oImpMem).Oplon_Codice_Fiscale__c) )
            {
                importMembriIdSet.add(oImpMem);
            }
        }
        if(! importMembriIdSet.isEmpty())
        {
            BP_MapImpMembWthAcctLeadBatch job= new BP_MapImpMembWthAcctLeadBatch(importMembriIdSet);
            Database.executeBatch(job, 50);
        }
    }
    /*
    public static void updateImportMembriCampStatus(List<Import_Membri__c> newImportMemList){
        
        Set<Campaign> campToUpdate = new Set<Campaign>();
        List<Campaign> newList = new List<Campaign>();
        for(Import_Membri__c impMem : newImportMemList)
        {
            if(String.isNotBlank(impMem.Campaign__c))
            {
                campToUpdate.add(new Campaign(Id = impMem.Campaign__c,Import_Membri_Status__c = 'Conferma Import'));
            }
        }
        newList.addAll(campToUpdate);
        if( ! campToUpdate.isEmpty())
        {
            update newList;
        }
        
    }
	*/
}