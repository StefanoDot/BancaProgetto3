trigger UserTrigger on User (before update, after update) {
    System.debug('e mire jena ketu');
    List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='User'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
    new UserController().run();
        }}}