public class GaranzieController extends TriggerHandler{
    
    public static Boolean bypassTrigger{set;get;}
    public static Boolean bypassUserAccess = ! Utils.checkUserBypassAccess();
    
    public static User loggedInUser;
    
    public override void run(){
        if(bypassTrigger==null || bypassTrigger==false){
            super.run();
        }
    }
    
    public override void beforeInsert(){
        System.debug('GaranzieController.beforeInsert trigger- Start');
        
        GaranzieController.BeforeInsert(Trigger.new);
        GaranzieController.PreventGaranziaInStages(Trigger.new);
        
        System.debug('GaranzieController.beforeInsert trigger - End');   
    }
    
        public override void afterInsert(){
        System.debug('GaranzieController.beforeInsert trigger- Start');
        
        GaranzieController.AfterInsert(Trigger.new);
       // UpdateOppCountersAfterQuoteInsert(Trigger.new);

        System.debug('GaranzieController.beforeInsert trigger - End');   
    }
    
    public override void beforeUpdate()
    {   
        System.debug('GaranzieController.beforeUpdate trigger- Start');
        
        list<Garanzia__c> listBeforeUpdateTipo =new list<Garanzia__c>();
  
        for(Garanzia__c opp: (List<Garanzia__c>)Trigger.new)
        {
            
            Garanzia__c oldOpp = (Garanzia__c) Trigger.oldMap.get(opp.id);
            
           if((opp.Tipo_Confidi__c != oldOpp.Tipo_Confidi__c && opp.Tipo_di_Garanzia__c == 'Confidi')
               || (opp.Tipo_di_Fidejussione__c != oldOpp.Tipo_di_Fidejussione__c && opp.Tipo_di_Garanzia__c == 'Fidejussione'))
            { 
                listBeforeUpdateTipo.add(opp);
           }
        } 
        
        if(!listBeforeUpdateTipo.isempty()){
             GaranzieController.BeforeUpdate(listBeforeUpdateTipo); 
        } 
        
                 System.debug('GaranzieController.beforeUpdate trigger - End');
    }
    
    public override void afterUpdate()
    {   
        System.debug('GaranzieController.afterUpdate trigger- Start');
        list<Garanzia__c> GaranziaCuisaList =new list<Garanzia__c>();
        
        for(Garanzia__c opp: (List<Garanzia__c>)Trigger.new)
        {
            
            Garanzia__c oldOpp = (Garanzia__c) Trigger.oldMap.get(opp.id);
            if(opp.Stato_Garanzia__c != oldOpp.Stato_Garanzia__c && opp.Stato_Garanzia__c =='Chiusa')
            { 
                GaranziaCuisaList.add(opp);
            }
            
        } 
        if(!GaranziaCuisaList.isempty()){
            GaranzieController.GaranziaCuisa(GaranziaCuisaList);
        }

       // UpdateOppCountersAfterQuoteUpdate(Trigger.old);
        
        System.debug('GaranzieController.afterUpdate trigger - End');
    }//Da passare in PROD task 3132

    public override void beforeDelete()
    {  
        restrictUserFromDeletingGaranzies(Trigger.old);
        System.debug('Trigger before delete' + Trigger.old);
    } //fin qui

    /** Triggered after a Contact is deleted FROM the database **/
    public override void afterDelete() {
        UpdateOppCountersAfterQuoteDeleted(Trigger.old);
    }
    
