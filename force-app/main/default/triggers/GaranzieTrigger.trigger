trigger GaranzieTrigger on Garanzia__c (before insert, after insert, before update, after update, before delete, after delete) {
    List<SwitchTrigger__mdt> metadata= [Select Id, DeveloperName, Status__c from SwitchTrigger__mdt where DeveloperName='Garanzia'];
    if(metadata.size()==1){
        if(metadata[0].Status__c == 'ON'){
   new GaranzieController().run();
        }}
 /*  
if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('GaranzieController.BeforeInsert');
        GaranzieController.BeforeInsert(Trigger.new); 
       
        system.debug(' GaranzieController Before insert - end' + Trigger.new);
    } */
   

}