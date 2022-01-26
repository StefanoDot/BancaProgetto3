@isTest
public class CompletamentoDocumentiCreditiTest {
    @TestSetup
    static void makeData(){
        Utils_Constants constants = new Utils_Constants();
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Profile profileSys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'test@test.test',
                            EmailEncodingKey = 'UTF-8', LastName = 'di Test', FirstName = 'Utente', LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', ProfileId = profileSys.Id, IsActive = true,
                            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'monica1@test.test');
        insert u;
        Account acc = new Account();
        acc.Name = 'kottt mooouyuyuyuyu';
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = 'ggggg';
        acc.Ricezione_Dati_Oplon__c= constants.OPLON_OK_FULL;
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Punteggio_di_rischio__c=1;
        acc.OwnerId = u.id;
        insert acc;
        Opportunity o = new Opportunity(AccountId=acc.Id,
                                        Name = 'test',
                                        CloseDate = Date.today()+1,
                                        StageName=constants.OPPORTUNITY_PRIMO_CONTATTO,
                                        Forecast_Category_Custom__c='Elevata Probabilità',
                                        Tipo_Linea_di_Credito__c='Mutuo',
                                        Finalita_Finanziamento__c='Liquidità',
                                        Ammontare_Iniziale__c=1000,
                                        Durata_Partner__c=100,
                                        Linea_di_Credito_in_Mesi__c =20,
                                        Data_Stipula__c = Date.today(),
                                        OwnerId=acc.OwnerId,
                                        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
                                        Sales_Support_Approver__c = u.id,
                                        Inside_Sales_di_Riferimento__c = u.id ,  
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'
                                       );      
        insert o;
    }
@isTest
    public static void testNotificationsStageCompletamentoDocumenti(){
        List<Opportunity> oppList = [SELECT id, name, StageName FROM Opportunity];
        test.startTest();
            CompletamentoDocumentiCrediti.notificationsStageCompletamentoDocumenti(oppList);
        test.stopTest();
    }
}