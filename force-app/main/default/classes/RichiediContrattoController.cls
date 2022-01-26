/**
* Created by ACAPUTO00 on 03/03/2020.
*/

public with sharing class RichiediContrattoController {
    
    public class RichiediContratto{
        @AuraEnabled
        public Boolean ok{set;get;}
        @AuraEnabled
        public Boolean error{set;get;}
        @AuraEnabled
        public Boolean imediatelyManual{set;get;}
        @AuraEnabled
        public String responseMessage{set;get;}
        @AuraEnabled
        public String title{set;get;}
        @AuraEnabled
        public Contact con{set;get;}
        @AuraEnabled
        public  Map<String,String> condizioni{set;get;}
    }
    public static Utils_Constants constants = new Utils_Constants();
    @AuraEnabled
    public static RichiediContratto checkCambioStipula(Id oppId){
        
        system.debug('RichiediContrattoController checkCambioStipula Start oppId'+oppId);
        
        Utils_Constants constants = new Utils_Constants();
        RichiediContratto response = new RichiediContratto();        
        response.ok=true;
        response.responseMessage='';
        //Commented by Stefano Porcari 13/08, disalignment from the other check Checks why
        //fileUploaderController.numerimi(oppId);
        Boolean isCrediti;
        Opportunity opp =[select id, accountid, StageName,Verifica_condizioni_sospensive__c, Tipo_di_opportunit__c, Condizioni_Sospensive__c, Total_Optional_Docs__c, Total_Mandatories_Docs__c, Total_Uploaded_Docs__c, Totale_Verified_Docs_Verificati__c, Verifica_Firmatario__c 
                          from Opportunity where id=: oppId];
        if(opp.Tipo_di_opportunit__c == constants.OPPORTUNITY_TIPO_FISCALE){
            isCrediti = true;
        }

        List<Quote> quotes = [SELECT Id, Name, Status,Condizioni_Sospensive__c,Percentuale_Commissione_Intermediazione__c, OpportunityId FROM Quote WHERE OpportunityID=:opp.id];
        list<Contact> firmatari =[select id, percentuale_di_riferimento_socio__c from Contact where accountid=:opp.accountid and Firmatario__c =true ];
        
        Boolean isActive = false;

        for(Quote q:quotes){
            if(q.Status == 'In Corso' || q.Status == 'Delibera Positiva')
                isActive=true;
            
            if(q.Percentuale_Commissione_Intermediazione__c==null){
                system.debug('a jeeeee');
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n ' + '- valorizzare la percentuale di intermediazione creditizia sulla ' + q.Name;
            }
        }
        
        if(!isActive || quotes.size()==0){
            response.ok=false;
            response.responseMessage= response.responseMessage + '\n ' + '- avere almeno una linea di credito attiva per questa opportunità';
        }
        if(opp.StageName != constants.OPPORTUNITY_DELIBERATA){
            response.ok=false;
            response.responseMessage= response.responseMessage + '\n ' + '- passare l\'Opportunità in fase Deliberata';
        }
        if(firmatari.isempty()){
            response.ok=false;
            response.responseMessage = response.responseMessage + '\n ' + '- avere almeno un Firmatario';
        }
         if(response.ok==true){
            RichiediContratto campi =checkCampiRichiediContratto(oppId);
            return campi;
        }
        System.debug('response.ok = ' + response.ok);
        System.debug('response.error = ' + response.error);
        System.debug('response.responseMessage = ' + response.responseMessage);
        response.error=true;
        system.debug('response checkCambioStipula'+response);
        return response;
    }
    
    
    @AuraEnabled
    public static RichiediContratto checkCampiRichiediContratto(String oppId){
        system.debug('RichiediContrattoController checkCampiRichiediContratto - Start oppId '+ oppId);
        
        Utils_Constants constants = new Utils_Constants();
        RichiediContratto response = new RichiediContratto();
        response.ok=true;        
        
        String finalMessage = '';
        Boolean isOppMissingFields = false;
        Boolean isAccMissingFields = false;
        Boolean isContMissingFields = false;
        Boolean isQuoteMissingFields = false;
        Boolean isGaranziaMissingFields = false;
        List<String> kot = new List<String>();
        
        List<String> oppFieldList = new List<String>{'AccountId','Name','Verifica_condizioni_sospensive__c', 'Totale_Verified_Docs_Verificati__c', 'Tasso_Cliente__c',
            'Total_Optional_Docs__c', 'Total_Mandatories_Docs__c','Tipo_di_opportunit__c', 'Data_Prevista_Incasso__c', 'Importo_del_Credito__c', 'Total_Uploaded_Docs__c','Verifica_Firmatario__c','Condizioni_Sospensive__c'};
        List<String> oppFieldMutuoList = new List<String>{'AccountId','Name','Verifica_condizioni_sospensive__c', 'Totale_Verified_Docs_Verificati__c',
            'Total_Optional_Docs__c', 'Total_Mandatories_Docs__c','Tipo_di_opportunit__c', 'Total_Uploaded_Docs__c','Verifica_Firmatario__c','Condizioni_Sospensive__c'};
        
        List<String> accountFieldList = new List<String>{'BillingCountry','Cap__c','Capitale_Sociale__c','Capitale_Versato__c','Casa_Comunale_Domicilio__c','Codice_Fiscale__c',
                    'Comune__c','Id','Indirizzo_Sede_Legale_Esteso__c','Microimpresa__c','Name','Tipo_Via__c','Nome_Via__c','Numero_Civico__c','Provincia__c',
                    'Sigla_Provincia__c','Paese_Sede_Azienda__c', 'Piccola_Media_Impresa__c'};
                    
        List<String> accountFieldListCrediti = new List<String>{'Cap__c','Codice_Fiscale__c','Partita_Iva__c',
                    'Comune__c','Id','Indirizzo_Sede_Legale_Esteso__c','Microimpresa__c','Name',
                    'Sigla_Provincia__c'};
                        
        List<String> contactFieldList = new List<String>{'AccountId','Cap__c','Comune__c','Comune_di_Nascita__c','Data_di_Nascita__c','Email',
                            'Firmatario__c','FirstName','Genere_Nascita__c','Id','Indirizzo_Residenza_Esteso__c','LastName','Name',
                            'Oplon_Codice_Fiscale__c','Percentuale_di_riferimento_socio__c', 'Ruolo_in_Azienda__c','Sigla_Provincia__c',
                            'Titolo_Firmatario__c', 'Localita__c','Sigla_Provincia_Nascita__c', 'Localita_Residenza__c','Paese_Rilascio__c', 'Stato_ResidenzaEstero__c'}; 

        List<String> contactFieldListCrediti = new List<String>{'Email','Percentuale_di_riferimento_socio__c',
                        'Firmatario__c','FirstName','Id','LastName','Name','MobilePhone'}; 
                                
        List<String> quoteFieldList = new List<String>{'Name','OpportunityId', 'Data_fine_mutuo_Formula__c', 'Data_Fine_Preammortamento__c',
                                    'Percentuale_Commissioni_da_Istruttoria__c', 'Percentuale_Commissione_Intermediazione__c', 'Percentuale_Spread__c',
                                    'Importo_Imposta_Sostitutiva__c', 'Importo_Commissioni_di_Istruttoria__c', 'Numero_Rapporto__c','Filiale_Banca_Cliente__c', 
                                     'Data_Stipula__c', 'Sigla_Provincia_Firma__c', 'Citta_Firma__c', 'Nome_Azienda_Sede_Firma__c',
                                    'Tipo_Via__c', 'Nome_Via__c', 'Cognome_Procuratore_Speciale__c', 'Cap_Firma__c', 'Banca_Cliente__c', 'Nome_Procuratore_Speciale__c',
                                    'Finalita_Finanziamento__c', 'Numero_Civico__c','IBAN__c'};  
        List<String> quoteFieldListCrediti = new List<String>{'Data_Stipula__c','Commissione_acquisto_pro_soluto__c','Corrispettivo_cessione__c',
                                'Name','Tasso_nominale_base_annua__c', 'n_gg_lavorativi_Bonifici__c',
                                'n_gg_lavorativi_Incassi_a_mezzo_bonific__c','Spese_istruttoria_cedente__c',
                                'Spese_istruttoria_rinnovo_pratica_cedent__c','Spese_istruttoria_debitore__c','Spese_handling_per_fattura__c','Spese_handling_per_effetto__c',
                                'Spese_per_distinta__c', 'Spese_Hnadling_per_presentazione__c','Spese_per_bonifico__c','Spese_per_tenuta_conto__c','Spese_postali__c',
                                'Spese_per_bolli__c','Canone_Home_factoring__c', 'Certificazione_ai_revisori__c' ,'Dichiarazione_crediti__c','Anno_crediti__c',
                                'C_c_banca_Cedente__c','Banca_Cedente__c','IBAN_Cedente__c'

                                }; 
                                    
        List<String> garanziaFieldList = new List<String>{'Garanzie_Name__c','Expiration_Date__c','Percentuale_Garantito__c', 'Percentuale_Libero__c', 'Is_Standard__c', 'Tipo_di_Garanzia__c' };  
                                            
        List<Opportunity> myOpp = new List<Opportunity>([SELECT Id, StageName FROM Opportunity where Id=: oppId]);
        
        String oppFieldsString = String.join(oppFieldList, ',');
        String accountFieldsString = String.join(accountFieldList, ',');
        String contactFieldsString = String.join(contactFieldList, ',');
        String quoteFieldsString = String.join(quoteFieldList, ',');
        String garanziaFieldsString = String.join(garanziaFieldList, ',');
        //Crediti
        String accountFieldsCreditiString = String.join(accountFieldListCrediti, ',');
        String contactFieldsCreditiString = String.join(contactFieldListCrediti, ',');
        String quoteFieldsCreditiString = String.join(quoteFieldListCrediti, ',');
        

        String currentMissingFields;
        Boolean isCreditiFiscali=false;
        String queryOppString = 'SELECT ' + oppFieldsString + ' FROM Opportunity WHERE Id = :oppId';
        List<Opportunity> opps = (List<Opportunity>) (Database.query(queryOppString));
        system.debug('opps: '+opps);
        if(opps.size()>0) {
            Opportunity opp = opps.get(0);
            if(opp.Tipo_di_opportunit__c == constants.OPPORTUNITY_TIPO_FISCALE){
                isCreditiFiscali=true;
            }
            
            response.responseMessage='<b>Per richedere il contratto occorre:</b><br/><br/>' + '\n';
            
            if( opp.Condizioni_Sospensive__c<>null && opp.Verifica_condizioni_sospensive__c<>'Si')
            {
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n ' + '- verificare le Condizioni Sospensive.<br/>';
            }
            //remove the wrong 
            /*if(opp.Totale_Verified_Docs_Verificati__c !=(opp.Total_Optional_Docs__c + opp.Total_Mandatories_Docs__c ) ||
               opp.Total_Uploaded_Docs__c   !=(opp.Total_Optional_Docs__c + opp.Total_Mandatories_Docs__c))  
            {*/
            if(opp.Totale_Verified_Docs_Verificati__c != opp.Total_Mandatories_Docs__c){
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n ' +  '- convalidare il set documentale.<br/>';
            }
            
            if(opp.Verifica_Firmatario__c == 'Esito Negativo' || opp.Verifica_Firmatario__c == null) 
            {
                response.ok=false;
                response.responseMessage=response.responseMessage + '\n ' + '- verificare il firmatario con Esito Positivo.<br/>';
            }
            if(response.ok)
            {
                response.responseMessage=''; 
            }
            
            String oppMissingFields = '<br/><b>Opportunity:</b><br/>';
            if(!isCreditiFiscali){
            for (String oppF : oppFieldMutuoList) {
                if (opp.get(oppF) == null || opp.get(oppF) == '') {
                    if(oppF=='Verifica_condizioni_sospensive__c' || oppF=='Condizioni_Sospensive__c' || oppF=='Verifica_Firmatario__c')
                        continue;
                    
                    isOppMissingFields = true;
                    String fieldLabel = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(oppF).getDescribe().getLabel();
                    oppMissingFields =oppMissingFields + '</br> - ' + fieldLabel;
                }
            }
        } else{
            //check for crediti fiscali fields that are different from mutuo
            for (String oppF : oppFieldList) {
                if (opp.get(oppF) == null || opp.get(oppF) == '') {
                    if(oppF=='Verifica_condizioni_sospensive__c' || oppF=='Condizioni_Sospensive__c' || oppF=='Verifica_Firmatario__c')
                        continue;
                    system.debug('checkCampiRichiediContratto isOppMissingFields true');
                    isOppMissingFields = true;
                    String fieldLabel = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(oppF).getDescribe().getLabel();
                    oppMissingFields = oppMissingFields + '</br> - ' +fieldLabel;
                }
            }
        }
            oppMissingFields = oppMissingFields.removeEnd(', ');
            oppMissingFields = oppMissingFields + '<br/><br/>';
            String queryAccountString;
            String accId = opp.AccountId; 
            if(!isCreditiFiscali){
                queryAccountString= 'SELECT ' + accountFieldsString + ' FROM Account WHERE Id = :accId';
            }else{
                queryAccountString= 'SELECT ' + accountFieldsCreditiString + ' FROM Account WHERE Id = :accId';
            }
            List<Account> accounts = (List<Account>) (Database.query(queryAccountString));
            system.debug('accounts: ' + accounts);
            Account acc = accounts.get(0);
            system.debug('acc: ' + acc);
            String accMissingFields = '<br/><b>Per l\'Anagrafica:</b><br/>';
            if(!isCreditiFiscali){
                for (String accF : accountFieldList) {
                    if (acc.get(accF) == null || acc.get(accF) == '') {
                        system.debug('checkCampiRichiediContratto isAccMissingFields true');
                        isAccMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                        accMissingFields = accMissingFields + '</br> - ' +fieldLabel;
                    }
                }
            }else{
                //check for crediti fiscali fields that are different from mutuo
                for (String accF : accountFieldListCrediti) {
                    if (acc.get(accF) == null || acc.get(accF) == '') {
                        system.debug('checkCampiRichiediContratto isAccMissingFields true');
                        isAccMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                        accMissingFields = accMissingFields + '</br> - ' +fieldLabel;
                    }
                }
            }
            accMissingFields = accMissingFields.removeEnd(', ');
            accMissingFields = accMissingFields + '<br/><br/>';
            String queryContactString;
            if(!isCreditiFiscali){
                queryContactString= 'SELECT '+ contactFieldsString +',Residenza__c FROM Contact WHERE AccountId = :accId AND Firmatario__c = true AND Percentuale_di_riferimento_socio__c != null';
            }else{
                queryContactString= 'SELECT '+ contactFieldsCreditiString +',Residenza__c FROM Contact WHERE AccountId = :accId AND Firmatario__c = true AND Percentuale_di_riferimento_socio__c != null';
            }
             
            List<Contact> contacts = (List<Contact>) (Database.query(queryContactString));
            system.debug('contactsss'+ contacts);
            String contMissingFields = '';
            for(Contact cont : contacts){
                currentMissingFields = ' ';
                if(!isCreditiFiscali){
                    for(String contF : contactFieldList){
                        if(contF != 'Email') {
                            if (cont.get(contF) == null || cont.get(contF) == '') {
                                 if(contF=='Stato_ResidenzaEstero__c'){
                                    if(cont.Residenza__c=='ITALIA' || cont.Residenza__c==null){
                                        continue;
                                    }
                                }
                                isContMissingFields = true;
                                String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                currentMissingFields += '</br> - ' +fieldLabel;
                            }
                        }
                    }
                }else{
                    for(String contF : contactFieldListCrediti){
                            if (cont.get(contF) == null || cont.get(contF) == '') {
                                isContMissingFields = true;
                                String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                currentMissingFields += '</br> - ' +fieldLabel;
                            }
                    }
                }
                
                if(currentMissingFields!= ' ')
                    contMissingFields = '</br><b>Per il Referente '+cont.Name+':</b><br/>'  + currentMissingFields;
            }
            contMissingFields = contMissingFields.removeEnd(', ');
            contMissingFields = contMissingFields + '<br/><br/>';     
            String queryQuoteString;       
            if(!isCreditiFiscali){
                queryQuoteString = 'SELECT '+ quoteFieldsString +' FROM Quote WHERE OpportunityId =: oppId and Status= \'In Corso\'';// and Status!=:constants.LINEE_DI_CREDITO_ANNULLATA 
            }else{
                queryQuoteString = 'SELECT '+ quoteFieldsCreditiString +' FROM Quote WHERE OpportunityId =: oppId and Status= \'In Corso\'';// and Status!=:constants.LINEE_DI_CREDITO_ANNULLATA 
            }
            List<Quote> quotes = (List<Quote>) (Database.query(queryQuoteString));
            String quoteMissingFields = '';
            List<String> profileIds = new List<String>();
            
            /*    for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'Intermediario Finanziario' OR Name = 'Mediatore Creditizio']){
profileIds.add(pr.Id);
}
String currentProfileId = UserInfo.getProfileId();
*/
            for(Quote q : quotes){
                currentMissingFields = ' ';
                if(!isCreditiFiscali){
                    for(String quoteF : quoteFieldList){
                        if (q.get(quoteF) == null || q.get(quoteF) == '') {
                            isQuoteMissingFields = true;
                            String fieldLabel = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().get(quoteF).getDescribe().getLabel();
                            currentMissingFields += '</br> - ' + fieldLabel;
                        }
                    }
                }else{
                    for(String quoteF : quoteFieldListCrediti){
                        if (q.get(quoteF) == null || q.get(quoteF) == '') {
                            isQuoteMissingFields = true;
                            String fieldLabel = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().get(quoteF).getDescribe().getLabel();
                            currentMissingFields += '</br> - ' + fieldLabel;
                        }
                    }
                }

                if(currentMissingFields!= ' ')
                    quoteMissingFields +=  '<br/>' + '</br><b>Per la Linea di Credito '+q.Name+':</b><br/>' + currentMissingFields;   
            }
            quoteMissingFields = quoteMissingFields.removeEnd(', ');
            quoteMissingFields =  quoteMissingFields + '<br/><br/>';
            system.debug('quoteMissingFields ' + quoteMissingFields);
            
            String queryGaranziaString = 'SELECT '+ garanziaFieldsString +' FROM Garanzia__c WHERE Opportunit__c =: oppId and Stato_Garanzia__c != \'Chiusa\'';
            List<Garanzia__c> garanzias = (List<Garanzia__c>) (Database.query(queryGaranziaString));
            system.debug('garanzias: ' + garanzias);
            String garanziaMissingFields = '';
            for(Garanzia__c g : garanzias){
                currentMissingFields = ' ';
                for(String garanziaF : garanziaFieldList){
                    
                    if (g.get(garanziaF) == null || g.get(garanziaF) == '') {
                        if(garanziaF=='Percentuale_Garantito__c'){
                            if(g.Tipo_di_Garanzia__c=='Fidejussione'){
                                if(g.Is_Standard__c==false){
                                    continue;
                                }
                            }
                            else
                                continue;
                        }
                        if(garanziaF=='Percentuale_Libero__c'){
                            if(g.Tipo_di_Garanzia__c=='Fidejussione'){
                                if(g.Is_Standard__c==true){
                                    continue;
                                }
                            }
                            else
                                continue;
                        }
                       
                        
                        
                        isGaranziaMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Garanzia__c').getDescribe().fields.getMap().get(garanziaF).getDescribe().getLabel();
                        currentMissingFields += '</br> - ' +fieldLabel;
                    } 
                }
                if(currentMissingFields!= ' ')
                    garanziaMissingFields = '</br><b>Per la garanzia '+g.Garanzie_Name__c+':</b><br/>' + currentMissingFields;
            }
            garanziaMissingFields = garanziaMissingFields.removeEnd(', ');
            garanziaMissingFields = garanziaMissingFields + '<br/><br/>';            
            
            system.debug('oppMissingFields'+oppMissingFields);
            system.debug('accMissingFields'+accMissingFields);
            system.debug('contMissingFields'+contMissingFields);
            system.debug('quoteMissingFields'+quoteMissingFields);
            system.debug('isOppMissingFields'+isOppMissingFields);
            
            if(isOppMissingFields || isAccMissingFields || isContMissingFields || isQuoteMissingFields || isGaranziaMissingFields) {
                
                response.ok=false;
                
                finalMessage = '</br></br></br><b>Compilare i seguenti campi:</b><br/>';
                if(isOppMissingFields){
                    finalMessage = finalMessage + oppMissingFields;
                }
                if(isAccMissingFields){
                    finalMessage = finalMessage + accMissingFields;
                }
                if(isContMissingFields){
                    finalMessage = finalMessage + contMissingFields;
                }
                if(isQuoteMissingFields){
                    finalMessage = finalMessage + quoteMissingFields;
                }
                if(isGaranziaMissingFields){
                    finalMessage = finalMessage + garanziaMissingFields;
                }
                response.responseMessage+=finalMessage;
                
            }
        }
        
        if(response.ok==true){
            RichiediContratto firma =calcolaTipoFirma(oppId);
            system.debug('po pse');
            return firma;
        }else{
            response.title='Condizioni richiesta contratto';
        }      
        
        system.debug('RichiediContrattoController checkCampiRichiediContratto - End');
        return response; 
    }
    
    
    public static RichiediContratto calcolaTipoFirma(String oppId){
        system.debug('RichiediContrattoController.calcolaTipoFirma --- Start  oppId '+oppId);
        
        RichiediContratto response = new RichiediContratto();
        response.responseMessage = '';
        Map<String, String> test = new Map<String, String>();
        response.condizioni =test;
        response.error=true;
        System.debug('response.condizioni test'+ response.condizioni);
        
        // response.condizioni.put('Solo un firmatario', 'false');
        list<Contact> contacts = new List<Contact>();
        Opportunity opp=[select id , Richiesta_Firma_Digitale__c, StatusVideoconferenza__c, Tipo_Linea_di_Credito__c from Opportunity where id=:oppId];
        if(opp.Tipo_Linea_di_Credito__c =='Mutuo'){
            contacts.addAll( ElevaRestApiHelper.getAllFidejussori(oppId));
            contacts.addAll([select id, Name, FinServ__EmailVerified__c, FinServ__MobileVerified__c from Contact 
                                where accountid in (select accountid from Opportunity where id=:oppId) and firmatario__c = true]);
        }else if(opp.Tipo_Linea_di_Credito__c =='Crediti Fiscali'){
            contacts=[select id, Name, FinServ__EmailVerified__c, FinServ__MobileVerified__c from Contact 
                                where accountid in (select accountid from Opportunity where id=:oppId) and firmatario__c = true ];  
        }   
        /* list<Contact> contacts=[select id, Name, FinServ__EmailVerified__c, FinServ__MobileVerified__c from Contact 
                                where accountid in (select accountid from Opportunity where id=:oppId) and (firmatario__c = true or fidejussore__c = true)];
        
        list<Contact> contactCrediti=[select id, Name, FinServ__EmailVerified__c, FinServ__MobileVerified__c from Contact 
                                where accountid in (select accountid from Opportunity where id=:oppId) and firmatario__c = true ];                
        */
       // List<Garanzia__c> garanzie =[select id, Tipo_di_Garanzia__c, Opportunit__c from Garanzia__c where Opportunit__c =:oppId and Tipo_di_Garanzia__c='Fidejussione'];
        
        system.debug('RichiediContrattoController.calcolaTipoFirma firmatari ' + contacts );
        
           //Commentatto per modifiche di firma digitale
       /* if(contacts.size()> 0 || garanzie.size()>0){
            response.imediatelyManual=true;
            response.responseMessage='Stai per richiedere il contratto con la Firma Manuale. Sei sicuro di voler procedere?';
            response.title='Tipo di Firma';
            return response;
        }*/
        
      /*  if(contacts.size()> 0){
            response.condizioni.put('Indicare solo un firmatario.', 'true');  
            response.con= contacts[0];*/
         if(opp.Tipo_Linea_di_Credito__c == 'Mutuo'){   
          for(Contact contact : contacts){
            if(!contact.FinServ__EmailVerified__c){
                response.condizioni.put(' Certificare il numero di cellulare dei Firmatari/Fidejussori.', 'false');
                response.error=false;
            }
            
            if(!contact.FinServ__MobileVerified__c){
                response.condizioni.put(' Certificare la mail dei Firmatari/Fidejussori.', 'false'); 
                response.error=false;
            
            }
          }
        } else if (opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
            for(Contact contact : contacts){
                if(!contact.FinServ__EmailVerified__c){
                    response.condizioni.put(' Certificare il numero di cellulare dei Firmatari.', 'false');
                    response.error=false;
                }
                
                if(!contact.FinServ__MobileVerified__c){
                    response.condizioni.put(' Certificare la mail dei Firmatari.', 'false'); 
                    response.error=false;
                
                }
              }
        }
            if(opp.StatusVideoconferenza__c != 'Positivo'){
            response.condizioni.put(' Verificare che Esito Videoconferenza sull\'opportunità abbia esito "Positivo".', 'false');
                response.error=false;
            }
        //}
        
        response.title='Tipo di Firma';
        response.ok=true;
        system.debug('response' + response);
        system.debug('RichiediContrattoController.calcolaTipoFirma --- End');
        return response;
    }
    
    @AuraEnabled
    public static RichiediContratto decideTipoFirma(Id recordId, Boolean isManuale){
        system.debug('RichiediContrattoController.decideTipoFirma Start recordId '+recordId+' isManuale '+isManuale);
        RichiediContratto response = new RichiediContratto();
        response.ok=true;
        Map<String,String> oppInfo = new Map<String,String> ();
       
        
        list<Contact> contacts=[select id, Name, Email, FinServ__EmailVerified__c, FinServ__MobileVerified__c from Contact 
                                where accountid in (select accountid from Opportunity where id=:recordId) and firmatario__c=true];
        
        List<Quote> quotes = [SELECT Id, Name, Status, OpportunityId,Opportunity.Tipo_di_opportunit__c,Opportunity.AccountId FROM Quote WHERE OpportunityID=:recordId];
        
        opportunity o = new Opportunity();
        o.Id= recordId;
            if(isManuale == false){
                o.Tipo_Firma__c='Firma Digitale';
                o.Richiesta_Firma_Digitale__c='SI';
                o.Nome_Cognome_Firmatario__c=contacts[0].Name;
                o.Email_Firmatario__c=contacts[0].Email;
            }
            else{
                o.Tipo_Firma__c='Firma Manuale';
                o.Richiesta_Firma_Digitale__c='NO';
            }
            system.debug('Tipo_Firma__c'+ o.Tipo_Firma__c);
        
        OpportunityController.bypassTrigger=true;
        update o;
        OpportunityController.bypassTrigger=false;
        
        for(Quote q: quotes){
            if(q.Status=='In Corso'){
                oppInfo.put('opportunityType', q.Opportunity.Tipo_di_opportunit__c);
                oppInfo.put('accountId', q.Opportunity.AccountId);
                ElevaRestApiController.generateContractFuture(q.Id,oppInfo);
            }
        }
        response.ok=true;
        response.responseMessage='Contratto con ' + o.Tipo_Firma__c + ' richiesto.';
        system.debug('RichiediContrattoController.decideTipoFirma End ');
        return response;
    }
    
    @AuraEnabled
    public static String disponiInvioContratto(String oppId){
        system.debug('RichiediContrattoController disponiInvioContratto - Start oppId'+oppId);
        
        String finalMessage = '';
        String queryOppString = 'SELECT Id, Invio_Landing_Page_Cliente__c FROM Opportunity WHERE Id = :oppId';
        List<Opportunity> opps = (List<Opportunity>) (Database.query(queryOppString));
        system.debug('List<Opportunity> opps: '+ opps);
        
        if(opps.size()>0) {
            
            Opportunity opp = opps.get(0);
            opp.Invio_Landing_Page_Cliente__c = true;
            
            system.debug('Start Update opp: ' + opp);
            
            OpportunityController.bypassTrigger=true;
            update opp;
            OpportunityController.bypassTrigger=false;
            
            finalMessage = 'Disponi Invio Contratto: Azione effettuata';
            
        }
        system.debug('return: ' + finalMessage);
        system.debug('RichiediContrattoController disponiInvioContratto - End');
        return finalMessage;
        
    }
    
  @AuraEnabled
    public static RichiediContratto checkCampiRichiedi(String oppId){
        system.debug('RichiediContrattoController checkCampiRichiediContratto - Start oppId '+ oppId);
        
        Utils_Constants constants = new Utils_Constants();
        RichiediContratto response = new RichiediContratto();
        response.ok=true;        
        response.responseMessage='';
        String finalMessage = '';
        Boolean isOppMissingFields = false;
        Boolean isAccMissingFields = false;
        Boolean isContMissingFields = false;
        Boolean isQuoteMissingFields = false;
        Boolean isGaranziaMissingFields = false;
        List<String> kot = new List<String>();
        
        List<String> oppFieldList = new List<String>{'AccountId','Name','Verifica_condizioni_sospensive__c', 'Totale_Verified_Docs_Verificati__c', 'Tasso_Cliente__c',
            'Total_Optional_Docs__c', 'Total_Mandatories_Docs__c', 'Tipo_di_opportunit__c','Data_Prevista_Incasso__c', 'Importo_del_Credito__c','Total_Uploaded_Docs__c','Verifica_Firmatario__c','Condizioni_Sospensive__c','StageName'};
        List<String> oppFieldMutuoList = new List<String>{'AccountId','Name','Verifica_condizioni_sospensive__c', 'Totale_Verified_Docs_Verificati__c',
            'Total_Optional_Docs__c', 'Total_Mandatories_Docs__c','Tipo_di_opportunit__c', 'Total_Uploaded_Docs__c','Verifica_Firmatario__c','Condizioni_Sospensive__c'};

        List<String> accountFieldList = new List<String>{'BillingCountry','Cap__c','Capitale_Sociale__c','Capitale_Versato__c','Casa_Comunale_Domicilio__c','Codice_Fiscale__c',
                    'Comune__c','Id','Indirizzo_Sede_Legale_Esteso__c','Microimpresa__c','Name','Tipo_Via__c','Nome_Via__c','Numero_Civico__c','Provincia__c',
                    'Sigla_Provincia__c','Paese_Sede_Azienda__c', 'Piccola_Media_Impresa__c'};
        List<String> accountFieldListCrediti = new List<String>{'Cap__c','Codice_Fiscale__c','Partita_Iva__c',
                    'Comune__c','Id','Indirizzo_Sede_Legale_Esteso__c','Microimpresa__c','Name',
                    'Sigla_Provincia__c'};
                        
        List<String> contactFieldList = new List<String>{'AccountId','Cap__c','Comune__c','Comune_di_Nascita__c','Data_di_Nascita__c','Email',
                            'Firmatario__c','FirstName','Genere_Nascita__c','Id','Indirizzo_Residenza_Esteso__c','LastName','Name',
                            'Oplon_Codice_Fiscale__c','Percentuale_di_riferimento_socio__c', 'Ruolo_in_Azienda__c','Sigla_Provincia__c',
                            'Titolo_Firmatario__c', 'Localita__c','Sigla_Provincia_Nascita__c', 'Localita_Residenza__c','Paese_Rilascio__c', 'Stato_ResidenzaEstero__c'}; 
        List<String> contactFieldListCrediti = new List<String>{'Email','Percentuale_di_riferimento_socio__c',
                        'Firmatario__c','FirstName','Id','LastName','Name','MobilePhone'}; 
                                
        List<String> quoteFieldList = new List<String>{'Name','OpportunityId', 'Data_fine_mutuo_Formula__c', 'Data_Fine_Preammortamento__c',
                                    'Percentuale_Commissioni_da_Istruttoria__c', 'Percentuale_Commissione_Intermediazione__c', 'Percentuale_Spread__c',
                                    'Importo_Imposta_Sostitutiva__c', 'Importo_Commissioni_di_Istruttoria__c', 'Numero_Rapporto__c','Filiale_Banca_Cliente__c', 
                                     'Data_Stipula__c', 'Sigla_Provincia_Firma__c', 'Citta_Firma__c', 'Nome_Azienda_Sede_Firma__c','Status',
                                    'Tipo_Via__c', 'Nome_Via__c', 'Cognome_Procuratore_Speciale__c', 'Cap_Firma__c', 'Banca_Cliente__c', 'Nome_Procuratore_Speciale__c',
                                    'Finalita_Finanziamento__c', 'Numero_Civico__c','IBAN__c'};  
        List<String> quoteFieldListCrediti = new List<String>{'Data_Stipula__c','Commissione_acquisto_pro_soluto__c','Corrispettivo_cessione__c',
                                    'Name', 'Tasso_nominale_base_annua__c', 'n_gg_lavorativi_Bonifici__c',
                                    'n_gg_lavorativi_Incassi_a_mezzo_bonific__c','Spese_istruttoria_cedente__c','Status','Percentuale_Commissione_Intermediazione__c',
                                    'Spese_istruttoria_rinnovo_pratica_cedent__c','Spese_istruttoria_debitore__c','Spese_handling_per_fattura__c','Spese_handling_per_effetto__c',
                                    'Spese_per_distinta__c', 'Spese_Hnadling_per_presentazione__c','Spese_per_bonifico__c','Spese_per_tenuta_conto__c','Spese_postali__c',
                                    'Spese_per_bolli__c','Canone_Home_factoring__c', 'Certificazione_ai_revisori__c' ,'Dichiarazione_crediti__c','Anno_crediti__c',
                                   'C_c_banca_Cedente__c','Banca_Cedente__c','IBAN_Cedente__c' }; 
                                        
        List<String> garanziaFieldList = new List<String>{'Garanzie_Name__c','Expiration_Date__c','Percentuale_Garantito__c', 'Percentuale_Libero__c', 'Is_Standard__c', 'Tipo_di_Garanzia__c' };  
                                            
        List<Opportunity> myOpp = new List<Opportunity>([SELECT Id, StageName FROM Opportunity where Id=: oppId]);
        
        String oppFieldsString = String.join(oppFieldList, ',');
        String accountFieldsString = String.join(accountFieldList, ',');
        String contactFieldsString = String.join(contactFieldList, ',');
        String quoteFieldsString = String.join(quoteFieldList, ',');
        //for crediti
        String accountFieldsStringCrediti = String.join(accountFieldListCrediti, ',');
        String contactFieldsStringCrediti = String.join(contactFieldListCrediti, ',');
        String quoteFieldsStringCrediti = String.join(quoteFieldListCrediti, ',');

        String garanziaFieldsString = String.join(garanziaFieldList, ',');
        Boolean isCreditiFiscali=false;
        String currentMissingFields;
        String queryOppString = '';
       
         queryOppString = 'SELECT ' + oppFieldsString + ' FROM Opportunity WHERE Id = :oppId';
        
        List<Opportunity> opps = (List<Opportunity>) (Database.query(queryOppString));
        system.debug('opps: '+opps);
        if(opps.size()>0) {
            Opportunity opp = opps.get(0);
            if(opp.Tipo_di_opportunit__c == constants.OPPORTUNITY_TIPO_FISCALE){
                isCreditiFiscali=true;
            }
            response.responseMessage='<b>Per richedere il contratto occorre:</b><br/><br/>' + '\n';
            
            if( opp.Condizioni_Sospensive__c<>null && opp.Verifica_condizioni_sospensive__c<>'Si')
            {
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n ' + '- verificare le Condizioni Sospensive.<br/>';
            }
            
            if(opp.Totale_Verified_Docs_Verificati__c != opp.Total_Mandatories_Docs__c)  
            {
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n ' +  '- convalidare il set documentale.<br/>';
            }
            
            if(opp.Verifica_Firmatario__c == 'Esito Negativo' || opp.Verifica_Firmatario__c == null) 
            {
                response.ok=false;
                response.responseMessage=response.responseMessage + '\n ' + '- verificare il firmatario con Esito Positivo.<br/>';
            }
            if(opp.StageName != constants.OPPORTUNITY_DELIBERATA){
            response.ok=false;
            response.responseMessage= response.responseMessage + '\n ' + '<br/><br/>'+ '- passare l\'Opportunità in fase Deliberata';
        }
            if(response.ok)
            {
                response.responseMessage=''; 
            }
            
            String oppMissingFields = '<br/><b>Opportunity:</b><br/>';
            if(!isCreditiFiscali){
            for (String oppF : oppFieldMutuoList) {
                if (opp.get(oppF) == null || opp.get(oppF) == '') {
                    if(oppF=='Verifica_condizioni_sospensive__c' || oppF=='Condizioni_Sospensive__c' || oppF=='Verifica_Firmatario__c')
                        continue;
                    
                    isOppMissingFields = true;
                    String fieldLabel = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(oppF).getDescribe().getLabel();
                    oppMissingFields =oppMissingFields + '</br> - ' + fieldLabel;
                }
            } 
            }else{
                //check for crediti fiscali fields that are different from mutuo
                for (String oppF : oppFieldList) {
                    if (opp.get(oppF) == null || opp.get(oppF) == '') {
                     if(oppF=='Verifica_condizioni_sospensive__c' || oppF=='Condizioni_Sospensive__c' || oppF=='Verifica_Firmatario__c')
                        continue;
                        system.debug('checkCampiRichiediContratto isOppMissingFields true');
                        isOppMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(oppF).getDescribe().getLabel();
                        oppMissingFields = oppMissingFields + '</br> - ' +fieldLabel;
                    }
                }
            }
        
            oppMissingFields = oppMissingFields.removeEnd(', ');
            oppMissingFields = oppMissingFields + '<br/><br/>';
        
            String accId = opp.AccountId; 
            String queryAccountString ;
            if(!isCreditiFiscali){
                queryAccountString = 'SELECT ' + accountFieldsString + ' FROM Account WHERE Id = :accId';
            }else{
                queryAccountString = 'SELECT ' + accountFieldsStringCrediti + ' FROM Account WHERE Id = :accId';
            }
            
            List<Account> accounts = (List<Account>) (Database.query(queryAccountString));
            system.debug('accounts: ' + accounts);
            Account acc = accounts.get(0);
            system.debug('acc: ' + acc);
            String accMissingFields = '<br/><b>Per l\'Anagrafica:</b><br/>';
            if(!isCreditiFiscali){
                for (String accF : accountFieldList) {
                    if (acc.get(accF) == null || acc.get(accF) == '') {
                        system.debug('checkCampiRichiediContratto isAccMissingFields true');
                        isAccMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                        accMissingFields = accMissingFields + '</br> - ' +fieldLabel;
                    }
                }
            }else{
                for (String accF : accountFieldListCrediti) {
                    if (acc.get(accF) == null || acc.get(accF) == '') {
                        system.debug('checkCampiRichiediContratto isAccMissingFields true');
                        isAccMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                        accMissingFields = accMissingFields + '</br> - ' +fieldLabel;
                    }
                }
            }
            
            accMissingFields = accMissingFields.removeEnd(', ');
            accMissingFields = accMissingFields + '<br/><br/>';
            String queryContactString;
            if(!isCreditiFiscali){
                queryContactString = 'SELECT '+ contactFieldsString +',Residenza__c FROM Contact WHERE AccountId = :accId AND Firmatario__c = true';
            }else{
                queryContactString = 'SELECT '+ contactFieldsStringCrediti +',Residenza__c FROM Contact WHERE AccountId = :accId AND Firmatario__c = true';
            }
            
            List<Contact> contacts = (List<Contact>) (Database.query(queryContactString));
            system.debug('contactsss'+ contacts);
            String contMissingFields = '';
            //questo sempre pure per crediti
            if(contacts.isempty()){
                response.ok=false;
                response.responseMessage = response.responseMessage + '\n ' + '<br/><br/>'+ '- avere almeno un Firmatario';
            }
            for(Contact cont : contacts){
                 
                currentMissingFields = ' ';
                if(cont.Percentuale_di_riferimento_socio__c != null){
                    if(!isCreditiFiscali){
                        for(String contF : contactFieldList){
                            if(contF != 'Email') {
                                if (cont.get(contF) == null || cont.get(contF) == '') {
                                    if(contF=='Stato_ResidenzaEstero__c'){
                                        if(cont.Residenza__c=='ITALIA' || cont.Residenza__c==null){
                                                continue;
                                        }
                                    }
                                    isContMissingFields = true;
                                    String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                    currentMissingFields += '</br> - ' +fieldLabel;
                                }
                            }
                        }
                    }else{
                        for(String contF : contactFieldListCrediti){
                            if(contF != 'Email') {
                                if (cont.get(contF) == null || cont.get(contF) == '') {
                                    if(contF=='Stato_ResidenzaEstero__c'){
                                        if(cont.Residenza__c=='ITALIA' || cont.Residenza__c==null){
                                                continue;
                                        }
                                    }
                                    isContMissingFields = true;
                                    String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                    currentMissingFields += '</br> - ' +fieldLabel;
                                }
                            }
                        }
                    }
                if(currentMissingFields!= ' ')
                    contMissingFields = '</br><b>Per il Referente '+cont.Name+':</b><br/>'  + currentMissingFields;
            }
            }
            contMissingFields = contMissingFields.removeEnd(', ');
            contMissingFields = contMissingFields + '<br/><br/>';       
            String queryQuoteString;     
            if(!isCreditiFiscali){
                queryQuoteString = 'SELECT '+ quoteFieldsString +' FROM Quote WHERE OpportunityId =: oppId';// and Status!=:constants.LINEE_DI_CREDITO_ANNULLATA and Status= \'In Corso\'
            }else{
                queryQuoteString = 'SELECT '+ quoteFieldsStringCrediti +' FROM Quote WHERE OpportunityId =: oppId';// and Status!=:constants.LINEE_DI_CREDITO_ANNULLATA and Status= \'In Corso\'
            }
            List<Quote> quotes = (List<Quote>) (Database.query(queryQuoteString));
            String quoteMissingFields = '';
              Boolean isActive = false;
            List<String> profileIds = new List<String>();
            
            /*    for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'Intermediario Finanziario' OR Name = 'Mediatore Creditizio']){
profileIds.add(pr.Id);
}
String currentProfileId = UserInfo.getProfileId();
*/
            for(Quote q : quotes){
                if(q.Status == 'In Corso' || q.Status == 'Delibera Positiva'){
                    isActive=true;
                }
                //lasciare cosi anche per crediti fiscali
                 if(q.Percentuale_Commissione_Intermediazione__c==null){
                system.debug('a jeeeee');
                response.ok=false;
                response.responseMessage= response.responseMessage + '\n ' + '<br/><br/>'+ '- valorizzare la percentuale di intermediazione creditizia sulla ' + q.Name;
            }
                currentMissingFields = ' ';
                if(!isCreditiFiscali){
                    for(String quoteF : quoteFieldList){
                        if(q.Status == 'In Corso'){
                            if (q.get(quoteF) == null || q.get(quoteF) == '') {
                                isQuoteMissingFields = true;
                                String fieldLabel = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().get(quoteF).getDescribe().getLabel();
                                currentMissingFields += '</br> - ' + fieldLabel;
                            }
                        }
                    }
                }else{
                    for(String quoteF : quoteFieldListCrediti){
                        if(q.Status == 'In Corso'){
                            if (q.get(quoteF) == null || q.get(quoteF) == '') {
                                isQuoteMissingFields = true;
                                String fieldLabel = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().get(quoteF).getDescribe().getLabel();
                                currentMissingFields += '</br> - ' + fieldLabel;
                            }
                        }
                    }
                }
                
                if(currentMissingFields!= ' ')
                    quoteMissingFields +=  '<br/>' + '</br><b>Per la Linea di Credito '+q.Name+':</b><br/>' + currentMissingFields;   
            }
            if(!isActive || quotes.size()==0){
            response.ok=false;
            response.responseMessage= response.responseMessage + '\n ' +'<br/><br/>' + '- avere almeno una linea di credito attiva per questa opportunità';
        }
            quoteMissingFields = quoteMissingFields.removeEnd(', ');
            quoteMissingFields =  quoteMissingFields + '<br/><br/>';
            system.debug('quoteMissingFields ' + quoteMissingFields);
            
            String queryGaranziaString = 'SELECT '+ garanziaFieldsString +' FROM Garanzia__c WHERE Opportunit__c =: oppId and Stato_Garanzia__c != \'Chiusa\'';
            List<Garanzia__c> garanzias = (List<Garanzia__c>) (Database.query(queryGaranziaString));
            system.debug('garanzias: ' + garanzias);
            String garanziaMissingFields = '';
            for(Garanzia__c g : garanzias){
                currentMissingFields = ' ';
                for(String garanziaF : garanziaFieldList){
                    
                    if (g.get(garanziaF) == null || g.get(garanziaF) == '') {
                        if(garanziaF=='Percentuale_Garantito__c'){
                            if(g.Tipo_di_Garanzia__c=='Fidejussione'){
                                if(g.Is_Standard__c==false){
                                    continue;
                                }
                            }
                            else
                                continue;
                        }
                        if(garanziaF=='Percentuale_Libero__c'){
                            if(g.Tipo_di_Garanzia__c=='Fidejussione'){
                                if(g.Is_Standard__c==true){
                                    continue;
                                }
                            }
                            else
                                continue;
                        }
                       
                        
                        isGaranziaMissingFields = true;
                        String fieldLabel = Schema.getGlobalDescribe().get('Garanzia__c').getDescribe().fields.getMap().get(garanziaF).getDescribe().getLabel();
                        currentMissingFields += '</br> - ' +fieldLabel;
                    } 
                }
                if(currentMissingFields!= ' ')
                    garanziaMissingFields = '</br><b>Per la garanzia '+g.Garanzie_Name__c+':</b><br/>' + currentMissingFields;
            }
            garanziaMissingFields = garanziaMissingFields.removeEnd(', ');
            garanziaMissingFields = garanziaMissingFields + '<br/><br/>';            
            
            system.debug('oppMissingFields'+oppMissingFields);
            system.debug('accMissingFields'+accMissingFields);
            system.debug('contMissingFields'+contMissingFields);
            system.debug('quoteMissingFields'+quoteMissingFields);
            system.debug('isOppMissingFields'+isOppMissingFields);
            
            if(isOppMissingFields || isAccMissingFields || isContMissingFields || isQuoteMissingFields || isGaranziaMissingFields) {
                
                response.ok=false;
                
                finalMessage = '</br></br></br><b>Compilare i seguenti campi:</b><br/>';
                if(isOppMissingFields){
                    finalMessage = finalMessage + oppMissingFields;
                }
                if(isAccMissingFields){
                    finalMessage = finalMessage + accMissingFields;
                }
                if(isContMissingFields){
                    finalMessage = finalMessage + contMissingFields;
                }
                if(isQuoteMissingFields){
                    finalMessage = finalMessage + quoteMissingFields;
                }
                if(isGaranziaMissingFields){
                    finalMessage = finalMessage + garanziaMissingFields;
                }
                response.responseMessage+=finalMessage;
                
            }
        }
                 
        system.debug('RichiediContrattoController checkCampiRichiediContratto - End');
        return response; 
    }

    
@AuraEnabled
    public static RichiediContratto rissotemettere(String recordId){
      system.debug('RichiediContrattoController rissotemettere - Start oppId'+recordId);
        RichiediContratto response = new RichiediContratto();        
        response.ok=true;
        List<Quote> quotee = new List<Quote>();
        List<Document__c> docc = new List<Document__c>();
    Opportunity oppRetrieve = [SELECT Id, Tipo_di_opportunit__c, Tipo_Linea_di_Credito__c  FROM Opportunity where Id =:recordId ];
      Opportunity opps = new Opportunity();
        opps.Id = recordId;
        opps.StageName = 'Deliberata';
        opps.Rissotomettere__c = 'hera e 2';
        opps.Tipo_Firma__c = '';
        opps.Richiesta_Firma_Digitale__c = '';
        opps.Nome_Cognome_Firmatario__c= '';
        opps.Email_Firmatario__c = '';
        opps.Errore_Richiedi_Contratto__c = '';
            
    
           
      if(oppRetrieve.Tipo_di_opportunit__c == 'Mutuo'){     
        List<Quote> quoteRisList = [Select id, OpportunityId, Description, (Select id, Url_Documento__c, DocumentTypeNameFormula__c, IDTipoDocumentoFormula__c from Documenti__r where DocumentTypeNameFormula__c = 'Contratto cartaceo/digitale' OR DocumentTypeNameFormula__c = 'Fideiussione un garante/più garanti cartaceo/digitale' ) from Quote where OpportunityId =:recordId and Status !='Annullata'];
          System.debug('quoteRisList ' +quoteRisList);
            for(Quote quote : quoteRisList){
                Quote q = new quote ();
                    q.id = quote.id;
                    q.RichiestaContrattoOk__c = false;
                    q.Landing_Page__c = '';
                    q.Documento_Da_Firmare__c = '';
                    q.Contratto_Verificato__c =false;
                    q.Link_Documento_Firmato__c = '';
                    q.Link_URL_Documento__c = '';
                    q.Tipologia_Contratto__c = '';
                    q.Contratto_Firmato_Flusso__c = false;
                    q.Contratto_Verificato__c = false;
                    quotee.add(q);
                    System.debug('quote 2: ' + q);
                    System.debug('quoteList: ' + quotee);
                
                    if(!quote.Documenti__r.isEmpty()){
                        for(Document__c d : quote.Documenti__r){
                            Document__c doc58 = new Document__c();
                            doc58.id =d.Id;
                            doc58.Url_Documento__c ='';
                            doc58.Url_Servizio_Esterno__c ='';
                            doc58.Id_File__c ='';
                            doc58.Verifica_Sales_Support__c ='';
                            doc58.Errore_Store_Document__c = '';
                            doc58.Data_Caricamento__c=null;
                            docc.add(doc58);
                        }
               
                    }
            }
        } else if (oppRetrieve.Tipo_di_opportunit__c == 'Crediti Fiscali'){
            System.debug('Tipo_di_opportunit__c : ' + opps.Tipo_di_opportunit__c);
            for(Quote quote : [Select id, OpportunityId, Description, (Select id, Url_Documento__c, DocumentTypeNameFormula__c from Documenti__r where DocumentTypeNameFormula__c = 'Contratto di cessione crediti IVA')
                                          from Quote where OpportunityId =:recordId and Status !='Annullata']){
             System.debug('quote: ' + quote);
                Quote q = new quote ();
                    q.id = quote.id;
                    q.RichiestaContrattoOk__c = false;
                    q.Landing_Page__c = '';
                    q.Documento_Da_Firmare__c = '';
                    q.Contratto_Verificato__c =false;
                    q.Link_Documento_Firmato__c = '';
                    q.Link_URL_Documento__c = '';
                    q.Tipologia_Contratto__c = '';
                    q.Contratto_Firmato_Flusso__c = false;
                    q.Contratto_Verificato__c = false;
                    quotee.add(q);
                    System.debug('quote 2: ' + q);
                    System.debug('quoteList: ' + quotee);
                
                    Document__c doci = new Document__c ();
                    if(!quote.Documenti__r.isEmpty()){
                    doci.id =quote.Documenti__r[0].Id;
                                       
                    doci.Url_Documento__c ='';
                    doci.Url_Servizio_Esterno__c ='';
                    doci.Id_File__c ='';
                    doci.Verifica_Sales_Support__c ='';
                    doci.Errore_Store_Document__c = '';
                    doci.Data_Caricamento__c=null;
                      
                    docc.add(doci);  }
                    System.debug('docclist: ' + docc);
                    System.debug('doci: ' + doci);
                
            }
        }
        
         try{
            OpportunityController.bypassTrigger = true;
            QuoteController.bypassTrigger=true;   
       update opps;
       update quotee;
       update docc;
       OpportunityController.bypassTrigger = false;
       QuoteController.bypassTrigger=false;
       List<Opportunity> oppList = new List<Opportunity>{opps};
       List<Id> oppListId = new List<Id>{opps.Id};
       fileUploaderController.numerimi(recordId);
       fileUploaderController.UpdateDocCountAfterStageChange(oppList);
       OpportunityController.LendingRecordType(oppListId);
         } catch(dmlexception e){
                               system.debug('RichiediContrattoController response.ok - ' + response.ok);

             response.ok=false;
             system.debug('RichiediContrattoController response.ok f - ' + response.ok);

             response.responseMessage=e.getMessage();
                          system.debug('RichiediContrattoController response.ok f - ' + response.responseMessage);
    system.debug('RichiediContrattoController response.okrrr - ' + response);
              return response;
     
         }
        
                  system.debug('RichiediContrattoController disponiInvioContratto - End' + response);

        
      
         system.debug('opps' + opps);
         system.debug('quotee' + quotee);
         system.debug('docc' + docc);
        
          system.debug('RichiediContrattoController disponiInvioContratto - End' + response);
      return response;
    }

    @AuraEnabled
    public static Boolean getCertificatoNotarileDocs (String oppId) {
        System.debug('* getCertificatoNotarileDocs * ');
        Boolean allDocsAreVerified = false;
        System.debug('* allDocsAreVerified = ' + allDocsAreVerified);
        List<String> oppRecordTypes = new List<String>{'Inserimento_Crediti_Fiscali','Crediti_Fiscale_Lending','Crediti_Fiscale_Lending_RO','Lending'};
        Opportunity opportunity = [SELECT Id, StageName, RecordType.DeveloperName FROM Opportunity WHERE Id =: oppId];
        System.debug('opportunity = ' + opportunity);
        if (oppRecordTypes.contains(opportunity.RecordType.DeveloperName)) {
            System.debug('opp has correct record type');
            List<Quote> quoteList = [
                    SELECT Id
                    FROM Quote
                    WHERE OpportunityId =: oppId
                    AND Status != 'Annullata'
            ];
            List<Id> quoteIdList = new List<Id>();

            for (Quote quote : quoteList) {
                quoteIdList.add(quote.Id);
            }

            System.debug('* quoteList = ' + quoteList);
            System.debug('* quoteIdList.size() = ' + quoteIdList.size());

            List<Document__c> docList = [
                    SELECT Id, ObjectName__c, File_Name__c, Url_Documento__c, DocumentType__c, DocumentType__r.Name,
                            DocumentType__r.ObjectName__c, DocumentType__r.Obbligatorio_in_Deliberata__c,
                            DocumentType__r.Check_RichiediContratto__c, DocumentType__r.Obbligatorio_in_Erogazione__c,
                            Verifica_Sales_Support__c
                    FROM Document__c
                    WHERE Quote__c IN :quoteIdList
                    AND DocumentType__r.Obbligatorio_in_Deliberata__c = TRUE
                    AND DocumentType__r.Check_RichiediContratto__c = TRUE
                    AND File_Name__c != NULL
                    AND Quote__c != NULL
            ];

            System.debug('* docList = ' + docList);
            System.debug('* docList.size() = ' + docList.size());

            for (Document__c document : docList) {
                System.debug('** document = ' + document);
                System.debug('** document.Verifica_Sales_Support__c = ' + document.Verifica_Sales_Support__c);

                if (document.Verifica_Sales_Support__c != 'Verifica OK') {
                    System.debug('*** not ok');
                    allDocsAreVerified = false;
                    break;
                } else {
                    System.debug('*** is ok');
                    allDocsAreVerified = true;
                }
            }
            System.debug('* final allDocsAreVerified = ' + allDocsAreVerified);
        }

        return allDocsAreVerified;
    }
    @AuraEnabled
    public static Map<String,List<Contact>> getAllFidejussori(String oppId) {
        
        return ElevaRestApiHelper.getFidejussoreWithOppId(oppId);
    }
    @AuraEnabled
    public static List<BP_VideoConferenzaController.bookVideoConfWrapper> isFirmatarioContact(Id oppId, Id accountId, String tipoLineaCredito){
       return BP_QR_Contact.getFirmatarioContact(oppId, accountId, tipoLineaCredito);
    }
    
}