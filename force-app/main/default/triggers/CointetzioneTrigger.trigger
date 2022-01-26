trigger CointetzioneTrigger on Cointestazione__c (before update, before delete,after update) {
    List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Cointestazione'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
    new CointestazioneController().run();
 }
    }
}