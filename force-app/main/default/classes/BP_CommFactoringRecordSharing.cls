public class BP_CommFactoringRecordSharing {
    
    public static void shareAccountRecWithCommFactoring(List<Id> updatedAccIdList){
        
        List<Account> accountList = [Select Id, Sales_Crediti_Fiscali__c,Sales_Crediti_Fiscali__r.UserRole.Name 
                                     from Account where Id IN:updatedAccIdList];
        
        List<AccountShare> oAccShareLst = new List<AccountShare>();
        for(Account ac : accountList){
            
            if(ac.Sales_Crediti_Fiscali__r.UserRole.Name == 'Commerciale Factoring CF'){
                
                System.debug('UserRole.Name Sales Crediti ' + ac.Sales_Crediti_Fiscali__r.UserRole.Name);
              
                AccountShare acShare = new AccountShare();
                acShare.AccountId = ac.Id;
                acShare.AccountAccessLevel = 'Edit';
                acShare.OpportunityAccessLevel = 'None';
                acShare.UserOrGroupId = ac.Sales_Crediti_Fiscali__c;

                System.debug('acShare.UserOrGroupId ' + acShare.UserOrGroupId);
                
                oAccShareLst.add(acShare);

                System.debug('Account share List ' + oAccShareLst);

            
            }
        }
        
        if(! oAccShareLst.isEmpty()){
            try{ 
            insert oAccShareLst;
            
            }catch (Exception ex){
                System.debug('ex.getMessage() ' + ex.getMessage());
            }
        }
        
    }
    public static void shareOppRecWithCommFactoring(List<Id> updatedOppIdList){
        
        List<Opportunity> opportunityList = [Select Id, Sales_owner_opportunita__c,Sales_owner_opportunita__r.UserRole.Name 
                                     		from Opportunity where Id IN:updatedOppIdList];
        
        List<OpportunityShare> oppShareLst = new List<OpportunityShare>();
        for(Opportunity  oppRec : opportunityList){
            
            if(oppRec.Sales_owner_opportunita__r.UserRole.Name == 'Commerciale Factoring CF'){
                
                OpportunityShare opShare = new OpportunityShare();
                opShare.OpportunityId = oppRec.Id; 
                opShare.OpportunityAccessLevel = 'Edit';
                opShare.UserOrGroupId = oppRec.Sales_owner_opportunita__c;
                
                oppShareLst.add(opShare);
            }
        }
        
        if(! oppShareLst.isEmpty()){
            try{ 
            insert oppShareLst;
            }catch (Exception ex){
                System.debug('ex.getMessage() ' + ex.getMessage());
            }
        }
    }

}