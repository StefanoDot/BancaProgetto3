public without sharing class LeadsController {

    /*
    @future
    public static void triggerHandlerAssignLeads(String jsonLeads) {
        List<Lead> leads = (List<Lead>)JSON.deserialize(jsonLeads, List<Lead>.class);
        if(!leads.isEmpty()) {
            List<Matrice_Di_Assegnazione__c> matriceList = MatriceDiAssegnazioneDAO.getMatriceDiAssegnazione(new String[] {'CAP__c', 'Codice_Comune__c',
                    'Codice_Provincia__c','Sales_di_Riferimento__c','Regione__c'});
            Map<String, Matrice_Di_Assegnazione__c> capMap = MatriceDiAssegnazioneService.createCAPMap(matriceList);
            Map<String, Matrice_Di_Assegnazione__c> stateMap = MatriceDiAssegnazioneService.createStateMap(matriceList);
            system.debug(capMap);
            system.debug(stateMap);
            for (Lead l : leads) {
                system.debug('entro nel trigger Lead');
                system.debug(l.LeadSource);
                system.debug(l.PostalCode);
                system.debug(capMap.containsKey(l.PostalCode));
                system.debug(stateMap.containsKey(l.State));

                if(capMap.containsKey(l.PostalCode)) {
                    Matrice_Di_Assegnazione__c cap = capMap.get(l.PostalCode);
                    if(l.LeadSource != 'Inserimento Manuale') {
                        //NON aggiorno il campo OwnerId se LeadSource = Inserimento Manuale
                        l.OwnerId = cap.Sales_di_Riferimento__c;
                    }
                    l.region__c = cap.Regione__c;
                    system.debug('Sales di riferimento: ' + cap.Sales_di_Riferimento__c);
                    l.Inside_Saels_di_Riferimento__c = cap.Sales_di_Riferimento__c;
                    l.Errore_Assegnazione_Lead__c = false;
                    l.Motivazione_Errore_Assegnazione__c = null;
                } else if(stateMap.containsKey(l.StateCode)) {
                    Matrice_Di_Assegnazione__c state = stateMap.get(l.StateCode);
                    system.debug(state.Codice_Provincia__c);
                    if(state.Codice_Provincia__c != 'duplicate') {
                        if(l.LeadSource != 'Inserimento Manuale') {
                            //NON aggiorno il campo OwnerId se LeadSource = Inserimento Manuale
                            l.OwnerId = state.Sales_di_Riferimento__c;
                        }
                        l.region__c = state.Regione__c;
                        l.Inside_Saels_di_Riferimento__c = state.Sales_di_Riferimento__c;
                        l.Errore_Assegnazione_Lead__c = false;
                        l.Motivazione_Errore_Assegnazione__c = null;
                    } else {
                        l.Errore_Assegnazione_Lead__c = true;
                        l.Motivazione_Errore_Assegnazione__c = System.Label.ErroreAssegnazioneLead_ProvinciaDuplicata;
                    }
                } else {
                    l.Errore_Assegnazione_Lead__c = true;
                    l.Motivazione_Errore_Assegnazione__c = System.Label.ErroreAssegnazioneLead_NessunaAssegnazioneTrovata;
                }
                system.debug(l);
                system.debug(l.OwnerId);
                system.debug('Inside Sales: ' + l.Inside_Saels_di_Riferimento__c);
                system.debug('region: ' + l.region__c);
            }
            Database.update(leads,false);
        }
    }
    */

}