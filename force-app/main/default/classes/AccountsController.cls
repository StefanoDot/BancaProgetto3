public without sharing class AccountsController extends TriggerHandler{
    public static Boolean bypassTrigger{set;get;}
    public static Boolean recursiveTrigger = false;
    public static Boolean bypassUserAccess = ! Utils.checkUserBypassAccess();
    public static Utils_Constants constants = new Utils_Constants();
    
    public override void run(){
        if(bypassTrigger==null || bypassTrigger==false){
            super.run();
        }
    }
    public override void beforeInsert(){
        System.debug('AccountsController.beforeInsert trigger - Start');
        AccountsController.AssegnazioneManager(Trigger.new);
        AccountsController.backupTitolareeCanale(Trigger.new);
        AccountsController.billingAddressUpdate(Trigger.new);
         AccountsController.duplicatePartitaIva(Trigger.new);
        System.debug('AccountsController.beforeInsert trigger - End');
    }
    
    public override void afterInsert(){
        System.debug('AccountsController.afterInsert trigger - Start');
        List<Account> listGetMoreScoreData = new List<Account>();
        List<Account> acctsShreCFLst = new List<Account>();
        List<Account> acctsShreInsideSalesLst = new List<Account>();
        
        for(Account NewAcc: (List<Account>)Trigger.new)
        {
         //   if(NewAcc.Origine__c!='Portale_Imprese')
                listGetMoreScoreData.add(NewAcc);
            
            if( !String.isEmpty(NewAcc.Sales_Crediti_Fiscali__c) )
            {
                acctsShreCFLst.add(NewAcc);
            }
            if( !String.isEmpty(NewAcc.Inside_Sales_di_riferimento__c))
            {
                acctsShreInsideSalesLst.add(NewAcc);
            }
        }
        if(!listGetMoreScoreData.isEmpty()){
            AccountsController.getMoreScoreData(listGetMoreScoreData); 
        }
        AccountsController.AfterInsertAddDoc(Trigger.new);
        if(! acctsShreCFLst.isEmpty()){
            BP_AccountSharingManager.accountEditAccessForSalesCrediti(acctsShreCFLst);
        }
        if(! acctsShreInsideSalesLst.isEmpty()){
            BP_AccountSharingManager.accountEditAccessForInsideSales(acctsShreInsideSalesLst);
        }
        
        //AccountsController.AssegnazioneManager(Trigger.new);
        System.debug('AccountsController.afterInsert trigger - End');
    }
    
    public override void beforeUpdate(){
        System.debug('AccountsController.beforeUpdate trigger - Start');
        Utils_Constants constants = new Utils_Constants();
        List<Account> listActionBeforeUpdate = new List<Account>();
        List<Account> listBackupTitolareeCanale = new List<Account>();
        List<Account> listDocumentazioneFidejusore = new List<Account>();
        List<Account> listStatoEleggibilita = new List<Account>();
        List<Account> listBillingAdress = new List<Account>();
        List<Account> listricezioni = new List<Account>();
        
        
        for(Account NewAcc: (List<Account>)Trigger.new)
        {
            
            Account oldAcc= (Account) Trigger.oldMap.get(NewAcc.id);
            
            If(newAcc.Paese_Sede_Azienda__c<>oldAcc.Paese_Sede_Azienda__c||newAcc.Cap__c<>oldAcc.Cap__c || newAcc.Nome_Via__c<>oldAcc.Nome_Via__c|| newAcc.Provincia__c<>oldAcc.Provincia__c
               ||newAcc.Comune__c<>oldAcc.Comune__c){
                   listBillingAdress.add(newAcc);
               }
            if(NewAcc.Ricezione_Dati_Oplon__c <> oldAcc.Ricezione_Dati_Oplon__c ){
                listricezioni.add(newAcc);
            }
            if(NewAcc.Fidejussore__c == true && oldAcc.Fidejussore__c == false)
            {
                listDocumentazioneFidejusore.add(NewAcc);
            }    
            if(NewAcc.OwnerId <> oldAcc.OwnerId)
            {
                listBackupTitolareeCanale.add(NewAcc);
            }
            if(NewAcc.Account_Owner_Name__c != oldAcc.Account_Owner_Name__c &&( NewAcc.Account_Owner_Name__c != 'Banca Progetto Admin'||NewAcc.Account_Owner_Name__c != 'IT Banca Progetto' )){
                NewAcc.Manager_NomeCompleto__c = NewAcc.Manager_ID__c;
            }
            
            if(newAcc.CodiceKoOplon__c != oldAcc.CodiceKoOplon__c && newAcc.CodiceKoOplon__c != null && newAcc.Count_of_Opportunities__c  == oldAcc.Count_of_Opportunities__c )
            {
                system.Debug('Skip_BeforeUpdate');
            }
          
            if(newAcc.MoreScore__c != oldAcc.MoreScore__c || newAcc.Ricezione_Dati_Oplon__c != oldAcc.Ricezione_Dati_Oplon__c){
                listStatoEleggibilita.add(newAcc);
            }
            if(newAcc.Ricezione_Dati_Oplon__c != oldAcc.Ricezione_Dati_Oplon__c && newAcc.Ricezione_Dati_Oplon__c == 'Ok Full'){
                newAcc.Errore_Ricezione_Dati_Oplon__c = '';
            }
             if(newAcc.Comune__c != oldAcc.Comune__c && newAcc.Comune__c != ''){
                 newAcc.Casa_Comunale_Domicilio__c = newAcc.Comune__c;
            }
             if((NewAcc.Name != oldAcc.Name||NewAcc.Tipo_Via__c != oldAcc.Tipo_Via__c||NewAcc.Nome_Via__c != oldAcc.Nome_Via__c||NewAcc.Numero_Civico__c != oldAcc.Numero_Civico__c
             ||NewAcc.erogazione_dei_servizi__c != oldAcc.erogazione_dei_servizi__c||NewAcc.Ricerche_di_Mercato__c != oldAcc.Ricerche_di_Mercato__c||NewAcc.Dati_Particolari__c != oldAcc.Dati_Particolari__c
             ||NewAcc.Consenso_Sic__c != oldAcc.Consenso_Sic__c||NewAcc.Valutazione_Qualit_Servizio__c != oldAcc.Valutazione_Qualit_Servizio__c||NewAcc.Profilazione_Banca__c != oldAcc.Profilazione_Banca__c
             ||NewAcc.Marketing_Banca__c != oldAcc.Marketing_Banca__c||NewAcc.SAE__c != oldAcc.SAE__c||NewAcc.RAE__c != oldAcc.RAE__c||NewAcc.Provincia__c != oldAcc.Provincia__c||
                NewAcc.Cap__c != oldAcc.Cap__c||NewAcc.Comune__c != oldAcc.Comune__c)&&NewAcc.AccountNumber<>null){
                NewAcc.Aggiorna_Cedacri__c=true; 
            }
           
 
        }
        
        if(!listBillingAdress.isEmpty()){
            AccountsController.billingAddressUpdate(listBillingAdress); 
        }
        if(!listDocumentazioneFidejusore.isEmpty()){
            AccountsController.notifyMissingFieldsServiceFidejusioneBeforeUpdate(listDocumentazioneFidejusore);
        }

        if(!listStatoEleggibilita.isEmpty())
        {
            AccountsController.statoEleggibilita(listStatoEleggibilita);
        }
        //Commentato da Enxhisa per task 6017
       /* if(!listBackupTitolareeCanale.isEmpty()){
            AccountsController.backupTitolareeCanale(listBackupTitolareeCanale); 
        }*/
        
        if(!listricezioni.isEmpty()){
            AccountsController.NoopportunityKO(listricezioni);
        }   
        System.debug('AccountsController.beforeUpdate trigger - End');
    }
    
    public override void afterUpdate()
    {
        System.debug('AccountsController.afterUpdate trigger - Start');      
        List<Account> listGetAnagraphicDetails = new List<Account>();
        List<Account> listCheckComune = new List<Account>();
        List<Account> listNotifyMissingFields = new List<Account>();
        List<Account> listDocumentazioneFidejusore = new List<Account>();
        List<Account> listcollegamentoInsideSales = new List<Account>();
        List<Account> test = new List<Account>();
        List<String> accountIds = new List<String>();
        List<Account> ncgList = new List<Account>();
        List<Id> listupdareContatiInteresati = new List<Id>();
        List<Id> listCreaPDF = new List<Id>(); 
        List<Account> acctsShreCFLst = new List<Account>();
        List<Account> acctsShreInsideSalesLst = new List<Account>();
   		
        for(Account acc : (List<Account>)Trigger.new)
        {
            Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
            Utils_Constants constants = new Utils_Constants();                   
            accountIds.add(acc.Id);
            
            Account mapOldAccounts = (Account) Trigger.oldMap.get(acc.id);
            
            if(acc.Inside_Sales_di_riferimento__c != mapOldAccounts.Inside_Sales_di_riferimento__c){
                listcollegamentoInsideSales.add(acc);
            }
            
            if((acc.Ricezione_Dati_Oplon__c != mapOldAccounts.Ricezione_Dati_Oplon__c ||acc.Tipo_di_Azienda__c != mapOldAccounts.Tipo_di_Azienda__c) &&( 
                acc.Ricezione_Dati_Oplon__c=='Ok Full' && (
                acc.Errore_Ricezione_Dati_Oplon__c=='Modefinance Analysis Create Budget KO' || acc.Errore_Anagraphica_Light__c=='Modefinance Analysis Create Budget KO'))){
                        ncgList.add(acc);
                    } 
            if(acc.Ricezione_dati_Coface__c != mapOldAccounts.Ricezione_dati_Coface__c && acc.Ricezione_dati_Coface__c=='OK'){
                listCreaPDF.add(acc.Id);
            }        
            if((acc.MoreScore__c != mapOldAccounts.MoreScore__c  && (acc.MoreScore__c<>' ' && acc.MoreScore__c<>null) || (acc.No_MoreScore__c && acc.No_MoreScore__c!= mapOldAccounts.No_MoreScore__c ) )
               && acc.MoreScore__c != 'C' && acc.MoreScore__c != 'D' ){
                   listGetAnagraphicDetails.add(acc);
               }
            if(acc.Comune__c != mapOldAccounts.Comune__c && acc.Comune__c != null && acc.Comune__c != '')
            {
                listCheckComune.add(acc);
            }
            if(acc.Ricezione_Dati_Oplon__c != mapOldAccounts.Ricezione_Dati_Oplon__c && acc.Ricezione_Dati_Oplon__c == 'Ok Full')
            {
                
                listNotifyMissingFields.add(acc);
               
            }
            
            if(acc.Fidejussore__c == true && mapOldAccounts.Fidejussore__c == false)
            {
                listDocumentazioneFidejusore.add(acc);
            }       
            if(acc.Erogazione_dei_Servizi__c <> mapOldAccounts.Erogazione_dei_Servizi__c || acc.Marketing_Banca__c <> mapOldAccounts.Marketing_Banca__c || 
               acc.Profilazione_Banca__c <> mapOldAccounts.Profilazione_Banca__c || acc.Valutazione_Qualit_Servizio__c <> mapOldAccounts.Valutazione_Qualit_Servizio__c ||
               acc.Ricerche_di_Mercato__c <> mapOldAccounts.Ricerche_di_Mercato__c ||  acc.Dati_Particolari__c <> mapOldAccounts.Dati_Particolari__c ||
               acc.Consenso_Sic__c <> mapOldAccounts.Consenso_Sic__c)
            {
                listupdareContatiInteresati.add(acc.iD);
            }
            
            if( (!String.isEmpty(acc.Sales_Crediti_Fiscali__c)) && ( acc.Sales_Crediti_Fiscali__c != mapOldAccounts.Sales_Crediti_Fiscali__c ))
            {
                acctsShreCFLst.add(acc);
            }
            if( (!String.isEmpty(acc.Inside_Sales_di_riferimento__c)) && ( acc.Inside_Sales_di_riferimento__c != mapOldAccounts.Inside_Sales_di_riferimento__c ))
            {
                acctsShreInsideSalesLst.add(acc);
            }
     
        }
        
        if(!ncgList.isEmpty()){
            AccountsController.ncgCambiaMorescore(ncgList);
        }
        if(!listCreaPDF.isEmpty()){
            QueueableCofaceDocumentGeneration updateJob = new QueueableCofaceDocumentGeneration(listCreaPDF);
            ID jobID = System.enqueueJob(updateJob);
        }
        if(!listGetAnagraphicDetails.isEmpty()){
            AccountsController.getAnagraphicDetails(listGetAnagraphicDetails);
        }
        if(!listCheckComune.isEmpty()){
            AccountsController.checkComune(listCheckComune);
        }
        if(!listNotifyMissingFields.isEmpty()){
            AccountsController.notifyMissingFields(listNotifyMissingFields);   
        }
        if(!listDocumentazioneFidejusore.isEmpty()){
            AccountsController.DocumentazioneFidejusore(listDocumentazioneFidejusore);
            AccountsController.notifyMissingFieldsServiceFidejusione(listDocumentazioneFidejusore);
        }
        if(!listcollegamentoInsideSales.isEmpty()){
            AccountsController.collegamentoInsideSales(listcollegamentoInsideSales);
        }
        if(!listupdareContatiInteresati.isEmpty()){
            AccountsController.updareContatiInteresati(listupdareContatiInteresati);
        }       
        if(! acctsShreCFLst.isEmpty()){
            BP_AccountSharingManager.accountEditAccessForSalesCrediti(acctsShreCFLst);
        }
        if(! acctsShreInsideSalesLst.isEmpty()){
            BP_AccountSharingManager.accountEditAccessForInsideSales(acctsShreInsideSalesLst);
        }
        
        if(!accountIds.isEmpty() && !recursiveTrigger)
        {
            recursiveTrigger = true;
            isAccountsModifiedBySpecificAccounts(accountIds);            
        }      
        
        System.debug('AccountsController.afterUpdate - End');
    }
    
    public static void isAccountsModifiedBySpecificAccounts(List<String> accountIds)
    {
        String profiles = System.Label.Exclude_Profiles;
        List<String> profilesList = profiles.split(',');
        List<Account> accountList = [SELECT Id, LastModifiedById, OwnerId, LastModifiedBy.Profile.Name, Modified_Date_By_Specific_User__c, LastModifiedDate FROM Account WHERE Id IN : accountIds];
        List<Account> accountToBeUpdated = new List<Account>();
        for(Account acc : accountList)
        {
            if(acc.LastModifiedById == acc.OwnerId || acc.LastModifiedBy.Profile.Name.contains('Sales')){
                acc.Modified_Date_By_Specific_User__c = acc.LastModifiedDate;
                accountToBeUpdated.add(acc);
            }
        }
        if(!accountToBeUpdated.isEmpty()){
            update accountToBeUpdated;
        }
    }
    
    public static void ApexSharing(List<Account> acc){
        System.debug('jena fut qetu');
        
         
            List<AccountShare> jobShares = new List<AccountShare>();
        for(Account t : acc){
            
            AccountShare studentRecord = new AccountShare();
            studentRecord.AccountId = t.Id;
            studentRecord.UserOrGroupId =t.Inside_Sales_di_riferimento__c;
           studentRecord.AccountAccessLevel = 'Edit';
            

		studentRecord.CaseAccessLevel = 'Edit';
		studentRecord.OpportunityAccessLevel = 'Edit';
            studentRecord.RowCause = 'manual';
            jobShares.add(studentRecord);
            
        }
        try{
            insert   jobShares;    
        }catch(Exception e){
            System.debug('excption  '+ e.getMessage());
        }
    
    System.debug('jobShares'+jobShares);
            System.debug('jobShares'+jobShares[0].Id);

        
        
    }
    
    public  static void ncgCambiaMorescore(List<Account> accountsId){
        List<NoMoreScore_EP__mdt>  NoMoreScore = [select Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Name__c from NoMoreScore_EP__mdt ];       
        
        List<Account> accupdate = new List<Account>();
        For(Account acc : accountsId){
            Account accnew = new Account();
            accnew.Id = acc.Id;
            Boolean  easyplus = false;
            for ( NoMoreScore_EP__mdt md :  NoMoreScore){
                if(acc.Tipo_di_Azienda__c== md.Api_Name__c){
                    easyplus =true;
                }
            }
            if(easyplus==true){
                accnew.MoreScore__c='No Morescore'; 
            }
            else{
                accnew.MoreScore__c='CC';
            }
            accupdate.add(accnew);
        }     

        AccountsController.bypasstrigger=true;
        update accupdate;
        AccountsController.bypasstrigger=false;
    }
    
    public  static void NoopportunityKO(List<Account> acco){
        
        Utils_Constants costanti = new Utils_Constants();
        string RecordTypeNo = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(costanti.RECORD_TYPE_NoOpp).getRecordTypeId();
        string RecordTypeSi = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(costanti.RECORD_TYPE_BUSINESS).getRecordTypeId();
        
        /*List<RecordType> RecNoopp = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :costanti.RECORD_TYPE_NoOpp AND SobjectType = 'Account'];
        RecordTypeNo = RecNoopp.get(0).Id;
        
        List<RecordType> RecOpp = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :costanti.RECORD_TYPE_BUSINESS AND SobjectType = 'Account'];
        RecordTypeSi = RecOpp.get(0).Id;*/ 
        system.debug(RecordTypeNo);
          system.debug(RecordTypeSi);

        for(Account acc:acco){
            if(acc.Ricezione_Dati_Oplon__c != costanti.OPLON_OK_FULL && RecordTypeNo != ''){
                system.debug('a vjen ketu'+acc.Ricezione_Dati_Oplon__c);
                acc.RecordTypeId=RecordTypeNo;
            }
            else{
                acc.RecordTypeId=RecordTypeSi;
            }
        }
    }
    
    public  static void updareContatiInteresati(List<Id> accountsId){    
        System.debug('AccountsController.updareContatiInteresati - START accountsId' + accountsId);
        
        List<Contact> updateCont = new List<Contact>();
        
        For(Contact CON : [Select id,Skip_Flag_Privacy__c,Interessato__c,Erogazione_dei_Servizi__c,Marketing_Banca__c,Profilazione_Banca__c,Valutazione_Qualita_Servizio__c,Ricerche_di_Mercato__c,Dati_Particolari__c,Consenso_Sic__c,
                           Account.erogazione_dei_servizi__c,Account.Marketing_Banca__c,Account.Profilazione_Banca__c,Account.Valutazione_Qualit_Servizio__c,Account.Ricerche_di_Mercato__c,Account.Dati_Particolari__c,Account.Consenso_Sic__c
                           from Contact where AccountId IN: accountsId AND Interessato__c= true ]){
                               Contact cont = new Contact();
                               cont.Id= CON.Id;
                               cont.Erogazione_dei_Servizi__c=CON.Account.erogazione_dei_servizi__c;
                               cont.Marketing_Banca__c=CON.Account.Marketing_Banca__c;
                               cont.Profilazione_Banca__c=CON.Account.Profilazione_Banca__c;
                               cont.Valutazione_Qualita_Servizio__c=CON.Account.Valutazione_Qualit_Servizio__c;
                               cont.Ricerche_di_Mercato__c = CON.Account.Ricerche_di_Mercato__c;
                               cont.Dati_Particolari__c= CON.Account.Dati_Particolari__c;
                               cont.Consenso_Sic__c= CON.Account.Consenso_Sic__c;
                               if(CON.Skip_Flag_Privacy__c == null){
                                   cont.Skip_Flag_Privacy__c=1;
                               }
                               else{ cont.Skip_Flag_Privacy__c =CON.Skip_Flag_Privacy__c+1;
                                   }
                               updateCont.add(cont);             
                           }
        System.debug('AccountsController.updareContatiInteresati - End - updateCont '+updateCont);
        update updateCont;   
    }
    
    public  static String getredirectToAccountCreation(){
        System.debug('AccountsController.getredirectToAccountCreation - Start');
        
        String UserType = UserInfo.getUserType();
        
        if(UserType == 'PowerPartner')
        {
            network myNetwork = [SELECT Id,Name  FROM Network WHERE Name ='Banca Progetto' ];
            system.debug(myNetwork );
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            
            system.debug('myCommunity ' + myCommunity);
            
            System.debug('AccountsController.getredirectToAccountCreation - End ' + myCommunity.siteUrl +'/s/account-creation');
            
            return myCommunity.siteUrl +'/s/account-creation';           
        }
        else
        {     System.debug(URL.getSalesforceBaseUrl().getProtocol()+'://'+URL.getSalesforceBaseUrl().getHost()+'/lightning/n/Account_Creation');
         
         System.debug('AccountsController.getredirectToAccountCreation - End');
         
         return URL.getSalesforceBaseUrl().getProtocol()+'://'+URL.getSalesforceBaseUrl().getHost()+'/lightning/n/Account_Creation';
        }    
    }
    
    @RemoteAction
    public static List<AccoutSearchBean> searchAccount(String name, String partitaIva, String codiceFiscale, String telefono) {
        
        System.debug('AccountsController searchAccount-Start '+'name: '+name+' partitaIva: '+partitaIva+ 
                     ' codiceFiscale: '+codiceFiscale+ 'telefono: ' +telefono);
        
        name = (!String.isEmpty(name)) ? '%' + String.escapeSingleQuotes(name) + '%' : null;
        partitaIva = (!String.isEmpty(partitaIva)) ? String.escapeSingleQuotes(partitaIva) : null;
        codiceFiscale = (!String.isEmpty(codiceFiscale)) ? String.escapeSingleQuotes(codiceFiscale) : null;
        telefono = (!String.isEmpty(telefono)) ? String.escapeSingleQuotes(telefono) : null;
        if (name != null || partitaIva != null || codiceFiscale != null || telefono != null) {
            List<Account> accountsWS = AccountsWithSharingDAO.searchAccount(new String[]{
                'Id'
                    }, name, partitaIva, codiceFiscale, telefono);
            System.debug('AccountsController searchAccount accountsWS'+accountsWS);
            
            List<Account> accounts = AccountsDAO.searchAccount(new String[]{
                'Name', 'Owner.Name', ' Partita_Iva__c', 'Codice_Fiscale__c', 'BillingState',
                    'BillingPostalCode', 'Phone', 'Type', 'Owner.Profile.Name', 'RecordTypeId'
                    }, name, partitaIva, codiceFiscale, telefono);
            System.debug('AccountsController searchAccount '+accounts);
            
            List<Account> filteredAccounts = AccountsDAO.filterAccountsByRecordType(accounts, 'Anagrafica_Partner');
            
            Set<String> accountIdsWS = Utils.creteSetIds(accountsWS, 'Id');
            system.debug('accountIdsWS'+accountIdsWS);
            List<AccoutSearchBean> searchResults = new List<AccoutSearchBean>();
            for (Account acc : filteredAccounts) {
                if (accountIdsWS.contains(acc.Id)) {
                    searchResults.add(new AccoutSearchBean(acc, 1));
                } else if (acc.Owner.Profile.Name.containsIgnoreCase('Admin') || acc.Owner.Profile.Name.containsIgnoreCase('Administrator') || acc.Owner.Profile.Name.containsIgnoreCase('Amministratore')) {
                    acc.Phone = null;
                    searchResults.add(new AccoutSearchBean(acc, 2));
                } else {
                    acc.Phone = null;
                    searchResults.add(new AccoutSearchBean(acc, 0));
                }
            }
            System.debug('AccountsController searchAccount-End '+searchResults);
            return searchResults;
        }
        System.debug('AccountsController searchAccount-End ');
        return new List<AccoutSearchBean>();
    }
    
    @RemoteAction
    public static String assignToCurrentUser(String accId) {
        System.debug('AccountsController assignToCurrentUser-Start '+accId);
        User u = UsersDAO.getUsersFromIds(new String[]{
            'Id', 'Name', 'IsPortalEnabled'
                }, new Set<String>{
                    UserInfo.getUserId()
                        })[0];
        System.debug('**** User u ' + u);
        System.debug('**** u.isPortalEnabled ' + u.isPortalEnabled);
      //  if (!u.IsPortalEnabled) {
            Account acc = new Account(Id = accId, OwnerId = u.Id);
            update acc;
      /*  } else {
            Account acc = AccountsDAO.getAccountFromIds(new String[]{
                'Id', 'BillingPostalCode', 'BillingState', 'OwnerId'
                    }, new Set<String>{
                        accId
                            })[0];
            System.debug('**** Account acc ' + acc);
            acc.OwnerId = u.Id;
            Set<String> newOwnerIds = assignAccounts(new Account[]{
                acc
                    });
            if (newOwnerIds.size() > 0) {
                u = UsersDAO.getUsersFromIds(new String[]{
                    'Id', 'Name'
                        }, newOwnerIds)[0];
                System.debug('**** User u 2 ' + u);
            }
            acc.Ricezione_Dati_Oplon__c = null;
            acc.Manager_NomeCompleto__c = null;
            update acc;
        }*/
        System.debug('AccountsController assignToCurrentUser-End ');
        return u.Name;
    }
    
    public class AccoutSearchBean {
        public Account account;
        public Integer action;
        public Boolean showDetails;
        
        public AccoutSearchBean(Account acc, Integer action) {
            System.debug('AccoutSearchBean Controller-Start '+'acc: '+acc+' action: '+action);
            this.account = acc;
            this.action = action;
            this.showDetails = false;
            System.debug('AccoutSearchBean Controller-End ');
        }
    }
    
    public static void triggerHandlerAssignAccounts(List<Account> accounts, Map<Id, Account> oldMap) {
        System.debug('AccountsController triggerHandlerAssignAccounts-Start '+'accounts: '+accounts+' oldMap: '+oldMap);
        List<Account> accountsToAssign = new List<Account>();
        for (Account acc : accounts) {
            Account oldAcc = oldMap.get(acc.Id);
            system.debug(acc.Id);
            system.debug(oldAcc);
            if (
                //COMMENTATO per call con ROBERTO ACONE
                //acc.AccountSource == 'Inserimento Manuale' &&
                //(oldAcc.BillingStreet == null && oldAcc.BillingCity == null && oldAcc.BillingState == null  && oldAcc.BillingpostalCode == null) &&
                (acc.BillingStreet != null || acc.BillingCity != null || acc.BillingState != null || acc.BillingpostalCode != null)) {
                    accountsToAssign.add(acc);
                }
        } 
        if (!accountsToAssign.isEmpty()) {
            assignAccounts(accountsToAssign);
        }
        System.debug('AccountsController triggerHandlerAssignAccounts-End ');
    }
    
    public static Set<String> assignAccounts(List<Account> accounts) {
        
        system.debug('AccountsController assignAccounts-Start accounts: '+accounts);
        
        Set<String> newOwnerIds = new Set<String>();
        if (!accounts.isEmpty()) {
            Set<String> userIds = new Set<String>();
            for (Account acc : accounts) {
                userIds.add(acc.OwnerId);
            }
            List<Matrice_Di_Assegnazione__c> matriceList = MatriceDiAssegnazioneDAO.getMatriceDiAssegnazione(new String[]{
                'CAP__c', 'Codice_Comune__c',
                    'Codice_Provincia__c', 'Sales_di_Riferimento__c', 'Regione__c'
                    });
            Map<String, Matrice_Di_Assegnazione__c> capMap = MatriceDiAssegnazioneService.createCAPMap(matriceList);
            Map<String, Matrice_Di_Assegnazione__c> stateMap = MatriceDiAssegnazioneService.createStateMap(matriceList);
            Map<String, User> usersMap = new Map<String, User>(UsersDAO.getUsersFromIds(new String[]{
                'Id', 'Profile.Name'
                    }, userIds));
            system.debug(capMap);
            system.debug(stateMap);
            //List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();
            
            for (Account acc : accounts) {
                system.debug(acc.BillingPostalCode);
                system.debug(capMap.containsKey(acc.BillingPostalCode));
                system.debug(stateMap.containsKey(acc.BillingState));
                
                if (capMap.containsKey(acc.BillingPostalCode) || stateMap.containsKey(acc.BillingState)) {
                    Matrice_Di_Assegnazione__c cap = (capMap.containsKey(acc.BillingPostalCode)) ? capMap.get(acc.BillingPostalCode) : stateMap.get(acc.BillingState);
                    if (cap.Codice_Provincia__c != 'duplicate') {
                        if (usersMap.get(acc.OwnerId).Profile.Name == 'Agente') {
                            acc.Canale__C = 'Agente';
                        } else if (usersMap.get(acc.OwnerId).Profile.Name == 'Intermediario Finanziario') {
                            acc.Canale__C = 'Intermediario Finanziario';
                        } else if (usersMap.get(acc.OwnerId).Profile.Name == 'Mediatore Creditizio') {
                            acc.Canale__C = 'Mediatore Creditizio';
                        } else {
                            acc.Canale__c = 'Contatto Diretto';
                        }
                        acc.Inside_Sales_di_riferimento__c = cap.Sales_di_Riferimento__c;
                        acc.region__c = cap.Regione__c;
                        acc.Errore_Assegnazione_Account__c = false;
                        acc.Motivo_Errore_Assegnazione_Account__c = null;
                        newOwnerIds.add(acc.OwnerId);
                        
                    } else {
                        acc.Errore_Assegnazione_Account__c = true;
                        acc.Motivo_Errore_Assegnazione_Account__c = System.Label.ErroreAssegnazioneLead_ProvinciaDuplicata;
                    }
                } else {
                    acc.Errore_Assegnazione_Account__c = true;
                    acc.Motivo_Errore_Assegnazione_Account__c = System.Label.ErroreAssegnazioneLead_NessunaAssegnazioneTrovata;
                }
            }
        }
        system.debug('AccountsController assignAccounts-End newOwnerIds' +newOwnerIds);
        
        return newOwnerIds;
    }
    
    public static void ActionBeforeUpdate(List<Account> newAccList, Map<Id, Account> oldAccMap){
        System.debug('AccountsController.ActionBeforeUpdate - Start newAccList'+' oldAccMap '+oldAccMap);
        Utils_Constants constants = new Utils_Constants();
        String businessId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_BUSINESS).getRecordTypeId();
        /*List<RecordType> accBusinessRT = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :constants.RECORD_TYPE_BUSINESS AND SobjectType = 'Account'];
        if (accBusinessRT.size() > 0) {
            businessId = accBusinessRT.get(0).Id;
        }*/
        for (Account newAcc : newAccList)
        {   
            Account oldAcc= oldAccMap.get(newAcc.id);
            if (newAcc.Ricezione_Dati_Oplon__c ==constants.OPLON_OK_LIGHT ){//&& newAcc.MoreScore__c != oldAcc.MoreScore__c
                System.debug('AccountsController ActionBeforeUpdate OK Light');
                if(newAcc.MoreScore__c =='C' || newAcc.MoreScore__c =='D' || newAcc.MoreScore__c ==''){
                    System.debug('AccountsController ActionBeforeUpdate OK Light Non Eleggibile');
                    newAcc.Type=constants.TYPE_NON_ELEGGIBILE;
                    newAcc.CodiceKoOplon__c ='';
                    newAcc.Errore_Ricezione_Dati_Oplon__c='';
                }
                else{
                    newAcc.Type=constants.TYPE_ELEGGIBILE;
                    System.debug('AccountsController ActionBeforeUpdate OK Light Eleggibile');
                    newAcc.CodiceKoOplon__c ='';
                    newAcc.Errore_Ricezione_Dati_Oplon__c='';
                }
            }
            if(oldAcc.Ricezione_Dati_Oplon__c == constants.OPLON_OK_FULL && ((newAcc.Ricezione_Dati_Oplon__c == constants.OPLON_OK_LIGHT && newAcc.MoreScore__c == oldAcc.MoreScore__c) 
                                                                             || newAcc.Ricezione_Dati_Oplon__c ==constants.OPLON_KO_LIGHT))
            {
                newAcc.Ricezione_Dati_Oplon__c= constants.OPLON_OK_FULL;
                newAcc.Errore_Ricezione_Dati_Oplon__c='';
            }
            
            else if(newAcc.Ricezione_Dati_Oplon__c == constants.OPLON_KO_LIGHT ){
                newAcc.Type=constants.TYPE_NON_ELEGGIBILE;
            }
            
            if(newAcc.Ricezione_Dati_Oplon__c == constants.OPLON_OK_FULL ){
                newAcc.CodiceKoOplon__c ='';
                newAcc.Errore_Ricezione_Dati_Oplon__c='';
            }
            if(newAcc.RecordTypeId == businessId && newAcc.Fax == null)
                newAcc.Fax = '0';
            system.debug('AccountsController ActionBeforeUpdate - End   RecordType: ' +newAcc.Record_Type_Name__c);
        }
    }
    
    public static void getMoreScoreData(List<Account> newAccounts) {
        
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        
        serializeCredential = JSON.serialize(elevaCredentials, true);
        System.debug('Eleva Credential flusso 1.1 ' + serializeCredential);
        System.debug('AccountsController GetMoreScore - Start');
        
        //TODO: FAR PARTIRE IL TRIGGER IN BASE AL PROFILE??
        Utils_Constants constants = new Utils_Constants();
        String businessId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.RECORD_TYPE_ANAGRAF).getRecordTypeId();
        
        /*List<RecordType> accBusinessRT = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :constants.RECORD_TYPE_ANAGRAF AND SobjectType = 'Account'];
        if (accBusinessRT.size() > 0) {
            businessId = accBusinessRT.get(0).Id;
        }*/
        List<Account> toBeProcessed = new List<Account>();
        for (Account acc : newAccounts) {
            if (acc.RecordTypeId == businessId) {
                if (acc.Codice_Fiscale__c != null) {
                    toBeProcessed.add(acc);
                }
            }
        }
        for (Account acc : toBeProcessed) {
            
            ElevaRestApiController.getMoreScoreTrigger(acc.Codice_Fiscale__c, acc.Id, acc.userMail__c,acc.Anagrafica_Id_Oplon__c,serializeCredential);
        
             }
        System.debug('AccountsController GetMoreScore - End');
    }
    
    public static void getAnagraphicDetails(List<Account> toBeProcessed ) {
        System.debug('AccountsController getAnagraphicDetails - Start toBeProcessed'+toBeProcessed);
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        serializeCredential = JSON.serialize(elevaCredentials, true);
        
        System.debug('Eleva Credential flusso 1.1 ' + serializeCredential);

        for (Account acc : toBeProcessed) {
             
            ElevaRestApiController.getAnagraphicDetailsTrigger(acc.Codice_Fiscale__c, acc.Id, acc.userMail__c,serializeCredential, acc.updateOplonUserEmail__c, acc.Anagrafica_Id_Oplon__c);
        }
        System.debug('AccountsController getAnagraphicDetails - End');     
    }
    
    public static void AfterInsertAddDoc(List<Account> newAccList){
        system.debug('AccountController.AfterInsertAddDoc Start newAccList'+newAccList);
        List<DocumentType__c> docType = [SELECT Id, ObjectName__c , Referente_Fidejussore__c, Opportunita_Mutuo__c FROM DocumentType__c where Opportunita_Mutuo__c=true and ObjectName__c='Account' ];
        List<Document__c> docList = new List<Document__c> ();
        
        for (Account acc : newAccList) {
            if(acc.Fidejussore__c == true){
                for (DocumentType__c doc : docType) {
                    if( doc.ObjectName__c=='Account'){
                        docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = doc.Id ));
                    }
                }
            }   
            
            else if (acc.Fidejussore__c == false){
                
                for (DocumentType__c doc : docType) {
                    if( doc.ObjectName__c=='Account' && doc.Referente_Fidejussore__c==false){
                        docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = doc.Id ));
                    }
                }
            }
        }
        system.debug('AccountController.AfterInsertAddDoc - End   docList:'+docList);
        insert docList;
    }
    
    
    public static void DocumentazioneFidejusore(List<Account> newAccounts){
        System.debug('AccountsController.DocumentazioneFidejusore - Start newAccounts '+newAccounts); 
        Set<Id> stAccIds = new Set<Id>(); //Suppose this set has Account Ids 
        List<DocumentType__c> docType = [SELECT Id, ObjectName__c,Referente_Fidejussore__c, Opportunita_Mutuo__c FROM DocumentType__c where ObjectName__c='Account' and Opportunita_Mutuo__c=true];        
        List<Document__c> docList = new List<Document__c> ();        
        
        Map<Id,Integer> ContactIdWithDocumentFidejusoreCountInt = new Map<Id,Integer>();        
        
        for(Account acc : newAccounts){ 
            stAccIds.add(acc.Id);
        }
        for(Account acc : [SELECT Id,Name,(SELECT Id,DocumentType__r.Referente_Fidejussore__c  FROM Documenti__r where DocumentType__r.Referente_Fidejussore__c= true AND DocumentType__r.ObjectName__c= 'Account') FROM Account WHERE Id In :stAccIds])
            
        { ContactIdWithDocumentFidejusoreCountInt.put(acc.Id,acc.Documenti__r.size()); }
        
        for(Account acc : newAccounts) {
            
            if(ContactIdWithDocumentFidejusoreCountInt.get(acc.id)==0 ){
                for (DocumentType__c doc : docType) {
                    if(doc.ObjectName__c=='Account' && doc.Referente_Fidejussore__c== true ){
                        
                        docList.add(new Document__c(
                            Account__c = acc.Id,
                            DocumentType__c = doc.Id
                        ));
                    }
                }
            }
        }
        
        insert docList;  
        
        System.debug('AccountsController.DocumentazioneFidejusore - End docList'+docList);  
    }
    
    public static list<Account> notifyMissingFieldsServiceFidejusione(List<Account> toBeProcessed){
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusione start toBeProcessed: ' +toBeProcessed);
        
        List<String> accountFieldList = new List<String>{
            'Phone','Cellulare__c',
                'Name','Tipo_di_Azienda__c','Cittadinanza__c','Lingua__c','Italia__c','Tipo_Via__c','Nome_Via__c','Provincia__c','Comune__c','Cap__c','Email__c',
                'Fax','Codice_Fiscale__c','Ind_Marketing__c', 'Agenzia__c','Client_Manager__c','Numero_Civico__c','Codice_Estero__c','SAE__c','Ateco_2007__c','Numero_CCIAA_REA__c',
                'Data_Iscrizione_Legale__c','Provincia_Iscrizione_Legale__c','Res_Valutaria__c','Appellativo__c','Convenzione__c',
                'erogazione_dei_servizi__c','Marketing_Banca__c','Profilazione_Banca__c','Valutazione_Qualit_Servizio__c','Ricerche_di_Mercato__c','Dati_Particolari__c','Consenso_Sic__c'
                };
                    
                    Utils_Constants costants =new Utils_Constants();
        String CONTACT_LEGALE_RAPPRESENTANTE= costants.CONTACT_LEGALE_RAPPRESENTANTE;
        String CONTACT_TITOLARE_EFFETTIVO= costants.CONTACT_TITOLARE_EFFETTIVO;
        
        List<Account> toBeUpdated = new List<Account>();
        
        for (Account acc : toBeProcessed) {
            Boolean test=false;
            Boolean test2=false;
            string accController='N';
            String accountMissingFields ='';
            for (String accF : accountFieldList) {
                if (accF=='Phone' && (acc.get(accF) != null  && acc.get(accF) != '')){   
                    test=true;
                }
                
                if(accF=='Cellulare__c' && (acc.get(accF) != null  && acc.get(accF) != '')){
                    test2=true;
                }
                
                if (acc.get(accF) == null || acc.get(accF) == '') {
                    
                    if(accF=='Cellulare__c' && test==false){
                        accountMissingFields = accountMissingFields + 'Telefono oppure '; 
                    }
                    
                    if((accF=='Phone' && test2==false) || (accF=='Cellulare__c' && test==true)){
                        continue;
                    }
                    
                    String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                    accController='Y';
                    accountMissingFields = accountMissingFields + fieldLabel + ', '; 
                }
            }
            
            If(accountMissingFields != ''){
                
                accountMissingFields = 'Account:<br/> '+accountMissingFields;
                accountMissingFields = accountMissingFields.removeEnd(', ');
                accountMissingFields = accountMissingFields + '<br/>';
            }
            System.debug('AccountsController notifyMissingFieldsServiceFidejusione accountMissingFields: ' +accountMissingFields);
            String accId = acc.Id;
            Account accToBeUpdated = new Account(Id = accId);
            accToBeUpdated.campi_mancanti_fidejussione__c = accountMissingFields;
            if(accToBeUpdated.campi_mancanti_fidejussione__c=='')
            {
                accToBeUpdated.fidejussore_completo__c= true;
            }
            else
            {
                accToBeUpdated.fidejussore_completo__c= false;
            }
            toBeUpdated.add(accToBeUpdated);
        }
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusione - End  Account:' + toBeUpdated);
        return toBeUpdated;
    }
    
    public static void notifyMissingFieldsServiceFidejusioneBeforeUpdate(List<Account> toBeProcessed){
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusioneBeforeUpdate start toBeProcessed: ' +toBeProcessed);
        
        List<String> accountFieldList = new List<String>{
            'Phone','Cellulare__c',
                'Name','Tipo_di_Azienda__c','Cittadinanza__c','Lingua__c','Italia__c','Tipo_Via__c','Nome_Via__c','Provincia__c','Comune__c','Cap__c','Email__c',
                'Fax','Codice_Fiscale__c','Ind_Marketing__c', 'Agenzia__c','Client_Manager__c','Numero_Civico__c','Codice_Estero__c','SAE__c','Ateco_2007__c','Numero_CCIAA_REA__c',
                'Data_Iscrizione_Legale__c','Provincia_Iscrizione_Legale__c','Res_Valutaria__c','Appellativo__c','Convenzione__c',
                'erogazione_dei_servizi__c','Marketing_Banca__c','Profilazione_Banca__c','Valutazione_Qualit_Servizio__c','Ricerche_di_Mercato__c','Dati_Particolari__c','Consenso_Sic__c'
                };
                    List<Account> toBeUpdated = new List<Account>();
        
        for (Account acc : toBeProcessed) {
            Boolean test=false;
            Boolean test2=false;
            string accController='N';
            String accountMissingFields ='';
            for (String accF : accountFieldList) {
                if (accF=='Phone' && (acc.get(accF) != null  && acc.get(accF) != '')){   
                    test=true;
                }
                
                if(accF=='Cellulare__c' && (acc.get(accF) != null  && acc.get(accF) != '')){
                    test2=true;
                }
                if (acc.get(accF) == null || acc.get(accF) == '') {
                    
                    if(accF=='Cellulare__c' && test==false){
                        accountMissingFields = accountMissingFields + 'Telefono oppure '; 
                    }
                    
                    if((accF=='Phone' && test2==false) || (accF=='Cellulare__c' && test==true)){
                        continue;
                    }
                    String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                    accController='Y';
                    accountMissingFields = accountMissingFields + fieldLabel + ', ';
                } 
            }
            
            If(accountMissingFields != ''){
                accountMissingFields = 'Account:<br/> '+accountMissingFields;
                accountMissingFields = accountMissingFields.removeEnd(', ');
                accountMissingFields = accountMissingFields + '<br/>';
            }
            System.debug('AccountsController notifyMissingFieldsServiceFidejusioneBeforeUpdate accountMissingFields: ' +accountMissingFields);
            acc.campi_mancanti_fidejussione__c = accountMissingFields;
            if(acc.campi_mancanti_fidejussione__c=='')
            {
                acc.fidejussore_completo__c= true;
            }
            else
            {
                acc.fidejussore_completo__c= false;
            }
            toBeUpdated.add(acc);
        }
        System.debug('AccountsController.notifyMissingFieldsServiceFidejusioneBeforeUpdate - End  Account:' + toBeUpdated);
    }
    
    
    public static void notifyMissingFields(List<Account> toBeProcessed) {
        System.debug('AccountsController.notifyMissingFields - Start toBeProcessed' + toBeProcessed);
        if (toBeProcessed.size() > 0) {
            notifyMissingFieldsService(toBeProcessed);
        }
        System.debug('AccountsController.notifyMissingFields - End');
    }
    
    public static list<Account> notifyMissingFieldsService(List<Account> toBeProcessed){
        System.debug('AccountsController.notifyMissingFieldsService start toBeProcessed: ' +toBeProcessed);
        
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Referente_Oplon'];
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
            System.debug('AccountsController notifyMissingFieldsService RecTid: ' +recordTypeId);
        }*/
        
        List<String> accountFieldList = new List<String>{
            'Phone','Cellulare__c',
                'Name','Tipo_di_Azienda__c','Cittadinanza__c','Lingua__c','Italia__c','Tipo_Via__c','Nome_Via__c','Provincia__c','Comune__c','Cap__c','Email__c',
                'Fax','Codice_Fiscale__c','Ind_Marketing__c', 'Agenzia__c','Client_Manager__c','Numero_Civico__c','Codice_Estero__c','SAE__c','Ateco_2007__c','Numero_CCIAA_REA__c',
                'Data_Iscrizione_Legale__c','Provincia_Iscrizione_Legale__c','Res_Valutaria__c','Appellativo__c','Convenzione__c',
                'erogazione_dei_servizi__c','Marketing_Banca__c','Profilazione_Banca__c','Valutazione_Qualit_Servizio__c','Ricerche_di_Mercato__c','Dati_Particolari__c','Consenso_Sic__c'
                };
                    List<String> contactFieldList = new List<String>{
                        'Phone','MobilePhone',
                            'AccountId','Agenzia__c', 'Appellativo__c', 'CAE__c', 'Cap__c', 'Cittadinanza__c', 'Client_Manager__c', 'Comune_di_Nascita__c',
                            'Comune__c', 'Convenzione__c', 'Data_di_Nascita__c', 'Data_Rilascio__c', 'Data_Scadenza__c', 'Dati_Identificativi_Cliente_Potenziale__c',
                            'Dipendente__c', 'Email', 'FinServ__Gender__c', 'FirstName','Indicativo_Marketing__c', 'Lingua__c',
                            'LastName', 'Localita_Residenza__c', 'Localita__c', 'Luogo_Rilascio__c',  'Nome_Via__c', 'Numero_Civico__c', 'Numero_Documento__c',
                            'Oplon_Codice_Fiscale__c',  'Professione__c', 'Provincia__c', 'RAE__c', 'Residenza__c', 'ResValutaria__c','Esecutore__c','Firmatario__c','Fidejussore__c','percentuale_di_riferimento_socio__c','Altre_Cariche_Flag__c',
                            'SAE__c', 'Sigla_Provincia_Nascita__c', 'Stato_di_Nascita__c', 'Stato_Nascita__c', 'Stato_Residenza_Estero__c', 'TAE__c', 'Tipo_Documento__c',
                            'Tipo_Via__c', 'TitNon_Acc__c','Ricerche_di_Mercato__c', 'Erogazione_dei_Servizi__c', 'Marketing_Banca__c', 'Profilazione_Banca__c', 'Valutazione_Qualita_Servizio__c', 'Dati_Particolari__c', 'Consenso_Sic__c'
                            };
                                
                                List<Id> listAccountId = new List<Id>();
        Map<String, List<Contact>> mapAccCont = new Map<String, List<Contact>>();
        for (Account acc : toBeProcessed) {
            listAccountId.add(acc.Id);
            List<Contact> listCont = new List<Contact>();
            mapAccCont.put(acc.Id, listCont);
            
        }
        System.debug('AccountsController notifyMissingFieldsService mapAccCont: ' +mapAccCont);
        Utils_Constants costants =new Utils_Constants();
        String CONTACT_LEGALE_RAPPRESENTANTE= costants.CONTACT_LEGALE_RAPPRESENTANTE;
        String CONTACT_TITOLARE_EFFETTIVO= costants.CONTACT_TITOLARE_EFFETTIVO;
        String contactFieldsString = String.join(contactFieldList, ',');
