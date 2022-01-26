trigger QuoteTrigger on Quote (before insert, after insert,before update,after update,before delete, after delete) {
  List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Quote'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
    
    new QuoteController().run();
    
        }}
    
    
    
    
   /* if (Trigger.isInsert && Trigger.isAfter) {
      QuoteController.AfterInsertAddDoc(Trigger.new);
        system.debug(' QuoteTrigger after insert - end' + Trigger.new);
    }
    else if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('QuoteController.BeforeInsert');
        QuoteController.BeforeInsert(Trigger.new); 
        QuoteController.checkStageNameOpp(Trigger.new);
        system.debug(' QuoteTrigger Before insert - end' + Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter)
    {
        System.debug('QuoteController.AfterUpdate');
       
        System.debug('QuoteTrigger After Update- end'+Trigger.new);
    }*/
    
}