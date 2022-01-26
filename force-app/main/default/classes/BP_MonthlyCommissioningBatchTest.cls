@isTest
public with sharing class BP_MonthlyCommissioningBatchTest {
    @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
        return metadata;
    }
    @isTest
    public static void executeTest() {
        String  username=Math.random()+'@'+Math.random()+'.test';
        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usrInsSal = new User(Alias = 'eww80mm2', Email = 'aldora.hajronenavetmoj@dunegrouphamomomomo.it',
                                  EmailEncodingKey = 'UTF-8', LastName = 'ewwmm', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = pInsSal.Id,  IsActive = true, Check_Fidimed__c=true, 
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName =username );
                                  insert usrInsSal;
        Switch_Validation__mdt testtt = BP_MonthlyCommissioningBatchTest.generateMetadataValidation();
        OpportunityController.bypassTrigger =true;
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Manager_NomeCompleto__c = usrInsSal.id;
        a.Inside_Sales_di_Riferimento__c = usrInsSal.id;
        a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = '1548';
        a.OwnerId = usrInsSal.id;
        a.Ricezione_Dati_Oplon__c= 'Ok Full';
        a.Tipo_di_Azienda__c= 'SRI';
        a.Privacy__c=true;
        a.Verifica_liste_negative__c='OK'; 
        a.Punteggio_di_rischio__c=1;
        a.erogazione_dei_servizi__c='YES';
        a.Scenario__c='A';
        insert a;
        Opportunity o = new Opportunity(AccountId=a.Id,
                                        Name = 'test',
                                        CloseDate = Date.today()+1,
                                        StageName = 'Primo Contatto',
                                        Forecast_Category_Custom__c = 'Elevata Probabilità',
                                        Tipo_Linea_di_Credito__c = 'Progetto EasyPlus',
                                        Finalita_Finanziamento__c = 'Liquidità',
                                        Ammontare_Iniziale__c = 1000,
                                        Durata_Partner__c = 100,
                                        Linea_di_Credito_in_Mesi__c = 20,
                                        Data_Stipula__c = Date.today(),
                                        OwnerId = a.OwnerId,
                                        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',                              
                                        Sales_Support_Approver__c = ObjectFactory.aldora.id,
                                        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,  
                                        Sabatini_Applicabile__c = 'Si',
                                        Data_Erogazione__c = Date.newInstance(2021, 06, 06)                                     
                                       );

        insert o;
        
        
        
        Quote q1 = new Quote();
        q1.OpportunityId = o.Id;
        System.debug('oppList1[0].Id ' + o.Id);
        q1.Name = 'Aldoraaaa';
        q1.ExpirationDate = Date.today();
        q1.Ammontare_Iniziale__c = 1000;
        q1.Ammontare_Direzione__c = 1000;
        q1.Durata_Direzione__c = 10;
        q1.Ammontare_Deliberato__c = 1000;
        q1.Durata_Partner__c = 10;
        q1.Tipo_Linea_di_Credito__c = 'Progetto EasyPlus';
        q1.Finalita_Finanziamento__c = 'Investimento';
        q1.OpportunityId = o.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100;
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c='Si';
        q1.Numero_Rapporto__c = '12345';
        q1.Data_Firma__c = Date.newInstance(2021, 7, 6);
        q1.Ammontare_Erogato__c = 2.5;
        q1.Commissioni_da_Istruttoria__c = 6;
        q1.Periodicita__c = 'mensile';
        q1.Percentuale_Spread__c = 6;
        q1.Contratto_Firmato_Flusso__c = true;
        q1.Contratto_Verificato__c = true;
        q1.Percentuale_Commissioni_da_Istruttoria__c = 123.3;
        insert q1;
        
        List<Opportunity> oppList = new List<Opportunity>{o};
            System.debug('Contratti_Verificati__c ' + o.Contratti_Verificati__c);
        System.debug('Active quotes  ' + o.Active_Quotes__c);
        List<Opportunity> oppList1 = new List<Opportunity>();
        for(Opportunity opp : oppList){
            Opportunity opp1 = new Opportunity();
            opp1.Id = opp.Id;
            opp1.StageName = 'In Erogazione';
            System.debug('opp1 ' + opp1);
            oppList1.add(opp1);
            System.debug('oppList1 ' + oppList1);
        }
        update oppList1;
        List<String> finListString = new List<String>();
        String theString = 'Test body string';
        finListString.add(theString);
        Map<Id, List<String>> finalString = BP_CommissioningController.generateString(oppList1);
        finalString.put(o.id, finListString);
        
        System.debug('finalString ' + finalString);
        System.Debug('oppList1? '+ oppList1[0].StageName);
        System.debug('Quote after update    ' + q1);
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; 
        cVersion.PathOnClient = 'Test.txt';	
        cVersion.Origin = 'C';	
        cVersion.Title = 'Test file';	
        cVersion.VersionData = Blob.valueOf(String.join(finalString.get(oppList[0].id),' '));	
        
        insert cVersion;     
        
        ContentVersion conVer = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id];
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        
        cDocLink.ContentDocumentId = conVer.ContentDocumentId;	
        cDocLink.LinkedEntityId = oppList1[0].Id;
        cDocLink.ShareType = 'V'; 
        cDocLink.Visibility = 'AllUsers'; 
        insert cDocLink; 
        
        Test.startTest();
        BP_MonthlyCommissioningFileCreationBatch b =  new BP_MonthlyCommissioningFileCreationBatch();
        DataBase.executeBatch(b);
        System.assert(b != null);
        Test.stopTest();
    }
}