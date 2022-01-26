public class UserController extends TriggerHandler{

 public override void afterUpdate(){
     
        System.debug('UserController.afterUpdate trigger - Start' +Trigger.new);
             System.debug('UserController.afterUpdate trigger - Start' +Trigger.Old);

           
        List<User> myUsers = [select Id,Name, ManagerId from User where Id IN : Trigger.new];
        Set<Id> changedManager = new Set<Id>();
        
         for(User user: myUsers)
        {
            User oldUser = (User) Trigger.oldMap.get(user.id);
            if(user.ManagerId != oldUser.ManagerId && user.Name != 'Banca Progetto Admin'){
                changedManager.add(user.Id);
            }
    	}
     if(!changedManager.isEmpty()){
            UserController.AfterUpdate(changedManager);
        }
     
     
        System.debug('UserController.afterUpdate trigger - End');   
    }
    
   
    
    
    @future
    public static void AfterUpdate(Set<Id> userIds){
        
        System.debug('UserController.AfterUpdate - Start userIds '+userIds);
        
        List<User> userManager = [select id , ManagerId from User where Id IN : userIds];
        List<Account> newAcc = new List<Account>();
        List<Account> myAccs = [select Id, Manager_NomeCompleto__c, Manager_ID__c from Account where ownerId IN : userIds];
        
       
        for (Account acc : myAccs) {
            
            if(acc.Manager_ID__c != null){
                
                 acc.Manager_NomeCompleto__c = acc.Manager_ID__c;
                newAcc.add(acc);
            }
            
        }
        
       

        update newAcc;
        System.debug('UserController.AfterUpdate - End newAcc'+newAcc);
    }
    
}