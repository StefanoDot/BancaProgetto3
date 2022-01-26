/**
* Created by ACAPUTO00 on 07/02/2020.
*/

trigger ContactTrigger on Contact (after update, before insert , before update, after insert, before delete, after delete) {
    List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Contact'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
            new ContactController().run();
        }
    }
    
    
    /*   if (Trigger.isAfter) {
if (Trigger.isUpdate) {
//    ContactController.manageUpdateVerifiedFlags(Trigger.new,Trigger.oldMap);
ContactController.checkComune(Trigger.new, Trigger.oldMap);
ContactController.DocumentazioneFidejusore(Trigger.new, Trigger.oldMap);
system.debug(' ContactTrigger after updat - end' + Trigger.new);
} 

else if (Trigger.isInsert){
ContactController.AfterInsertAddDoc(Trigger.new);

}
} else if (Trigger.isBefore) {
if (Trigger.isUpdate) {
ContactController.completeField(Trigger.new, Trigger.oldMap);
ContactController.checkVia(Trigger.new, Trigger.oldMap);
system.debug(' ContactTrigger before update - end' + Trigger.new);
} else if (Trigger.isInsert) {
ContactController.completeField(Trigger.new, Trigger.oldMap);
system.debug(' ContactTrigger before insert - end' + Trigger.new);
}
}*/
    
}