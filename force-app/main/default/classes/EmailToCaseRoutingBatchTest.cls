@isTest
public class EmailToCaseRoutingBatchTest {
	@testSetup
    public static void testsetup(){
       List<Group> owner = [Select Id From Group where Name='CQS Tecnical Admin' And Type = 'Queue'];
        CQSCliente__c cl = new CQSCliente__c();
        cl.Name = 'Mario Rossi';
        cl.CQSNome_Cliente__c = 'mario';
        cl.CQSCodice_Cliente__c = '123456';
        cl.CQSCodice_Fiscale__c = 'CF123456ART23145';
        insert cl;
        CQSProdotto__c cpro = new CQSProdotto__c();
       cpro.cqsstatus_Pratica__C = 'LIQUIDATO';
       cpro.name = '12345678';
       cpro.CQSCodice_Pratica__c = '12345678';
        cpro.CQSCliente__c = cl.id;
       insert cpro;
       Case c = new Case();
       c.subject= 'Prova MREROS93L07E512T Test01';
       c.Description = '12345678';
       c.origin = 'Posta Elettronica';
       c.ownerId = owner[0].id;
       insert c;
       Case c2 = new Case();
       c2.subject= 'Prova CF123456ART23145 Test02';
       c2.Description = '12345678';
       c2.origin = 'Posta Elettronica';
       c2.ownerId = owner[0].id;
       insert c2;
        Case c3 = new Case();
       c3.subject= 'ACCETTAZIONE: Prova MREROS93L07E512T Test 12345678';
       c3.Description = '';
       c3.origin = 'Posta Elettronica';
       c3.ownerId = owner[0].id;
       insert c3; 
       Case c4 = new Case();
       c4.subject= 'POSTA CERTIFICATA: Prova MREROS93L07E512T Test N.123456';
       c4.Description = '';
       c4.origin = 'Posta Elettronica';
       c4.ownerId = owner[0].id;
       insert c4; 
       CQSTechnicalAssigment__c cta = new CQSTechnicalAssigment__c();
       cta.Priority__c = 0;
       cta.caseOwner__c = 'CQS_Admin_e_Supervisor';
       insert cta;
        CQSTechnicalAssigment__c cta2 = new CQSTechnicalAssigment__c();
       cta2.Priority__c = 1;
       cta2.KeyWordGroup__c = 'Test01';
       cta2.CQSStatus_Pratica__c = 'LIQUIDATO';
       cta2.caseOwner__c = 'CQS_Admin_e_Superviso';
         CQSTechnicalAssigment__c cta3 = new CQSTechnicalAssigment__c();
       cta3.Priority__c = 2;
       //cta3.CQSStatus_Pratica__c = 'Liquidata BP';
       cta3.KeyWordGroup__c = 'Test02';
       cta3.caseOwner__c = 'CQS_Admin_e_Supervisor';
       insert cta3;
        insert cta2;
    }
    @isTest
    public static void runTest01(){
        List<Group> owner   = [Select Id From Group where Name='CQS Tecnical Admin' And Type = 'Queue'];
       List<Case> allCases = [SELECT id,status,Subject,Description,CQSProdotto__c,CQSCliente__c,Origin from Case where OwnerId =: owner[0].ID AND status != 'Pending'];
        EmailToCaseRoutingBatch b = new EmailToCaseRoutingBatch();
        b.dtos = allCases;
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,5);
    }
}