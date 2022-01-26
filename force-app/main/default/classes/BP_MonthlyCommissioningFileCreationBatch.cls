public class BP_MonthlyCommissioningFileCreationBatch implements Database.Batchable<sObject> {

String query='';
String statusOfQuote = 'Annullata';
String StageNameOppty = 'In Erogazione';
ContentDocumentLink finalLink = new ContentDocumentLink();


public Database.QueryLocator start(Database.BatchableContext BC){
    query = 'SELECT Id, AccountId, Account.AccountNumber, Owner.Profile.Name, Owner.CF_P_IVA__c, Data_Erogazione__c, Finalita_Finanziamento__c, ' ;
    query += '(SELECT Id, Owner.Profile.Name, Numero_Rapporto__c, Periodicita__c, Durata_in_mesi__c, Ammontare_Deliberato__c,Percentuale_Spread__c, ' ;
    query += ' Importo_Commissioni_di_Istruttoria__c, Data_Firma__c, Percentuale_Commissioni_da_Istruttoria__c  ' ;
    query += 'FROM Quotes WHERE Status !=: statusOfQuote ) FROM Opportunity WHERE StageName =: StageNameOppty'; 
    return Database.getQueryLocator(query);

}

public void execute(Database.BatchableContext BC, List<Opportunity> scope){
    Map<Id, List<String>> oppMap = BP_CommissioningController.generateString(scope);
    String output = '';   
  for (Id key : oppMap.keySet()) {
    for(String singleOpp : oppMap.get(key)){
        output += singleOpp +  '\n' ;
       
    }
}
    String fileName = 'OpportunityInErogazione' + date.today().year() + date.today().month() + date.today().day();
    
    BP_CommissioningController.CommissioningFileWrapper oWrap = new BP_CommissioningController.CommissioningFileWrapper(scope[0].Id,scope[0].OwnerId,fileName, output);
    finalLink = BP_FileCreationCommissioning.createFile(oWrap);
}

public void finish(Database.BatchableContext BC){
    System.debug('ContentDocumentLink' + finalLink.id);
}

}