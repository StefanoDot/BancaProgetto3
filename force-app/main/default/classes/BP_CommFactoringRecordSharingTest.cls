@isTest
public class BP_CommFactoringRecordSharingTest {
    
    @TestSetup
    static void makeData(){
        
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'Agente' LIMIT 1];
        UserRole userRole = [SELECT Id,DeveloperName from UserRole WHERE DeveloperName = 'Commerciale_Factoring_CF' LIMIT 1];
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User u = new User();
        System.runAs ( thisUser ) {
            u.Alias  = 'standt';
            u.Email = 'test@test.test';
            u.EmailEncodingKey = 'UTF-8';
            u.LastName = 'di Test';
            u.FirstName = 'Utente';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
            u.ProfileId = profileSys.Id;
            u.IsActive = true;
            u.UserRoleId = userRole.Id;
            u.TimeZoneSidKey = 'America/Los_Angeles';
            u.UserName = 'monica1@test.test';
            insert u;
        }
        Account acc = new Account();
        acc.Name = 'Test DOT Account';
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = '1548';
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
        acc.erogazione_dei_servizi__c='YES';
        acc.Scenario__c='A';
        insert acc;
        
        Opportunity o = new Opportunity(AccountId = acc.Id,
                                        Name = 'test',
                                        CloseDate = Date.today() + 1,
                                        StageName = 'Primo Contatto',
                                        Forecast_Category_Custom__c = 'Elevata Probabilità',
                                        Tipo_Linea_di_Credito__c = 'Mutuo',
                                        Finalita_Finanziamento__c = 'Liquidità',
                                        Ammontare_Iniziale__c = 1000,
                                        Durata_Partner__c = 100,
                                        Linea_di_Credito_in_Mesi__c = 20,
                                        Data_Stipula__c = Date.today(),
                                        OwnerMigrazione__c = 'Utente di Test',
                                        Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
                                        Sabatini_Applicabile__c = 'Si',
                                        Numero_Pratica__c = '12345');
        insert o;
        
    }
    @isTest
    public static void shareAccountRecWithCommFactoringTest(){
        
        Account ac = [Select Id,Sales_Crediti_Fiscali__c from Account where Name = 'Test DOT Account' Limit 1];
        User u = [Select Id from User where Email = 'test@test.test' limit 1];
        
        Test.startTest();
            ac.Sales_Crediti_Fiscali__c = u.Id;
            update ac;
        Test.stopTest();
    }
    @isTest
    public static void shareOppRecWithCommFactoringTest(){
        
        Opportunity op = [Select Id,Sales_owner_opportunita__c from Opportunity Limit 1];
        User u = [Select Id from User where Email = 'test@test.test' limit 1];
        
        Test.startTest();
            op.Sales_owner_opportunita__c = u.Id;
            update op;
        Test.stopTest();
    }
    
}