public class SchedulableEmailToCaseRoutingBatch implements Schedulable {
public void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       List<Group> owner   = [Select Id From Group where Name='CQS Tecnical Admin' And Type = 'Queue'];
       List<Case> allCases = [SELECT id,status,Subject,Description,CQSProdotto__c,CQSCliente__c,Origin from Case where OwnerId =: owner[0].ID AND status != 'Pending' AND status != 'Closed'];
        for(Case c : allCases){
            c.status= 'Pending';
        }
        update allCases;
        
        system.debug(allCases);
       
        EmailToCaseRoutingBatch b = new EmailToCaseRoutingBatch();
        b.dtos = allCases;
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,5);
    }
}