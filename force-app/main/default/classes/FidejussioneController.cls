public class FidejussioneController  extends TriggerHandler{
    public static Boolean bypassUserAccess = ! Utils.checkUserBypassAccess();
    public override void beforeInsert(){
        System.debug('FidejussioneController.beforeInsert trigger - Start');
        FidejussioneController.BeforeInsert(Trigger.new);
        FidejussioneController.checknumberFid(Trigger.new);
        System.debug('FidejussioneController.beforeInsert trigger - End');  
    }
    
    public override void afterInsert()
    {
        System.debug('FidejussioneController.afterInsert trigger - Start');
        FidejussioneController.numberOfFidejussione(Trigger.new);
        FidejussioneController.duplicateFidejussioni(Trigger.new);
        FidejussioneController.prendiNDG(Trigger.new);   
        System.debug('FidejussioneController.afterInsert trigerr - End'); 
    }
    
    public override void beforeDelete(){
        System.debug('FidejussioneController - beforeDelete --- Start');
        
        FidejussioneController.preventDeleteFidejussioni(Trigger.old);
        
        System.debug('FidejussioneController - beforeDelete --- End');
    }
    
    public override void afterDelete(){
        System.debug('FidejussioneController - afterDelete --- Start');
        system.debug('Trigger.new ' + Trigger.old);
        FidejussioneController.numberOfFidejussione(Trigger.old);
        System.debug('FidejussioneController - afterDelete --- End');
    }
    
    
    public override void afterUpdate() {   
        System.debug('FidejussioneController.afterUpdate trigger- Start');
        List<Fidejussione__c> fidList = new List<Fidejussione__c>();
        for( Fidejussione__c fid: (List<Fidejussione__c>)Trigger.new)
        {
            
            Fidejussione__c oldFid = (Fidejussione__c) Trigger.oldMap.get(fid.id);
            
            If (oldFid.Persona_Fisica__c <> fid.Persona_Fisica__c || oldFid.Persona_Giuridica__c<> fid.Persona_Giuridica__c){
                fidList.add(fid);
            }
        }
        if(!fidList.isEmpty()){
            FidejussioneController.numberOfFidejussione(fidList);
        }
        System.debug('FidejussioneController.afterUpdate trigger- End');
        
    }
    
    
    public static void BeforeInsert(List<Fidejussione__c> newQuoteList){
        
        system.debug('FidejussoreController.BeforeInsert Start newQuoteList '+newQuoteList);
        list<Id> OpportunityList = new list<String>();
        
        
        for (Fidejussione__c newQuote : newQuoteList)
        { 
            Contact con = new Contact(id = newQuote.Persona_Fisica__c);
            Account acc = new Account(id = newQuote.Persona_Giuridica__c);
            
            OpportunityList.add(newQuote.Garanzia__c);
            
            if(newQuote.Tipo_fidejussione__c =='Persona Fisica' && newQuote.Garanzia__c != null &&  newQuote.Cointestazione__c == null)
            {
                system.debug('ContactId'+ con.Id);
                if(newQuote.Persona_Fisica__c<>null){
                    con.Fidejussore__c= true;
                    update con;  
                }
            }
            if(newQuote.Tipo_fidejussione__c =='Persona Giuridica' && newQuote.Garanzia__c != null && newQuote.Cointestazione__c == null) 
            {
                system.debug('AccId'+ acc.Id);
                if(newQuote.Persona_Giuridica__c<> null){
                    acc.Fidejussore__c = true;
                    update acc;
                }
            }
            if(newQuote.Tipo_fidejussione__c =='Cointestazione')
            {       
                if(newQuote.Persona_Fisica__c<>null){
                    con.Fidejussore__c= true;
                  //  update con; 
                }
            }
        }
        Map<ID,Garanzia__c> OpportunityMap = new Map<ID, Garanzia__c>([SELECT Id, Name,Tipo_di_Fidejussione__c, (Select Id from Fidejussioni__r ) FROM Garanzia__c where Id in :OpportunityList]);
        String newNameOpp ;
        
        
        for (Fidejussione__c newQuote : newQuoteList)
        {
            if(OpportunityMap.get(newQuote.Garanzia__c)!=null)
                newNameOpp=newQuote.Tipo_fidejussione__c+' '+(OpportunityMap.get(newQuote.Garanzia__c).Fidejussioni__r.size()+1);
            newQuote.Fidejussione_NameText__c= newNameOpp;
        } 
        
        system.debug('QuoteController.BeforeInsert End');
    }
    
    
    public static void numberOfFidejussione(List<Fidejussione__c> fidList){
        system.debug('FidejussioneController.numberOfFidejussione - Start fidList '+fidList);
        
        List<Cointestazione__c> updateCointList = new List<Cointestazione__c>();
        
        List<Id> cointId = new List<Id>();
        
        for(Fidejussione__c f : fidList ){
            System.debug('id fid' + f.Id);
            cointId.add(f.Cointestazione__c);
        }
        
        
        List<Fidejussione__c> kot = [select id from Fidejussione__c where id =: fidList[0].Id];
        
        System.debug('kot' +kot);
        System.debug('cointId' +cointId);
        
        List<Cointestazione__c> coint = [select Id,Fide__c,Tipo_di_Cointestazione__c, (select id, Persona_Fisica__r.name, Persona_Giuridica__r.name from Fidejussioni__r) from Cointestazione__c where id in:cointId]; 
        
        for(Cointestazione__c c:coint){
            String ourFid = '';
            for(Fidejussione__c f: c.Fidejussioni__r){
                if(c.Tipo_di_Cointestazione__c=='Contact' && c.Tipo_di_Cointestazione__c<> null){ 
                    ourFid += f.Persona_Fisica__r.name+ ', ';
                }
                else if(c.Tipo_di_Cointestazione__c=='Account'&& c.Tipo_di_Cointestazione__c<> null){
                    ourFid += f.Persona_Giuridica__r.name+ ', ';
                }
            }
            system.debug('ourFid '+ourFid);
            ourFid = ourFid.removeEnd(', ');
            c.Fide__c= ourFid;
            
            updateCointList.add(c);
            
        }
        
        
        update updateCointList;
        
        System.debug('FidejussioneController.numberOfFidejussione - End ' + updateCointList);
    }
    
    public static void duplicateFidejussioni (List<Fidejussione__c> fideList){
        
        System.debug('FidejussioneController.duplicateFidejussioni - Start '+fideList);  
        
        List<Id> cointId = new List<Id>();
        
        
        for(Fidejussione__c f : fideList ){
            cointId.add(f.Cointestazione__c);   
        }
        
        List<Fidejussione__c> listFid = [select Id, NDG__c from Fidejussione__c where id in:fideList];
        system.debug('id e fid' +fideList);
        
        string ndgControl= listFid[0].NDG__c;
        system.debug('ndgControl'+ndgControl);
        Boolean error= false;
        List<Cointestazione__c> listCoint= [select id, (select id, NDG__c from Fidejussioni__r) from Cointestazione__c where id in:cointId];  
        
        List<Fidejussione__c> errList = new List<Fidejussione__c>();
        
        for(Cointestazione__c c :listCoint){
            system.debug('a futesh ketu');
            for(Fidejussione__c f: c.Fidejussioni__r){
                system.debug('f'+f);
                if(listFid[0].Id<> f.id){ 
                    if(f.NDG__c==ndgControl){ 
                        
                        error=true;  
                    } 
                }
            }
        }
        for(Fidejussione__c f :fideList){
            if(error){ 
                if(bypassUserAccess)
                {
                	f.addError('Esiste già questo Fidejussore');
                }
            }
        }
        System.debug('FidejussioneController.duplicateFidejussioni - End ');    
        
    }
    public static void preventDeleteFidejussioni (List<Fidejussione__c> delfideList){
        System.debug('FidejussioneController.preventDeleteFidejussioni - Start ' + delfideList);  
        Set<id> fidId = new Set<Id>();
        for(Fidejussione__c  fid : delfideList ){
            fidId.add(fid.Id);
        }
        System.debug('fidId ' +fidId); 
        List<Fidejussione__c> listCoint =[select id, Cointestazione__c, Cointestazione__r.NDG_Cointestazione__c, Garanzia__c  from Fidejussione__c where id IN : fidId];
        System.debug('listCoint ' +listCoint);
        
            List<Garanzia__c> garanziaUpdate = new List<Garanzia__c>();
        
        for(Fidejussione__c  fide : listCoint){
            System.debug('fide ' +fide);
            System.debug('fide.Cointestazione__r.NDG_Cointestazione__c' +fide.Cointestazione__r.NDG_Cointestazione__c);
            if(fide.Cointestazione__r.NDG_Cointestazione__c <> null){
                Fidejussione__c newcoin = (Fidejussione__c) Trigger.oldMap.get(fide.id); 
                System.debug('newcoin ' +newcoin);
                if(bypassUserAccess)
                {
                	newcoin.addError('Non puoi cancellato Fidejussione perche Cointestaziona ha NDG');
                }
            }
            else if( fide.Cointestazione__c == null && fide.Garanzia__c <> null){
            Garanzia__c gar = new Garanzia__c();
            gar.id = fide.Garanzia__c;
            gar.NDG_Fidejussore__c=' ';
            garanziaUpdate.add(gar);
            }
        }
        
        if(!garanziaUpdate.isEmpty())
           update garanziaUpdate;  
        System.debug('FidejussioneController.preventDeleteFidejussioni - End '); 
    }
    
    public static void checknumberFid (List<Fidejussione__c> newFidList){
        System.debug('FidejussioneController.checknumberFid - Start '); 
        list<Id> garanziaid = new list<String>();
        for (Fidejussione__c newFid : newFidList)
        { 
            garanziaid.add(newFid.Garanzia__c);
        }
        Map<ID,Garanzia__c> GaranziaMap = new Map<ID, Garanzia__c>([SELECT Id,  (Select Id from Fidejussioni__r ) FROM Garanzia__c where Id in :garanziaid]);
        for (Fidejussione__c newFid : newFidList){ 
            
            if( newFid.Garanzia__c != null && GaranziaMap.containsKey(newFid.Garanzia__c) ){
                
                Garanzia__c gara = GaranziaMap.get(newFid.Garanzia__c);
                system.debug('gara' + gara);
                if(gara.Fidejussioni__r.size()>0){
                    system.debug('gara.Fidejussioni__r.size()' + gara.Fidejussioni__r.size());
                    if(bypassUserAccess)
                    {
                    	newFid.addError('Su una garanzia di tipo Fidejussione, non puoi creare più di un Fidejussore!');
                    }
                }
            }
        }
        System.debug('FidejussioneController.checknumberFid - End '); 
    }
    
    public static void prendiNDG(List<Fidejussione__c> newFidList){
        
        List<Garanzia__c> garanziaUpdate = new List<Garanzia__c>();
        
        for(Fidejussione__c fid : newFidList){
            if( fid.Cointestazione__c == null && fid.Garanzia__c <> null)
            {
            Garanzia__c gar = new Garanzia__c();
            gar.id = fid.Garanzia__c;
            gar.NDG_Fidejussore__c=fid.NDG__c;
            garanziaUpdate.add(gar);
            }

        }
        update garanziaUpdate;   
    }
    
}