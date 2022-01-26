trigger DocumentTrigger on Document__c (after update, after insert, after delete) {
     List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Document'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
 new fileUploaderController().run();

   }
    }

}