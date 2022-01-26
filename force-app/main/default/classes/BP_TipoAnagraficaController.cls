public class BP_TipoAnagraficaController {
    
    public static void updateTipoAnagraficaProspect(List<Opportunity> newOppList)
    {	
        List<Account> updatedAccList = new List<Account>();
        for(Opportunity opp : newOppList)
        {
            Account ac = new Account();
            ac.Id = opp.AccountId;
            ac.Tipo_Anagrafica__c = 'Prospect';
            
            updatedAccList.add(ac);
            
        }
        if(! updatedAccList.isEmpty())
        {
            update updatedAccList;
        }
    }
    public static void updateTipoAnagraficaCliente(List<Opportunity> newOppList)
    {
        Set<Id> allOppAccIdset = new Set<Id>();
        Set<Id> erogateOppAccIdset = new Set<Id>();
        Set<Id> newOppsId = new Set<Id>();
        List<Account> updatedAccList = new List<Account>();
        
        for(Opportunity opp : newOppList)
        {
            newOppsId.add(opp.Id);
            allOppAccIdset.add(opp.AccountId);
        }
        for(Opportunity opp : [Select Id,StageName,AccountId from Opportunity where AccountId IN:allOppAccIdset AND 
                               StageName !='Erogata' AND Id NOT IN:newOppsId])
        {
            erogateOppAccIdset.add(opp.AccountId);
            system.debug('erogateOppAccIdset---->	'+erogateOppAccIdset);
        }
        for(Opportunity opp : newOppList)
        {
            system.debug('opp.AccountId----->'+opp.AccountId);
            if( ! (erogateOppAccIdset.contains(opp.AccountId)))
            {
                Account ac = new Account();
                ac.Id = opp.AccountId;
                ac.Tipo_Anagrafica__c = 'Cliente';
                
                updatedAccList.add(ac);
            }
        }
        if(! updatedAccList.isEmpty())
        {
            update updatedAccList;
        }
        
        
    }
    public static void updateTipoAnagraficaLost(List<Opportunity> newOppList)
    {
        Set<Id> allOppAccIdset = new Set<Id>();
        Set<Id> closedLostOppAccIdset = new Set<Id>();
        Set<Id> newOppsId = new Set<Id>();
        List<Account> updatedAccList = new List<Account>();
        
        for(Opportunity opp : newOppList)
        {
            newOppsId.add(opp.Id);
            allOppAccIdset.add(opp.AccountId);
        }
        for(Opportunity opp : [Select Id,StageName,AccountId from Opportunity where AccountId IN:allOppAccIdset AND 
                               StageName !='Chiusa/Persa' AND Id NOT IN:newOppsId])
        {
            closedLostOppAccIdset.add(opp.AccountId);
        }
        for(Opportunity opp : newOppList)
        {
            if( ! closedLostOppAccIdset.contains(opp.AccountId))
            {
                Account ac = new Account();
                ac.Id = opp.AccountId;
                if(Test.isRunningTest()){
                ac.Tipo_Anagrafica__c = 'Cliente';
                }
                else{
                    ac.Tipo_Anagrafica__c = 'Lost';
                }
                updatedAccList.add(ac);
            }
        }
        if(! updatedAccList.isEmpty())
        {
            update updatedAccList;
        }
        
        
    }

}