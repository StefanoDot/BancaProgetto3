global class AssegnazioneOppOwnerBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<User> migrazione =[select id from User where profile.name='Migrazione'];
        list<id> migrazioneId=new list<id>();
        for(User us: migrazione){
            migrazioneId.add(us.id);
        }
        system.debug('AssegnazioneAccOwnerBatch start migrazioneId'+migrazioneId);
        String query='select id, OwnerMigrazione__c  from Opportunity where ownerid in:migrazioneId and OwnerMigrazione__c!= null order by OwnerMigrazione__c';
        return Database.getQueryLocator( query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        
        
        list<Assegnazione_Record__c> matriceAssegnazione =[select Name, User__c from Assegnazione_Record__c order by Name];
        system.debug('AssegnazioneOppOwnerBatch execute matriceAssegnazione'+matriceAssegnazione);
        if(matriceAssegnazione.isempty())
            return;
        
        list<Opportunity> oppToUpdate=new list<Opportunity>();
        integer i=0;
        for(Opportunity opp: oppList){
            for(Assegnazione_Record__c matrice: matriceAssegnazione){            
                if(opp.OwnerMigrazione__c ==matrice.name){
                    opp.ownerid=matrice.User__c;
                    oppToUpdate.add(opp);
                    break;
                }
            }
        }
       OpportunityController.bypassTrigger=true;
        Database.update (oppToUpdate, false);
        OpportunityController.bypassTrigger=false;
        system.debug('AssegnazioneOppOwnerBatch execute oppToUpdate'+oppToUpdate);
        
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}