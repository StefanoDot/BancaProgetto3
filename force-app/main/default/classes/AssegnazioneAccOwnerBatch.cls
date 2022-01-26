global class AssegnazioneAccOwnerBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<User> migrazione =[select id from User where profile.name='Migrazione'];
        list<id> migrazioneId=new list<id>();
        for(User us: migrazione){
            migrazioneId.add(us.id);
        }
        system.debug('AssegnazioneAccOwnerBatch start migrazioneId'+migrazioneId);
        String query='select id, OwnerMigrazione__c  from Account where ownerid in:migrazioneId and OwnerMigrazione__c!= null order by OwnerMigrazione__c';
        return Database.getQueryLocator( query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList){
                

        list<Assegnazione_Record__c> matriceAssegnazione =[select Name, User__c from Assegnazione_Record__c order by Name];
        system.debug('AssegnazioneAccOwnerBatch execute matriceAssegnazione'+matriceAssegnazione);
        if(matriceAssegnazione.isempty())
            return;
       
        list<Account> accToUpdate=new list<Account>();
        integer i=0;
        for(Account acc: accList){
            for(Assegnazione_Record__c matrice: matriceAssegnazione){            
                if(acc.OwnerMigrazione__c ==matrice.name){
                    acc.ownerid=matrice.User__c;
                    accToUpdate.add(acc);
                    break;
                }
            }
        }
        AccountsController.bypassTrigger=true;
        Database.update (accToUpdate, false);
        AccountsController.bypassTrigger=false;
        system.debug('AssegnazioneAccOwnerBatch execute accToUpdate'+accToUpdate);

        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}