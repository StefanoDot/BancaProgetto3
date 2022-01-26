public class BP_OpportunitySharingManager {
    
    public static void OppEditForSalesOwner(List<Opportunity> opportunityList){
        
        List<OpportunityShare> oppShareLst = new List<OpportunityShare>();
        for(Opportunity  oppRec : opportunityList){
            
            OpportunityShare opShare = new OpportunityShare();
            opShare.OpportunityId = oppRec.Id; 
            opShare.OpportunityAccessLevel = 'Edit';
            opShare.UserOrGroupId = oppRec.Sales_owner_opportunita__c;
            
            oppShareLst.add(opShare);
        }
        
        if(! oppShareLst.isEmpty()){
            try{
                insert oppShareLst;
            }catch(Exception e ){
                System.debug('DUPLICATE RECORDS');
            }
            
        }
    }

}