public class QuoteController extends TriggerHandler{
    
        public static Boolean bypassTrigger{set;get;}
    public static Boolean bypassUserAccess = ! Utils.checkUserBypassAccess();
    
    public override void run(){
        if(bypassTrigger==null || bypassTrigger==false){
            super.run();
        }
    }
    
    public static User loggedInUser;
    
    public override void afterInsert(){
        System.debug('* afterInsert *');
        //QuoteController.AfterInsertAddDoc(Trigger.new);
        QuoteController.CreateSme100(Trigger.new);
        System.debug('* updating opp counters *');
        UpdateOpportunityCounters(Trigger.new, new Map<Id, Quote>());
        BP_UTL_FieldsUpdateOpportunity.fieldAmountUpdateOpportunity((List<Quote>)Trigger.new, new Map<Id,Quote>());
    }
    
    public override void afterDelete(){
        System.debug('* afterDelete *');
        Set<Id> oppDeleted =new Set<Id>();
        for(Quote q: (List<Quote>)Trigger.old)
        {
            oppDeleted.add(q.opportunityid); 
        }

        if(!oppDeleted.isEmpty())
        {
            QuoteController.CalculateAmontareDurataOpp(oppDeleted);
        }
        System.debug('* updating opp counters *');
        UpdateOpportunityCounters(Trigger.old, new Map<Id, Quote>());
    }
    
    public override void beforeInsert(){
        QuoteController.BeforeInsert(Trigger.new);
        QUoteController.PreventQuotesOnStages(Trigger.new);
    }
    //Da passare in prod task 3132
    public override void beforeDelete()
    {  
        restrictUserFromDeletingQuotes(Trigger.old);
        System.debug('Trigger before delete' + Trigger.old);
    } //fin qui
    public override void beforeUpdate(){
        Utils_Constants costanti = new Utils_Constants();
        string RecordTypeRO = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(costanti.RECORD_TYPE_LINEA_RO).getRecordTypeId();
        /*List<RecordType> LineaRO = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :costanti.RECORD_TYPE_LINEA_RO AND SobjectType = 'Quote'];
        RecordTypeRO = LineaRO.get(0).Id;*/
        
        List<Quote> deliberaAnnullata = new List<Quote>();
        Set<Quote> listEasyAmount = new Set<Quote>();
        
        for(Quote quote: (List<Quote>)Trigger.new)
        {
            Quote oldQuote = (Quote)trigger.oldMap.get(quote.id);
            
            if(quote.Oplon_Esito_Delibera__c== costanti.LINEE_DI_CREDITO_Oplon_ESITO_DELIBERA_NEGATIVO){
                if (oldQuote!=null && quote.Oplon_Esito_Delibera__c != oldQuote.Oplon_Esito_Delibera__c){
                    quote.status=costanti.LINEE_DI_CREDITO_ANNULLATA;
                    quote.RecordTypeId=RecordTypeRO;    
                }
            }
        }
    }
    
