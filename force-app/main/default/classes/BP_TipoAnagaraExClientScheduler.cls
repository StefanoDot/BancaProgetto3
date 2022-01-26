global class BP_TipoAnagaraExClientScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
    
        BP_TipoAnagraficaExClienteBatch b = new BP_TipoAnagraficaExClienteBatch();
        database.executebatch(b,50);
    }
}