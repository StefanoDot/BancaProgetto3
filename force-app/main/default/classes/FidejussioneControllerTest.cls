@isTest(SeeAllData=false)
public with sharing class FidejussioneControllerTest {
    
    @isTest static void testBeforeInsertFidejussione(){
        Cointestazione__c coin2 = ObjectFactory.insertNewCointestazione();
        
        Contact c = ObjectFactory.insertNewContact();
        Quote q = ObjectFactory.insertNewQuote();
        Id recordTypeIdInsAnag = Schema.SObjectType.Garanzia__c.getRecordTypeInfosByDeveloperName().get('Fidejussione_Layout_Inserimento').getRecordTypeId();
        
        Garanzia__c e = new Garanzia__c();
        e.Linea_di_Credito__c=q.id;
        e.Tipo_di_Garanzia__c = 'Fidejussione';
        e.Tipo_di_Fidejussione__c='Persona Fisica';
        e.Stato_Garanzia__c = 'Aperta';
        e.Percentuale_Garantito__c = '80';
        e.recordTypeId=recordTypeIdInsAnag;
        insert e;
        
        Test.startTest();
        Fidejussione__c a = new Fidejussione__c();
        a.Persona_Fisica__c=c.id;
        a.Garanzia__c = e.id;
        a.Cointestazione__c=coin2.Id;
        insert a;
        
        List<Fidejussione__c> listFid = new List<Fidejussione__c>{a};
            FidejussioneController.numberOfFidejussione(listFid);
        
        Test.stopTest();
        
    }
    
    
    @isTest static void testUpdate(){
        
        Contact co = ObjectFactory.insertNewContact();
        Quote q = ObjectFactory.insertNewQuote();
        
        Id recordTypeIdInsAnag = Schema.SObjectType.Garanzia__c.getRecordTypeInfosByDeveloperName().get('Fidejussione_Layout_Inserimento').getRecordTypeId();
        Test.startTest();
        Garanzia__c e = new Garanzia__c();
        e.Linea_di_Credito__c=q.id;
        e.Tipo_di_Garanzia__c = 'Fidejussione';
        e.Tipo_di_Fidejussione__c='Persona Fisica';
        e.Stato_Garanzia__c = 'Aperta';
        e.Percentuale_Garantito__c = '80';
        e.recordTypeId=recordTypeIdInsAnag;
        insert e;
        Fidejussione__c a = new Fidejussione__c();
        a.Persona_Fisica__c=co.id;
        a.Garanzia__c = e.id;
        
        insert a;
        
        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();
        
        Account acc = ObjectFactory.insertNewAccount();
        Contact c = new Contact();
        c.LastName= 'testiiiiii';
        c.AccountId = acc.Id;
        c.RecordTypeId = recordTypeIdRefOpl;
        c.Fidejussore__c = false;
        c.Email = 'aldoraaaaaaa@gmail.com';
        c.Phone = '123456755';
        c.NDG__C = '12355';
        insert c;
        
        Fidejussione__c fide = [SELECT Persona_Fisica__c FROM Fidejussione__c WHERE Id = :a.Id LIMIT 1];
        fide.Persona_Fisica__c = c.id;
        update fide;
        
        Test.stoptest();
        List<Fidejussione__c> listFid = new List<Fidejussione__c>{fide};
        FidejussioneController.preventDeleteFidejussioni(listFid);
    }
    
}