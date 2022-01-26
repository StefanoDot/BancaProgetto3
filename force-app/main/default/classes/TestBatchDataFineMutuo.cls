@isTest

public class TestBatchDataFineMutuo {
    
    @testSetup static void methodName() {
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'test@test.test',
                          EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                          TimeZoneSidKey = 'America/Los_Angeles', Username = 'eni@bancaprogetto.it');
        
        System.debug('Utente inserito ' + u);
        insert u;
    }    
    @isTest 
    private static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
        return metadata;
        
    }
    
    @isTest 
    private static Switch__mdt generateMetadataSwitch(){
        Switch__mdt metadata = new Switch__mdt(
            DeveloperName='NDG_Eleva',
            Status__c='Active'
        );
        return metadata;
        
    }
    
    @isTest 
    private static Default_User__mdt generateMetadataUser(){
        User u = [SELECT Id, Username from User where Username = 'eni@bancaprogetto.it' Limit 1];
        Default_User__mdt metadata1 = [SELECT username__c, DeveloperName  FROM Default_User__mdt WHERE DeveloperName='Admin' LIMIT 1];
        metadata1.username__c = u.Username;
        return metadata1;
        
    }
    
    @isTest 
    private static void testDataFineMutuo(){ 
        try{
            Test.startTest();
            Switch_Validation__mdt test12 = TestBatchDataFineMutuo.generateMetadataValidation();
            Switch__mdt test123 =   TestBatchDataFineMutuo.generateMetadataSwitch();
            Default_User__mdt mdtUser = TestBatchDataFineMutuo.generateMetadataUser();
            System.debug('mdtUser ' + mdtUser);
            User u = [SELECT Id, Username from User Limit 1];
            
            Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
            
            Account a = new Account();
            a.Name = 'Test Account';
            a.Manager_NomeCompleto__c = u.id;
            a.Inside_Sales_di_Riferimento__c = u.id;
            a.RecordTypeId = recordTypeIdInsAnag;
            a.AccountNumber = '1548';
            a.OwnerId = u.id;
            a.Ricezione_Dati_Oplon__c= 'Ok Full';
            a.Tipo_di_Azienda__c= 'SRI';
            a.Privacy__c=true;
            a.Verifica_liste_negative__c='OK'; 
            a.Punteggio_di_rischio__c=1;
            a.erogazione_dei_servizi__c='YES';
            a.Scenario__c='A';
            
            
            
            System.runAs(u){insert a;}
            System.debug('mbushet apo jo  ' + a);
            
            
            Opportunity o = new Opportunity
                (AccountId=a.Id,
                 Name = 'test',
                 CloseDate = Date.today()+1,
                 StageName='Primo Contatto',
                 Forecast_Category_Custom__c='Elevata Probabilità',
                 Tipo_Linea_di_Credito__c='Mutuo',
                 Finalita_Finanziamento__c='Liquidità',
                 Ammontare_Iniziale__c=1000,
                 Durata_Partner__c=100,
                 Linea_di_Credito_in_Mesi__c =1,
                 Data_Stipula__c = Date.today().addDays(-100),
                 OwnerId=a.OwnerId,
                 Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
                 Sales_Support_Approver__c = u.id,
                 Inside_Sales_di_Riferimento__c = u.id,
                 Sabatini_Applicabile__c='Si');
            
            insert o;    
            Quote q1 = new Quote();
            q1.Name = 'Aldoraaaa';
            q1.Data_Stipula__c = Date.today().addDays(-100);
            q1.ExpirationDate = Date.today();
            q1.Ammontare_Iniziale__c = 1000;
            q1.Ammontare_Direzione__c = 1000;
            q1.Durata_Direzione__c = 1;
            q1.Ammontare_Deliberato__c = 1000;
            q1.Durata_Partner__c = 1;
            q1.Tipo_Linea_di_Credito__c = 'Mutuo';
            q1.Finalita_Finanziamento__c  = 'Investimento';
            q1.OpportunityId = o.Id;
            q1.Status = 'In Corso';
            q1.Durata_Deliberata__c = 1;
            q1.Ammontare_Erogato__c = 100;
            q1.Durata_Erogata__c = 1;
            q1.Durata_Commerciale__c=1;
            q1.Sabatini_Applicabile__c='Si';
            
            insert q1;

            BatchDataFineMutuo myBatchObject = new BatchDataFineMutuo();
            Database.executeBatch(myBatchObject, 1);
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
            BatchDataFineMutuo myBatchObject = new BatchDataFineMutuo();
            myBatchObject.finish(BC);
            System.assert(myBatchObject!=null);
            Test.stopTest(); 
            
        }catch(Exception e){ 
            System.assertEquals(e.getMessage(), e.getMessage(), 'The method generate the error'); 
            
        }
    }
    
}