// Contains all the methods related to Account Apex Sharing
public class BP_AccountSharingManager {
    
    //Edit Access for Inside Sales Di Refremento
    public static void accountEditAccessForInsideSales(List<Account> newAccountLst){
        List<AccountShare> oAccShareLst = new List<AccountShare>();
        for(Account oAcc : newAccountLst){
            
            AccountShare acShare = new AccountShare();
            acShare.AccountId = oAcc.Id;
            acShare.AccountAccessLevel = 'Edit';
            acShare.OpportunityAccessLevel = 'None';
            acShare.UserOrGroupId = oAcc.Inside_Sales_di_riferimento__c;
            
            oAccShareLst.add(acShare);
        }
        if(! oAccShareLst.isEmpty()){
            try{
                insert oAccShareLst;
            }catch(Exception e ){
                System.debug('DUPLICATE RECORDS');
            }

            
        }
    }
    
    //Edit Access for SalesCrediti
    public static void accountEditAccessForSalesCrediti(List<Account> newAccountLst){
        List<AccountShare> oAccShareLst = new List<AccountShare>();
        for(Account oAcc : newAccountLst){
            
            AccountShare acShare = new AccountShare();
            acShare.AccountId = oAcc.Id;
            acShare.AccountAccessLevel = 'Edit';
            acShare.OpportunityAccessLevel = 'None';
            acShare.UserOrGroupId = oAcc.Sales_Crediti_Fiscali__c;
            
            oAccShareLst.add(acShare);
        }
        if(! oAccShareLst.isEmpty()){
            try{
                insert oAccShareLst;
            }catch(Exception e ){
                System.debug('DUPLICATE RECORDS');
            }
            
        }
    }

}