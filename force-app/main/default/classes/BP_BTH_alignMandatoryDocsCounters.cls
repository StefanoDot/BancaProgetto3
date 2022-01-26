public class BP_BTH_alignMandatoryDocsCounters Implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('------BP_BTH_alignMandatoryDocsCounters start-------');
        return Database.getQueryLocator(
        'SELECT Id, Total_Mandatories_Docs__c, Total_Uploaded_Docs__c ' + 
        'FROM Opportunity ' + 
        'WHERE Total_Uploaded_Docs__c != 0 ');
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        System.debug('------BP_BTH_alignMandatoryDocsCounters execute-------');
        List<Opportunity> oppsToEdit = new List<Opportunity>();
        for (Opportunity o: scope) {
            if (o.Total_Mandatories_Docs__c != o.Total_Uploaded_Docs__c) {
                oppsToEdit.add(o);
            }
        }
        OpportunityController.bypassTrigger=true;
        fileUploaderController.UpdateDocCountAfterStageChange(oppsToEdit);
        OpportunityController.bypassTrigger=false;
    }
    public void finish(Database.BatchableContext bc){
        System.debug('------BP_BTH_alignMandatoryDocsCounters finish-------');
    }
}