public with sharing class BP_UTL_FieldsUpdateOpportunity {
    public static void fieldAmountUpdateOpportunity(List<Quote> quoteListNew, Map<Id, Quote> quoteOldMap) {

        Map<Id, Decimal> oppDecimalMap = new Map<Id, Decimal>();

            for(Quote q : quoteListNew){
                if(quoteOldMap.isEmpty() || (q.Status != 'Anullata' && quoteOldMap.get(q.Id) != null && quoteOldMap.get(q.Id).Ammontare_Aggiornato__c != q.Ammontare_Aggiornato__c)){   
                    oppDecimalMap.put(q.OpportunityId, q.Ammontare_Aggiornato__c);
                }

            }
            if(!oppDecimalMap.isEmpty()){
                List<Opportunity> oppToUpd = [Select Id, Amount,Tipo_Linea_di_Credito__c from Opportunity where id in: oppDecimalMap.keySet()];

                for(Opportunity opp : oppToUpd) {
                    if(opp.Tipo_Linea_di_Credito__c =='Progetto EasyPlus' || opp.Tipo_Linea_di_Credito__c=='Mutuo'){
                    opp.Amount = opp.Amount == null ? oppDecimalMap.get(opp.Id) : opp.Amount + oppDecimalMap.get(opp.Id);
                    }
                }
                update oppToUpd;
            }
    }
}