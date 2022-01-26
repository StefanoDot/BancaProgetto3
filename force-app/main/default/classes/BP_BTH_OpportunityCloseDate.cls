public class BP_BTH_OpportunityCloseDate Implements Database.Batchable<SObject> {
    public Utils_Constants constants = new Utils_Constants();
    public List<String> listStage = new List<String>{constants.OPPORTUNITY_PRIMO_CONTATTO, constants.OPPORTUNITY_PRIMA_VISITA, constants.OPPORTUNITY_COMPLETAMENTO_DOCUMENTI, constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA, constants.OPPORTUNITY_PEF_ISTRUTTORIA, constants.OPPORTUNITY_DELIBERATA, constants.OPPORTUNITY_IN_PRE_ANALISI_E_PRICING, constants.OPPORTUNITY_IN_DUE_DILIGENCE, constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE};

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('------BP_BTH_OpportunityCloseDate start-------');

        return Database.getQueryLocator(
        'SELECT Id, CloseDate, StageName '+ 
        'FROM Opportunity ' + 
        'WHERE StageName IN :listStage AND CloseDate <= TODAY');
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        System.debug('------BP_BTH_OpportunityCloseDate execute-------');
        List<Opportunity> allOpportunityToUpdate = new List<Opportunity>();
        List<Opportunity> listDeliberata = new List<Opportunity>();
        List<Opportunity> listPefIstruttoria = new List<Opportunity>();
        List<Opportunity> listPrecedentePreIstruttoria = new List<Opportunity>();

        for (Opportunity opp: records) {
            if (opp.StageName == constants.OPPORTUNITY_DELIBERATA) {
                listDeliberata.add(opp);
            } else if (opp.StageName == constants.OPPORTUNITY_PEF_ISTRUTTORIA) {
                listPefIstruttoria.add(opp);
            } else {
                listPrecedentePreIstruttoria.add(opp);
            }
        }

        if (listDeliberata != null && !listDeliberata.isEmpty()) {
            for (Opportunity opp: listDeliberata) {
                opp.CloseDate = opp.CloseDate.addDays(10);
            } 
        }
        if (listPefIstruttoria != null && !listPefIstruttoria.isEmpty()) {
            for (Opportunity opp: listPefIstruttoria) {
                opp.CloseDate = opp.CloseDate.addDays(15);
            }
        }
        if (listPrecedentePreIstruttoria != null && !listPrecedentePreIstruttoria.isEmpty()) {
            for (Opportunity opp: listPrecedentePreIstruttoria) {
                opp.CloseDate = opp.CloseDate.addDays(20);
            }
        }

        allOpportunityToUpdate.addAll(listDeliberata);
        allOpportunityToUpdate.addAll(listPefIstruttoria);
        allOpportunityToUpdate.addAll(listPrecedentePreIstruttoria);
        update allOpportunityToUpdate;
    }
    public void finish(Database.BatchableContext bc){
        System.debug('------BP_BTH_OpportunityCloseDate finish-------');
    }
}