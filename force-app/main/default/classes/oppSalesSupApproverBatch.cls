global with sharing class oppSalesSupApproverBatch implements Database.Batchable<sObject>{
    
  global Database.QueryLocator start(Database.BatchableContext BC){
      
       System.debug('query ' + Database.getQueryLocator('SELECT Id, Tipo_Linea_di_Credito__c,  Sales_Support_Approver__c  FROM Opportunity WHERE CreatedDate >2021-05-28T20:00:00.000+0000 AND CreatedDate<2021-06-01T04:30:00.000+00:00 AND CreatedBy.Profile.Name =\'Migrazione\' AND Account.IsPartner=false ORDER BY CreatedDate DESC'));
                    
        return Database.getQueryLocator('SELECT Id, Tipo_Linea_di_Credito__c,  Sales_Support_Approver__c  FROM Opportunity WHERE CreatedDate >2021-05-28T20:00:00.000+0000 AND CreatedDate<2021-06-01T04:30:00.000+00:00 AND CreatedBy.Profile.Name =\'Migrazione\' AND Account.IsPartner=false ORDER BY CreatedDate DESC');
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('vijm ktu te batchi'+scope);
        system.debug('jemi qe jemi '+scope.size());
        
        for(Opportunity  opp : scope)
        {
            Map<String,Opportunity> oppMap = new Map<String, Opportunity>();                
            oppMap.put('opportunity', opp);
            
            Flow.Interview.Assegnazzione_sales_support_approver_new flow1 = new Flow.Interview.Assegnazzione_sales_support_approver_new(oppMap);
            flow1.start();
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}