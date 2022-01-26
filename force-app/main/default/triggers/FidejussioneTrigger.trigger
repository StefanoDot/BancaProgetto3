trigger FidejussioneTrigger on Fidejussione__c (before insert, before delete, after insert, after delete, after update) {
     List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Fidejussione'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
        new FidejussioneController().run();
        }}

  /*  if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('GaranzieController.BeforeInsert');
        FidejussioneController.BeforeInsert(Trigger.new); 
       
        system.debug(' GaranzieController Before insert - end' + Trigger.new);s
    }
    */
    
}