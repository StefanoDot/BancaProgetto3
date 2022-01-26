trigger DocumentTypeTrigger on DocumentType__c (before insert, after insert) {
new DocumentTypeController().run();
}