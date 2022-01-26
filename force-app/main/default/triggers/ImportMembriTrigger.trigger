trigger ImportMembriTrigger on Import_Membri__c (after update, before insert , before update, after insert) {
	
    new BP_ImportMembriTriggerHandler().run();

}