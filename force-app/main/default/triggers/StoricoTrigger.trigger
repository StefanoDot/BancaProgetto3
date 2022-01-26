trigger StoricoTrigger on Storico_Opportunit__c (after insert, after update) {
     List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Storico'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
      new StoricoController().run();
        }}}