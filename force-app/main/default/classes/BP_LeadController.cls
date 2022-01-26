public class BP_LeadController extends TriggerHandler {
    
    public override void beforeInsert(){
        
        List<Lead> newLeadsLst = (List<Lead>)trigger.new;
        
        // Lead - Sales_di_Riferimento__c assignment - Start //
        
        List<Lead> newLeadProvinceLst = new List<Lead>();
        List<Lead> newLeadMIMBProvinceLst = new List<Lead>();
        
        for(Lead oLead: newLeadsLst)
        {
            if(! String.isEmpty(oLead.Sigla_Provincia__c) )
            {
                if(oLead.Sigla_Provincia__c == 'MI' || oLead.Sigla_Provincia__c == 'MB')
                {
                    newLeadMIMBProvinceLst.add(oLead);
                }
                else
                {
                    newLeadProvinceLst.add(oLead);
                }
                
            }
        }
        if(! newLeadProvinceLst.isEmpty())
        {
            BP_LC_SalesAssignment.insideSalesAssignment(newLeadProvinceLst);
        }
        if(! newLeadMIMBProvinceLst.isEmpty())
        {
            BP_LC_SalesAssignment.insideSalesAssignmentForMIMB(newLeadMIMBProvinceLst);
        }
        // Lead - Sales_di_Riferimento__c assignment - End // 
        
    }
    public override void beforeUpdate(){
        
        List<Lead> newLeadsLst = (List<Lead>)trigger.new;
        Map<Id,Lead> oldLeadsMap = (Map<Id,Lead>)trigger.oldMap;
        
        // Lead - Sales_di_Riferimento__c assignment - Start //
        
        List<Lead> newLeadProvinceLst = new List<Lead>();
        List<Lead> newLeadMIMBProvinceLst = new List<Lead>();
        
        for(Lead oLead: newLeadsLst)
        {
            if(oLead.Sigla_Provincia__c != ((oldLeadsMap.get(oLead.Id)).Sigla_Provincia__c) && String.isEmpty(oLead.Sigla_Provincia__c))
            {
                oLead.Inside_Saels_di_Riferimento__c = null;
            }
            else if(oLead.Sigla_Provincia__c != ((oldLeadsMap.get(oLead.Id)).Sigla_Provincia__c))
            {
                if(oLead.Sigla_Provincia__c == 'MI' || oLead.Sigla_Provincia__c == 'MB')
                {
                    newLeadMIMBProvinceLst.add(oLead);
                }
                else
                {
                    newLeadProvinceLst.add(oLead);
                }
            }
        }
        if(! newLeadProvinceLst.isEmpty())
        {
            BP_LC_SalesAssignment.insideSalesAssignment(newLeadProvinceLst);
        }
        if(! newLeadMIMBProvinceLst.isEmpty())
        {
            BP_LC_SalesAssignment.insideSalesAssignmentForMIMB(newLeadMIMBProvinceLst);
        }
        
        // Lead - Sales_di_Riferimento__c assignment - End
    }
    public override void afterInsert(){
    }
    public override void afterUpdate(){
    }
    
}