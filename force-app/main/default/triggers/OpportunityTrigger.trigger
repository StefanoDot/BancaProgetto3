trigger OpportunityTrigger on Opportunity (before insert, After insert, before update, after update) {
    
    List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Opportunity'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
new OpportunityController().run();
        }
    }
    
   /* if (Trigger.isInsert && Trigger.isAfter) {
        system.debug(' OpportunityTrigger after insert - start' + Trigger.new);    
        OpportunityController.AfterInsert(Trigger.new);
        system.debug(' OpportunityTrigger after insert - end' + Trigger.new);
    }
    else if (Trigger.isInsert && Trigger.isBefore) {
        system.debug(' OpportunityTrigger before insert - start' + Trigger.new);
       OpportunityController.BeforeInsert(Trigger.new);
        system.debug(' OpportunityTrigger Before insert - end' + Trigger.new);
    }
    else {
        if (Trigger.isUpdate && Trigger.isBefore) {
            system.debug('OpportunityTrigger before update - start' + Trigger.new);
          OpportunityController.AggiornaAmount(Trigger.new,  Trigger.oldMap);
            OpportunityController.checkForCtnCheckBox(Trigger.new,  Trigger.oldMap);
            //OpportunityController.validateApprovalProcess(Trigger.new, Trigger.oldMap);
           // OpportunityController.checkApprPreistToPEFIst(Trigger.new, Trigger.oldMap);
             OpportunityController.checkCambioDiFaseToPEFIst(Trigger.new, Trigger.oldMap);

            OpportunityController.checkFineMutuo(Trigger.new); 

            system.debug(' OpportunityTrigger before update - end' + Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            system.debug(' OpportunityTrigger after update - start' + Trigger.new);
            //OpportunityController.resetStatusDocumentoOfOpportunity(OpportunityController.opportunityWithPrimoContattoStatus(Trigger.new));
         //   AccountsController.notifyMissingFieldsForOpportunity(Trigger.new, Trigger.oldMap);
           // OpportunityController.checkApprPreistToPEFIst(Trigger.new, Trigger.oldMap); 
      
            OpportunityController.ChangeQuoteStatus(Trigger.new, Trigger.oldMap);

        OpportunityController.checkFidejussione(Trigger.new, Trigger.oldMap);
       OpportunityController.checkCambioDiFaseToPEFIst(Trigger.new, Trigger.oldMap);
        OpportunityController.DontSendApprovalProcess(Trigger.new, Trigger.oldMap);
  
         
        OpportunityController.createInquiry(Trigger.new, Trigger.oldMap);
        OpportunityController.checkApprovalProcess(Trigger.new, Trigger.oldMap); 

            system.debug(' OpportunityTrigger after update - end' + Trigger.new);
        }
    }  */
}