//E SAKTA String queryContactString = 'SELECT ' + contactFieldsString + ' FROM Contact WHERE ((Esecutore__c = true OR Firmatario__c = true OR Fidejussore__c = true  OR percentuale_di_riferimento_socio__c <> null OR Altre_Cariche_Flag__c =true)AND Ruolo_in_Azienda__c <> null) AND AccountId IN :listAccountId';     

        String queryContactString = 'SELECT ' + contactFieldsString + ' FROM Contact WHERE (Esecutore__c = true OR Firmatario__c = true OR Fidejussore__c = true OR Ruolo_in_Azienda__c <> null OR percentuale_di_riferimento_socio__c <> null OR Altre_Cariche_Flag__c =true) AND AccountId IN :listAccountId LIMIT 20';     
        List<Contact> listContact = (List<Contact>) (Database.query(queryContactString));
        
        for (Contact cont : listContact) {
            List<Contact> listContTemp = mapAccCont.get(cont.AccountId);
            listContTemp.add(cont);
            mapAccCont.put(cont.AccountId, listContTemp);
        }
        System.debug('AccountsController notifyMissingFieldsService listContact: ' +listContact);
        List<Account> toBeUpdated = new List<Account>();
        
        for (Account acc : toBeProcessed) {
            Boolean test=false;
            Boolean test2=false;
            String totalString = '';
            string accController='N';
            string contController='N';
            String accountMissingFields ='Account:<br/>';
            String contactMissingFields = 'Contatti:<br/>';
            
            for (String accF : accountFieldList) {
                if (accF=='Phone' && (acc.get(accF) != null  && acc.get(accF) != '')){   
                    test=true;
                }
                
                if(accF=='Cellulare__c' && (acc.get(accF) != null  && acc.get(accF) != '')){
                    test2=true;
                }
                if (acc.get(accF) == null || acc.get(accF) == '') {
                    if(accF=='Cellulare__c' && test==false){
                        accountMissingFields = accountMissingFields + 'Telefono oppure '; 
                        
                    }
                    
                    if((accF=='Phone' && test2==false) || (accF=='Cellulare__c' && test==true)){
                        continue;
                    }
                    String fieldLabel = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(accF).getDescribe().getLabel();
                    accController='Y';
                    accountMissingFields = accountMissingFields + fieldLabel + ', ';
                }
            }
            accountMissingFields = accountMissingFields.removeEnd(', ');
            accountMissingFields = accountMissingFields + '<br/>';
            System.debug('accountMissingFields'+accountMissingFields);
            
            List<Contact> listContTemp = mapAccCont.get(acc.Id);
            for (Contact cont : listContTemp) {
                Boolean testCont=false;
                Boolean testCont2=false;
            
               
                contactMissingFields = contactMissingFields + 'Contatto ' + '<b>'+cont.FirstName + '</b>'+' ' + '<b>'+cont.LastName + '</b>'+ ':<br/>';
                for (String contF : contactFieldList) {
                    
                    if (contF=='Phone' && (cont.get(contF) != null  && cont.get(contF) != '')){   
                        testCont=true;
                    }
                    
                    if(contF=='MobilePhone' && (cont.get(contF) != null  && cont.get(contF) != '')){
                        testCont2=true;
                    }
                    
                    if (contF == 'Sigla_Provincia_Nascita__c' || contF == 'Comune_di_Nascita__c' || contF == 'Localita__c') {
                        if (cont.Stato_Nascita__c == 'Italia') {
                            if (cont.get(contF) == null || cont.get(contF) == '') {
                                String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                contactMissingFields = contactMissingFields + fieldLabel + ', ';
                                contController='Y';
                            }
                        }
                    }
                    
                    else if (contF == 'Stato_di_Nascita__c') {
                        if (cont.Stato_Nascita__c == 'Estero') {
                            if (cont.get(contF) == null || cont.get(contF) == '') {
                                String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                contactMissingFields = contactMissingFields + fieldLabel + ', ';
                                contController='Y';
                            }
                        }
                    }
                    
                    else if (contF == 'Tipo_Via__c' || contF == 'Provincia__c' || contF == 'Comune__c' || contF == 'Cap__c') {
                        if (cont.Residenza__c == 'Italia') {
                            if (cont.get(contF) == null || cont.get(contF) == '') {
                                String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                contactMissingFields = contactMissingFields + fieldLabel + ', ';
                                contController='Y';
                            }
                        }
                    }
                    
                    else if (contF == 'Stato_Residenza_Estero__c') {
                        if (cont.Residenza__c == 'Estero') {
                            if (cont.get(contF) == null || cont.get(contF) == '') {
                                String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                                contactMissingFields = contactMissingFields + fieldLabel + ', ';
                                contController='Y';
                            }
                        }
                    }
                    
                    else if (cont.get(contF) == null || cont.get(contF) == '') {
                        if(contF=='MobilePhone' && testCont==false){
                            contactMissingFields = contactMissingFields + 'Telefono oppure '; 
                        }
                        
                        if((contF=='Phone' && testCont2==false) || (contF=='MobilePhone' && testCont==true)){
                            continue;
                        }
                        
                        
                        String fieldLabel = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(contF).getDescribe().getLabel();
                        if(fieldLabel == 'Mobile Phone'){
                            contactMissingFields = contactMissingFields + 'Cellulare, '; 
                            continue;
                        }
                        
                        contactMissingFields = contactMissingFields + fieldLabel + ', ';
                        contController='Y';
                    }
                }
                
                contactMissingFields = contactMissingFields.removeEnd(', ');
                contactMissingFields = contactMissingFields + '<br/></br>';
            }
            System.debug('AccountsController notifyMissingFieldsService accountMissingFields: ' +accountMissingFields);
            System.debug('AccountsController notifyMissingFieldsService contactMissingFields: ' +contactMissingFields);
            
            
            if(contController =='Y' && accController =='Y')
                totalString = accountMissingFields +'</br>'+ contactMissingFields;
            else if (accController =='Y')
                totalString = accountMissingFields;
            else if (contController =='Y')
                totalString = contactMissingFields;
            
            String accId = acc.Id;
            System.debug('AccountsController notifyMissingFieldsService totalString: ' +totalString);
            Account accToBeUpdated = new Account(Id = accId);
            
          String  FinalUpdate='';
            if(totalString.length() >=131070){
                FinalUpdate=totalString.substring(0, 131070);
            }
            else {
                                FinalUpdate=totalString;

            }
            accToBeUpdated.Campi_Cedacri_Mancanti__c = FinalUpdate;
            if(accToBeUpdated.Campi_Cedacri_Mancanti__c=='')
            {
                accToBeUpdated.Anagrafica_Completa__c= 'True';
            }
            else
            {
                accToBeUpdated.Anagrafica_Completa__c= 'False';
            }
            toBeUpdated.add(accToBeUpdated);
        }
        
        update toBeUpdated;
        System.debug('AccountsController.notifyMissingFieldsService - End  toBeUpdated:' + toBeUpdated);
        return toBeUpdated;
    }
    
    public static void checkComune(List<Account> toBeProcessed){
        System.debug('AccountsController checkComune - Start toBeProcessed '+ toBeProcessed);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        /*List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Referente_Oplon'];
        if(recordTypes.size()>0){
            recordTypeId = recordTypes.get(0).Id;
        }*/
        
        List<Account> toBeUpdated = new List<Account>();
        
        List<Id> listAccountId = new List<Id>();
        Map<String, List<Contact>> mapAccCont = new Map<String, List<Contact>>();
        
        List<String> ComuneTrimmedUpperList = new List<String>();
        
        for (Account acc : toBeProcessed) {
            String accComuneTrimmedUpper = acc.Comune__c.trim().toUpperCase();
            ComuneTrimmedUpperList.add(accComuneTrimmedUpper);
            listAccountId.add(acc.Id);
            List<Contact> listCont = new List<Contact>();
            mapAccCont.put(acc.Id, listCont);
        }
        
        System.debug('ComuneTrimmedUpperList' + ComuneTrimmedUpperList);
        
        String queryContactString = 'SELECT Id, AccountId, Comune__c, Name FROM Contact WHERE RecordTypeId = :recordTypeId AND AccountId IN :listAccountId';
        List<Contact> listContact = (List<Contact>) (Database.query(queryContactString));
        
        for (Contact cont : listContact) {
            if(cont.Comune__c != null && cont.Comune__c != ''){
                String contComuneTrimmedUpper = cont.Comune__c.trim().toUpperCase();
                ComuneTrimmedUpperList.add(contComuneTrimmedUpper);
                List<Contact> listContTemp = mapAccCont.get(cont.AccountId);
                listContTemp.add(cont);
                mapAccCont.put(cont.AccountId, listContTemp);
            }
        }
        List<Matrice_di_Assegnazione__c> matriceDiAssegnazione = [SELECT Id, Name FROM Matrice_di_Assegnazione__c Where Name =:ComuneTrimmedUpperList];
        
        if(matriceDiAssegnazione.size() > 0){
            
            List<String> matriceDiAssegnazioneComuni = new List<String>();
            
            for(Matrice_di_Assegnazione__c mda : matriceDiAssegnazione){
                matriceDiAssegnazioneComuni.add(mda.Name);
            }  
            
            
            for(Account acc : toBeProcessed){
                
                String finalMessage = '';
                
                String accComuneTrimmedUpper = acc.Comune__c.trim().toUpperCase();
                
                if(!matriceDiAssegnazioneComuni.contains(accComuneTrimmedUpper)){
                    finalMessage = finalMessage + 'Account '+acc.Name+':<br/>';
                    finalMessage = finalMessage + 'Comune: '+acc.Comune__c;
                    finalMessage = finalMessage + '<br/>';
                }
                
                for(Contact cont : mapAccCont.get(acc.Id)){
                    
                    if(cont.Comune__c != null && cont.Comune__c != '') {
                        
                        String contComuneTrimmedUpper = cont.Comune__c.trim().toUpperCase();
                        
                        if (!matriceDiAssegnazioneComuni.contains(contComuneTrimmedUpper)) {
                            finalMessage = finalMessage + 'Contact ' + cont.Name + ':<br/>';
                            finalMessage = finalMessage + 'Comune: ' + cont.Comune__c + ':<br/>';
                        }
                        
                    }
                    
                }
                String accId = acc.Id;
                Account accToBeUpdated = new Account(Id= accId);
                accToBeUpdated.Comune_Dicitura_Errata__c = finalMessage;
                //       if(finalMessage != '') {
                toBeUpdated.add(accToBeUpdated);
                //       }
                
            }
            
            /*   if(!Test.isRunningTest()) {
update toBeUpdated;
System.debug('AccountsController checkComune - End');
}
*/
        }  
    }
    
    
    public static void AssegnazioneManager(List<Account> newAccList){
        
        System.debug('AccountsController.AssegnazioneManager - Start newAccList'+ newAccList);
        
        for (Account acc : newAccList) {
            acc.Fax='0';
            
            if(acc.Manager_ID__c != null){
                
                acc.Manager_NomeCompleto__c = acc.Manager_ID__c;
                
                
            }
            
        }
        System.debug('AccountsController.AssegnazioneManager - END');
    }
    
    public static void backupTitolareeCanale(List<Account> newAccList){
        
        System.debug('AccountsController.backupTitolareeCanale - Start newAccList'+newAccList);
        
        Set<Id> ownerIDs = new Set<Id>();
        for( Account acc : newAccList )
        {
            
            if( acc.OwnerId != null )
            {
                ownerIDs.add( acc.OwnerId );
            }    
        }
        Map<Id, User> ownerMap = new Map<Id, User>([ Select Id, ProfileId, Profile.Name From User where Id IN: ownerIDs ]);
        
        for( Account a : newAccList )
        {
            if( ownerMap.containsKey( a.OwnerId ) )
            {
                system.debug('Account Owner Profile Name ==> ' + ownerMap.get( a.OwnerId ).Profile.Name);
                String Profile = ownerMap.get( a.OwnerId ).Profile.Name;
                
                if(Profile <> 'System Administrator' && Profile <> 'Integrator' && Profile <> 'Amministratore del sistema')
                {
                    switch on Profile{
                        when 'Agente'
                        {
                            a.Canale__c = 'Agente';
                        } 
                        when 'Intermediario Finanziario'{
                            a.Canale__c = 'Intermediario Finanziario';
                        }
                        when 'Mediatore Creditizio'
                        {
                            a.Canale__c = 'Mediatore Creditizio';
                        }
                        when else{
                            a.Canale__c = 'Contatto Diretto';
                        }
                        
                    }
                    a.Titolare__c= a.OwnerId;  
                }
            }   
        }   
        System.debug('AccountsController.backupTitolareeCanale - End');
    }
    
    
     public static void collegamentoInsideSales(List<Account> newAccList){
        
        System.debug('Accounts.Controller.collegamentoInsideSales - Start newAccList' +newAccList);
        
        List<Opportunity> updateOpportunity = new List<Opportunity>();
        Set<Id> accIds = new Set<Id>();
        for (Account acc :newAccList ){
            accIds.add(acc.Id); 
        }
        
        for(Opportunity opp : [Select Id, Inside_Sales_di_Riferimento__c, Account.Inside_Sales_di_riferimento__c, Account.Sales_Crediti_Fiscali__c, Tipo_Linea_di_Credito__c,StageName  from Opportunity where AccountId IN : accIds ]){
            if((opp.Tipo_Linea_di_Credito__c =='Mutuo' || opp.Tipo_Linea_di_Credito__c == 'Crediti fiscali') && (opp.StageName != 'Chiusa/Persa' && opp.StageName != 'Erogata')){
                Opportunity oppNew = new Opportunity();
                oppNew.Id = opp.Id;
                oppNew.Inside_Sales_di_Riferimento__c = opp.Account.Inside_Sales_di_riferimento__c;
                oppNew.Sales_Crediti_Fiscali__c = opp.Account.Sales_Crediti_Fiscali__c;
                oppNew.Sales_owner_opportunita__c = opp.Account.Inside_Sales_di_riferimento__c;
                
                updateOpportunity.add(oppNew);
            }
        }
        System.debug('Accounts.Controller.collegamentoInsideSales - End updateOpportunity' + updateOpportunity);
        
        update updateOpportunity;
    }
    
    public static void statoEleggibilita(List<Account> newAccList){
        System.debug('Accounts.Controller.statoEleggibilita - Start newAccList' + newAccList);
        
        Utils_Constants constants = new Utils_Constants();
        List<String> partitaIva = new List<String>();
        
        for (Account newAcc : newAccList)
        {   
            
            if(newAcc.MoreScore__c =='C' || newAcc.MoreScore__c =='D' || newAcc.MoreScore__c ==''){                  
                newAcc.Type=constants.TYPE_NON_ELEGGIBILE;
                
            }
            else{
                newAcc.Type=constants.TYPE_ELEGGIBILE;
            }
            
        }
        System.debug('Accounts.Controller.statoEleggibilita - End');
        
    }
    
    
    public static void attachPDFSync(List<Id> listCreaPDF){
        system.debug('AccountsController.attachPDF --- Start');
        
        List<ContentVersion> cntVersion = new List<ContentVersion>();
        List<ContentDocumentLink> cntDocLink = new List<ContentDocumentLink>();
        List<Document__c> docList = new List<Document__c>();
        
        
        Map<Id, ID > accDoc= new Map<Id,Id>();
        
        for(Account acc : [Select id ,Name ,(Select id, Name, DocumentTypeNameFormula__c from Documenti__r where DocumentTypeNameFormula__c = 'Analisi Coface' )from Account where id in : listCreaPDF ]){
            Id docId = acc.Documenti__r[0].Id;
            accDoc.put(acc.Id, docId );
            
        }
        
        for(Id accId : listCreaPDF){
            
            PageReference pdfPage = Page.AccountPDF; 
            pdfPage.getParameters().put('id', accId);
            if(!Test.isRunningTest()){ 
                Blob pdfContent = pdfPage.getContentAsPdf();
                
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S';
                cVersion.PathOnClient = 'Analisi Coface.pdf';
                cVersion.Origin = 'H';
                cVersion.Title = 'Analisi Coface.pdf';
                cVersion.VersionData = pdfContent;
                if(accDoc.get(accId) !=null) {
                    cVersion.Description=accDoc.get(accId);
                    
                    cntVersion.add(cVersion);
                }
            }
        }
        insert cntVersion;
        
        for(ContentVersion c : [SELECT Id, ContentDocumentId, VersionData, Description, Title FROM ContentVersion WHERE Id IN:cntVersion]){
            
            Document__c doc = new Document__c();
            
            doc.id=c.Description;
            doc.Id_File__c=c.ContentDocumentId;
            doc.File_Name__c = 'Analisi Coface';
            doc.Url_Servizio_Esterno__c=c.Title;
            Datetime uploadDate = Datetime.now();
            doc.Data_Caricamento__c = uploadDate;
            doc.Verifica_Sales_Support__c='Verifica OK';
            docList.add(doc);

        }
        update docList;
        
        
        system.debug('AccountsController.attachPDF --- End docList '+docList);
    }
    
    public static void billingAddressUpdate(List<Account> accList){
        system.debug('AccountsController.billingAddressUpdate --- Start accList '+accList);
        for(Account a : accList){
            a.BillingPostalCode= a.Cap__c; 
            //   a.BillingCountry= '';          
            a.BillingStreet= a.Indirizzo_Sede_Legale_Esteso__c;
            a.BillingCity= a.Comune__c;
            //   a.BillingState= 'Italia';
        }
        system.debug('AccountsController.billingAddressUpdate --- End'); }
 /*  public static void duplicatePartitaIva(List<Account> accList){
        system.debug('AccountsController.duplicatePartitaIva --- Start');

        List<Account> acc = [select Id, Partita_Iva__c, Codice_Fiscale__c  from Account]; 
        
        Account a = accList[0];
        system.debug('a'+ a);

        for(Account oldacc : acc){
        if(a.Codice_Fiscale__c == oldacc.Partita_Iva__c){
            a.addError('Questa anagrafica gia esiste in sistema');
        }
        
        }
        
    }*/
    public static void duplicatePartitaIva(List<Account> accList){
        system.debug('AccountsController.duplicatePartitaIva --- Start');
         list<string> accountCodice=new list<string>();
        for(Account accountVar:accList)
    {
        accountCodice.add(accountVar.Codice_Fiscale__c);
    }
   list<Account> listOfDuplicateAccounts=[select id,name,Partita_Iva__c from Account where Partita_Iva__c in :accountCodice];
   Map<string,Account> duplicateaccIds= new Map<string,Account>();
        
        for(account dup: listOfDuplicateAccounts )
	{
		duplicateaccIds.put(dup.Partita_Iva__c,dup);
	}
       
 for(account a : accList)
	{
		if(a.Codice_Fiscale__c!=null)
		{
			if(duplicateaccIds.containsKey(a.Codice_Fiscale__c))
			{
                if(bypassUserAccess)
                {
					a.addError('Questa anagrafica gia esiste in sistema');
                }
			}
		}
	}
	
}
}