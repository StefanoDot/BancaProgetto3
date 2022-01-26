global class BP_BTH_OpportunityCloseDateSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    
        BP_BTH_OpportunityCloseDate b = new BP_BTH_OpportunityCloseDate();
        database.executebatch(b,50);
    }

}