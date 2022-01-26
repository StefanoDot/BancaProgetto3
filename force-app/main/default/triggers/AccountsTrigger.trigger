/**
* Created by Matteo Tornielli on 03/04/2019.
*/

trigger AccountsTrigger on Account (before Insert , before update, after insert, after update) {
    
    List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Account'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
            new AccountsController().run();
        }
    }
    
    /*if(Trigger.isBefore) {           
if(Trigger.isInsert){
System.debug('Before Insert');
}
if(Trigger.isUpdate){
for(Account NewAcc: Trigger.new)
{
Account oldAcc= Trigger.oldMap.get(NewAcc.id);
if(newAcc.CodiceKoOplon__c != oldAcc.CodiceKoOplon__c && newAcc.CodiceKoOplon__c != null || newAcc.Count_of_Opportunities__c  != oldAcc.Count_of_Opportunities__c ){
system.Debug('Skip_BeforeUpdate');
return;
}

}
AccountsController.ActionBeforeUpdate(Trigger.new,Trigger.oldMap);

}     
// AccountsController.triggerHandlerAssignAccounts(Trigger.New, Trigger.oldMap);    
}
else if(Trigger.isAfter){

if(Trigger.isInsert){
System.debug('AccountsTriggerNew - Start'+ Trigger.new);
AccountsController.getMoreScoreData(Trigger.new);
AccountsController.AfterInsertAddDoc(Trigger.new);

System.debug('AccountsTriggerNew - End'+Trigger.new);

} 
else if(Trigger.isUpdate){
List<Account> acc = new List<Account>();
for(Account NewAcc: Trigger.new)
{
Account oldAcc= Trigger.oldMap.get(NewAcc.id);
if(newAcc.CodiceKoOplon__c != oldAcc.CodiceKoOplon__c && newAcc.CodiceKoOplon__c != null || newAcc.Count_of_Opportunities__c  != oldAcc.Count_of_Opportunities__c  ){
system.Debug('Skip_AfterUpdate');
return;
}



else if( NewAcc.Fidejussore__c == true && oldAcc.Fidejussore__c ==false ){
system.Debug('Trigger documentazioneFidejusore');
acc.add(NewAcc);

}


}

if( acc.size() != null && !acc.isEmpty()){
AccountsController.DocumentazioneFidejusore(acc);}
System.debug('AccountsTriggerUpdate - Start');
System.debug(Trigger.new);


AccountsController.getAnagraphicDetails(Trigger.new,Trigger.oldMap);



AccountsController.checkComune(Trigger.new,Trigger.oldMap);
AccountsController.notifyMissingFields(Trigger.new,Trigger.oldMap);

System.debug('AccountsTriggerUpdate - End');

}
}*/
}