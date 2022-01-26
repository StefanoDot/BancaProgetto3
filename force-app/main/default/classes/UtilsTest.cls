@isTest
public with sharing class UtilsTest {
    
    @isTest static Switch__mdt generateMetadata(){
        Switch__mdt metadata = new Switch__mdt(
            DeveloperName='NDG_Eleva',
            Status__c='Active'
        );
                return metadata;
    }
      
    @isTest static Switch_Validation__mdt generateMetadataValidation(){
        Switch_Validation__mdt metadata = new Switch_Validation__mdt(
            DeveloperName='Account',
            Status__c='ON'
        );
                return metadata;
    }


    @isTest static void testCreaCointestazione(){
                    Switch_Validation__mdt testtt=   UtilsTest.generateMetadataValidation();
        GaranzieController.bypassTrigger = true;
     Switch__mdt testttt=   UtilsTest.generateMetadata();
        Cointestazione__c coin = ObjectFactory.insertNewCointestazione();
        
         Cointestazione__c coin2 = ObjectFactory.insertNewCointestazione();
        
        Cointestazione__c coin3 = new Cointestazione__c();
        coin3.Tipo_di_Cointestazione__c = 'Account';
        coin3.NDG_Cointestazione__c='12345';
       
        insert coin3;
        
        QuoteController.bypassTrigger= true;
                Quote q = ObjectFactory.insertNewQuote();

          Id recordTypeIdInsGaranzia = Schema.SObjectType.Garanzia__c.getRecordTypeInfosByDeveloperName().get('Fidejussione_Layout_Inserimento').getRecordTypeId();

       Garanzia__c e = new Garanzia__c();
        e.Linea_di_Credito__c=q.id;
        e.Tipo_di_Garanzia__c = 'Fidejussione';
        e.Tipo_di_Fidejussione__c='Persona Fisica';
        e.Stato_Garanzia__c = 'Aperta';
        e.Percentuale_Garantito__c = '80';
        e.recordTypeId=recordTypeIdInsGaranzia;
        insert e;
        Contact cont =     ObjectFactory.insertNewContact();
        
        Fidejussione__c a = new Fidejussione__c();
		a.Persona_Fisica__c=cont.id;
         a.Cointestazione__c=coin2.id;
        a.Garanzia__c=e.Id;
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
        
        
        Fidejussione__c b = new Fidejussione__c();
		b.Persona_Fisica__c=cont.id;
        b.Cointestazione__c=coin2.id;
        b.Garanzia__c=e.Id;
    //   insert b;
        
        
         Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
       
        Account aa = new Account();
        aa.Name = 'kottt';
        aa.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
     aa.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
     	aa.RecordTypeId = recordTypeIdInsAnag;
        aa.AccountNumber = '11111';
        aa.OwnerId = ObjectFactory.aldora.id;
                aa.Punteggio_di_rischio__c=1;

        
		insert aa;
        
        
        
          Fidejussione__c fid = new Fidejussione__c();
		fid.Persona_Giuridica__c=aa.id;
        fid.Cointestazione__c=coin3.id;
                fid.Garanzia__c=e.Id;

      //insert fid;
        
           Fidejussione__c fidd = new Fidejussione__c();
		fidd.Persona_Giuridica__c=acc.id;
        fidd.Cointestazione__c=coin3.id;
                        fidd.Garanzia__c=e.Id;

      // insert fidd;
        
       

        Test.startTest();
        Utils.creaCointestazioneCallout(coin2.id);
        Utils.creaCointestazioneCallout(coin3.id);
        Utils.checkDublicateCointestazione(coin.id);
        Utils.checkDublicateCointestazione(coin2.id);
        Utils.checkDublicateCointestazione(coin3.id);
        Utils.deleteCoin(coin.id);
        Utils.switchSystems();

        Test.stopTest();
    }
    
        @isTest static void testCheckDueFidejussioneNDGbuttone(){
                                Switch_Validation__mdt testtt=   UtilsTest.generateMetadataValidation();

                 Switch__mdt testttt=   UtilsTest.generateMetadata();

        
        Account acc = ObjectFactory.insertNewAccount();
         
        Test.startTest();
        Utils.checkDueFidejussioneNDGbuttone(acc.id);
        Test.stopTest();
    }
    
     @isTest static void testCheckDueFidejussioneNDGbuttoneContact(){
              Switch__mdt testttt=   UtilsTest.generateMetadata();

          
        Contact cont = ObjectFactory.insertNewContact();
         

        
        Test.startTest();
        Utils.checkDueFidejussioneNDGbuttoneContact(cont.id);
        Test.stopTest();
    }
    
  /*       @isTest static void testUpdateCheck(){
        
        Quote q = ObjectFactory.insertNewQuote();
        
        Test.startTest();
        Utils.updateCheck(q.id);
        Test.stopTest();
    }
    */
        @isTest static void testChuisaGaranzia(){
                                Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        GaranzieController.bypassTrigger = true;
        Garanzia__c g = ObjectFactory.insertNewGaranzia();
        
        Test.startTest();
        Utils.ChuisaGaranzia(g.id);
        Test.stopTest();
    }
    
     @isTest static void testUpdateButtonFondo(){
        GaranzieController.bypassTrigger = true;
        Garanzia__c g = ObjectFactory.insertNewGaranzia();
        String bName = 'Verifica';
        String bName1 = 'Simulazione';
         String bName2 = 'Congelamento';
         
        Test.startTest();
        //Utils.updateButtonFondo(g.id, bName);
          //Utils.updateButtonFondo(g.id, bName1);
     // Utils.updateButtonFondo(g.id, bName2);
        Test.stopTest();
     }
    
      @isTest static void testAnnullaQuote(){
                              Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        QuoteController.bypassTrigger= true;
        Quote q = ObjectFactory.insertNewQuote();
        
        Test.startTest();
        Utils.AnullataQuote(q.id);
           Utils.AnnullaQuote(q.id);
        Test.stopTest();
    }
    
      @isTest static void testGetSalesDiRiferimentoAreaMail(){
                              Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        
          List<ID> myAccs = new List<ID>();

        Account acc1 = ObjectFactory.insertNewAccount();
        Account acc2 = ObjectFactory.insertNewAccount();
        
          myAccs.add(acc1.ID);
          myAccs.add(acc2.ID);
          
        Test.startTest();
        Utils.getSalesDiRiferimentoAreaMailTest(myAccs);
          Utils.getSalesDiRiferimentoAreaMail(new List<Account>{acc1, acc2});
        Test.stopTest();
    }
    
          @isTest static void testGetCurrentUserMail(){
                                  Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

      
        Test.startTest();
        Utils.getCurrentUserMail();
        Test.stopTest();
    }
    
    
      @isTest static void testCreteSetIds(){
                              Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        
          List<Account> myAccs = new List<Account>();

        Account acc1 = ObjectFactory.insertNewAccount();
        Account acc2 = ObjectFactory.insertNewAccount();
        
          myAccs.add(acc1);
          myAccs.add(acc2);
          
        Test.startTest();
        Utils.creteSetIds(myAccs, 'Id');
        Test.stopTest();
    }
    
         @isTest static void testCreteMapKeyObjectList(){
                                 Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        
          List<Account> myAccs = new List<Account>();

        Account acc1 = ObjectFactory.insertNewAccount();
        Account acc2 = ObjectFactory.insertNewAccount();
        
          myAccs.add(acc1);
          myAccs.add(acc2);
          
        Test.startTest();
        Utils.creteMapKeyObject(myAccs, 'Id');
             Utils.creteMapKeyObjectList(myAccs, 'Id');
        Test.stopTest();
    }
    
    @isTest static void testDesospensioneOpp(){
                            Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        GaranzieController.bypassTrigger = true;
        Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        //QuoteController.bypassTrigger = true;
        Account acc = new Account();
        acc.Name = 'kottt mooouyuyuyuyu';
        acc.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
        acc.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
        acc.RecordTypeId = recordTypeIdInsAnag;
        acc.AccountNumber = 'ggggg';
        acc.OwnerId = ObjectFactory.aldora.id;
        acc.Ricezione_Dati_Oplon__c= 'Ok Full';
        acc.Tipo_di_Azienda__c= 'SRI';
        acc.Privacy__c=true;
        acc.Verifica_liste_negative__c='OK'; 
        acc.Punteggio_di_rischio__c=1;
       
        
        insert acc;
        
        OpportunityController.byPassTrigger = true;
Opportunity opp =  ObjectFactory.insertNewOpportunity();
 
  Opportunity o = new Opportunity();
       o.Id=opp.Id;
         o.StageName='PEF Pre-Istruttoria';
o.Is_Suspended__c=true;
        o.Creazione_Rete_Azienda__c=true;
        o.AccountId=acc.Id;
        o.Numero_Pratica__c='14521';
        o.Filiale_Banca_Cliente__c='test';
        o.Controllo_parti_correlate__c = 'Si';
       
        QuoteController.bypassTrigger= true;
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
        q1.OpportunityId = o.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100;
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c='Si';
        
        insert q1;

     Garanzia__c e2 = ObjectFactory.insertNewGaranzia(); 
        Garanzia__c g = new Garanzia__c();
        g.Id= e2.Id;
        g.Linea_di_Credito__c=q1.Id;
        g.Opportunit__c=o.id;
        
        update g;
       update o;
        
        Test.startTest();
        Utils.DesospensioneOpp(opp.id);
        Utils.checkCount(o.id);
    //    Utils.DesospensioneOpp2(opp.id);
    }
    
    @isTest static void testRecuperoDati(){
                            Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        Contact cont = ObjectFactory.insertNewContact();
        
        Test.startTest();
        Utils.RecuperoDatiReferenti(cont.id);
        Test.stopTest();
        
    }
    
    @isTest static void testCampiMancantiCedacri(){
                            Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        
        Account acc = ObjectFactory.insertNewAccount();
        
        Test.startTest();
        Utils.campiMancantiCedacri(acc.id);
        Test.stopTest();
    }
       
    @isTest static void DesospensioneOppMasivoFutureTest(){
                            Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        OpportunityController.byPassTrigger = true;
        Opportunity opp = ObjectFactory.insertNewOpportunity();
        Account acc = ObjectFactory.insertNewAccount();
        
        QuoteController.bypassTrigger= true;
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

     Garanzia__c e2 = ObjectFactory.insertNewGaranzia(); 
        Garanzia__c g = new Garanzia__c();
        g.Id= e2.Id;
        g.Linea_di_Credito__c=q1.Id;
        g.Opportunit__c=opp.id;
        
        update g;
             
        Test.startTest();
        Utils.DesospensioneOppMasivoFuture(opp.id);
        Test.stopTest();
    }
  /* @isTest static void testgetDocUserMail(){
     Opportunity opp = ObjectFactory.insertNewOpportunity();
        DocumentType__c dt = ObjectFactory.insertNewDocumentType('Opportunity');
        Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=dt.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
        d.Opportunity__c=opp.Id;
       
		insert d;
        
    Account acc = ObjectFactory.insertNewAccount();    
         DocumentType__c dty = ObjectFactory.insertNewDocumentType('Opportunity');
        Document__c b = new Document__c();
        b.Name='test';
        b.DocumentType__c=dty.id;
        b.Id_File__c='0691w0000010Rs9AAE';
        b.Commento_Sales_Support__c='test';
        b.Account__c=acc.Id;
       
		insert b;
      Contact cont = ObjectFactory.insertNewContact();
         DocumentType__c dtyp = ObjectFactory.insertNewDocumentType('Opportunity');
        Document__c t = new Document__c();
        t.Name='test';
        t.DocumentType__c=dtyp.id;
        t.Id_File__c='0691w0000010Rs9AAE';
        t.Commento_Sales_Support__c='test';
        t.Contact__c=cont.Id;
       
		insert t;
         Quote q = ObjectFactory.insertNewQuote();
         DocumentType__c dtype = ObjectFactory.insertNewDocumentType('Opportunity');
        Document__c doc = new Document__c();
        doc.Name='test';
        doc.DocumentType__c=dtype.id;
        doc.Id_File__c='0691w0000010Rs9AAE';
        doc.Commento_Sales_Support__c='test';
        doc.Quote__c=q.Id;
       
		insert doc;
         Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
       
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
     	a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.Ricezione_Dati_Oplon__c= 'Ok Full';
        a.Tipo_di_Azienda__c= 'SRI';
        
		insert a;
         
        
        Opportunity o = new Opportunity(AccountId=a.Id,
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
        OwnerId=acc.OwnerId,
        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
        Sabatini_Applicabile__c='Si');
        insert o;
          Document__c d1 = new Document__c();
        d1.Name='test';
        d1.DocumentType__c=dt.id;
        d1.Id_File__c='0691w0000010Rs9AAE';
        d1.Commento_Sales_Support__c='testtt';
        d1.Opportunity__c=o.Id;
       
		insert d1;
        
        
        
      
       
         Test.startTest();
        Utils.getDocUserMail(d.Id);
        Utils.getDocUserMail(b.Id);
        Utils.getDocUserMail(t.Id);
        Utils.getDocUserMail(doc.Id);
        Utils.getDocUserMail(d1.Id);

        Test.stopTest();
    }
*/
       @isTest static void profileDocTest(){
                               Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

        Account acc = ObjectFactory.insertNewAccount();
             OpportunityController.byPassTrigger = true;
             Opportunity o = new Opportunity(AccountId=acc.Id,
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
                                        OwnerId=acc.OwnerId,
                                        Dettaglio_Finalita_Finanziamento__c='Liquidità - Pagamento fornitori',                              
                                        Sales_Support_Approver__c = ObjectFactory.aldora.id,
                                        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,  
                                        Sabatini_Applicabile__c='Si'
                                       
                                       );
        
        
        insert o;
      User u = ObjectFactory.aldora;
        
        Test.startTest();
        Utils.profileDoc(o.id);
        Utils.getUsers(acc.Id);
       Utils.changeUtente(u.Id, acc.id);
        o.Numero_Pratica__c = '12345';
        o.StageName = 'Closed Won';
        update o;
        acc.Inside_Sales_di_riferimento__c = null;
        update acc;
        Utils.changeUtente(u.Id, acc.id);
        Utils.nomeUtente(u.Id);
        Utils.getUsers(acc.Id);
        Test.stopTest();
    }
    
  /*   @isTest static void switchUsersTest(){
     Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();

      User u = ObjectFactory.aldora;
        
        Test.startTest();
       // Utils.switchUsers('off');
       // Utils.switchUsers('on');

        Test.stopTest();
    }*/

    @isTest static void mapDocumentsTest(){
                               Switch_Validation__mdt testttt=   UtilsTest.generateMetadataValidation();


          Id recordTypeIdInsAnag = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        //OpportunityController.bypassTrigger = true;
        Account a = new Account();
        a.Name = 'kottt mooouyuyuyuyu';
        a.Manager_NomeCompleto__c = ObjectFactory.aldora.id;
        a.Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id;
        a.RecordTypeId = recordTypeIdInsAnag;
        a.AccountNumber = 'ggggg';
        a.OwnerId = ObjectFactory.aldora.id;
        a.Ricezione_Dati_Oplon__c= 'Ok Full';
        a.Tipo_di_Azienda__c= 'SRI';
        a.Privacy__c=true;
        a.Verifica_liste_negative__c='OK';
        a.Punteggio_di_rischio__c=1;

        insert a;


        Id recordTypeIdRefOpl = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referente_Oplon').getRecordTypeId();

        Contact c = new Contact();
        c.LastName= 'test';
        c.AccountId = a.Id;
        c.RecordTypeId = recordTypeIdRefOpl;
        c.Fidejussore__c = true;
        c.Email = 'aldora@gmail.com';
        c.Phone = '123456789';
        c.NDG__C = '12345';



        insert c;
        
        OpportunityController.byPassTrigger = true;
             Opportunity o = new Opportunity(AccountId=a.Id,
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
                                        Sales_Support_Approver__c = ObjectFactory.aldora.id,
                                        Inside_Sales_di_Riferimento__c = ObjectFactory.aldora.id ,
                                        Sabatini_Applicabile__c='Si',
                                        Numero_Pratica__c='12345'

                                       );


        insert o;

        QuoteController.bypassTrigger= true;
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
        q1.OpportunityId = o.Id;
        q1.Status = 'In Corso';
        q1.Durata_Deliberata__c = 10;
        q1.Ammontare_Erogato__c = 100;
        q1.Durata_Erogata__c = 10;
        q1.Sabatini_Applicabile__c='Si';

        insert q1;

             DocumentType__c dt = ObjectFactory.insertNewDocumentType('Opportunity');

        Document__c d = new Document__c();
        d.Name='test';
        d.DocumentType__c=dt.id;
        d.Id_File__c='0691w0000010Rs9AAE';
        d.Commento_Sales_Support__c='testtt';
           d.Opportunity__c=o.Id;

        insert d;


        
        Test.startTest();
        Utils.GetNotVerifiedDocumentTypes(o.Id);
        Utils.GetMissingMandatoryDocTypes(o.Id);
        Utils.getDocUserMail(d.Id);
        Test.stopTest();
    }
    @isTest static void aggiornaTest(){

        Account acc = ObjectFactory.insertNewAccount();
          Contact c = ObjectFactory.insertNewContact(); 
        
        Test.startTest();
      Utils.aggiorna(acc.Id,'Account');
       Utils.aggiorna(c.Id,'Contact');
        acc.Tipo_di_Azienda__c = 'DI';
        update acc;
        Utils.aggiorna(acc.Id,'Account');
        
        Test.stopTest();
    }

    @IsTest
    static void testGetPicklistValues() {
        SObject objInfo = Schema.getGlobalDescribe().get('DocumentType__c').newSObject() ;
        String picklistFieldApi = 'Document_Block__c';
        List<Utils.Option> result;

        Test.startTest();
        result = Utils.getPicklistValues(objInfo, picklistFieldApi);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Document_Block__c picklist has no values');
    }
    
    @isTest
    static void profileUserTest(){
        Utils.FidejussoreResponse response = Utils.profileUser();
    }
    
    @isTest
    static void getRecordsTypeOpptyQuoteMapTest(){
        Utils.getRecordsTypeOpptyQuoteMap();
    }
    
    @isTest
    static void switchUsersTest(){
        Utils.switchUsers('test');
    }
}