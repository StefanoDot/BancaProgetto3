public class CointestazioneController extends TriggerHandler{
    public static Boolean bypassUserAccess = ! Utils.checkUserBypassAccess();
    public override void beforeDelete(){
        System.debug('CointestazioneController - afterDelete --- Start');
        
        system.debug('Trigger.new ' + Trigger.old);
        CointestazioneController.deleteFidejussore(Trigger.old);
        
        System.debug('CointestazioneController - afterDelete --- End');
    }
    
    public override void beforeUpdate(){
        System.debug('CointestazioneController - beforeUpdate --- Start');
                system.debug('Trigger.new ' + Trigger.new);

        List<Id > changeTipo = new List<Id>();
        for (Cointestazione__c  coint : (List<Cointestazione__c>)Trigger.new){
            Cointestazione__c oldCoint = (Cointestazione__c) Trigger.oldMap.get(coint.id);
            

            System.debug('oldCoint' +oldCoint);
            if(coint.Tipo_di_Cointestazione__c <> oldCoint.Tipo_di_Cointestazione__c){
                changeTipo.add(coint.Id);
                
            }
            
        }

System.debug('changeTipo' +changeTipo);        
         if(!changeTipo.isEmpty()){
            CointestazioneController.controlPicklist(changeTipo);            
        }
        
        
        System.debug('CointestazioneController - beforeUpdate --- End');
    }
    
    
    
     public override void afterUpdate(){
        System.debug('CointestazioneController - beforeUpdate --- Start');
                system.debug('Trigger.new ' + Trigger.new);

        List<Id > ListndgRicheistaCR = new List<Id>();
        for (Cointestazione__c  coint : (List<Cointestazione__c>)Trigger.new){
            Cointestazione__c oldCoint = (Cointestazione__c) Trigger.oldMap.get(coint.id);
            

            System.debug('oldCoint' +oldCoint);
            if(coint.NDG_Cointestazione__c <> oldCoint.NDG_Cointestazione__c && coint.NDG_Cointestazione__c <> null && coint.Tipo_di_Cointestazione__c=='Contact'){
                ListndgRicheistaCR.add(coint.Id);
                
            }
            
        }

System.debug('ListndgRicheistaCR' +ListndgRicheistaCR);        
         if(!ListndgRicheistaCR.isEmpty()){
            CointestazioneController.ndgRicheistaCR(ListndgRicheistaCR);            
        }
        
        
        System.debug('CointestazioneController - beforeUpdate --- End');
    }
    
    public static void ndgRicheistaCR(List<Id> ListndgRicheistaCR ){
                System.debug('CointestazioneController - beforeUpdate --- kottttt'+ ListndgRicheistaCR);

        List<Contact> updateCont = new List<Contact>();
        for(Cointestazione__c coint : [Select id, (Select  id , NDG__c, Persona_Fisica__r.Fidejussore__c,Persona_Fisica__c  from  Fidejussioni__r where Persona_Fisica__r.Fidejussore__c =false) from   Cointestazione__c where id IN:ListndgRicheistaCR  ] ) {
            
 for(Fidejussione__c  fid : coint.Fidejussioni__r){
              
Contact cont = new Contact();
     cont.Id= fid.Persona_Fisica__c;
     cont.Fidejussore__c=true;
     
 updateCont.add(cont);
 
 }            
        }
        update updateCont;
        System.debug('updateCont'+updateCont);
        
    }
    
    public static void deleteFidejussore(List<Cointestazione__c> deletedCoin){
        System.debug('CointestazioneController.deleteFidejussore --- Start deletedCoin ' +deletedCoin);
        
        Set<id> cointId = new Set<Id>();
           for(Cointestazione__c  coint : deletedCoin ){
               cointId.add(coint.id);
           }
        
        System.debug('cointId'+cointId);
        
        List<Fidejussione__c> fidDelete = new List<Fidejussione__c>();
        system.debug('deletedCoin ' + deletedCoin);
        
        List<Cointestazione__c>  cointList=   [Select Id, ( Select id  from Fidejussioni__r) from Cointestazione__c  where id IN: cointId];
                system.debug('cointList ' + cointList);

        for(Cointestazione__c  coint : cointList){
            
            for(Fidejussione__c  fid : coint.Fidejussioni__r){
              
                fidDelete.add(fid);
        }
            
    }
        System.debug('CointestazioneController.deleteFidejussore --- end fidDelete  '+fidDelete);
        delete fidDelete;
            
}
     public static void controlPicklist(List<Id> idcoin){
    
         
         List<Cointestazione__c > cointFull = [Select id,Tipo_di_Cointestazione__c, (Select id from  Fidejussioni__r ) from Cointestazione__c where  Id in :  idcoin];
         
         for( Cointestazione__c coint :cointFull ){
             
          
             if( coint.Fidejussioni__r.size() >0){
                 Cointestazione__c newcoin = (Cointestazione__c) Trigger.newMap.get(coint.id);  
                 if(bypassUserAccess)
                 {
        	     	newcoin.Tipo_di_Cointestazione__c.adderror('Non puoi modificare perche ha Fidejussione');
                 }
             }
             
         }   
         
}
}