    public override void afterUpdate()
    {
        System.debug('* afterupdate *');

        Set<Id> oppId = new Set<Id>();
        List<Quote> listAnullataQuote = new List<Quote>();
        Set<Id> quoteId = new Set<Id>();
        Set<Quote> listEasyAmount = new Set<Quote>();
        
        for(Quote quote: (List<Quote>)Trigger.new)
        {
            Utils_Constants constants = new Utils_Constants();
            Quote oldQuote = (Quote) Trigger.oldMap.get(quote.id);
            
            if(quote.Status =='Annullata' && quote.Status != oldQuote.Status )
            {
                listAnullataQuote.add(quote);
            }
            if((quote.Ammontare__c != oldQuote.Ammontare__c) || (quote.Ammontare_Direzione__c != oldQuote.Ammontare_Direzione__c)
               || (quote.Ammontare_Deliberato__c != oldQuote.Ammontare_Deliberato__c) || (quote.Ammontare_Erogato__c != oldQuote.Ammontare_Erogato__c)
               || (quote.Durata_Partner__c != oldQuote.Durata_Partner__c) || 
               (quote.Durata_Commerciale__c != oldQuote.Durata_Commerciale__c) || (quote.Durata_Direzione__c != oldQuote.Durata_Direzione__c)
               || (quote.Durata_Deliberata__c != oldQuote.Durata_Deliberata__c) || (quote.Durata_Erogata__c != oldQuote.Durata_Erogata__c)
               ||(quote.Ammontare_Iniziale__c != oldQuote.Ammontare_Iniziale__c)
              ){
                oppId.add(quote.OpportunityId);
            }
            
            if((quote.Data_Stipula__c != oldQuote.Data_Stipula__c) || (quote.Linea_di_Credito_in_Mesi__c != oldQuote.Linea_di_Credito_in_Mesi__c))     
            {
                quoteId.add(quote.Id);
            }
        if((quote.Ammontare__c != oldQuote.Ammontare__c) || (quote.Ammontare_Direzione__c != oldQuote.Ammontare_Direzione__c)
               || (quote.Ammontare_Deliberato__c != oldQuote.Ammontare_Deliberato__c) || (quote.Ammontare_Erogato__c != oldQuote.Ammontare_Erogato__c)
               ||(quote.Ammontare_Iniziale__c != oldQuote.Ammontare_Iniziale__c)){
                  listEasyAmount.add(quote);
              }
              if(quote.Contratto_Firmato_Flusso__c!=oldQuote.Contratto_Firmato_Flusso__c && quote.Contratto_Firmato_Flusso__c==true){
               // quote.Contratto_Verificato__c=false;
            }
            BP_UTL_FieldsUpdateOpportunity.fieldAmountUpdateOpportunity((List<Quote>)Trigger.new, (Map<Id,Quote>) Trigger.oldMap);
        }

        if(!listEasyAmount.isEmpty()){   
            QuoteController.checkAmontareEasyPlus(listEasyAmount);
        }
        
      /*  if(!listAnullataQuote.isEmpty()){   
            QuoteController.AnullataQuote(listAnullataQuote);
        }*/
  
        if(!oppId.isempty()){
            QuoteController.CalculateAmontareDurataOpp(oppId);
        }
        
        if(!quoteId.isempty()){
            QuoteController.dataScadenzaGaranzia(quoteId);
        }
        if(!listEasyAmount.isEmpty()){   
            QuoteController.checkAmontareEasyPlus(listEasyAmount);
        }
        list<Id> quotesIDAumentati= getAumentatoAmmontare();
        if(!quotesIDAumentati.isempty())
            resetGaranzie(quotesIDAumentati);
        System.debug('* updating opp counters *');
        UpdateOpportunityCounters(Trigger.new, (Map<Id, Quote>) Trigger.oldMap);
    }
    
