public with sharing class OpportunityController extends TriggerHandler{
    public static Utils_Constants constants = new Utils_Constants();
    public static Boolean bypassTrigger{set;get;}
    public static Boolean bypassUserAccess = ! Utils.checkUserBypassAccess();
    public static User loggedInUser = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() limit 1];
    public static List<User> Fidimed = [Select id from User where isFidimed__c=true];
    public static Id userFidimed =Fidimed[0].Id;    
    public static Map<String, Id> usersMap = new Map<String, Id>();
    public static Map<Id, User> ownerMap = new Map<Id, User>();
    public static List<Profile> integratorProfileList = new List<Profile>();
    public static List<Profile> differentProfileList = new List<Profile>();
    
    public OpportunityController(){
        if(usersMap.isEmpty()){
            usersMap = getUsersMap();
        }
    }

    public override void run(){
        if(bypassTrigger==null || bypassTrigger==false){
            super.run();
        }
    }
    public override void afterInsert()
    {
        System.debug('OpportunityController.afterInsert trigger - Start');
        OpportunityController.AfterInsert(Trigger.new);
        BP_StoricoFaseManager.createStoricoFaseRecOnOppCreate(Trigger.new);
        //OpportunityController.decideScenario(Trigger.new);
        OpportunityWOSharingController.decideScenario(Trigger.new);
        System.debug('OpportunityController.afterInsert trigerr - End');
    }
    public override void beforeInsert()
    {
        System.debug('OpportunityController.beforeInsert trigger- Start');
        OpportunityController.BeforeInsert(Trigger.new);
        OpportunityController.backupTitolareeCanale(Trigger.new);
        OpportunityController.CreditiOpp(Trigger.new);
        OpportunityController.checkNewOppCloseDate(Trigger.new);
        System.debug('OpportunityController.beforeInsert trigger- End');
    }
    
    public override void beforeUpdate()
    {
        System.debug('OpportunityController.beforeUpdate trigger- Start');
    
        list<opportunity> moti=new list<opportunity>();
        list<Opportunity> listacheckFineMutuo=new list<Opportunity>();
        List<Opportunity> listBackupTitolareeCanale = new List<Opportunity>();
        
        list<Opportunity> listacheckCambioPEFPREISTRUTORIA=new list<Opportunity>();
        
        List<Opportunity> listCheckCambioConsolidamentoDocumento = new List<Opportunity>();
        List<Id> listCheckCambioErogazione = new List<Id>();
    
        List<Opportunity> listCheckCambioDataErogata = new List<Opportunity>();
        List<Opportunity> listCheckCampoNoteEsitoNegativo = new List<Opportunity>();
        List<Opportunity> listCheckCampoNoteEsitoRedFlags = new List<Opportunity>();
        List<Opportunity> listCheckCampoEsitoValutazioneRedFlags = new List<Opportunity>();
        List<Opportunity> listCheckCampoEsitoDueDiligencePositivoDaRedFlags = new List<Opportunity>();
        List<Opportunity> listCheckCampoEsitoDueDiligenceNegativoDaRedFlags = new List<Opportunity>();
        List<Opportunity> listCheckPassareStageInDueDiligence = new List<Opportunity>();
        List<Opportunity> listcheckPassareStageInChiusaPersaDaPreAnalising = new List<Opportunity>();
        List<Opportunity> listnotifyUser = new List<Opportunity>();
        List<Opportunity> listCheckCompletamentoVerificaReportFinale = new List<Opportunity>();
        List<Opportunity> FieldEsitoPropostaPricingList = new List<Opportunity>();
        List<Opportunity> EsitoPropostaPricingPositivoList = new List<Opportunity>();
        List<Opportunity> EsitoPropostaPricingNegativoList = new List<Opportunity>();
        List<Opportunity> listNotificationsStageDueDiligence = new List<Opportunity>();
        List<Opportunity> CondizionePassaggioInCompletamentoDocumentiList = new List<Opportunity>();
        List<Opportunity> chiusaLostDueDiligenceList = new List<Opportunity>();
        List<Opportunity> notificationsStageCompletamentoDocumentiList = new List<Opportunity>();
        List<Opportunity> notificationsStagePreDueDiligenceList = new List<Opportunity>();
        List<Opportunity> mandatoryStageNameForUploadedDocs = new List<Opportunity>();
        List<Opportunity> mandatoryStageNameForVerifiedDocs = new List<Opportunity>();
        List<Opportunity> listEsitoDueDiligenceRedFlagsConditions = new List<Opportunity>();
        List<Opportunity> checkPassareInErogazioneList = new List<Opportunity>();
        List<Opportunity> listCheckCambioFaseSuccessivaPrimaVisita = new List<Opportunity>();
        List<Opportunity> oppListInqury = new List<Opportunity>();
        Set<String> profileList = new Set<String>{ 'Sales Support', 'Sales Support Easy Plus', 'Sales Support Supervisor', 'System Administrator' };
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        
        if(usersMap.isEmpty()){
            usersMap = getUsersMap();
        }
        
        for(Opportunity opp: (List<Opportunity>)Trigger.new)
        {
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.Id);
    
            if((opp.Tipo_Linea_di_Credito__c == 'Mutuo' || opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus') && oldOpp.StageName != opp.StageName && opp.StageName == constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA && oldOpp.StageName == 'Completamento Documenti' && profileList.contains(profileName)){
                if(anticipoPEFValidation(opp.Id)){
                    System.debug('Error???');
                    //opp.addError('Per passare in PEF pre-Istruttoria è necessario che tutte le Linee di Credito in corso abbiano il Numero rapporto!');
                }   
            }
    		
            //Validation For Primary Campaign Source field - Starting
            Map<String, String> campaignDetails = new Map<String, String>();
            String namesOfCampaign = '';
            if(!opp.OpportunitaCollegataACampagna__c && oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Primo Contatto' && opp.StageName == 'Prima Visita'){
                if(String.isNotBlank(opp.AccountId)){
                    campaignDetails = BP_LC_ServicesToast.validatePrimaryCampaignSource(opp.AccountId);
                    if(!campaignDetails.isEmpty()){
                        for(String campaignName: campaignDetails.values()){
                            namesOfCampaign += campaignName + ', ';
                        }
                        namesOfCampaign.removeEnd(',');
                        if(String.isBlank(oldOpp.CampaignId) || (String.isNotBlank(oldOpp.CampaignId) && !campaignDetails.containsKey(opp.CampaignId))){
                            opp.addError(System.Label.Campaign_Names_Warning_Msg + ' ' + namesOfCampaign);
                        }
                    }
                }
            }
            //Validation For Primary Campaign Source field - End
            if(opp.Importo_commissione_FdG__c != oldOpp.Importo_commissione_FdG__c && opp.Importo_commissione_FdG__c != null)
                opp.Importo_Commissione_FdG_in_Lettere__c=AmmontareInLettere.CurrencyToWordsFormat(opp.Importo_commissione_FdG__c);
            
            if((opp.Amount != oldOpp.Amount) )
            { 
                opp.Ammontare_in_lettere__c=AmmontareInLettere.CurrencyToWordsFormat(opp.Amount);
            }
            if(opp.OwnerId <> oldOpp.OwnerId)
            {
                listBackupTitolareeCanale.add(opp);
            }
            if( opp.StageName == constants.OPPORTUNITY_IN_STIPULA && opp.Tipo_Firma__c  =='Firma Digitale' ){  
                if(opp.Tipo_di_opportunit__c !=constants.OPPORTUNITY_TIPO_FISCALE &&
                   opp.QuoteConLandingPage__c == opp.Active_Quotes__c){
                       opp.StageName= constants.OPPORTUNITY_FIRMA;
                       
                   }else if(opp.Tipo_di_opportunit__c ==constants.OPPORTUNITY_TIPO_FISCALE) {
                       String oppId = opp.Id;
                       Document__c doc = [SELECT id, Id_File__c,Url_Documento__c from Document__c where Quote__c In (SELECT ID FROM QUOTE WHERE OpportunityId =:oppId) and IDTipoDocumentoFormula__c ='SME_114' ];
                       if(doc.Url_Documento__c!= null&&doc.Id_File__c== null )
                           opp.StageName= 'Firma e Cessione';
                   }
               }
            if( opp.StageName == constants.OPPORTUNITY_IN_STIPULA && opp.Tipo_Firma__c  =='Firma Manuale' &&
            opp.DocumentoDaFirmareCount__c == opp.Active_Quotes__c){
                    if(opp.Tipo_di_opportunit__c ==constants.OPPORTUNITY_TIPO_FISCALE){
                        opp.StageName= 'Firma e Cessione';
                    }else{
                        opp.StageName= constants.OPPORTUNITY_FIRMA;
                    }
                }
    
            if(opp.Certificato_Notaio_Richiesto__c == 'Certificato Ko'){
                opp.StageName = 'Chiusa/Persa';
                opp.Motivazione_Causa_Lost__c = 'Stipula - Certificazione Notarile Bloccante';
            }
            if( (oldOpp.Motivazione_Causa_Lost__c <> opp.Motivazione_Causa_Lost__c) &&(opp.StageName == 'Chiusa/Persa')){
                moti.add(opp);
            }
            
            //Method will be executed when Opportunity stage change - Start
            if(oldOpp.StageName != opp.StageName){
                
                //this thing is done only with the actual requests if there are changes it should bo done with every stage separately
                if((opp.StageName == constants.OPPORTUNITY_COMPLETAMENTO_DOCUMENTI|| opp.StageName==constants.OPPORTUNITY_IN_PRE_DUE_DILIGENCE) && (oldOpp.StageName != opp.StageName) &&  oldOpp.StageName <>  constants.OPPORTUNITY_PEF_Pre_ISTRUTTORIA )
                {
                    listCheckCambioConsolidamentoDocumento.add(opp);
                }
                if(opp.StageName == constants.OPPORTUNITY_PEF_Pre_ISTRUTTORIA &&  (oldOpp.StageName != opp.StageName))
                {
                    listacheckCambioPEFPREISTRUTORIA.add(opp);
                }
                if(opp.StageName == constants.OPPORTUNITY_EROGATA && (oldOpp.StageName != opp.StageName) ) {
                    listCheckCambioDataErogata.add(opp);
                }
                if(opp.StageName == constants.OPPORTUNITY_IN_EROGAZIONE  &&  opp.Tipo_Linea_di_Credito__c == 'Mutuo' && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA){
                    listCheckCambioErogazione.add(opp.Id);
                }
                
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Pre-Analisi e Pricing' && opp.StageName == 'Due Diligence'){
                    listCheckPassareStageInDueDiligence.add(opp);
                }
                if(opp.Tipo_Linea_di_Credito__c =='Crediti Fiscali' && oldOpp.StageName == 'Pre-Analisi e Pricing' && (oldOpp.StageName != opp.StageName && opp.StageName == 'Chiusa/Persa')){
                    listCheckPassareStageInChiusaPersaDaPreAnalising.add(opp);
                }
                
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Pre-Due Diligence'  && opp.StageName == 'Pre-Analisi e Pricing'){
                    EsitoPropostaPricingPositivoList.add(opp);
                }
                
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Prima Visita' && opp.StageName == 'Pre-Due Diligence'){
                    notificationsStagePreDueDiligenceList.add(opp);
                }
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && (oldOpp.StageName == 'Pre-Due Diligence' &&  opp.StageName == 'Chiusa/Persa')){
                    EsitoPropostaPricingNegativoList.add(opp);
                }
                
                /*if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && (oldOpp.StageName == 'Pre-Analisi e Pricing' && opp.StageName == 'Due Diligence')){
                listNotificationsStageDueDiligence.add(opp);
                }*/
                
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Due Diligence' &&  opp.StageName == 'Completamento Documenti'){
                    CondizionePassaggioInCompletamentoDocumentiList.add(opp);
                }
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && (oldOpp.StageName != opp.StageName && opp.StageName == 'Chiusa/Persa') && oldOpp.StageName =='Due Diligence' ){
                    chiusaLostDueDiligenceList.add(opp);
                }
                
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName && opp.StageName == 'Completamento Documenti'){
                    notificationsStageCompletamentoDocumentiList.add(opp);
                }
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && (oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Firma e Cessione' && opp.StageName == 'In Erogazione')){
                    checkPassareInErogazioneList.add(opp);
                }
                /*if((opp.Tipo_Linea_di_Credito__c== 'Mutuo' ||  opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus')  && (oldOpp.StageName != opp.StageName && oldOpp.StageName == 'Firma' && opp.StageName == 'In Erogazione')){
                checkPassareInErogazioneList.add(opp);
            }*/
                if (opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && (oldOpp.StageName != opp.StageName && (oldOpp.StageName == 'Completamento Documenti' && opp.StageName == 'PEF Pre-Istruttoria') || (oldOpp.StageName == 'Firma e Cessione' && opp.StageName == 'In Erogazione'))){
                    mandatoryStageNameForVerifiedDocs.add(opp);
                }
                if ((opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.StageName != opp.StageName) && ((oldOpp.StageName == 'Prima Visita' && opp.StageName == 'Pre-Due Diligence') || (oldOpp.StageName =='Due Diligence' && opp.StageName == 'Completamento Documenti') || (oldOpp.StageName == 'Completamento Documenti' && opp.StageName == 'PEF Pre-Istruttoria') || (oldOpp.StageName == 'PEF Istruttoria' && opp.StageName == 'Deliberata'))){
                    mandatoryStageNameForUploadedDocs.add(opp);
                }
                else if ((opp.Tipo_Linea_di_Credito__c== 'Mutuo' ||  opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus') && oldOpp.StageName != opp.StageName && ((oldOpp.StageName == 'Prima Visita' && opp.StageName ==  'Completamento Documenti') || (oldOpp.StageName == 'Completamento Documenti' && opp.StageName == 'PEF Pre-Istruttoria') || (oldOpp.StageName == 'PEF Istruttoria' && opp.StageName == 'Deliberata'))){
                mandatoryStageNameForUploadedDocs.add(opp);                  
                }
                if ((opp.Tipo_Linea_di_Credito__c== 'Mutuo' ||  opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus') && oldOpp.StageName != opp.StageName && ((oldOpp.StageName == 'Completamento Documenti' && opp.StageName == 'PEF Pre-Istruttoria'))){
                    mandatoryStageNameForVerifiedDocs.add(opp);
                }
                if( opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus' && oldOpp.StageName != opp.StageName &&(oldOpp.StageName == 'Deliberata' && opp.StageName == 'In Erogazione')){
                    mandatoryStageNameForVerifiedDocs.add(opp);
                    mandatoryStageNameForUploadedDocs.add(opp);
                }
                if (oldOpp.StageName == 'Prima Visita' && oldOpp.StageName != opp.StageName && (opp.StageName == 'Completamento Documenti' || opp.StageName == 'Pre-Due Diligence')) {
                    listCheckCambioFaseSuccessivaPrimaVisita.add(opp);
                }
            }            
            //Method will be executed when Opportunity stage change - End
            
            //CREDITI
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.Esito_Due_Diligence__c != oldOpp.Esito_Due_Diligence__c && opp.Esito_Due_Diligence__c == 'Negativo'){
                listCheckCampoNoteEsitoNegativo.add(opp);
            }
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.Esito_Due_Diligence__c != oldOpp.Esito_Due_Diligence__c && (oldOpp.Esito_Due_Diligence__c == 'Red Flags' && opp.Esito_Due_Diligence__c == 'Red Flags Risolti')){
                listcheckCampoEsitoDueDiligencePositivoDaRedFlags.add(opp);
            }
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.Esito_Due_Diligence__c != oldOpp.Esito_Due_Diligence__c && opp.Esito_Due_Diligence__c == 'Red Flags'){
                listCheckCampoNoteEsitoRedFlags.add(opp);
            }
            if(opp.Note_Desospensione__c != oldOpp.Note_Desospensione__c && opp.Esito_Due_Diligence__c == 'Red Flags'){
                listCheckCampoEsitoValutazioneRedFlags.add(opp);
            }
            if(opp.Tipo_Linea_di_Credito__c =='Crediti Fiscali' &&
               (opp.Verifica_Report_Finale_Studio_Dominici__c != oldOpp.Verifica_Report_Finale_Studio_Dominici__c && (
                   opp.Verifica_Report_Finale_Studio_Dominici__c == 'Esito Positivo' ||  opp.Verifica_Report_Finale_Studio_Dominici__c == 'Esito Negativo'))){
                       listCheckCompletamentoVerificaReportFinale.add(opp);
                   }
            
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.Esito_Due_Diligence__c != oldopp.Esito_Due_Diligence__c && opp.Esito_Due_Diligence__c =='Red Flags' && opp.StageName == 'Pre-Analisi e Pricing'){
                listnotifyUser.add(opp);
            }
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && oldOpp.Esito_Proposta_Pricing__c != opp.Esito_Proposta_Pricing__c && opp.Esito_Proposta_Pricing__c <> null ){
                FieldEsitoPropostaPricingList.add(opp);
            }            
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.StageName == 'Pre-Analisi e Pricing' && oldOpp.Esito_Due_Diligence__c != opp.Esito_Due_Diligence__c && opp.Esito_Due_Diligence__c == 'Red Flags Risolti' ){
                listEsitoDueDiligenceRedFlagsConditions.add(opp);
            }
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.Importo_del_Credito__c != null && oldOpp.Importo_del_Credito__c != opp.Importo_del_Credito__c){
                opp.Amount = opp.Importo_del_Credito__c;
            }
            if(opp.Tipo_Linea_di_Credito__c== 'Mutuo' && oldOpp.Inside_Sales_di_riferimento__c != opp.Inside_Sales_di_riferimento__c && ( oldOpp.Inside_Sales_di_riferimento__c == usersMap.get(constants.USER_Commerciale1) || oldOpp.Inside_Sales_di_riferimento__c == usersMap.get(constants.USER_Commerciale2)) && (opp.Inside_Sales_di_riferimento__c == usersMap.get(constants.USER_Pintavalle)|| opp.Inside_Sales_di_riferimento__c == usersMap.get(constants.USER_Pintavalle))){
                opp.Sales_owner_opportunita__c = opp.Inside_Sales_di_riferimento__c;
            }
            
        }
    
        if(!listCheckCambioDataErogata.isEmpty()){
            OpportunityController.cambioDataChiusura(listCheckCambioDataErogata);            
        }
    
        if(!listacheckCambioPEFPREISTRUTORIA.isEmpty()){
            OpportunityController.checkCambioPEFPREISTRUTORIA(listacheckCambioPEFPREISTRUTORIA);
    
        }
        if(!listCheckCambioConsolidamentoDocumento.isEmpty()){
            OpportunityController.checkCambioConsolidamentoDocumento(listCheckCambioConsolidamentoDocumento);            
        }
        if(!listBackupTitolareeCanale.isempty()){
            OpportunityController.backupTitolareeCanale(listBackupTitolareeCanale);
        } 
        
        if(!moti.isempty()){
            OpportunityController.motivazioneLost(moti);
        }
        if(!listCheckCambioErogazione.isempty()){
            OpportunityController.checkInErogazione(listCheckCambioErogazione);
        }
    
        //Crediti
        if(!listCheckCampoNoteEsitoNegativo.isempty()){
            PreAnalisingePricingStageCrediti.checkCampoNoteEsitoNegativo(listCheckCampoNoteEsitoNegativo);
        }
        if(!listCheckCampoNoteEsitoRedFlags.isempty()){
            PreAnalisingePricingStageCrediti.checkCampoNoteEsitoRedFlags(listCheckCampoNoteEsitoRedFlags);
        }
        if(!listCheckCampoEsitoValutazioneRedFlags.isempty()){
            PreAnalisingePricingStageCrediti.checkCampoNoteEsitoRedFlags(listCheckCampoEsitoValutazioneRedFlags);
        }
        if(!listCheckCampoEsitoDueDiligencePositivoDaRedFlags.isempty()){
            PreAnalisingePricingStageCrediti.checkCampoEsitoDueDiligencePositivoDaRedFlags(listCheckCampoEsitoDueDiligencePositivoDaRedFlags);
        }
        /*if(!listCheckCampoEsitoDueDiligenceNegativoDaRedFlags.isempty()){
            PreAnalisingePricingStageCrediti.checkCampoNoteEsitoNegativo(listCheckCampoEsitoDueDiligenceNegativoDaRedFlags);
        }*/
        if(!listCheckPassareStageInDueDiligence.isempty()){
            PreAnalisingePricingStageCrediti.checkPassareStageInDueDiligence(listCheckPassareStageInDueDiligence);
        }
        if(!listCheckPassareStageInChiusaPersaDaPreAnalising.isempty()){
            PreAnalisingePricingStageCrediti.checkPassareStageInChiusaPersaDaPreAnalising(listCheckPassareStageInChiusaPersaDaPreAnalising);
        }
        if(!listnotifyUser.isempty()){
            PreAnalisingePricingStageCrediti.notifyUser(listnotifyUser);
        }
    
    
        if(!FieldEsitoPropostaPricingList.isempty()){
            PreAnalisingePricingStageCrediti.FieldEsitoPropostaPricing(FieldEsitoPropostaPricingList);
        }
    
        if(!EsitoPropostaPricingPositivoList.isempty()){
            PreDueDiligenceCreditiCondizioni.EsitoPropostaPricingPositivo(EsitoPropostaPricingPositivoList);
    
        }
        if(!EsitoPropostaPricingNegativoList.isempty()){
            PreDueDiligenceCreditiCondizioni.EsitoPropostaPricingNegativo(EsitoPropostaPricingNegativoList);
        }
      /*  if(!listNotificationsStageDueDiligence.isempty()){
            DueDiligenceStageCrediti.notificationsStageDueDiligence(listNotificationsStageDueDiligence);
        }*/
        /*if(!notificationsStagePreDueDiligenceList.isempty()){
            PreDueDiligenceCreditiCondizioni.notificationsStagePreDueDiligence(notificationsStagePreDueDiligenceList);
        }*/
        if(!CondizionePassaggioInCompletamentoDocumentiList.isempty()){
                DueDiligenceStageCrediti.CondizionePassaggioInCompletamentoDocumenti(CondizionePassaggioInCompletamentoDocumentiList);
        }
        if(!chiusaLostDueDiligenceList.isempty()){
            DueDiligenceStageCrediti.chiusaLostDueDiligence(chiusaLostDueDiligenceList);
        }
            if(!listCheckCompletamentoVerificaReportFinale.isempty()){
                DueDiligenceStageCrediti.CheckCompletamentoVerificaReportFinale(listCheckCompletamentoVerificaReportFinale);
        }
       	if(!notificationsStageCompletamentoDocumentiList.isempty()){
            CompletamentoDocumentiCrediti.notificationsStageCompletamentoDocumenti(notificationsStageCompletamentoDocumentiList);
        }
        if(!listEsitoDueDiligenceRedFlagsConditions.isempty()){
            DueDiligenceStageCrediti.EsitoDueDiligenceRedFlagsConditions(listEsitoDueDiligenceRedFlagsConditions);
        }
        if(!checkPassareInErogazioneList.isempty()){
            OpportunityController.checkPassareInErogazione(checkPassareInErogazioneList);
        }
        if(!oppListInqury.isempty()){
            NotificaStagePefPreIstruttoria.notificationsPefPreIstrError(oppListInqury);
        }
        if(!mandatoryStageNameForVerifiedDocs.isempty()){
            OpportunityController.CheckIfMandatoryDocTypesAreVerifiedForStage(mandatoryStageNameForVerifiedDocs);
        }
        if(!mandatoryStageNameForUploadedDocs.isempty()){
            OpportunityController.CheckIfMandatoryDocTypesAreUploadedForStage(mandatoryStageNameForUploadedDocs);
        }
        if (!listCheckCambioFaseSuccessivaPrimaVisita.isEmpty()) {
            OpportunityController.checkPassaggioDaPrimaVisitaVersoFaseSuccessiva(listCheckCambioFaseSuccessivaPrimaVisita);
        }
   
        System.debug('OpportunityController.beforeUpdate trigger - End');
    }
    
    public override void afterUpdate() {
        List<Id> changeRecLending = new List<Id>();
        List<Id> changeRecRO = new List<Id>();
        List<Opportunity> changeOpp = new List<Opportunity>();
        List<Id> Listsospensione= new List<Id>();
        
        List<Opportunity> listupdateOplonAnalysis = new List<Opportunity>();
        List<Opportunity> listChiusaFase = new List<Opportunity>();
        List<Opportunity> listErrogataFase = new List<Opportunity>();
        List<Opportunity> listCreateInquiry = new List<Opportunity>();
        List<Opportunity> madrenList = new List<Opportunity>();
        
        Set<Id> listaDataScadenzaGaranzia = new Set<Id>();
        List<Id> listCheckCambioStipula = new List<Id>();
        List<Id> listCheckCambioConsolidamentoDocumento = new List<Id>();
        List<Id> listPrimoContatto = new List<Id>();
        List<Id> listPrimaVisita = new List<Id>();
        List<Id> listCheckCambioFirma = new List<Id>();
        List<Id> listCheckCambioDeliberata = new List<Id>();
        List<Id> listCheckCambioErogazione = new List<Id>();
        List<Id> listChiusuraFinale = new List<Id>();
        List<Id> listPEFylli = new List<Id>();
        List<Id> listOppJoYlli = new List<Id>();
        List<Id> readonlyCreditiOppId = new List<Id>();
        List<Id> readonlyCreditiOppIdChiusa = new List<Id>();
        List<Opportunity> listOfOppForSharing = new List<Opportunity>();
        
        //Creating Storico Fase records for Opportunity stage changes
        BP_StoricoFaseManager.createStoricoFaseRecOnOppUpdate( (Map<Id,Opportunity>) Trigger.oldMap,Trigger.new);
    
    
        for(Opportunity opp: (List<Opportunity>)Trigger.new) {
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.Id);
    
            if (opp.StageName == constants.OPPORTUNITY_PRIMO_CONTATTO && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listPrimoContatto.add(opp.Id);
            }
    
            if (opp.StageName == constants.OPPORTUNITY_PRIMA_VISITA && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listPrimaVisita.add(opp.Id);
            }
    
            if (opp.StageName == constants.OPPORTUNITY_COMPLETAMENTO_DOCUMENTI && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listCheckCambioConsolidamentoDocumento.add(opp.Id);
            }
    
            if (opp.StageName == constants.OPPORTUNITY_DELIBERATA && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listCheckCambioDeliberata.add(opp.Id);
            }
    
            if(opp.StageName == constants.OPPORTUNITY_IN_STIPULA  && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listCheckCambioStipula.add(opp.Id);
            }
    
            if (opp.StageName == constants.OPPORTUNITY_FIRMA  && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listCheckCambioFirma.add(opp.Id);
            }
    
            if (opp.StageName == constants.OPPORTUNITY_IN_EROGAZIONE  && (oldOpp.StageName != opp.StageName) && oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listCheckCambioErogazione.add(opp.Id);
            }
            
            if (oldOpp.StageName != opp.StageName && ( opp.StageName != constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA ) && oldOpp.StageName != constants.OPPORTUNITY_CHIUSA_PERSA) {
                System.debug('entra qui doc count ' );
                changeOpp.add(opp);
            }
    
            if (opp.Numero_Pratica__c != null && oldOpp.Numero_Pratica__c == null) {
                listupdateOplonAnalysis.add(opp);
            }
            
            if ((opp.StageName == constants.OPPORTUNITY_IN_EROGAZIONE && oldOpp.StageName != opp.StageName) || (opp.StageName == constants.OPPORTUNITY_DELIBERATA && oldOpp.StageName != opp.StageName)) {
                listaDataScadenzaGaranzia.add(opp.Id);
            }
            
            if (opp.StageName == constants.OPPORTUNITY_EROGATA && oldOpp.StageName != opp.StageName &&  oldOpp.StageName <> constants.OPPORTUNITY_CHIUSA_PERSA) {
                listErrogataFase.add(opp);
            }
            
            if(opp.StageName == constants.OPPORTUNITY_CHIUSA_PERSA &&  oldOpp.StageName != opp.StageName) {
                listChiusaFase.add(opp);
                readonlyCreditiOppIdChiusa.add(opp.Id);
            }
            
            if (oldOpp.StageName == constants.OPPORTUNITY_COMPLETAMENTO_DOCUMENTI && opp.StageName == constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA) {
                listCreateInquiry.add(opp);
                readonlyCreditiOppId.add(opp.Id);
            }
    
            if (opp.Errore_Chuisura_Opportunita__c == 'SUCCESS' &&  oldOpp.Errore_Chuisura_Opportunita__c != opp.Errore_Chuisura_Opportunita__c) {
                listChiusuraFinale.add(opp.Id);
            }
    
            if (opp.Is_Suspended__c == true &&  oldOpp.Is_Suspended__c != opp.Is_Suspended__c) {
                Listsospensione.add(opp.Id);
            }
            
            if (oldOpp.Is_Suspended__c != opp.Is_Suspended__c && (opp.StageName == constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA || opp.StageName == constants.OPPORTUNITY_PEF_ISTRUTTORIA) && opp.Is_Suspended__c == true) {
                changeRecLending.add(opp.Id);
            }
    
            if (oldOpp.Is_Suspended__c != opp.Is_Suspended__c && (opp.StageName == constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA || opp.StageName == constants.OPPORTUNITY_PEF_ISTRUTTORIA) && opp.Is_Suspended__c == false) {
                changeRecRO.add(opp.Id);
            }
    
            if (oldOpp.Resultati_Pef_Flusso__c != opp.Resultati_Pef_Flusso__c && opp.Resultati_Pef_Flusso__c=='OK' && opp.StageName == constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA ) {
                listPEFylli.add(opp.Id);
            }
    
            if (oldOpp.Resultati_Pef_Flusso__c != opp.Resultati_Pef_Flusso__c && opp.Resultati_Pef_Flusso__c=='KO') {
                System.debug('acusating me');
                madrenList.add(opp);
            }
            if( (! String.isEmpty(opp.Sales_owner_opportunita__c)) && (oldOpp.Sales_owner_opportunita__c != opp.Sales_owner_opportunita__c) ){
                listOfOppForSharing.add(opp);
            }

        }
        
        if (!listPrimoContatto.isEmpty()) {
            OpportunityController.LendingRecordType(listPrimoContatto);
        }
    
        if (!listPrimaVisita.isEmpty()) {
            OpportunityController.LendingRecordType(listPrimaVisita);
        }
    
        if (!listCheckCambioConsolidamentoDocumento.isEmpty()) {
            OpportunityController.LendingRecordType(listCheckCambioConsolidamentoDocumento);            
        }
    
        if (!listCheckCambioDeliberata.isEmpty()){
            fileUploaderController.firstRun = false;
            OpportunityController.respintiOpportunity(listCheckCambioDeliberata);
        }
    
        if (!listCheckCambioStipula.isEmpty()) {
            OpportunityController.ReadOnlyRecordType(listCheckCambioStipula);
        }
    
        if (!listCheckCambioFirma.isEmpty()) {
            OpportunityController.ReadOnlyRecordType(listCheckCambioFirma);
        }
        if (!listCheckCambioErogazione.isEmpty()){
            OpportunityController.ReadOnlyRecordType(listCheckCambioErogazione);
        }
    
        if (!changeOpp.isEmpty() && fileUploaderController.firstRun) {
            fileUploaderController.firstRun =false;
            	fileUploaderController.UpdateDocCountAfterStageChange(changeOpp);

        }
        
        if (!listaDataScadenzaGaranzia.isEmpty()) {
            OpportunityController.dataScadenzaGaranzia(listaDataScadenzaGaranzia);            
        }
    
        if (!listChiusaFase.isEmpty()) {
            OpportunityController.ChiusaFase(listChiusaFase, (Map<Id, Opportunity>) Trigger.oldMap);
        }
    
        if (!listErrogataFase.isEmpty()) {
            OpportunityController.ErrogataFase(listErrogataFase, (Map<Id, Opportunity>) Trigger.oldMap);
        }
    
        if (!listupdateOplonAnalysis.isEmpty()) {
            OpportunityController.updateOplonAnalysis(listupdateOplonAnalysis, (Map<Id, Opportunity>) Trigger.oldMap);
        }
        
        if (!listCreateInquiry.isEmpty()) {
            OpportunityController.createInquiry(listCreateInquiry);
            // OpportunityController.ReadOnlyRecordType(listCreateInquiry);
        }
    
        if (!listChiusuraFinale.isEmpty()) {
            OpportunityController.ChiusuraFinale(listChiusuraFinale);
        }
    
        if (!changeRecLending.isEmpty()) {
            OpportunityController.LendingRecordType(changeRecLending);
        }
    
        if (!changeRecRO.isEmpty()) {
            OpportunityController.ReadOnlyRecordType(changeRecRO);
        }
    
        if (!listPEFylli.isEmpty()) {
            OpportunityController.ReadOnlyRecordType(listPEFylli);
        }
    
        if (!madrenList.isEmpty()) {
            OpportunityController.ritornoInCompletamento(madrenList);
        }
        if(!listOppJoYlli.isEmpty()) {
            OpportunityController.switchPhase(listOppJoYlli);
            OpportunityController.ReadOnlyRecordType(listOppJoYlli);
        }
        if(!readonlyCreditiOppId.isEmpty()) {
            OpportunityController.ReadOnlyRecordTypeForCrediti(readonlyCreditiOppId);
        }
        if(!readonlyCreditiOppIdChiusa.isEmpty()) {
            OpportunityController.ReadOnlyRecordTypeForCrediti(readonlyCreditiOppIdChiusa);
        }
        if (!listOfOppForSharing.isEmpty()) {
            BP_OpportunitySharingManager.OppEditForSalesOwner(listOfOppForSharing);
        }
    
    }
    
    
    public static void ritornoInCompletamento(List<Opportunity> newOppList){
    
        List<Opportunity> opphamomo = new List<Opportunity>();
        for(Opportunity opp : newOppList ) {
            Opportunity oppi = new Opportunity();
            oppi.Id= opp.Id;
            oppi.StageName = constants.OPPORTUNITY_COMPLETAMENTO_DOCUMENTI;  
            oppi.Resultati_Pef_Flusso__c ='';
            
            opphamomo.add(oppi);
        }
        update  opphamomo   ;
    }

    public static void checkPassaggioDaPrimaVisitaVersoFaseSuccessiva(List<Opportunity> newOppList) {
        for (Opportunity o: newOppList) {
            if (o.Consegna_Documenti__c == false) {
                o.addError('Per procedere alla fase successiva occorre confermare la consegna al potenziale cliente dei documenti ai fini della Trasparenza: valorizza il campo "Consegna documenti di Trasparenza"');
            }
        }
    }
    
    public static void cambioDataChiusura(List<Opportunity> cambioDataOpp) {
        for (Opportunity op: [SELECT Id, CloseDate, Data_Erogazione__c FROM Opportunity WHERE Id IN : cambioDataOpp]) {
            op.CloseDate = op.Data_Erogazione__c;
            System.debug(op.id + ' Closedate -> Data di erogazione');
        }
    }
    
    public static void checkNewOppCloseDate(List<Opportunity> newOpp) {
        for (Opportunity o: newOpp) {
            if ((o.Tipo_Linea_di_Credito__c == 'Mutuo' || o.Tipo_Linea_di_Credito__c == 'Progetto Easy Plus') && o.CloseDate < Date.today().addDays(60)) {
                o.CloseDate = Date.today().addDays(60);
            }
        }
    }
    
    public static void dataScadenzaGaranzia(Set<Id> newOppList){
        List<Garanzia__c> garanziaUpdate = new List<Garanzia__c>();
        
        for (Garanzia__c garanzia : [SELECT Id, Stato_Garanzia__c, Tipo_di_Garanzia__c, Opportunit__r.Data_fine_mutuo_Formula__c, Linea_di_Credito__r.Data_fine_mutuo_Formula__c FROM Garanzia__c WHERE Opportunit__c IN :newOppList]) {
            
            if (garanzia.Stato_Garanzia__c <> 'Chiusa' && garanzia.Tipo_di_Garanzia__c == 'Fidejussione') {
                Garanzia__c g = new Garanzia__c();
                g.Id = garanzia.Id;
                g.Expiration_Date__c = garanzia.Linea_di_Credito__r.Data_fine_mutuo_Formula__c;
                garanziaUpdate.add(g);
            }
        }        
        update garanziaUpdate;
    }
    
    public static void ChiusaFase(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        System.debug('Chiusa fase method entered?');
        List<Id> oppIdFinal = new List<Id>();
        List<String> profileIds = new List<String>();
        Boolean notIntegrator=false;
        if(integratorProfileList.isEmpty()){
            integratorProfileList = [SELECT Id FROM Profile WHERE Name ='Integrator'];
        }
        for(Profile pr : integratorProfileList){
            profileIds.add(pr.Id);
        }
        String currentProfileId = loggedInUser.ProfileId;
        System.debug('Chiusa fase UserInfo.getProfileId() ' + UserInfo.getProfileId());
        if(!profileIds.contains(currentProfileId)){
            notIntegrator=true;
        }
    
        Set<Id> IdOpp = new Set<Id>();
        List<Quote> quoteUpdate = new List<Quote>();
        Set<Id> idacc = new Set<Id>();
        
        String serializeCredential;
        List<Account> accounts = new List<Account>();
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        System.debug('Metadata: ' + metadata);
        System.debug('Metadata1: ' + metadata[0].Status__c);
        
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        
        serializeCredential = JSON.serialize(elevaCredentials, true);
        
        for(Opportunity opp : newOppList){
            IdOpp.add(opp.Id);
            idacc.add(opp.AccountId);
            
        }
        System.debug('Chiusa fase IdOpp?' + IdOpp);
        System.debug('Chiusa fase idacc?' + idacc);
        accounts = [select id from Account where id IN :idacc];
        System.debug('Chiusa fase accounts?' + accounts);
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id, Name ,userMail__c
                                                            FROM Account where Id in :idacc]);
    
        System.debug('Chiusa fase AccountMap ' + AccountMap);
        
        for(Opportunity oppi : newOppList ) {
            // Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(oppi.id);
            
            Opportunity oldOpp = oldOppMap.get(oppi.id);
            System.debug('Chiusa fase oldOpp.StageName? ' + oldOpp.StageName);
            Account acc = AccountMap.get(oppi.AccountId);
            System.debug('Chiusa fase oppiNcg' + oppi.Numero_Pratica__c);
            System.debug('Chiusa fase oppiID' + oppi.Id);
            System.debug('Chiusa fase oppiMotivazioneLost' + oppi.Motivazione_Causa_Lost__c);
            System.debug('Chiusa fase oppiMail' + acc.userMail__c);
            System.debug('acc map ' + acc);
            System.debug('notIntegrator ' + notIntegrator);
            if(acc!=null){
                if(metadata[0].Status__c == 'Active'
                && notIntegrator
                && oldOpp.StageName<>constants.OPPORTUNITY_PEF_PRE_ISTRUTTORIA 
                && oldOpp.StageName<>constants.OPPORTUNITY_PEF_ISTRUTTORIA){
                    System.debug('If Eleva ');
                    ElevaRestApiController.chuisuraOpportunitaSF(oppi.Numero_Pratica__c,oppi.Id,oppi.Motivazione_Causa_Lost__c,acc.userMail__c,oldOpp.StageName,serializeCredential);
                }
            }
            
            if(notIntegrator==false && ( oldOpp.StageName=='PEF Pre-Istruttoria' || oldOpp.StageName=='PEF Istruttoria'))  {
                oppIdFinal.add(oppi.Id);
            }
        }
        System.debug('Chiusa fase oppIdFinal ' + oppIdFinal);
        
        if(!oppIdFinal.isEmpty()){
            OpportunityController.ChiusuraFinale(oppIdFinal);
        }
    }
    
    public static void ErrogataFase(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        List<Opportunity> oppUpdate = new List<Opportunity>();
        List<Garanzia__c> updateGaranzia = new List<Garanzia__c>();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LENDING_RO).getRecordTypeId();   
        String recordTypeEasy = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_EASY_RO).getRecordTypeId(); 
        String recordTypeLineaId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LINEA_RO).getRecordTypeId();
        
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_LENDING_RO];
        List<RecordType> recordTypePlus=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_EASY_RO];
        List<RecordType> recordTypeLinea=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_LINEA_RO];
        
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }
        if(recordTypePlus.size()>0){
            recordTypeEasy=recordTypePlus.get(0).Id;
        }
        if(recordTypeLinea.size()>0){
            recordTypeLineaId=recordTypeLinea.get(0).Id;
        }*/
        
        Set<Id> IdOpp = new Set<Id>();
        List<Quote> quoteUpdate = new List<Quote>();
        List<Id> AccountId = new List<Id>();
        List<Account> accUpdate = new List<Account>();
        
        for(Opportunity opp : newOppList){   
            Opportunity oppi = new Opportunity();
            oppi.Id= opp.Id;
            if(recordTypeId != '' && opp.Tipo_Linea_di_Credito__c == 'Mutuo') {
                oppi.RecordTypeId = recordTypeId;
            }
            else if(recordTypeEasy != '' && opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                oppi.RecordTypeId = recordTypeEasy;
            }
            oppUpdate.add(oppi);
            IdOpp.add(opp.Id);
            AccountId.add(opp.AccountId);
        }
        OpportunityController.bypassTrigger =true;
        update oppUpdate;
        OpportunityController.bypassTrigger =false;
        
        for(Quote q : [Select Id from Quote where OpportunityId IN : IdOpp]){
            Quote b = new Quote();
            b.Id =q.Id;
            b.Status = 'Chiusa';
            b.RecordTypeId=recordTypeLineaId;
            quoteUpdate.add(b);
        }
        update quoteUpdate;
        
        for(Account acc : [Select Id ,Tipo_Anagrafica__c from Account where Id IN: AccountId ]){
            
            Account a = new Account();
            a.Id=acc.Id;
            a.Tipo_Anagrafica__c = 'Cliente';
            accUpdate.add(a);
        }
        update accUpdate;
        
        for(Garanzia__c g : [Select Id,Record_Type_Only__c from Garanzia__c where Opportunit__c IN : IdOpp ]){
            Garanzia__c a = new Garanzia__c();
            a.Id = g.Id;
            a.RecordTypeId =g.Record_Type_Only__c;
            updateGaranzia.add(a);
        }
        update updateGaranzia;
    }
    
    /* 
    * aggiorna analisi id oplon sull'account dopo che è stato aggiornato sull'opportunity
    * ma perchè?*/
    public static void updateOplonAnalysis(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        List<Account> listaAccount = new List<Account>();
        List<Id> listIds = new List<Id>();
        for (Opportunity childObj : newOppList) {
            listIds.add(childObj.AccountId);
        } 
        
        Map<id,Account> mapAccounts=new Map<id,Account>([SELECT Id,Analysis_Id_Oplon__c FROM Account where Id IN :listIds]); 
        
        for(Opportunity opp : newOppList ) {
            if(mapAccounts.get(opp.AccountId).Analysis_Id_Oplon__c == null){
                listaAccount.add(new Account(
                    Id = opp.AccountId,
                    Analysis_Id_Oplon__c = opp.Numero_Pratica__c
                ));
            }
        }
        update listaAccount;
    }
    
    public static void AfterInsert(List<Opportunity> newOpp) {
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Quote> listaQuote = new List<Quote>();
        List<Account> accounts = new List<Account>();
        List<Opportunity> oppoList = new List<Opportunity>();
        List<Opportunity> listOfOppForSharing = new List<Opportunity>();
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        List<Switch__mdt> metadata = [SELECT Id, DeveloperName, Status__c FROM Switch__mdt WHERE DeveloperName = 'NDG_Eleva'];
        List<FieldMapping__mdt> metadataCase = [
                SELECT BP_Destination_Field__c,
                        BP_Destination_Object__c,
                        BP_Category__c,
                        BP_Source_Field__c,
                        BP_Source_Object__c,
                        BP_Value__c
                FROM FieldMapping__mdt
                WHERE BP_Category__c = 'Quote Creation From Opp Trigger'
        ];
        String serializeCredential = JSON.serialize(elevaCredentials, true);
    
        for (Opportunity opp : newOpp) {
            Quote qt = new Quote();
            oppIdSet.add(opp.Id);
            accountIdSet.add(opp.AccountId);
    
            for (FieldMapping__mdt fldmap : metadataCase) {
                qt.put(fldmap.BP_Destination_Field__c, opp.get(fldmap.BP_Source_Field__c));
            }
    
            listaQuote.add(qt);
            if( ! String.isEmpty(opp.Sales_owner_opportunita__c)){
                listOfOppForSharing.add(opp);
            }
        }
        List<Opportunity> oppoList2 = [ SELECT Numero_Pratica__c,Id, account.Anagrafica_Id_Oplon__c,account.Count_of_Opportunities__c, Account.Analysis_Id_Oplon__c,
        account.userMail__c from Opportunity where id IN :oppIdSet];
        insert listaQuote;
    
        for (String accountId : accountIdSet) {
            Account acc = new Account(Id = accountId);
            acc.erogazione_dei_servizi__c = null;
            acc.Marketing_Banca__c = null;
            acc.Profilazione_Banca__c = null;
            acc.Valutazione_Qualit_Servizio__c = null;
            acc.Ricerche_di_Mercato__c = null;
            acc.Dati_Particolari__c = 'NO';
            acc.Consenso_Sic__c = 'NO';
            acc.Privacy__c = false;
            accounts.add(acc);
        }
    
        AccountsController.bypassTrigger = true;
        update accounts;
        AccountsController.bypassTrigger = false;
    
        oppoList = setInitialOppMandatoryDocCounter(oppIdSet);
        for (Opportunity opp : oppoList2) {
            if (opp.Account.Analysis_Id_Oplon__c == null || (opp.Account.Count_of_Opportunities__c >= 1 && opp.Numero_Pratica__c == null) ) {
                if (metadata[0].Status__c == 'Active') {
                    ElevaRestApiController.newOpportunityAnalysis(opp.Account.userMail__c, opp.Account.Anagrafica_Id_Oplon__c, opp.Id, serializeCredential);
                }
    
            }
        }
        if (!listOfOppForSharing.isEmpty()) {
            BP_OpportunitySharingManager.OppEditForSalesOwner(listOfOppForSharing);
        }
    }
    
    public static void BeforeInsert(List<Opportunity> newOppList){    
        List<String> codiceProvinca = new List<String>{'BL', 'BZ', 'GO', 'PD', 'PN', 'RO', 'TN', 'TV', 'TS', 'UD', 'VE', 'VR', 'VI'};
        List<String> accProvinca = new List<String>{'AV', 'BN', 'CE', 'CH', 'FR', 'AQ', 'LT', 'NA', 'PG', 'PE', 'RI', 'RM', 'SA', 'TE', 'TR', 'VT'};
            
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LENDING).getRecordTypeId();
        String recordTypeEasy = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_EASY).getRecordTypeId();       
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_LENDING];
        List<RecordType> recordTypePlus=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_EASY];
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }
        if(recordTypePlus.size()>0){
            recordTypeEasy=recordTypePlus.get(0).Id;    
        }*/
        
        list<Id> AccountList = new list<String>();
        
        if(usersMap.isEmpty()){
            usersMap = getUsersMap();
        }
        
        for (Opportunity newOpp : newOppList)
        { 
            AccountList.add(newOpp.AccountId);
    
        }
        
        Map<Id, Account> AccountMap = new Map<Id, Account>([
                SELECT Id, Name, Count_of_Opportunities__c, Scenario__c, Opp_Easy_Plus__c, Titolare_Partner__c, Sales_Crediti_Fiscali__c, Opp_Easy_Plus_Active__c, Inside_Sales_di_riferimento__c, Analysis_Id_Oplon__c, Sigla_Provincia__c, Titolare_Anagrafica__c
    
                FROM Account
                WHERE Id IN :AccountList
        ]);
        
        String newNameOpp ;
        
        List<Account> updateAccount = new List<Account>();
        
        for (Opportunity newOpp : newOppList)
        {
            Account acc = AccountMap.get(newOpp.AccountId);
            //Change for crediti we couldn't create opp
            if(acc!=null){
                if((newOpp.Tipo_Linea_di_Credito__c =='Progetto EasyPlus' || acc.Opp_Easy_Plus__c >=1) && newOpp.Tipo_Linea_di_Credito__c != 'Crediti Fiscali')
                {
                    if(acc.Opp_Easy_Plus_Active__c + newOpp.Ammontare_Iniziale__c > 300000){
                        
                        if(bypassUserAccess)
                        {	
                            //newOpp.AddError('Non puoi creare una Linea di Credito Easy Plus, se lammontare totale di tutte le opportunità ancora aperte con le rispettive Linee di Credito, supera i 300.000 euro');
                        }
                    }
                }
     		//Assegnazione Sales Owner Oppty
             if(acc.Count_of_Opportunities__c == 0 && (newOpp.Tipo_Linea_di_Credito__c == 'Mutuo')){
                    newOpp.Sales_owner_opportunita__c = acc.Inside_Sales_di_riferimento__c;
                }else if(acc.Count_of_Opportunities__c == 0 && (newOpp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus')){
                    newOpp.Sales_owner_opportunita__c = userFidimed;
                } else if (acc.Count_of_Opportunities__c > 0 && acc.Scenario__c == 'C' && newOpp.Tipo_Linea_di_Credito__c == 'Mutuo'){
                    newOpp.Sales_owner_opportunita__c = acc.Inside_Sales_di_riferimento__c;
                }
                else if (acc.Count_of_Opportunities__c > 0 && acc.Scenario__c == 'C' && newOpp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                    newOpp.Sales_owner_opportunita__c = userFidimed;
                }
                else if((acc.Count_of_Opportunities__c > 0 && acc.Scenario__c == 'C' && newOpp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali') ) {
                newOpp.Sales_owner_opportunita__c = acc.Sales_Crediti_Fiscali__c;
                }
                
                else if(acc.Count_of_Opportunities__c == 0 && newOpp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali') {
                    newOpp.Sales_owner_opportunita__c = acc.Sales_Crediti_Fiscali__c;
                }
                else if(acc.Count_of_Opportunities__c > 0 && (acc.Scenario__c == 'A' || acc.Scenario__c == 'B')) {
                    newOpp.Sales_owner_opportunita__c = acc.Sales_Crediti_Fiscali__c;
                }
                
                String emri;
                if(acc.Name.length() > 118){
                    emri= acc.Name.subString(0,118);
                }
                else{
                    emri = acc.Name;
                }
                newNameOpp = emri + ' ' + (acc.Count_of_Opportunities__c +1);
                newOpp.Name = newNameOpp;
                if(acc.Count_of_Opportunities__c == 0)
                    newOpp.Numero_Pratica__c = acc.Analysis_Id_Oplon__c;
            }
            
            newOpp.Linea_di_Credito_in_Mesi__c = 0;
            newOpp.Titolare_Partner__c=acc.Titolare_Partner__c;
    
    
            if(newOpp.Amount != null){
                newOpp.Ammontare_in_lettere__c = AmmontareInLettere.CurrencyToWordsFormat(newOpp.Amount);
            }
    
            if(newOpp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && newOpp.Importo_del_Credito__c != null){
                newOpp.Amount = newOpp.Importo_del_Credito__c;
                } 
    
            if(newOpp.Importo_commissione_FdG__c != null){
                newOpp.Importo_Commissione_FdG_in_Lettere__c = AmmontareInLettere.CurrencyToWordsFormat(newOpp.Importo_commissione_FdG__c);
            }
            if(newOpp.Tipo_Linea_di_Credito__c == 'Mutuo') {
               /* if(newOpp.Ammontare_Iniziale__c <= 800000 && accProvinca.contains(AccountMap.get(newOpp.AccountId).Sigla_Provincia__c)){
                    newOpp.Inside_Sales_di_Riferimento__c = usersMap.get(constants.USER_Pintavalle);
                    newOpp.Sales_owner_opportunita__c = usersMap.get(constants.USER_Pintavalle);
                    Account ac = new Account();
                    ac.Id = newOpp.AccountId;
                    ac.Inside_Sales_di_riferimento__c = usersMap.get(constants.USER_Pintavalle);
                    updateAccount.add(ac);
                } else if(newOpp.Ammontare_Iniziale__c <= 800000 && codiceProvinca.contains(AccountMap.get(newOpp.AccountId).Sigla_Provincia__c)){
                    newOpp.Inside_Sales_di_Riferimento__c = usersMap.get(constants.USER_PORTESANI);
                    newOpp.Sales_owner_opportunita__c = usersMap.get(constants.USER_PORTESANI);
                    Account ac = new Account();
                    ac.Id = newOpp.AccountId;
                    ac.Inside_Sales_di_riferimento__c = usersMap.get(constants.USER_PORTESANI);
                    updateAccount.add(ac);
                
                }else{*/
                    newOpp.Inside_Sales_di_Riferimento__c = AccountMap.get(newOpp.AccountId).Inside_Sales_di_riferimento__c;
                //}
            }else if(newOpp.Tipo_Linea_di_Credito__c=='Progetto EasyPlus'){
                newOpp.Inside_Sales_di_Riferimento__c = userFidimed;
            } else {
                    newOpp.Inside_Sales_di_Riferimento__c = AccountMap.get(newOpp.AccountId).Inside_Sales_di_riferimento__c;
                }
                   
            if (recordTypeId != '' && newOpp.Tipo_Linea_di_Credito__c == 'Mutuo') {
                newOpp.RecordTypeId = recordTypeId;
            } else if(recordTypeEasy != '' && newOpp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                newOpp.RecordTypeId = recordTypeEasy;
                //TO FUCKING CHANGE THE NEXT ROWS FOR CREDITI FISCALI RECORDtYPE
            }
            /*else if (newOpp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
                newOpp.RecordTypeId = '0121x000002X8i0AAC';
                //Crediti fiscali fix assolutamente da cambiare solo per demo di domani
            }*/
            newOpp.Sales_Crediti_Fiscali__c = AccountMap.get(newOpp.AccountId).Sales_Crediti_Fiscali__c;
        }
        update updateAccount;
    }
    
    
    // fluso 5.1
    public static void createInquiry(List<Opportunity> toBeProcessed) {
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        
        
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        serializeCredential = JSON.serialize(elevaCredentials, true);
        
        String userMail;
        Map<Id, Map<String, List<Id>>> oppMapFinal = new Map<Id, Map<String, List<Id>>>();    
        Map<Id, List<Id>> mapAccount = new Map<Id, List<Id>>();        
        Map<Id, List<Id>> mapQuote = new Map<Id, List<Id>>();        
        Map<Id, List<Id>> mapContact1 = new Map<Id, List<Id>>();        
        Map<Id, List<Id>> mapContact2 = new Map<Id, List<Id>>();        
        
        Set<Id> IdOpp = new Set<Id>();
        Set<Id> IdAccount = new Set<Id>();
        Set<Id> idCointestazione = new Set<Id>();
        
        for(Opportunity opp : toBeProcessed){
            IdOpp.add(opp.Id);
            IdAccount.add(opp.AccountId);            
        }
    
        for(Opportunity o : [Select Id, (Select Id from Quotes where Status<>'Annullata' ) from Opportunity where Id IN : IdOpp ]){
            List<Id> IdQuote = new List<Id>();
            for(Quote q : o.Quotes){
                IdQuote.add(q.Id);
            }
            mapQuote.put(o.Id,IdQuote);
        }
        
        List<Garanzia__c> listGaranzia = [Select Id,Opportunit__c,Cointestazione__c,(Select Id,Persona_Fisica__r.NDG__c,Persona_Fisica__r.Id,Persona_Giuridica__r.Id from Fidejussioni__r) from Garanzia__c where  Opportunit__c IN :IdOpp   and Tipo_di_Garanzia__c ='Fidejussione' and Linea_di_Credito__r.Status <>'Annullata'  ];
        Set<Id> CointestazioneIdList = new Set<Id>();
        for(Garanzia__c  n : listGaranzia){
            if(n.Cointestazione__c !=null){
                CointestazioneIdList.add(n.Cointestazione__c);
            }
        }
    
        List<Cointestazione__c> ListCoinstazioneFull =[Select id, (Select Id, Name, Persona_Fisica__r.Id,Persona_Fisica__r.NDG__c,Persona_Giuridica__r.Id from Fidejussioni__r) from Cointestazione__c where Id IN : CointestazioneIdList];
        Map<Id, List<Fidejussione__c>> MapCointestazione = new Map<Id, List<Fidejussione__c>>();
        
        for(Cointestazione__c k : ListCoinstazioneFull){
            List<Fidejussione__c> nono = new List<Fidejussione__c>();
            nono = k.Fidejussioni__r;
            MapCointestazione.put(k.Id, nono);
        }
    
        for(Opportunity oppi :toBeProcessed ){
            Boolean blockOpp = false;
            Set<Id> amon = new Set<Id>();
            list<Id> test = new List<Id>();
            Set<Id> conts = new Set<Id>();
            List<Id> accs = new List<Id>();
            for(Contact c : [Select Id, AccountId, NDG__C from Contact where AccountId IN : IdAccount ]){
                
                if(oppi.AccountId == c.AccountId) { 
                    conts.add(c.Id);
                    test.add(c.Id);
                }
            }
    
            accs.add(oppi.accountID);
            for(Garanzia__c var :  listGaranzia){
                if(var.Opportunit__c == oppi.Id)
                {
                    if(var.Cointestazione__c == null){
                        if(var.Fidejussioni__r.size() ==0){
                            blockOpp= true;                        
                        }
                        for(Fidejussione__c var2 : var.Fidejussioni__r){
                            if(var2.Persona_Fisica__r.Id != null){
                                conts.add(var2.Persona_Fisica__r.Id);}
                            if(var2.Persona_Giuridica__r.Id != null){
                                accs.add(var2.Persona_Giuridica__r.Id);}
                        }
                    }
                    else {
                        for(Fidejussione__c nos : MapCointestazione.get(var.Cointestazione__c)) {
                            amon.add(nos.Persona_Fisica__r.Id);
                            if(nos.Persona_Fisica__r.Id != null){
                                conts.add(nos.Persona_Fisica__r.Id);
                            }
                            if(nos.Persona_Giuridica__r.Id != null){
                                accs.add(nos.Persona_Giuridica__r.Id);
                            }
                        }
                        idCointestazione.add(var.Cointestazione__c);
                    }
                }
            }
            
            Set<Id> l=new Set<Id>();
            l.addAll(conts);
            list<Id> kot = new list<id>();
            kot.addAll(l);
            
            
            
            Set<Id> a=new Set<Id>();
            a.addAll(accs);
            list<Id> kotA = new list<id>();
            kotA.addAll(a);
            
            mapContact1.put(oppi.Id,test);
            mapContact2.put(oppi.Id,kot);
            // mapAccount.put(oppi.Id, accs);
            mapAccount.put(oppi.Id, kotA);
            System.debug('blockOpp'+blockOpp);
            if(blockOpp == true){
                if(bypassUserAccess)
                {
                    oppi.AddError('Non si può avanzare la opportunità se alla garanzia di tipo fidejussione non è associata almeno un fidejussore.');
                }
            }
        }
    
        for(Opportunity op : toBeProcessed){
            if(metadata[0].Status__c == 'Active'){
                
                ElevaRestApiController.inquiry(op.Id,op.AccountId,mapQuote.get(op.Id),mapContact2.get(op.Id),mapAccount.get(op.Id),op.Doc_Mail_User__c, serializeCredential);
                
            }}
    }
    
    
    public static void backupTitolareeCanale(List<Opportunity> newOppList){
        Set<Id> ownerIDs = new Set<Id>();
        for( Opportunity opp : newOppList )
        {
            if( opp.OwnerId != null )
            {
                ownerIDs.add( opp.OwnerId );
            }
        }
        
        if(ownerMap.isEmpty()){
            ownerMap = getOwnerMap(ownerIDs);
        }
        
        for( Opportunity opp : newOppList )
        {
            if( ownerMap.containsKey( opp.OwnerId ) )
            {
                String Profile = ownerMap.get( opp.OwnerId ).Profile.Name;
                
                if(Profile <> 'System Administrator' && Profile <> 'Integrator' && Profile <> 'Amministratore del sistema')
                {
                    switch on Profile{
                        when 'Agente'
                        {
                            opp.Canale__c = 'Agente';
                        } 
                        when 'Intermediario Finanziario'{
                            opp.Canale__c = 'Intermediario Finanziario';
                        }
                        when 'Mediatore Creditizio'
                        {
                            opp.Canale__c = 'Mediatore Creditizio';
                        }
                        when else{
                            opp.Canale__c = 'Contatto Diretto';
                        }
                        
                    }
                    opp.Titolare__c= opp.OwnerId;  
                }
            }   
        }   
    }
    
    
    public static void ReadOnlyRecordType(List<Id> newOppList){
        List<Opportunity> oppUpdate = new List<Opportunity>();
        List<Quote> quoteUpdate = new List<Quote>();
        List<Garanzia__c> updateGaranzia = new List<Garanzia__c>();
        
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LENDING_RO).getRecordTypeId();
        String recordTypeEasy = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_EASY_RO).getRecordTypeId();
        String recordTypeLineaId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LINEA_RO).getRecordTypeId();
        String recordTypeCreditiLendingRO = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_LENDING_RO).getRecordTypeId();
        String recordTypeCreditFiscaliRO = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_RO).getRecordTypeId();
        
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_LENDING_RO];
        List<RecordType> recordTypePlus=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_EASY_RO];
        List<RecordType> recordTypeCreditiLendingRO = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_LENDING_RO];
        
        List<RecordType> recordTypeLinea=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_LINEA_RO];
        List<RecordType> recordTypeCreditFiscaliRO = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_RO];
    
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }
        if(recordTypePlus.size()>0){
            recordTypeEasy=recordTypePlus.get(0).Id;
        }
        if(recordTypeLinea.size()>0){
            recordTypeLineaId=recordTypeLinea.get(0).Id;
        }*/
        
        for (Opportunity opphamomo: [SELECT Id, Name, RecordTypeId, Tipo_Linea_di_Credito__c, (SELECT Id, Name, Status, RecordTypeId FROM Quotes WHERE Status !='Annullata') FROM Opportunity WHERE Id IN: newOppList]){
            Opportunity opp = new Opportunity();
            opp.Id= opphamomo.Id;
            if(recordTypeId != '' && opphamomo.Tipo_Linea_di_Credito__c == 'Mutuo') {
                opp.RecordTypeId = recordTypeId;
            }
            else if(recordTypeEasy != '' && opphamomo.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                opp.RecordTypeId = recordTypeEasy;
            }
            if(opphamomo.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
            {
                opp.RecordTypeId = recordTypeCreditiLendingRO;
            }
            
    
            oppUpdate.add(opp);
    
            if(opphamomo.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
            {
                for(Quote q: opphamomo.Quotes){
                    Quote quote = new Quote();
                    quote.id=q.id;
                    quote.RecordTypeId=recordTypeCreditFiscaliRO;
                    
                    quoteUpdate.add(quote);
                }
            }
            else
            {
                for(Quote q: opphamomo.Quotes){
                    Quote quote = new Quote();
                    quote.id=q.id;
                    quote.RecordTypeId=recordTypeLineaId;
                    
                    quoteUpdate.add(quote);
                }
                
            }
        }
        
        for(Garanzia__c g : [Select Id,Record_Type_Only__c from Garanzia__c where Opportunit__c IN : newOppList ]){
            Garanzia__c a = new Garanzia__c();
            a.Id = g.Id;
            a.RecordTypeId =g.Record_Type_Only__c;
            updateGaranzia.add(a);
        }
        OpportunityController.bypassTrigger =true;
        update oppUpdate;
        OpportunityController.bypassTrigger =false;
        
        update quoteUpdate;
        update updateGaranzia;
    
    }
    public static void ReadOnlyRecordTypeForCrediti(List<Id> newOppList){
        
        List<Opportunity> oppUpdate = new List<Opportunity>();
        List<Quote> quoteUpdate = new List<Quote>();
              
        String recordTypeCreditiLending = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_LENDING).getRecordTypeId();
        String recordTypeCreditiLendingRO = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_LENDING_RO).getRecordTypeId();
        String recordTypeCreditFiscaliRO = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_RO).getRecordTypeId();
        String recordTypeCreditFiscali = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI).getRecordTypeId();
        
        /*List<RecordType> recordTypeCreditiLending = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_LENDING];
        List<RecordType> recordTypeCreditiLendingRO = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_LENDING_RO];
        List<RecordType> recordTypeCreditFiscaliRO = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_RO];
        List<RecordType> recordTypeCreditFiscali=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI];*/
        
        
        
        for (Opportunity opphamomo: [SELECT Id, Name, RecordTypeId, Tipo_Linea_di_Credito__c, (SELECT Id, Name, Status, RecordTypeId FROM Quotes WHERE Status !='Annullata') FROM Opportunity WHERE Id IN: newOppList]){
            Opportunity opp = new Opportunity();
            opp.Id= opphamomo.Id;
            
            if(opphamomo.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
            {
                opp.RecordTypeId = recordTypeCreditiLendingRO;
            }
            
    
            oppUpdate.add(opp);
    
            if(opphamomo.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
            {
                for(Quote q: opphamomo.Quotes){
                    Quote quote = new Quote();
                    quote.id=q.id;
                    quote.RecordTypeId=recordTypeCreditFiscaliRO;
                    
                    quoteUpdate.add(quote);
                }
            }
        }
        
        
        OpportunityController.bypassTrigger =true;
        update oppUpdate;
        OpportunityController.bypassTrigger =false;
        
        update quoteUpdate;
    
    
    }
    
    public static void LendingRecordType(List<Id> newOppList){
        List<Opportunity> oppUpdate = new List<Opportunity>();
        List<Quote> quoteUpdate = new List<Quote>();
        List<Garanzia__c> updateGaranzia = new List<Garanzia__c>();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LENDING).getRecordTypeId();   
        String recordTypeEasy = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_EASY).getRecordTypeId();
        String recordTypeLineaId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LINEA).getRecordTypeId();
        String recordTypeCreditiLending = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_LENDING).getRecordTypeId();
        String recordTypeCreditFiscali = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI).getRecordTypeId();
        
        System.debug('recordTypeId lending' + recordTypeId);
        System.debug('recordTypeCreditiLending CF' + recordTypeCreditiLending);
        System.debug('recordTypeCreditFiscali cf' + recordTypeCreditFiscali);
        System.debug('recordTypeLineaId lending' + recordTypeLineaId);
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_LENDING];
        List<RecordType> recordTypePlus=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_EASY];
        List<RecordType> recordTypeCreditiLending = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_LENDING];
        
        List<RecordType> recordTypeLinea=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_LINEA];
        List<RecordType> recordTypeCreditFiscali=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI];
        
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }
        if(recordTypePlus.size()>0){
            recordTypeEasy=recordTypePlus.get(0).Id;
        }
        if(recordTypeLinea.size()>0){
            recordTypeLineaId=recordTypeLinea.get(0).Id;
        }*/
        
        
        for (Opportunity opp: [SELECT Id, Name, RecordTypeId, Tipo_Linea_di_Credito__c, (SELECT Id, Name, Status, RecordTypeId FROM Quotes WHERE Status !='Annullata') FROM Opportunity WHERE Id IN: newOppList]){
            Opportunity oppi = new Opportunity();
            oppi.id=opp.Id;
            if(recordTypeId != '' && opp.Tipo_Linea_di_Credito__c == 'Mutuo') {
                oppi.RecordTypeId = recordTypeId;
            }
            else if(recordTypeEasy != '' && opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                oppi.RecordTypeId = recordTypeEasy;
            }
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
            {
                oppi.RecordTypeId = recordTypeCreditiLending;
            }
            oppUpdate.add(oppi);
            
            if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
            {
                for(Quote q: opp.Quotes){
                    Quote quote = new Quote();
                    quote.id=q.id;
                    quote.RecordTypeId=recordTypeCreditFiscali;
                    
                    quoteUpdate.add(quote);
                }
            }
            else
            {
                for(Quote q: opp.Quotes){
                    Quote quote = new Quote();
                    quote.id=q.id;
                    quote.RecordTypeId=recordTypeLineaId;
                    
                    quoteUpdate.add(quote);
                }
            }
        }
        for(Garanzia__c g : [Select Id,Record_Type_Landing__c from Garanzia__c where Opportunit__c IN : newOppList ]){
            Garanzia__c a = new Garanzia__c();
            a.Id = g.Id;
            a.RecordTypeId =g.Record_Type_Landing__c;
            updateGaranzia.add(a);
        }
        OpportunityController.bypassTrigger =true;
        update oppUpdate;
        OpportunityController.bypassTrigger =false;
        QuoteController.bypassTrigger=true;
        update quoteUpdate;
        QuoteController.bypassTrigger=false;
        update updateGaranzia;
    }
    
    
    public static void checkCambioPEFPREISTRUTORIA (List<Opportunity> newOppList) {
        Set<Id> AccountId = new Set<Id>();
        List<String> oppIdList = new List<String>();
    
        for (Opportunity opportunity : newOppList) {
            if (!oppIdList.contains(opportunity.Id)) {
                oppIdList.add(opportunity.Id);
            }
            AccountId.add(opportunity.AccountId);
        }
    
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = fileUploaderController.MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = fileUploaderController.computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);
        Map<String, List<Quote>> oppQuoteMap = new Map<String, List<Quote>>();
    
        for(Opportunity opportunity : [SELECT Id, Name, AccountId, (SELECT Id, Name, Percentuale_Spread__c, Percentuale_Commissioni_da_Istruttoria__c, Percentuale_rete_tasso__c, Percentuale_rete_istruttoria__c FROM Quotes WHERE Status<>'Annullata') FROM Opportunity]) {
            oppQuoteMap.put(opportunity.Id, opportunity.Quotes);
        }
    
        for(Opportunity opp : newOppList ){
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(opp.Id);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(opp.Id);
    
            opp.Total_Mandatories_Docs__c = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(opp.Id), oppIdAndMandatoryDocTypeMap.get(opp.Id), opportunityMap.get(opp.Id), mandatoryContactDocs, mandatoryQuoteDocs);
            opp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(opp.Id).get('Uploaded');
            opp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(opp.Id).get('Verified');
        }  
        
        Map<Id, List<Contact >> AccCont = new Map<Id, List<Contact>>();
        for(Account acc : [Select Id, (Select Id, Name, Ruolo_in_Azienda__c , NDG__c,Interessato__c,Esecutore__c, Account.AccountNumber from Contacts ) from Account where Id IN:  AccountId]){
            List<Contact> cont = acc.Contacts;
            AccCont.put(acc.Id, cont);
        }
        
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id, AccountNumber FROM Account where Id in :AccountId]);
        
        for(Opportunity opps : newOppList){
            if(AccCont.get(opps.AccountId).size() >0 && AccountMap.get(opps.AccountId)<> null && AccCont.get(opps.AccountId)<> null ){
                Boolean flagInteresato= false;
                Boolean flagEsecutore= false;
                Boolean flag = true;
                for(Contact Con :AccCont.get(opps.AccountId) ){
                    if(Con.Interessato__c ==true){
                        flagInteresato= true;
                    }
                    if(Con.Esecutore__c== true){
                        flagEsecutore= true;
                    }
                    if(Con.Ruolo_in_Azienda__c <> null){
                        if(Con.NDG__C == null){
                            flag = false;
                        }
                    }
                }
    
                if (flagInteresato == false || flagEsecutore== false){
                    if(bypassUserAccess)
                    {
                        opps.addError('Per procedere alla fase successiva è necessario popolare sui referenti il flag esecutore e interessato');
                    }
                }                   
                if (flag == false|| AccountMap.get(opps.AccountId).AccountNumber == null){
                    if(bypassUserAccess)
                    {
                        opps.addError('Per procedere alla fase successiva è necessario popolare i referenti Titolare e Account con NDG');
                    }
                }
            }
            
            for(Quote q: oppQuoteMap.get(opps.id)){
                if( opps.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                    
                    if(q.Percentuale_Spread__c==null || q.Percentuale_Commissioni_da_Istruttoria__c==null || q.Percentuale_rete_tasso__c==null || q.Percentuale_rete_istruttoria__c==null){
                        if(bypassUserAccess)
                        {
                            opps.addError('Nel caso di Progetto Easy Plus per passare in PEF Pre-Istruttoria occorre verificare che siano valorizzati correttamente, su tutte le linee di credito associate, i seguenti campi:  Percentuale Spread, Percentuale rete su tasso, Percentuale Commissioni da Istruttoria, Percentuale rete istruttoria.');
                        }
                    }
                }
            }
        }
    }
    
    public static void checkCambioConsolidamentoDocumento(List<Opportunity> newOppList) {
        Set<Id> accIdSet = new Set<Id>();
        List<String> oppIdList = new List<String>();
        Map<Id, List<Contact >> AccCont = new Map<Id, List<Contact>>();
    
        for (Opportunity opportunity : newOppList) {
            if (!oppIdList.contains(opportunity.Id)) {
                oppIdList.add(opportunity.Id);
            }
            accIdSet.add(opportunity.AccountId);
        }
    
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = fileUploaderController.MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = fileUploaderController.computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);
    
        for (Opportunity opp : newOppList) {
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(opp.Id);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(opp.Id);
    
            opp.Total_Mandatories_Docs__c = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(opp.Id), oppIdAndMandatoryDocTypeMap.get(opp.Id), opportunityMap.get(opp.Id), mandatoryContactDocs, mandatoryQuoteDocs);
    
            opp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(opp.Id).get('Uploaded');
            opp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(opp.Id).get('Verified');
        }
        for (Account acc : [SELECT Id, (SELECT Id, Name,Interessato__c,Esecutore__c, Account.AccountNumber FROM Contacts ) FROM Account WHERE Id IN: accIdSet]) {
            List<Contact> cont = acc.Contacts;
            AccCont.put(acc.Id, cont);
        }
        
        Map<Id, Account> AccountMap = new Map<Id, Account>([SELECT Id, AccountNumber FROM Account WHERE Id IN :accIdSet]);
        
        for (Opportunity opps : newOppList) {
            if (AccCont.get(opps.AccountId).size() > 0 && AccountMap.get(opps.AccountId) <> null && AccCont.get(opps.AccountId) <> null ) {
                Boolean flagInteresato = false;
                Boolean flagEsecutore = false;
                for (Contact Con :AccCont.get(opps.AccountId)) {
                    if (Con.Interessato__c == true) {
                        flagInteresato = true;
                    }
                    if (Con.Esecutore__c == true) {
                        flagEsecutore = true;
                    }
                    
                }
                
                if (flagInteresato == false && flagEsecutore== false ){
                    if(bypassUserAccess)
                    {
                        opps.addError('Per procedere alla fase successiva è necessario popolare sui referenti il flag interessato e esecutore');
                    }
                } else if (flagInteresato == false) {
                    if (bypassUserAccess) {
                        opps.addError('Per procedere alla fase successiva è necessario popolare sui referenti il flag interesato ');
                    }
                } else if (flagEsecutore == false) {
                    if (bypassUserAccess) {
                        opps.addError('Per procedere alla fase successiva è necessario popolare sui referenti il flag  e esecutore');
                    }
                }
            }
        }
    }
    
    public static void ChiusuraFinale(List<Id> newOppList){
        System.debug('Chiusura finale entered ');
        List<Opportunity> oppUpdate = new List<Opportunity>();
        List<Quote> quoteUpdate = new List<Quote>();
        List<Garanzia__c> updateGaranzia = new List<Garanzia__c>();
        Map<String, Id> mapOfRecords= Utils.getRecordsTypeOpptyQuoteMap();
    
        String recordTypeId = mapOfRecords.get(constants.RECORD_TYPE_LENDING_RO);   
        String recordTypeEasy = mapOfRecords.get(constants.RECORD_TYPE_EASY_RO);
        String recordTypeCreditFiscali = mapOfRecords.get(constants.RECORD_TYPE_LENDING_RO_CREDITI);
    
        System.debug('recordTypeId ' + recordTypeId);
        
        for (Opportunity opptys: [SELECT Id, Name, RecordTypeId, Tipo_Linea_di_Credito__c, Tipo_di_opportunit__c, (SELECT Id, Name, Status, RecordTypeId FROM Quotes WHERE Status !='Annullata') FROM Opportunity WHERE Id IN: newOppList]){
            Opportunity opp = new Opportunity();
            opp.Id= opptys.Id;
            System.debug('opp.Id' + opp.Id);
            System.debug('opptys.Tipo_di_opportunit__c ' + opptys.Tipo_di_opportunit__c);
            if(recordTypeId != '' && opptys.Tipo_di_opportunit__c == 'Mutuo') {
                System.debug('recordTypeId1 ' + recordTypeId);
                opp.RecordTypeId = recordTypeId;
                System.debug('opp.RecordTypeId : ' + opp.RecordTypeId);
            }
            else if(recordTypeEasy != '' && opptys.Tipo_di_opportunit__c == 'Progetto EasyPlus'){
                opp.RecordTypeId = recordTypeEasy;
                System.debug('opp.RecordTypeId1 : ' + opp.RecordTypeId);
            }
            else if(recordTypeCreditFiscali != '' &&  opptys.Tipo_di_opportunit__c == 'Crediti Fiscali'){
                opp.RecordTypeId = recordTypeCreditFiscali;
                System.debug('opp.RecordTypeId2 : ' + opp.RecordTypeId);
            }
            
            
            oppUpdate.add(opp);
            System.debug('oppUpdate : ' + oppUpdate);
            System.debug('opptys.Quotes : ' + opptys.Quotes);
            for(Quote q: opptys.Quotes){
                Quote quote = new Quote();
                quote.id=q.id;
                quote.Status = 'Annullata';
                quoteUpdate.add(quote);
                
            }
            System.debug('quoteUpdate : ' + quoteUpdate);
        }
        
        OpportunityController.bypassTrigger =true;
        update oppUpdate;
        OpportunityController.bypassTrigger =false;
        QuoteController.bypassTrigger = true;
        update quoteUpdate;
        QuoteController.bypassTrigger = false;
    }
    public static void motivazioneLost(List<Opportunity> newOppList){
        List<String> profileIds = new List<String>();
        Boolean notIntegrator=false;
        if(integratorProfileList.isEmpty()){
           integratorProfileList = [SELECT Id FROM Profile WHERE Name ='Integrator'];
        }
        for(Profile pr : integratorProfileList){
            profileIds.add(pr.Id);
        }
        String currentProfileId = loggedInUser.ProfileId;
        if(!profileIds.contains(currentProfileId)){
            notIntegrator=true;
        }
        String oldstagename;
        String motivazionecausa;
        string motivi;
        
        Map<String, String> values = new Map<String, String>{};
            Schema.DescribeFieldResult fieldResult = Opportunity.Motivazione_Causa_Lost__c.getDescribe();    
        List<Schema.picklistEntry> vls = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry a : vls){
            
            values.put(a.getValue(), a.getLabel());
        }
        for(Opportunity opp : newOppList){
            if(values.containsKey(opp.Motivazione_Causa_Lost__c)){
                motivi = values.get(opp.Motivazione_Causa_Lost__c);
                Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.id);
                
                oldstagename = oldOpp.StageName;
                String oldstagenameS = oldstagename.substring(0, 5);
                // if(opp.StageName == 'Chiusa/Persa'){
                
                
                motivi = motivi.substring(0, 5);
                //system.debug('motivazionecausa shkurt'+motivazionecausaS);
                if(oldstagenameS != motivi&&notIntegrator){
                    if(bypassUserAccess)
                    {
                        trigger.newmap.get(opp.id).addError('Non è possibile selezionare la motivazione lost scelta in quanto non è coerente con la fase precedente di questa Opportunita');
                    }
                }
            }
        }
    }
    
    public static void checkInErogazione(List<Id> newOppList){
        for(Opportunity opp : [Select id, name, (Select id, Contratto_Firmato_Flusso__c ,Status, Contratto_Verificato__c from Quotes where Status !='Annullata') from Opportunity where Id IN: newOppList])
        {
            Boolean pass = true;
            
            For(Quote q : opp.Quotes)
            {
                if(q.Contratto_Firmato_Flusso__c==true && q.Contratto_Verificato__c==true) {
                    pass = false;  
                }
            }
            if(pass){
                if(bypassUserAccess)
                    {
                        trigger.newmap.get(opp.id).addError('Per passare In Erogazione è necessario prima firmare e verificare il contratto!');
                    }
            }
        }
    }
    
    public static void respintiOpportunity(List<Id> oppIds) {
        List<Opportunity> oppUpdate = new List<Opportunity>();
        
        List<Quote> quoteUpdate = new List<Quote>();
        List<Garanzia__c> updateGaranzia = new List<Garanzia__c>();
        
        List<Id> oppIdsGar = new List<Id>();
        
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LENDING).getRecordTypeId();   
        String recordTypeEasy = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_EASY).getRecordTypeId();
        String recordTypeLineaId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LINEA).getRecordTypeId();
        String recordTypeCreditiLending = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI_LENDING).getRecordTypeId();
        String recordTypeCreditFiscali = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI).getRecordTypeId();
            
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_LENDING];
        List<RecordType> recordTypePlus=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_EASY];
        List<RecordType> recordTypeLinea=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_LINEA];
        List<RecordType> recordTypeCreditiLending = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI_LENDING];
        List<RecordType> recordTypeCreditFiscali=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI];
        
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }
        if(recordTypePlus.size()>0){
            recordTypeEasy=recordTypePlus.get(0).Id;
        }
        if(recordTypeLinea.size()>0){
            recordTypeLineaId=recordTypeLinea.get(0).Id;
        }*/
        System.debug('quote debug before query  ');
        for(Opportunity opp : [Select id, Tipo_Linea_di_Credito__c, RecordTypeId, (Select id, Status, Oplon_Esito_Delibera__c from Quotes where Oplon_Esito_Delibera__c=:constants.LINEE_DI_CREDITO_Oplon_ESITO_DELIBERATA_POS or Oplon_Esito_Delibera__c = null) from Opportunity where Id IN: oppIds ]){
            
            if(opp.Quotes.size()==0){
                Opportunity oppi  = new Opportunity();
                oppi.Id = opp.Id;
                oppi.StageName=constants.OPPORTUNITY_CHIUSA_PERSA;
                oppi.Motivazione_Causa_Lost__c='D_NEGATIVA';
                
                oppUpdate.add(oppi);
            }else{
                
                //oppIdsGar.add(opp.id);
                
                Opportunity oppi = new Opportunity();
                oppi.id=opp.Id;
                
                if(recordTypeId != '' && opp.Tipo_Linea_di_Credito__c == 'Mutuo') {
                    //modificato da stefano prima stava sotto else (inutile per crediti)
                    oppIdsGar.add(opp.id);
                    oppi.RecordTypeId = recordTypeId;
                }
                else if(recordTypeEasy != '' && opp.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                    //modificato da stefano prima stava sotto else (inutile per crediti)
                    oppIdsGar.add(opp.id);
                    oppi.RecordTypeId = recordTypeEasy;
                }
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
                {
                    oppi.RecordTypeId = recordTypeCreditiLending;
                }
                oppUpdate.add(oppi);
                
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali')
                {
                    for(Quote q: opp.Quotes){
                        Quote quote = new Quote();
                        quote.id=q.id;
                        quote.RecordTypeId=recordTypeCreditFiscali;
                        
                        quoteUpdate.add(quote);
                        
                    }
                    
                }
                else
                {
                    for(Quote q: opp.Quotes){
                        Quote quote = new Quote();
                        quote.id=q.id;
                        quote.RecordTypeId=recordTypeLineaId;
                        
                        quoteUpdate.add(quote);
                        
                    }                    
                }
            }
        }
        
        
        for(Garanzia__c g : [Select Id,Record_Type_Landing__c from Garanzia__c where Opportunit__c IN: oppIdsGar]){
            Garanzia__c a = new Garanzia__c();
            a.Id = g.Id;
            a.RecordTypeId =g.Record_Type_Landing__c;
            updateGaranzia.add(a);
            
            update updateGaranzia;
        }
            update quoteUpdate;
        update oppUpdate;
    }
    
    
    public static void switchPhase(List<Id> listInput){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity o : [Select Id, Name, StageName From Opportunity Where Id In : listInput]){
            Opportunity opp = new Opportunity();
            opp.Id = o.Id;
            opp.StageName = 'PEF Pre-Istruttoria';
            oppList.add(opp);
    
        }
        OpportunityController.bypassTrigger =true;
        update oppList;
        OpportunityController.bypassTrigger =false;
    }
    public static void CreditiOpp(List<Opportunity> newOppList){
        List<Opportunity> oppUpdate = new List<Opportunity>();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_NEW_OPPORTUNITY_CREDITI).getRecordTypeId();
        String recordTypeLineaId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LENDING_CREDITI).getRecordTypeId();
        
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_NEW_OPPORTUNITY_CREDITI];
        List<RecordType> recordTypeLinea=[SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName =: constants.RECORD_TYPE_LENDING_CREDITI];
    
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }
    
        if(recordTypeLinea.size()>0){
            recordTypeLineaId=recordTypeLinea.get(0).Id;
        }*/
    
        for (Opportunity opp: newOppList){
            //kontrollo nese ne inserimento eshte kjo
            if(opp.RecordTypeId == recordTypeId){
                opp.RecordTypeId = recordTypeLineaId;
            }
    
            }
    
    }
    
    public static void FieldSalesOwnerOpportunity(List<Opportunity> newopp){
            //Field Sales_owner_opportunita
        List<Opportunity> oppUpdate = new List<Opportunity>();
        Set<Id> AccountList = new Set<Id>();
        for (Opportunity opp : newOpp)
        {
            AccountList.add(opp.AccountId);
        }
    
        Map<ID, Account> AccountMap = new Map<ID, Account>([SELECT Id,Scenario__c,Sales_Crediti_Fiscali__c, Inside_Sales_di_Riferimento__c,Titolare_Anagrafica__c
                                                            FROM Account where Id in :AccountList]);
    
    
        For(Opportunity opp: newOpp){
                    String theField='';
                if(AccountMap.get(opp.AccountId).Scenario__c== null) {
                    theField = null;
            }
            if(AccountMap.get(opp.AccountId).Scenario__c=='A') {
                    theField = opp.Sales_Crediti_Fiscali__c;
            }
            else if(AccountMap.get(opp.AccountId).Scenario__c=='B'){
                    theField = opp.Sales_Crediti_Fiscali__c;
            }
            if(AccountMap.get(opp.AccountId).Scenario__c=='C'){
                theField = opp.Inside_Sales_di_Riferimento__c;
            }
                    // Opportunity oppi = new Opportunity();
            // oppi.Id = opp.Id;
            opp.Sales_owner_opportunita__c = theField;
            oppUpdate.add(opp);
    
        }
        OpportunityController.bypassTrigger = true;
        update oppUpdate;
        OpportunityController.bypassTrigger = false;
    }
    
    public static List<Opportunity> setInitialOppMandatoryDocCounter(Set<Id> oppIdSet) {
        List<String> oppIdList = (List<String>) new List<Id>(oppIdSet);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
        Map<String, Opportunity> opportunityMap = fileUploaderController.GetOpportunityMap(oppIdList);
        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = fileUploaderController.MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = fileUploaderController.computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);
    
        for (String oppId : oppIdAndDocStatusMap.keySet()) {
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(oppId);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(oppId);
            Opportunity newOpp = new Opportunity();
    
            newOpp.Id = oppId;
            newOpp.Total_Mandatories_Docs__c = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), mandatoryContactDocs, mandatoryQuoteDocs);
            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
            newOpp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
            oppsToUpdate.add(newOpp);
        }
        OpportunityController.bypassTrigger = true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger = false;
        return oppsToUpdate;
    }
    
    public static void CheckIfMandatoryDocTypesAreVerifiedForStage(List<Opportunity> oppList) {
        for(Opportunity opportunity : oppList){
        Integer totalMandatoryDocTypes = (Integer) opportunity.Total_Mandatories_Docs__c;
        Integer totalVerifiedDocs = (Integer) opportunity.Totale_Verified_Docs_Verificati__c;
    
        if (totalMandatoryDocTypes != totalVerifiedDocs) {
            opportunity.addError('Per procedere alla fase successiva occorre verificare tutti i documenti obbligatori!');
        }
    }
    }
    public static void CheckIfMandatoryDocTypesAreUploadedForStage(List<Opportunity> oppList) {
        for(Opportunity opportunity : oppList){
         Integer totalMandatoryDocTypes = (Integer) opportunity.Total_Mandatories_Docs__c;
         Integer totalUploadedDocs = (Integer) opportunity.Total_Uploaded_Docs__c;
     
         if (loggedInUser.Profile.name != 'Integrator' && totalMandatoryDocTypes != totalUploadedDocs) {
             opportunity.addError('Per procedere alla fase successiva occorre caricare tutti i documenti obbligatori!');
         }
        }
     }
     public static void checkPassareInErogazione(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();

        if(differentProfileList.isEmpty()){
            differentProfileList = [SELECT Id FROM Profile WHERE Name ='Responsabile BO Cedenti Ceduti' OR Name = 'System Administrator' OR Name = 'Back Office Cedenti Ceduti' OR Name = 'Integrator'];        
        }    
            
        for(Profile pr : differentProfileList){
            profileIds.add(pr.Id);
        }
        String currentProfileId = loggedInUser.ProfileId;
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
             pass = true;
        }
        if(pass){
            trigger.newmap.get(opp.id).addError('Solo Responsabile BO Cedenti Ceduti/Back Office Cedenti Ceduti può avanzare l\'opportunità in Erogazione!');
        }
        }
     }
     public static Map<String, Id> getUsersMap(){
        Map<String, Id> usersMap = new Map<String, Id>();
        List<String> nameList= new List<String> {constants.USER_Pintavalle, constants.USER_Commerciale1, constants.USER_Commerciale2, constants.USER_PORTESANI,constants.PARTNER_LEASING, constants.PARTNER_ARITMA, constants.PARTNER_AZIONI_LEASE, constants.PARTNER_CREDIPASS, constants.PARTNER_DOMINICI, constants.PARTNER_SOFFRITTI, constants.PARTNER_MARCANDELLI, constants.PARTNER_VALORIMPRESA};
        List<User> usersList = [SELECT Id, Name FROM User WHERE Name IN :nameList];
        for (User user : usersList){
            usersMap.put(user.Name, user.Id);
        }
        return usersMap;
     }
    
    public static Map<Id, User> getOwnerMap(Set<Id> ownerIDs){
         Map<Id, User> ownerMap = new Map<Id, User>([ Select Id, ProfileId, Profile.Name From User where Id IN: ownerIDs ]);
         return ownerMap;
    }
    
    public static Boolean anticipoPEFValidation(Id oppId){
        List<Quote> quoteList = new List<Quote>();
        System.debug('anticipoPEFValidation????');
        Boolean flag = false;
        //quoteList = [SELECT Id, Numero_Rapporto__c, Status, OpportunityId FROM Quote WHERE Status = 'In Corso' AND OpportunityId =: oppId AND Numero_Rapporto__c != null];
        for(Quote q: [SELECT Id, Numero_Rapporto__c, Status, OpportunityId FROM Quote WHERE OpportunityId =: oppId]){
            if(String.isEmpty(q.Numero_Rapporto__c) && q.Status == 'In Corso'){
                flag = true;
                break; 
            }
        }
        /*if(quoteList.isEmpty()){
            flag = true;
        }*/
        System.debug('flag????' + flag);
        return flag;
    }
    
    }