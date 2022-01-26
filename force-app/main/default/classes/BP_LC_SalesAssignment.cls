public class BP_LC_SalesAssignment {
    
    /* method invoked from the lead before insert and before update contexts to assign sales di rifiermento based on Sigla_Provincia__c */
    
    public static void insideSalesAssignment(List<Lead> newLeads)
    {
		Set<String> provinceSet = new Set<String>();
        Map<String,Matrice_di_Assegnazione__c> provinceAssignmntMap = new Map<String,Matrice_di_Assegnazione__c>();
        
        for(Lead oLead : newLeads)
        {
            if(! String.isEmpty(oLead.Sigla_Provincia__c))
            {
            	provinceSet.add(oLead.Sigla_Provincia__c);
            }
        }
        List<Matrice_di_Assegnazione__c> matrixAssignmentLst = [select id,Sales_di_Riferimento__c,Codice_Provincia__c,Regione__c,CAP__c 
         														from Matrice_di_Assegnazione__c where Codice_Provincia__c IN:provinceSet];
        for(Matrice_di_Assegnazione__c oAssign : matrixAssignmentLst)
        {
            if(! String.isEmpty(oAssign.Sales_di_Riferimento__c))
            {
            	provinceAssignmntMap.put(oAssign.Codice_Provincia__c,oAssign);
            }
        }
        for(Lead oLead : newLeads)
        {
          if(provinceAssignmntMap.containsKey(oLead.Sigla_Provincia__c))
          {
          	oLead.Inside_Saels_di_Riferimento__c = provinceAssignmntMap.get(oLead.Sigla_Provincia__c).Sales_di_Riferimento__c;
          }
        }
        
    }
     
    /* method invoked from the lead before insert and before update contexts to assign sales di rifiermento based on CAP__c */
    
    public static void insideSalesAssignmentForMIMB(List<Lead> newLeads)
    {
        Set<String> CAPSet = new Set<String>();
        Map<String,Matrice_di_Assegnazione__c> capAssignmntMap = new Map<String,Matrice_di_Assegnazione__c>();
        
        for(Lead oLead : newLeads)
        {
            if(! String.isEmpty(oLead.CAP__c))
            {
            	CAPSet.add(oLead.CAP__c);
            }
        }
        List<Matrice_di_Assegnazione__c> matrixAssignmentLst = [select id,Sales_di_Riferimento__c,Codice_Provincia__c,Regione__c,CAP__c 
         														from Matrice_di_Assegnazione__c where CAP__c IN:CAPSet];
        
        for(Matrice_di_Assegnazione__c oAssign : matrixAssignmentLst)
        {
            if(! String.isEmpty(oAssign.Sales_di_Riferimento__c))
            {
            	capAssignmntMap.put(oAssign.CAP__c,oAssign);
            }
        }
        for(Lead oLead : newLeads)
        {
          if(capAssignmntMap.containsKey(oLead.CAP__c))
          {
          	oLead.Inside_Saels_di_Riferimento__c = capAssignmntMap.get(oLead.CAP__c).Sales_di_Riferimento__c;
          }
        }
        
    }

}