    public static void BeforeInsert(List<Quote> newQuoteList){    
        Set<Id> OpportunityList = new Set<Id>();
        Utils_Constants constants = new Utils_Constants();
        
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.LINEE_DI_CREDITO).getRecordTypeId();           
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.LINEE_DI_CREDITO];
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }*/
        String recordTypeCreditiId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_CREDITI_FISCALI).getRecordTypeId();  
        /*List<RecordType> recordTypesCrediti = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName =: constants.RECORD_TYPE_CREDITI_FISCALI];
        if(recordTypesCrediti.size()>0){
            recordTypeCreditiId = recordTypesCrediti.get(0).Id;
        }*/
        
        for (Quote newQuote : newQuoteList)
        { 
            OpportunityList.add(newQuote.OpportunityID);
        }
        
        Map<ID, Opportunity> OpportunityMap = new Map<ID, Opportunity>([SELECT Id, Name ,Quote_Number__c, Account.Opp_Easy_Plus__c,Account.Comune__c, Account.Cap__c, Account.Numero_Civico__c, Account.Tipo_Via__c, Account.Nome_Via__c, Account.Sigla_Provincia__c,  Account.Opp_Easy_Plus_Active__c, Tipo_Linea_di_Credito__c FROM Opportunity where Id in :OpportunityList]);
        System.debug('OpportunityMap: '+OpportunityMap);
        String newNameOpp ;
        for (Quote newQuote : newQuoteList)
        {
            if(OpportunityMap.get(newQuote.OpportunityId).Quote_Number__c  >=1){
                if(newQuote.Tipo_Linea_di_Credito__c =='Progetto EasyPlus' || OpportunityMap.get(newQuote.OpportunityId).Account.Opp_Easy_Plus__c >=1)
                {
                    If(OpportunityMap.get(newQuote.OpportunityId).Account.Opp_Easy_Plus_Active__c + newQuote.Ammontare_Iniziale__c > 300000){
                        if(bypassUserAccess)
                		{
                        	//newQuote.AddError('Non puoi creare una Linea di Credito Easy Plus, se lammontare totale di tutte le opportunità ancora aperte con le rispettive Linee di Credito, supera i 300.000 euro!');
                    
                        }
                    }
                }
            }
            //task 2005 Per passare in Prod
                newQuote.Citta_Firma__c = OpportunityMap.get(newQuote.OpportunityId).Account.Comune__c;
                newQuote.Sigla_Provincia_Firma__c =  OpportunityMap.get(newQuote.OpportunityId).Account.Sigla_Provincia__c;
                newQuote.Tipo_Via__c = OpportunityMap.get(newQuote.OpportunityId).Account.Tipo_Via__c;
                newQuote.Nome_Via__c = OpportunityMap.get(newQuote.OpportunityId).Account.Nome_Via__c;
                newQuote.Numero_Civico__c = OpportunityMap.get(newQuote.OpportunityId).Account.Numero_Civico__c;
                newQuote.Cap_Firma__c = OpportunityMap.get(newQuote.OpportunityId).Account.Cap__c;
            //fin qui
            
            Integer kot = integer.valueOf(OpportunityMap.get(newQuote.OpportunityId).Quote_Number__c +1);   
            String letteri  ='ABCDEFGHIGKLMNOPQRSTUVWXYZ';
            String result = letteri.substring(kot-1, kot);
            
            newNameOpp =OpportunityMap.get(newQuote.OpportunityId).Name +'_Linea   ' + result;
            newQuote.Name = newNameOpp;
            if(newQuote.Opportunity.StageName !='Erogata' &&   newQuote.Opportunity.StageName !='Chiusa/Persa') {
                newQuote.Status = 'In Corso';
            }

         /*   if(RecordTypeId != '') {
                newQuote.RecordTypeId = RecordTypeId;
            }*/
            if(OpportunityMap.get(newQuote.OpportunityId).Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
                 if(RecordTypeCreditiId != '')
                 newQuote.RecordTypeId = recordTypeCreditiId;
             }
            else {
                if(RecordTypeId != ''){
                newQuote.RecordTypeId = recordTypeId;
                }
            }
            
            
            if(OpportunityMap.get(newQuote.OpportunityId).Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                newQuote.Percentuale_Spread__c=5.5;
                newQuote.Percentuale_Commissioni_da_Istruttoria__c=0.0;
                newQuote.Percentuale_rete_tasso__c=0.0;
                newQuote.Percentuale_rete_istruttoria__c=0.0;
            }
            
            if(newQuote.Tipo_Linea_di_Credito__c =='Progetto EasyPlus'){
                newQuote.Categoria_Prodotto_Cedacri__c='201814';
            }
            else if(newQuote.Tipo_Linea_di_Credito__c =='Mutuo'){
                newQuote.Categoria_Prodotto_Cedacri__c='201801';
            }
        }
    }
    
    
    public static void AfterInsertAddDoc(List<Quote> newQuoteList){
        List<DocumentType__c> docType = [SELECT Id, ObjectName__c,Opportunita_EasyPlus__c,Opportunita_Mutuo__c FROM DocumentType__c where ObjectName__c='Quote'];
        Map<Id,Integer> mapi2 = new Map<Id, Integer>();
        Set<Id> OppId = New Set<Id>();
        List<Id> OPP = new List<Id>();
        
        for (Quote  q: newQuoteList){
            OppId.add(q.OpportunityId);
        }
        
        For(Opportunity opps : [Select Id, Name ,(Select Id from Quotes) from Opportunity where Id IN (Select OpportunityId from Quote where Id IN:newQuoteList )]){
            if(opps.Quotes.size() >=2){ 
                mapi2.put(opps.Id,opps.Quotes.size());
            }
        }
        
        List<Document__c> docList = new List<Document__c> ();
        for (Quote quote : newQuoteList) {
            if( mapi2.get(quote.OpportunityId) >=2){
                if(quote.Tipo_Linea_di_Credito__c=='Mutuo'){
                    for (DocumentType__c doc : docType) {
                        if( doc.ObjectName__c=='Quote' && doc.Opportunita_Mutuo__c==true){
                            docList.add(new Document__c(
                                Quote__c = quote.Id,
                                DocumentType__c = doc.Id
                            ));
                        }
                    }
                }
                else if (quote.Tipo_Linea_di_Credito__c=='Progetto EasyPlus')
                {
                    for (DocumentType__c doc : docType) {
                        if( doc.ObjectName__c=='Quote' && doc.Opportunita_EasyPlus__c==true ){
                            docList.add(new Document__c(
                                Quote__c = quote.Id,
                                DocumentType__c = doc.Id
                            ));
                        }
                    }
                }
            }
        }
        QuoteController.CalculateAmontareDurataOpp(OppId);
        insert docList;
    }
    
    public static void AnullataQuote(List<Quote> newQuoteList)
    {
        Utils_Constants constants = new Utils_Constants();
        List<Garanzia__c> updateGaranzia = new List<Garanzia__c>();
        Set<Id> quoteId = new Set<Id>();
        Set<Id> opportunityId = new Set<Id>();

        string RecordTypeRO = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_LINEA_RO).getRecordTypeId();
        /*List<RecordType> LineaRO = [SELECT DeveloperName, Id, Name, SobjectType FROM RecordType WHERE DeveloperName = :constants.RECORD_TYPE_LINEA_RO AND SobjectType = 'Quote'];
        RecordTypeRO = LineaRO.get(0).Id;*/
        List<Quote> updateQuote = new List<Quote>();

        for (Quote quote :newQuoteList ){
            quoteId.add(quote.Id);

            Quote p =new Quote();
            p.id=quote.id;
            p.RecordTypeId=RecordTypeRO;
            updateQuote.add(p);

            if(quote.Opportunity.StageName !=constants.OPPORTUNITY_CHIUSA_PERSA){
                opportunityId.add(quote.OpportunityId);
            }
        }

        for(Garanzia__c g : [Select Id,Stato_Garanzia__c, Record_Type_Only__c  from Garanzia__c where Linea_di_Credito__c IN : quoteId ]){
            Garanzia__c a = new Garanzia__c();
            a.Id = g.Id;
            a.Stato_Garanzia__c ='Chiusa';
            updateGaranzia.add(a);
        }

        QuoteController.CalculateAmontareDurataOpp(opportunityId);

        QuoteController.bypassTrigger =true;
        update updateQuote;
        QuoteController.bypassTrigger =false;

        update updateGaranzia;
    }
    
    public static void CalculateAmontareDurataOpp(Set<Id> oppId){
        List<Opportunity> oppUpdate = new List<Opportunity>();
        Utils_Constants constants = new Utils_Constants();
        
        for(Opportunity opp: [SELECT Id, Name, Amount, Linea_di_Credito_in_Mesi__c, (SELECT Id, Status, Ammontare_aggiornato__c, Durata_in_mesi__c FROM Quotes WHERE Status !='Annullata') FROM Opportunity WHERE StageName !=: constants.OPPORTUNITY_CHIUSA_PERSA AND Id IN: oppId]){
            Decimal totalAmount=0.00;
            Decimal maxDurata=0.00;
            
            for(Quote q: opp.Quotes){
                totalAmount += q.Ammontare_aggiornato__c;
                
                if(q.Durata_in_mesi__c>maxDurata)
                    maxDurata=q.Durata_in_mesi__c;
            }
            
            Opportunity newOpp = new Opportunity();
            newOpp.id=opp.id;
            newOpp.Amount=totalAmount;
            newOpp.Linea_di_Credito_in_Mesi__c=maxDurata;
            oppUpdate.add(newOpp);
        }
        update oppUpdate;
    }
    
    
    @TestVisible   private static list<Id> getAumentatoAmmontare(){
        list<ID> quotesId = new list<ID>();
        
        for(Quote newQuote: (list<Quote>) trigger.new){
            Quote oldQuote= (Quote)trigger.oldMap.get(newQuote.id);
            if(oldQuote!=null){
                if(newQuote.Ammontare_Deliberato__c!= null && newQuote.Ammontare_Deliberato__c>0){
                    if(oldQuote.Ammontare_Deliberato__c==null || oldQuote.Ammontare_Deliberato__c==0){
                        if(newQuote.Ammontare_Deliberato__c > oldQuote.Ammontare_Iniziale__c){
                            quotesId.add(newQuote.id);
                        }
                    }else{
                        if(newQuote.Ammontare_Deliberato__c > oldQuote.Ammontare_Deliberato__c){
                            quotesId.add(newQuote.id);
                        }
                    }
                }
            } 
        }
        return quotesId;
    }

    @TestVisible private static void resetGaranzie(list<Id> quotesId){
        Utils_Constants costanti=new Utils_Constants();
        list<Garanzia__c> garanzie = [select id from Garanzia__c where Linea_di_Credito__c in: quotesId and
                                      Stato_Garanzia__c!=: costanti.GARANZIA_STATOGARANZIA_CHIUSA and Stato_Garanzia__c!=: costanti.GARANZIA_STATOGARANZIA_APERTA];
        for(Garanzia__c garanzia: garanzie){
            garanzia.Stato_Garanzia__c=  costanti.GARANZIA_STATOGARANZIA_APERTA;
            garanzia.Verifica_fondo__c=null;
            garanzia.Esito_simulazione__c=null;
            garanzia.Esito_delibera__c=null;
        }
        if(!garanzie.isempty()){
            GaranzieController.bypassTrigger=true;
            update garanzie;
            GaranzieController.bypassTrigger=false;
        }
            
    }
    
    public static void dataScadenzaGaranzia(Set<Id> newOppList){
        System.debug('entra qui dataScadenzaGaranzia' );
        List<Garanzia__c> garanziaUpdate = new List<Garanzia__c>();
        List<Garanzia__c> lst= [Select id ,Stato_Garanzia__c,Tipo_di_Garanzia__c, Opportunit__r.StageName, Opportunit__r.Data_fine_mutuo_Formula__c, Linea_di_Credito__r.Data_fine_mutuo_Formula__c from Garanzia__c where Linea_di_Credito__c IN :newOppList];
        System.debug('lst  '+lst);
        for(Garanzia__c garanzia : [Select id ,Stato_Garanzia__c,Tipo_di_Garanzia__c, Opportunit__r.StageName, Opportunit__r.Data_fine_mutuo_Formula__c, Linea_di_Credito__r.Data_fine_mutuo_Formula__c from Garanzia__c where Linea_di_Credito__c IN :newOppList ]){
            if(garanzia.Opportunit__r.StageName== 'Deliberata' || garanzia.Opportunit__r.StageName == 'In Erogazione'){
                if(garanzia.Stato_Garanzia__c <> 'Chiusa' && garanzia.Tipo_di_Garanzia__c == 'Fidejussione'){
                    if(garanzia.Linea_di_Credito__r.Data_fine_mutuo_Formula__c != null){
                        Garanzia__c g = new Garanzia__c();
                        g.Id = garanzia.Id;
                        g.Expiration_Date__c = garanzia.Linea_di_Credito__r.Data_fine_mutuo_Formula__c;
                        garanziaUpdate.add(g);
                    }
                    
                }
            }
        }        
        GaranzieController.bypassTrigger=true;
        update garanziaUpdate;
        GaranzieController.bypassTrigger=false;
    }
    
    public static void checkAmontareEasyPlus(Set<Quote> quoteList){

        List<Id> SetAccountId = new List<Id>();
        for (Quote q: quoteList) { 
            SetAccountId.add(q.AccountId);
        }
        
        List<Quote> FullListQuote = [Select id, AccountId, name, Tipo_Linea_di_Credito__c, Ammontare_aggiornato__c, Status from Quote where Status != 'Annullata' AND AccountId IN:SetAccountId];

        Map<Id, List<Quote>> mapQuoteOpp =  new Map<Id,List<Quote>>();
        For(Quote  q :FullListQuote ) {
            if(mapQuoteOpp.containsKey(q.AccountId)) {
                mapQuoteOpp.get(q.AccountId).add(q);
            }
            else 
            {
                mapQuoteOpp.put(q.AccountId, new List<Quote>());
                mapQuoteOpp.get(q.AccountId).add(q);
            }
        }

        Set<id> accWithEasy = new Set<Id>();
        for (Id id : mapQuoteOpp.keySet())
        {
            boolean isEasy = false;
            
            for(Quote quote: mapQuoteOpp.get(id)){
                if(quote.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus'){
                    isEasy = true;
                } 
            }
            if(isEasy){       
                accWithEasy.add(id);
            }
        }

        Set<id> myAccs = new Set<Id>();
        for (Quote q: quoteList) { 
            if((q.Tipo_Linea_di_Credito__c=='Mutuo' && accWithEasy.contains(q.AccountId)) || q.Tipo_Linea_di_Credito__c=='Progetto EasyPlus'){
                myAccs.add(q.AccountId);
            }
        }

        Set<id> accWithMoney = new Set<Id>();
        if(myAccs.size()>0){
     
            for (Id id : mapQuoteOpp.keySet())
            {
                Double sumAmontare = 0.00;
                
                for(Quote quote: mapQuoteOpp.get(id)){
                    sumAmontare+=quote.Ammontare_aggiornato__c;
                }
                if(sumAmontare > 300000){
                    accWithMoney.add(id);
                }
                
            }
            
        }
        
        /*for (Quote q: quoteList) { 
            if((accWithMoney.contains(q.AccountId))){
                if(bypassUserAccess)
                {
                	q.addError('Non puoi creare una Linea di Credito Easy Plus, se lammontare totale di tutte le opportunità ancora aperte con le rispettive Linee di Credito, supera i 300.000 euro!');
            	}
            }
        }*/
    }

    public static void PreventQuotesOnStages(List<Quote> newQuoteList){

        Utils_Constants constants = new Utils_Constants();
        Map<Id, Id> quoteIdListMap = new Map<Id, Id>();
        Map<Id, String> quoteStageMap = new Map<Id, String>();
        
        if(loggedInUser == null){
            loggedInUser = [Select Id, Profile.Name from user where Id =: System.userInfo.getUserId()];
        }

        for(Quote quo : newQuoteList){

            quoteIdListMap.put(quo.Id , quo.OpportunityId);
        }
        for(Opportunity  oppy : [Select Id,StageName from Opportunity where Id IN: quoteIdListMap.Values()])
        {
            quoteStageMap.put(oppy.Id, oppy.StageName);

        }for(Quote quo : newQuoteList){

            if(quoteIdListMap.containsKey(quo.Id) ) {
                if(quoteStageMap.containsKey(quoteIdListMap.get(quo.Id)))
                {
                    String oppStageName = quoteStageMap.get(quoteIdListMap.get(quo.Id));
                    
                    if((oppStageName == 'Deliberata' || oppStageName == 'In Stipula' || oppStageName == 'Firma e Cessione' 
                    || oppStageName == 'In Erogazione'|| oppStageName == 'Closed') && loggedInUser.Profile.Name != 'System Administrator')
                    {
                        quo.addError(constants.ERROR_PREVENT_STAGE_QUOTE);
                    }
                }
            }
        }
       
    }

    //Per l'eleminazione di quote 3132 da passare in Prod
    public static void restrictUserFromDeletingQuotes(List<Quote> oldQuoteList){
       
        Map<Id, Id> quoteIdListMap = new Map<Id, Id>();
        Map<Id, String> quoteStageMap = new Map<Id, String>();
        if(loggedInUser == null){
            loggedInUser = [Select Id, Profile.Name from user where Id =: System.userInfo.getUserId()];
        }

        for(Quote quo : oldQuoteList){

            quoteIdListMap.put(quo.Id , quo.OpportunityId);
        }
        for(Opportunity  oppy : [Select Id,StageName from Opportunity where Id IN: quoteIdListMap.Values()])
        {
            quoteStageMap.put(oppy.Id, oppy.StageName);

        }for(Quote quo : oldQuoteList){

            if(quoteIdListMap.containsKey(quo.Id) ) {
                if(quoteStageMap.containsKey(quoteIdListMap.get(quo.Id)))
                {
                    String oppStageName = quoteStageMap.get(quoteIdListMap.get(quo.Id));
                    
                    if((oppStageName == 'PEF Pre-Istruttoria' || oppStageName == 'PEF Istruttoria' || oppStageName == 'Deliberata' || oppStageName == 'In Stipula'|| oppStageName == 'Firma' || oppStageName == 'Firma e Cessione' ||  oppStageName == 'In Erogazione') && loggedInUser.Profile.Name != 'System Administrator')

                    {
                        quo.addError('Non puoi eliminare Linee di credito!');
                    }
                }
            }
        }
    }  //fin qui
    public static void CreateSme100(List<Quote> newQuoteList){
        System.debug('newQuoteList ' +newQuoteList );
        List<DocumentType__c> docType = [SELECT Id, ObjectName__c,Opportunita_EasyPlus__c,Opportunita_Mutuo__c, Opportunity_Crediti_Fiscali__c, ID_Tipo_Documento__c FROM DocumentType__c where ObjectName__c='Quote' AND (ID_Tipo_Documento__c = 'SME_100' OR  ID_Tipo_Documento__c = 'SME_114' OR ID_Tipo_Documento__c = 'SME_058')];
        Map<Id,Integer> mapi2 = new Map<Id, Integer>();
        Set<Id> OppId = New Set<Id>();
        List<Id> OPP = new List<Id>();

     /*   for (Quote  q: newQuoteList){
            OppId.add(q.OpportunityId);
        }

        for(Opportunity opps : [Select Id, Name ,(Select Id from Quotes) from Opportunity where Id IN :OppId]){
            if(opps.Quotes.size() >0){ 
                mapi2.put(opps.Id,opps.Quotes.size());
            }
        }
*/
        List<Document__c> docList = new List<Document__c> ();
        for (Quote quote : newQuoteList) {
        //if( mapi2.get(quote.OpportunityId) >0){
               // if(quote.Tipo_Linea_di_Credito__c == 'Mutuo' || quote.Tipo_Linea_di_Credito__c == 'Progetto EasyPlus' || quote.Tipo_Linea_di_Credito__c == 'Crediti Fiscali'){
            for (DocumentType__c doc : docType) {
                if(doc.ID_Tipo_Documento__c == 'SME_058'){
                    docList.add(new Document__c(
                        Quote__c = quote.Id,
                        File_Name__c='Fidejussione non firmato',
                        DocumentType__c = doc.Id,
                        Verifica_Sales_Support__c = 'Da Verificare'
                    ));
                }else{
                    docList.add(new Document__c(
                        Quote__c = quote.Id,
                        File_Name__c='Contratto non firmato',
                        DocumentType__c = doc.Id,
                        Verifica_Sales_Support__c = 'Da Verificare'
                    ));
                }
                 //  if( doc.ObjectName__c == 'Quote' && (doc.Opportunita_Mutuo__c || doc.Opportunita_EasyPlus__c || doc.Opportunity_Crediti_Fiscali__c )){
                           
                      //  }
            }
                //}

            //}
        }
        insert docList;
    }
    @future
    public static void UpdateOpportunityCountersAsync(List<Id> accountIdList, Set<String> oppIdSet) {
        
        Map<String, Opportunity> opportunityMap = ContactController.GetOpportunityMapFromAccountIdList(accountIdList);
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        System.debug('oppIdSet ' + oppIdSet);
        for(String oStr : oppIdSet ){
            if(opportunityMap.containsKey(oStr)){
            oppMap.put(oStr, opportunityMap.get(oStr));
            }
        }
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(oppMap);
        System.debug('oppsToUpdate   '+oppsToUpdate);
        OpportunityController.bypassTrigger = true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger = false;
    }
  
    public static void UpdateOpportunityCounters(List<Quote> newQuoteList, Map<Id, Quote> oldQuoteMap)
    {
        Set<String> oppIdSet = new Set<String>();
        for(Quote q: newQuoteList){
           oppIdSet.add(q.OpportunityId);
        }
        System.debug('* UpdateOpportunityCounters *');
        List<Id> accountIdList = GetAccountIdFromQuote(newQuoteList, oldQuoteMap);
        UpdateOpportunityCountersAsync(accountIdList, oppIdSet);
        
    }
    
    public static List<Opportunity> GetUpdatedOpportunityCounters(Map<String, Opportunity> opportunityMap) {
        System.debug('** GetUpdatedOpportunityCounters **');
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = fileUploaderController.MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = fileUploaderController.computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);

        for (Id oppId : oppIdAndDocStatusMap.keySet()) {
            System.debug('** oppId = ' + oppId);
            Integer mandatoryContactDocs = oppIdAndMandatoryContacts.get(oppId);
            Integer mandatoryQuoteDocs = oppIdAndMandatoryQuotes.get(oppId);
            Opportunity newOpp = new Opportunity ();

            newOpp.Id = oppId;
            newOpp.Total_Mandatories_Docs__c = fileUploaderController.computeTotalMandatoryDocsForStageChange(oppIdAndDocumentsMap.get(oppId), oppIdAndMandatoryDocTypeMap.get(oppId), opportunityMap.get(oppId), mandatoryContactDocs, mandatoryQuoteDocs);
            newOpp.Total_Uploaded_Docs__c = oppIdAndDocStatusMap.get(oppId).get('Uploaded');
            newOpp.Totale_Verified_Docs_Verificati__c = oppIdAndDocStatusMap.get(oppId).get('Verified');
            oppsToUpdate.add(newOpp);
        }

        return oppsToUpdate;
    }

    public static List<Id> GetAccountIdFromQuote(List<Quote> newQuoteList, Map<Id, Quote> oldQuoteMap)
    {
        List<Id> accountIdList = new List<Id>();

        for (Quote newQuote : newQuoteList)
        {
            Quote oldQuote = oldQuoteMap.get(newQuote.Id);

            if (oldQuote != null)
            {
                if (oldQuote.AccountId != null) {
                    accountIdList.add(oldQuote.AccountId);
                }
            }

            if (newQuote.AccountId != null && !accountIdList.contains(newQuote.AccountId))
            {
                accountIdList.add(newQuote.AccountId);
            }
        }

        return accountIdList;
    }

}