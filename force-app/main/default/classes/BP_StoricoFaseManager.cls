public with sharing class BP_StoricoFaseManager {
    
    public static Map<String,Integer> oppStageOrderMap = getOppStageOrderMetadata();
    
    public static void createStoricoFaseRecOnOppCreate(List<Opportunity> newOppList){
        
        List<Storico_Fase__c> newStoricoFaseLst = new List<Storico_Fase__c>();
        for(Opportunity newOpp : newOppList)
        {
            Storico_Fase__c StoriFase = new Storico_Fase__c();
            StoriFase.Opportunity__c = newOpp.Id;
            StoriFase.Fase_Opportunit__c = newOpp.StageName;
            StoriFase.Data_di_riferimento__c = System.today();
            StoriFase.Data_di_chiusura__c = newOpp.CloseDate;
            newStoricoFaseLst.add(StoriFase);
        }
        if(! newStoricoFaseLst.isEmpty())
        {
            insert newStoricoFaseLst;
        }
        
        
    }
    public static void createStoricoFaseRecOnOppUpdate(Map<Id,Opportunity> oldOppMap, List<Opportunity> newOppList){
        
        List<Storico_Fase__c> newStoricoFaseLst = new List<Storico_Fase__c>();
        Map<Id,Set<String>> oppAndStoricoMap = new Map<Id,Set<String>>();
        
        for(Storico_Fase__c storFase : [Select Id,Opportunity__c,Fase_Opportunit__c from Storico_Fase__c where Opportunity__c IN: oldOppMap.keyset()])
        {
            if(oppAndStoricoMap.containsKey(storFase.Opportunity__c))
            {
                Set<String> tempStageSet = oppAndStoricoMap.get(storFase.Opportunity__c);
                tempStageSet.add(storFase.Fase_Opportunit__c);
                oppAndStoricoMap.put(storFase.Opportunity__c,tempStageSet);
            }
            else
            {
                Set<String> tempStageSet = new Set<String>();
                tempStageSet.add(storFase.Fase_Opportunit__c);
                oppAndStoricoMap.put(storFase.Opportunity__c,tempStageSet);
            }
        }
        for(Opportunity newOpp : newOppList)
        {
            if( ( newOpp.StageName != oldOppMap.get(newOpp.Id).StageName) &&  
               	( oppStageOrderMap.get(newOpp.StageName) > oppStageOrderMap.get(oldOppMap.get(newOpp.Id).StageName)) &&
               	( oppAndStoricoMap != null && ! oppAndStoricoMap.isEmpty()) &&
              	( ! (oppAndStoricoMap.get(newOpp.Id)).contains(newOpp.StageName)))
            {
                Storico_Fase__c StoriFase = new Storico_Fase__c();
                StoriFase.Opportunity__c = newOpp.Id;
                StoriFase.Fase_Opportunit__c = newOpp.StageName;
                StoriFase.Data_di_riferimento__c = System.today();
                StoriFase.Data_di_chiusura__c = newOpp.CloseDate;
                
                newStoricoFaseLst.add(StoriFase);
                
            }
        }
        if(! newStoricoFaseLst.isEmpty())
        {
            insert newStoricoFaseLst;
        }
    }
    
    public static Map<String,Integer> getOppStageOrderMetadata(){
        
        Map<String,Integer> oppStageOrderMap = new Map<String,Integer>();
        Map<String, Opportunity_Stage_Setting__mdt> mapEd = Opportunity_Stage_Setting__mdt.getAll();
        
        for(String key : mapEd.keySet()){
            oppStageOrderMap.put(mapEd.get(key).Opportunity_Stage__c,(Integer)mapEd.get(key).Opportunity_Stage_Order__c);
        }
        return oppStageOrderMap;
    }
    
}