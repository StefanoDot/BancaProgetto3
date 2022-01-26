global class BP_TipoAnagaraProspectScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
    
        BP_TipoAnagraficaProspectBatch b = new BP_TipoAnagraficaProspectBatch();
        database.executebatch(b,50);
    }
}