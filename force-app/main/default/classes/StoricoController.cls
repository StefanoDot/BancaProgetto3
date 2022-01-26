public class StoricoController extends TriggerHandler{
    
 public override void afterInsert(){
        System.debug('StoricoController.afterInsert trigger- Start');
             list<Storico_Opportunit__c> listaErrogata=new list<Storico_Opportunit__c>();

     
     For(Storico_Opportunit__c stoOpp : (List<Storico_Opportunit__c>)Trigger.new){
         if(stoOpp.Fase__c =='Erogata'){
             listaErrogata.add(stoOpp);
             
        
         }
        
     }
     
      if(!listaErrogata.isEmpty()){
            StoricoController.AfterInsertErrogata(listaErrogata);
        }
        System.debug('StoricoController.afterInsert trigger- End');

    }
    
    
    
     public override void afterUpdate(){
        System.debug('StoricoController.afterUpdate trigger- Start');
             list<Storico_Opportunit__c> listaErrogataUpdate=new list<Storico_Opportunit__c>();

     
     For(Storico_Opportunit__c stoOpp : (List<Storico_Opportunit__c>)Trigger.new){
         if(stoOpp.Fase__c =='Erogata'){
             listaErrogataUpdate.add(stoOpp);
             
        
         }
        
     }
     
      if(!listaErrogataUpdate.isEmpty()){
           StoricoController.AfterInsertErrogata(listaErrogataUpdate);
        }
        
             System.debug('StoricoController.afterUpdate trigger- End');

    }
    
    public static void AfterInsertErrogata(List<Storico_Opportunit__c> sto){
        
        System.debug('StoricoController.AfterInsertErrogata --Start sto'+sto);
        List<Opportunity> oppUpdate = new List<Opportunity>();
        
        
        for(Storico_Opportunit__c  st: sto){
            
            Opportunity opp = new Opportunity();
            opp.Id = st.Opportunit__c;
            opp.GCR_1__c  =st.GCR_GG__c;
            opp.CR__c=st.CR_GG__c;
            opp.VCR__c =st.VCR_GG__c;
            oppUpdate.add(opp);
            
        }
        
        
        System.debug('StoricoController.AfterInsertErrogata --End oppUpdate '+oppUpdate);
        update oppUpdate;
        
        
        
    }

}