      public static void GaranziaCuisa(List<Garanzia__c> newQuoteList){        
        System.debug('GaranzieController.GaranziaCuisa - Start newQuoteList '+newQuoteList);
        String userMail;
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        serializeCredential = JSON.serialize(elevaCredentials, true);
        System.debug('Eleva Credential flusso 6.2' + serializeCredential);
        System.debug('----> Flusso 6.2 <-------');

        List<Garanzia__c> updateGaranzia =new List<Garanzia__c>();
        
        //List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        if(loggedInUser == null){
            loggedInUser = [Select Id, Profile.Name from user where Id =: System.userInfo.getUserId()];    
        }
        String MyProflieName = loggedInUser.Profile.Name;
        System.debug('MyProflieName'+MyProflieName);
        for (Garanzia__c g :newQuoteList ){

            Garanzia__c a = new Garanzia__c();
            a.Id = g.Id;
            a.RecordTypeId = g.Record_Type_Only__c;
            updateGaranzia.add(a);

            if(MyProflieName !='Integrator'){
                userMail = g.Opportunit__r.Doc_Mail_User__c;
                // ElevaRestApiController.chuisuraGaranziaLineaSF(g.Id,g.Id_Garanzia_Oplon__c,serializeCredential,userMail);
            }
        }

        GaranzieController.bypassTrigger =true;
        update updateGaranzia;
        GaranzieController.bypassTrigger =false;
        system.debug('GaranzieController.BeforeInsert - End');

        
    }

    public static void BeforeInsert(List<Garanzia__c> newQuoteList){
  system.debug('GaranzieController.BeforeInsert - Start newQuoteList '+newQuoteList);
        list<Id> OpportunityList = new list<String>();
        
        Utils_Constants constants = new Utils_Constants();
        for (Garanzia__c newQuote : newQuoteList)
        { 
            OpportunityList.add(newQuote.Linea_di_Credito__c);
        }
        Map<ID,Quote> OpportunityMap = new Map<ID, Quote>([SELECT Id, Name, OpportunityId,(Select Id from Garanzie__r ) FROM Quote where Id in :OpportunityList]);
        Map<ID,Quote> OpportunityMCMap = new Map<ID, Quote>([SELECT Id, Name, OpportunityId,(Select Id, Tipo_di_Garanzia__c from Garanzie__r where Tipo_di_Garanzia__c='Fondo MCC' ) FROM Quote where Id in :OpportunityList]);
        
        System.debug(OpportunityMap);
        String newNameOpp ;
        
        List<ButtonFondo__mdt>  ButtonFondo = [SELECT TipiDiGaranzia__c, Buttone__c FROM ButtonFondo__mdt]; 
                List<Garanzia_Recordi__mdt>  garanziId = [select Id, DeveloperName, Id_Lending__c, Id_RO_Lending__c, Id_Inserimento__c from Garanzia_Recordi__mdt ]; 
System.debug('garanziId' +garanziId);
       
        
        for (Garanzia__c newQuote : newQuoteList)
        {
            
            for(Garanzia_Recordi__mdt garanzirec : garanziId){
                System.debug('kot.Id_Inserimento__c'+garanzirec.Id_Inserimento__c);
                 System.debug('newQuote.RecordTypeId'+newQuote.RecordTypeId);

                if (garanzirec.Id_Inserimento__c==newQuote.RecordTypeId){
                    System.debug('ha mo');
                    newQuote.RecordTypeId=garanzirec.Id_Lending__c;
                    newQuote.Record_Type_Landing__c=garanzirec.Id_Lending__c;
                    newQuote.Record_Type_Only__c=garanzirec.Id_RO_Lending__c;

                                        
                }
            }
            
            
            Boolean verifica=false;
            Boolean simulazione=false;
            Boolean congelamento=false;
            
            for ( ButtonFondo__mdt md :  ButtonFondo){
                if (md.TipiDiGaranzia__c==newQuote.Tipo_di_Garanzia__c){
                    if(md.Buttone__c== 'Verifica Fondo'){
                        verifica=true;
                    }
                    
                    if(md.Buttone__c== 'Simulazione Fondo'){
                        simulazione=true;
                    }
                    
                    if(md.Buttone__c== 'Congelamento Fondo'){
                        congelamento=true;
                    }
                    
                }
            }  
            
            if(verifica){
                newQuote.Verifica_fondo__c ='Da Verificare';
            }
            else{
                newQuote.Verifica_fondo__c ='Non Necessaria';
            }
            
            if(simulazione){
                newQuote.Esito_simulazione__c ='Da Simulare';
            }
            else{
                newQuote.Esito_simulazione__c ='Non Necessaria';
            }
            
            if(congelamento){
                newQuote.Esito_congelamento__c ='Da Congelare';
            }
            else{
                newQuote.Esito_congelamento__c ='Non Necessaria'; 
            }
            
            
            newQuote.Numero_Garanzia__c	= OpportunityMap.get(newQuote.Linea_di_Credito__c).Garanzie__r.size()+1;
            newQuote.Opportunit__c=OpportunityMap.get(newQuote.Linea_di_Credito__c).OpportunityId;
            
            if(newQuote.Tipo_di_Garanzia__c=='Fondo MCC'){
                
              
                if((OpportunityMCMap.get(newQuote.Linea_di_Credito__c).Garanzie__r.size())>=1){
                    if(bypassUserAccess)
                	{
                    	newQuote.addError('Garanzia Mcc già presente per la linea di credito');     
                    }
                    
                }
                else {
                    newNameOpp=newQuote.Tipo_di_Garanzia__c+' '+(OpportunityMap.get(newQuote.Linea_di_Credito__c).Garanzie__r.size()+1);
                    
                }
            }
            
            
            else if(newQuote.Tipo_di_Garanzia__c=='Fidejussione'){
                
             
                
                newNameOpp=newQuote.Tipo_di_Garanzia__c+' '+newQuote.Tipo_di_Fidejussione__c+' '+(OpportunityMap.get(newQuote.Linea_di_Credito__c).Garanzie__r.size()+1);
                
            }
            else if(newQuote.Tipo_di_Garanzia__c=='Confidi'){
              
                
                newNameOpp=newQuote.Tipo_di_Garanzia__c+' '+newQuote.Tipo_Confidi__c+' '+(OpportunityMap.get(newQuote.Linea_di_Credito__c).Garanzie__r.size()+1);
                 system.debug('newNameOpp '+newNameOpp);
            }
           
            else {
               
                
                newNameOpp=newQuote.Tipo_di_Garanzia__c+ ' '+(OpportunityMap.get(newQuote.Linea_di_Credito__c).Garanzie__r.size()+1);
                
            }
            system.debug('Quote'+newNameOpp);
            
            newQuote.Garanzie_Name__c= newNameOpp;
            
            //if(RecordTypeId != '') {
            //    newQuote.RecordTypeId = RecordTypeId;
        } 
        
        system.debug('GaranzieController.BeforeInsert - End');
    }
    
   public static void BeforeUpdate(List<Garanzia__c> newQuoteList){
       
        String newNameOpp ;
          
         for(Garanzia__c opp: newQuoteList){
             
               if(opp.Tipo_di_Garanzia__c == 'Confidi'){ 
                newNameOpp =opp.Tipo_di_Garanzia__c+' '+opp.Tipo_Confidi__c+' '+opp.Numero_Garanzia__c;
                 system.debug('newNameOpp '+newNameOpp);
            }
             
              else if(opp.Tipo_di_Garanzia__c=='Fidejussione'){
                newNameOpp=opp.Tipo_di_Garanzia__c+' '+opp.Tipo_di_Fidejussione__c+' '+opp.Numero_Garanzia__c;   
            }
             
               opp.Garanzie_Name__c= newNameOpp;
       }
   } 
    
    public static void AfterInsert(List<Garanzia__c> newGaranziaList){
        
        List<Quote> quoteUpdate = new List<Quote>();
        
        for(Garanzia__c gar : newGaranziaList){
            
            if(gar.Tipo_di_Garanzia__c == 'Sace'){
                Quote q = new Quote();
                q.id=gar.Linea_di_Credito__c;
                q.Categoria_Prodotto_Cedacri__c='202001';
                quoteUpdate.add(q);
            }
        }
        system.debug('quoteUpdate ' + quoteUpdate);
        update quoteUpdate;
    }
    //Da passare in Prod task 3132
    public static void restrictUserFromDeletingGaranzies(List<Garanzia__c> oldGaranziaList){
       System.debug('restrictUserFromDeletingGaranzies  STARY');
        Map<Id, Id> quoteIdGaranzieIdListMap = new Map<Id, Id>();
        Map<Id, String> garanzieIdOppStageMap = new Map<Id, String>();        
        
        if(loggedInUser == null){
            loggedInUser = [Select Id, Profile.Name from user where Id =: System.userInfo.getUserId()];    
        }
        
        System.debug('loggedInUser	--->'+loggedInUser.Profile.Name);
        for(Garanzia__c oGaranzia : oldGaranziaList){
        
            quoteIdGaranzieIdListMap.put(oGaranzia.Id , oGaranzia.Linea_di_Credito__c);   

            System.debug('quoteIdGaranzieIdListMap ' + JSON.serialize(quoteIdGaranzieIdListMap));        
            
        }
        for(Quote oQuote : [Select Id, OpportunityId, Opportunity.StageName from quote where Id IN: quoteIdGaranzieIdListMap.Values()])
        {
            garanzieIdOppStageMap.put(oQuote.Id, oQuote.Opportunity.StageName);
            System.debug('garanzieIdOppStageMap ' + JSON.serialize(garanzieIdOppStageMap));
            
        }
        
        for(Garanzia__c oGaranzia : oldGaranziaList){
        
            if(quoteIdGaranzieIdListMap.containsKey(oGaranzia.Id) )
            {
                if(garanzieIdOppStageMap.containsKey(quoteIdGaranzieIdListMap.get(oGaranzia.Id)) )
                {
                    String oppStageName = garanzieIdOppStageMap.get(quoteIdGaranzieIdListMap.get(oGaranzia.Id));
                    System.debug('Opp stagename ' + oppStageName);
                    if((oppStageName == 'PEF Pre-Istruttoria' || oppStageName == 'PEF Istruttoria' || oppStageName == 'Deliberata' || oppStageName == 'In Stipula'|| oppStageName == 'Firma' || oppStageName == 'In Erogazione') && loggedInUser.Profile.Name != 'System Administrator')
                    {
                        oGaranzia.addError('In questa fase dell\'opportunità non puoi eliminare Garanzie su Salesforce. È possibile farlo da Tigran!');
                    }
                } 
            }
        }
    }  //fin qui
    
    public static void PreventGaranziaInStages(List<Garanzia__c> newGaranziaList){

        Utils_Constants constants = new Utils_Constants();

        Map<Id, Id> GaranzieIdListMap = new Map<Id, Id>();

        Map<Id, String> garanzieIdStageMap = new Map<Id, String>();

       if(loggedInUser == null){
            loggedInUser = [Select Id, Profile.Name from user where Id =: System.userInfo.getUserId()];    
        }
        
        for(Garanzia__c grz : newGaranziaList){

            GaranzieIdListMap.put(grz.Id , grz.Linea_di_Credito__c);
        }
        for(Quote oQuote : [Select Id, OpportunityId, Opportunity.StageName from quote where Id IN: GaranzieIdListMap.Values()])
        {
            garanzieIdStageMap.put(oQuote.Id, oQuote.Opportunity.StageName);
        }
        for(Garanzia__c grz : newGaranziaList){

            if(GaranzieIdListMap.containskey(grz.Id) )
            {
                if(garanzieIdStageMap.containsKey(GaranzieIdListMap.get(grz.Id))) {

                    String oppStageName = garanzieIdStageMap.get(GaranzieIdListMap.get(grz.Id));
                    
                    if((oppStageName == 'Deliberata' || oppStageName == 'In Stipula' || oppStageName == 'Firma e Cessione' || oppStageName == 'In Erogazione'|| oppStageName == 'Closed') && loggedInUser.Profile.Name != 'System Administrator')
                    {
                        grz.addError(constants.ERROR_PREVENT_STAGE_GARANZIA);
                    }
                }
            }
        }
    }

    public static void UpdateOppCountersAfterQuoteDeleted(List<Garanzia__c> oldWarrantyList) {
        List<Id> oppIdList = GetOppIdListFromWarranty(oldWarrantyList);
        Map<String, Opportunity> opportunityMap = GetOpportunityMapFromQuoteIdList(oppIdList);
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(opportunityMap);
        OpportunityController.bypassTrigger = true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger = false;
    }

    public static void UpdateOppCountersAfterQuoteInsert(List<Garanzia__c> newWarrantyList) {
        List<Id> oppIdList = GetOppIdListFromWarranty(newWarrantyList);
        Map<String, Opportunity> opportunityMap = GetOpportunityMapFromQuoteIdList(oppIdList);
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(opportunityMap);

        OpportunityController.bypassTrigger = true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger = false;
    }

    public static void UpdateOppCountersAfterQuoteUpdate(List<Garanzia__c> updatedWarrantyList) {
        Set<String> garanziaSet = new Set<String>();
        for(Garanzia__c oGaran : updatedWarrantyList){
            garanziaSet.add(oGaran.Id);
        }
        if(! garanziaSet.isEmpty()){
            UpdateOppCountersAfterQuoteUpdateAsync(garanziaSet);
        }
    }
    @future
    public static void UpdateOppCountersAfterQuoteUpdateAsync(Set<String> updatedWarrantySetIds) {
        
        List<Garanzia__c> updatedWarrantyList = [Select Id,Opportunit__c from Garanzia__c WHERE Id IN:updatedWarrantySetIds];
        List<Id> oppIdList = GetOppIdListFromWarranty(updatedWarrantyList);
        Map<String, Opportunity> opportunityMap = GetOpportunityMapFromQuoteIdList(oppIdList);
        List<Opportunity> oppsToUpdate = GetUpdatedOpportunityCounters(opportunityMap);

        OpportunityController.bypassTrigger = true;
        update oppsToUpdate;
        OpportunityController.bypassTrigger = false;
    }

    public static List<Opportunity> GetUpdatedOpportunityCounters(Map<String, Opportunity> opportunityMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        Map<String, List<Document__c>> oppIdAndDocumentsMap = fileUploaderController.GetOppIdAndDocumentsMap(opportunityMap);
        Map<String, Map<String, Integer>> oppIdAndDocStatusMap = fileUploaderController.MapDocumentsConditions(oppIdAndDocumentsMap);
        Map<String, Map<String, DocumentType__c>> oppIdAndMandatoryDocTypeMap = fileUploaderController.GetMandatoryDocTypesMap(opportunityMap);
        List<Id> accountIdList = fileUploaderController.GetAccountIdList(opportunityMap.values());
        Map<Id, Integer> oppIdAndMandatoryContacts = fileUploaderController.computeUpdatedMandatoryContactDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap, accountIdList);
        Map<Id, Integer> oppIdAndMandatoryQuotes = fileUploaderController.computeUpdatedMandatoryQuoteDocTypes(oppIdAndMandatoryDocTypeMap, opportunityMap);

        for (Id oppId : oppIdAndDocStatusMap.keySet()) {
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

    private static List<Id> GetOppIdListFromWarranty(List<Garanzia__c> warrantyMap) {
        List<Id> oppIdList = new List<Id>();

        for (Garanzia__c warranty : warrantyMap) {
            if (!oppIdList.contains(warranty.Opportunit__c)) {
                oppIdList.add(warranty.Opportunit__c);
            }
        }

        return oppIdList;
    }

    public static Map<String, Opportunity> GetOpportunityMapFromQuoteIdList(List<Id> oppIdList) {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();

        for (Opportunity opp : [
                SELECT Id, Name, StageName, Total_Mandatories_Docs__c, RecordType.Id, RecordType.DeveloperName,
                        AccountId, Account.Societ_Appartiene_a_Gruppo__c, Tipo_di_Garanzia__c, Finalita_Finanziamento__c,
                        Account.Clientela_Incidenza__c, Account.Fidejussore__c
                FROM Opportunity
                WHERE Id IN :oppIdList
        ]) {
            opportunityMap.put(opp.Id, opp);
        }

        return opportunityMap;
    }
    
}