/*********************************************************************************************************************
 * Name of Class :  BP_TipoAnagraficaProspectBatch 
 * Purpose       :  Batch apex class 
 *********************************************************************************************************************
 * Author     ||      Date             ||      Change                 	||         Description of change
 * Mukesh	  ||      [11-Aug-2021]    ||      Initial Development    	||
 *********************************************************************************************************************/

global with sharing class BP_TipoAnagraficaProspectBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    String query='';  
    Integer oppCount = 0;        
    String ADMIN_USERNAME = System.Label.BP_Admin_UserName;
    Date dateValue = System.today() - 60;
    String userNames = System.Label.Migration_Users;
    String profiles = System.Label.Exclude_Profiles;
    List<String> Migration_Users = userNames.split(',');
    List<String> profilesList = profiles.split(',');
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(! Test.isRunningTest()){
        	query = 'SELECT Id,Count_of_Opportunities__c,Tipo_Anagrafica__c,LastModifiedDate, LastModifiedBy.Profile.Name from Account WHERE Count_of_Opportunities__c =:oppCount AND Owner.Name NOT IN: Migration_Users AND (Totale__c = null AND Totale_CF__c = null AND Totale_LL__c = null) AND ((LastModifiedDate < :dateValue) OR (LastModifiedDate >= :dateValue AND LastModifiedBy.Profile.Name IN :profilesList AND (Modified_Date_By_Specific_User__c < :dateValue OR Modified_Date_By_Specific_User__c = null)))';
        }
        else{
            query = 'SELECT Id,Count_of_Opportunities__c,Tipo_Anagrafica__c,LastModifiedDate, LastModifiedBy.Profile.Name from Account';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){	
        
        User BPadminUser =  new User(); 
        if( Test.isRunningTest() ){
            BPadminUser = [Select Id,Name,UserName from User WHERE Id = :UserInfo.getUserId() limit 1];
        }
        else{
            BPadminUser = [Select Id,Name,UserName from User WHERE UserName = :ADMIN_USERNAME Limit 1];
        }
		
        List<Account> updatedAccountLst = new List<Account>();
        for(Account ac : scope)
        {
            Account oAcc = new Account();
            oAcc.Id = ac.Id;
            oAcc.Tipo_Anagrafica__c = 'Prospect';
            oAcc.OwnerId = BPadminUser.Id;
            
            updatedAccountLst.add(oAcc);
        }
        
        if(! updatedAccountLst.isEmpty())
        {
            update updatedAccountLst;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}