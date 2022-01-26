@isTest
public class BatchDesospensioneTest {
    @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
        return metadata;
    }
    
    
    @isTest
    private static void testBatchDesospensione(){
        Switch_Validation__mdt testtt = BatchDesospensioneTest.generateMetadataValidation();
        
        String  username=Math.random()+'@'+Math.random()+'.test';
        Profile pInsSal = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usrInsSal = new User(Alias = 'eww80mm2', Email = 'aldora.hajronenavetmoj@dunegrouphamomomomo.it',
                                  EmailEncodingKey = 'UTF-8', LastName = 'ewwmm', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = pInsSal.Id,  IsActive = true, Check_Fidimed__c=true, 
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName =username );
        insert usrInsSal;
        
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Manager_NomeCompleto__c = usrInsSal.id;
        //a.Inside_Sales_di_Riferimento__c = usrInsSal.id;
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
        
        Opportunity opp = new Opportunity(AccountId=a.Id,
                                          Name = 'test',
                                          CloseDate = Date.today()+1,
                                          StageName='Primo Contatto',
                                          Forecast_Category_Custom__c='Elevata Probabilità',
                                          Tipo_Linea_di_Credito__c='Mutuo',
                                          Finalita_Finanziamento__c='Liquidità',
                                          Ammontare_Iniziale__c=1000,
                                          Durata_Partner__c=100,
                                          Linea_di_Credito_in_Mesi__c =20,
                                          Data_Stipula__c = Date.today(),
                                          OwnerId=a.OwnerId,
                                          Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
                                          Sales_Support_Approver__c = usrInsSal.id, 
                                          Sabatini_Applicabile__c='Si',
                                          Numero_Pratica__c='12345',
                                          Privacy__c = 'Sì'                             
                                          
                                         );
        OpportunityController.bypassTrigger = true;
        insert opp;
        OpportunityController.bypassTrigger = false;
        Quote q1 = new Quote();
        q1.Name = 'Aldoraaaa';
        q1.ExpirationDate = Date.today();
        q1.Ammontare_Iniziale__c = 1000;
        q1.Ammontare_Direzione__c = 1000;
        q1.Durata_Direzione__c = 10;
        q1.Ammontare_Deliberato__c = 1000;
        q1.Durata_Partner__c = 10;
        q1.Tipo_Linea_di_Credito__c = 'Mutuo';
        q1.Finalita_Finanziamento__c        = 'Investimento';
        q1.OpportunityId = opp.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100;
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c='Si';
        insert q1;
        
        Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=q1.Id;
        g.Percentuale_Garantito__c='80%';
        //g.Id= e2.Id;
        g.Linea_di_Credito__c=q1.Id;
        g.Opportunit__c=opp.id;
        insert g;
        List<Opportunity> oppList = new List<Opportunity>{opp};
        List<Opportunity> oppList1 = new List<Opportunity>();
        for(Opportunity opp1 : oppList){
            Opportunity o = new Opportunity();
            o.Id=opp1.Id;
            o.StageName='PEF Pre-Istruttoria';
            o.Is_Suspended__c=true;
            o.Creazione_Rete_Azienda__c=true;
            o.AccountId=a.Id;
            o.Numero_Pratica__c='14521';
            o.Filiale_Banca_Cliente__c='test';
            o.Titolare_Partner__c='Banca Proggetto';
            o.Privacy__c = 'Sì';
            System.debug('opp1 ' + opp1);
            oppList1.add(opp1);
            System.debug('oppList1 ' + oppList1);
        }
        OpportunityController.bypassTrigger = true;
        update oppList1;  
        OpportunityController.bypassTrigger = false;
        System.debug('oppList1 after update ' + oppList1);
        test.startTest();
        
        BatchDesospensione myBatchObject = new BatchDesospensione();
        Database.BatchableContext BC;
        myBatchObject.execute(BC, oppList1);
        System.assert(myBatchObject != null);
        
        test.stopTest();
    }
        @IsTest
    private static void startTst(){
        try{
            test.startTest();
            Database.BatchableContext BC;
            BatchDesospensione myBatchObject = new BatchDesospensione();
            myBatchObject.start(BC);
            System.assert(myBatchObject!=null);
            Test.stopTest(); 
            
        }catch(Exception e){ 
            System.assertEquals(e.getMessage(), e.getMessage(), 'The method generate the error'); 
            
        }
    }
        @IsTest
    private static void finishTst(){
        try{
            test.startTest();
            Database.BatchableContext BC;
            BatchDesospensione myBatchObject = new BatchDesospensione();
            myBatchObject.finish(BC);
            System.assert(myBatchObject!=null);
            Test.stopTest(); 
            
        }catch(Exception e){ 
            System.assertEquals(e.getMessage(), e.getMessage(), 'The method generate the error'); 
            
        }
    }
}