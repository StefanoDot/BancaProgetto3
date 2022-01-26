/**
 * Created by ACAPUTO00 on 05/03/2020.
 */

@isTest
public with sharing class RichiediContrattoControllerTest {
       
    @TestSetup
    static void makeData(){
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inserimento_Anagrafica').getRecordTypeId();
        Account acc = new Account(
                Name = 'testTest',
                RecordTypeId = recordTypeIdInsAnag,
                Codice_Fiscale__c = 'XXXXXXXXXXXXX',
                MoreScore__c = 'B',
                Ricezione_Dati_Oplon__c = 'Ok Full',
                Inside_Sales_di_riferimento__c =ObjectFactory.aldora.Id
        );
        insert acc;
        Contact con = new Contact(Email = 'bbbbb@bbb.it', Phone = '3213214321321321', LastName = 'aasasas',
                FinServ__EmailVerified__c = True, FinServ__MobileVerified__c = True,firmatario__c=true, AccountId=acc.Id, Percentuale_di_riferimento_socio__c =20.00);
        insert con;
        Opportunity opp = new Opportunity(AccountId = acc.id,Tipo_Linea_di_Credito__c = 'Mutuo', Name = 'aaa', StageName = 'Primo Contatto', CloseDate = Date.newInstance(2099, 12, 25),Sabatini_Applicabile__c='Si', amount = 100, Probability = 5);
        OpportunityController.bypassTrigger = true;
        insert opp;
        OpportunityController.bypassTrigger = false;
        Id creditiFiscaliOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Crediti_Fiscale_Lending').getRecordTypeId();
        Opportunity oppCF = new Opportunity(
                AccountId = acc.Id,
                Name = 'test',
                CloseDate = Date.today()+1,
                StageName = 'Primo Contatto',
                RecordTypeId = creditiFiscaliOppRecordType,
                Forecast_Category_Custom__c = 'Elevata Probabilità',
                Tipo_Linea_di_Credito__c = 'Crediti Fiscali',
                Finalita_Finanziamento__c = 'Liquidità',
                Ammontare_Iniziale__c = 1000,
                Durata_Partner__c = 100,
                Linea_di_Credito_in_Mesi__c = 20,
                Data_Stipula__c = Date.today(),
                Dettaglio_Finalita_Finanziamento__c = 'Liquidità - Pagamento fornitori',
                Sales_Support_Approver__c = ObjectFactory.aldora.Id,
                Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.Id ,
                Sabatini_Applicabile__c = 'Si',
                Numero_Pratica__c = '12345'
        );
        OpportunityController.bypassTrigger = true;
        insert oppCF;
        OpportunityController.bypassTrigger = false;
        DocumentType__c docType = ObjectFactory.generateDocumentType('Quote');
        insert docType;
        Document__c documentQuote = ObjectFactory.generateDocument(docType);
        insert documentQuote;
    }
    @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }

    @isTest static void testCheckCampiRichiediContratto() {
                       Switch_Validation__mdt testtt= RichiediContrattoControllerTest.generateMetadataValidation();
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
        Quote quote = new Quote();
        quote.Name = 'Aldoraaaa';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Durata_Direzione__c = 10;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c        = 'Investimento';
        quote.OpportunityId = opp.Id;
        quote.Status = 'In Corso';
        quote.Durata_Deliberata__c = 10;
        quote.Sabatini_Applicabile__c='Si';
        
        insert quote;
        
        Garanzia__c g = new Garanzia__c();
        g.Tipo_di_Garanzia__c='FONDO MCC';
        g.Stato_Garanzia__c='Aperta';
        g.Linea_di_Credito__c=quote.Id;
        g.Percentuale_Garantito__c='80%';
        insert g;
        String strId = Id.valueOf(opp.id);
        RichiediContrattoController.checkCampiRichiediContratto(strId);
        RichiediContrattoController.checkCambioStipula(strId);
        RichiediContrattoController.disponiInvioContratto(strId);
        RichiediContrattoController.calcolaTipoFirma(strId);
        RichiediContrattoController.checkCampiRichiedi(strId);
        RichiediContrattoController.getCertificatoNotarileDocs(strId);
        RichiediContrattoController.decideTipoFirma(strId,true);
        Test.stopTest();    
    }
    @isTest static void testCheckCampiRichiediContratto2() {
        Switch_Validation__mdt testtt= RichiediContrattoControllerTest.generateMetadataValidation();
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity][0];
    	Quote quote = new Quote();
        quote.Name = 'Aldoraaaa';
        quote.ExpirationDate = Date.today();
        quote.Ammontare_Iniziale__c = 1000;
        quote.Ammontare_Direzione__c = 1000;
        quote.Durata_Direzione__c = 10;
        quote.Ammontare_Deliberato__c = 1000;
        quote.Durata_Partner__c = 10;
        quote.Tipo_Linea_di_Credito__c = 'Mutuo';
        quote.Finalita_Finanziamento__c = 'Investimento';
        quote.OpportunityId = opp.Id;
        quote.Status = 'In Corso';
        quote.Durata_Deliberata__c = 10;
        quote.Sabatini_Applicabile__c='Si';

        insert quote;

        Document__c d = [SELECT Id FROM Document__c][0];
        String strId = Id.valueOf(opp.id);
        RichiediContrattoController.rissotemettere(strId);
        Test.stopTest();
    } 
    @isTest 
    static void checkCampiPerCrediti(){
        Switch_Validation__mdt testtt= RichiediContrattoControllerTest.generateMetadataValidation();
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Tipo_Linea_di_Credito__c = 'Crediti Fiscali'][0];
        String strId = Id.valueOf(opp.id);
        Test.startTest();
        RichiediContrattoController.checkCampiRichiedi(strId);
        Test.stopTest();
    }
}