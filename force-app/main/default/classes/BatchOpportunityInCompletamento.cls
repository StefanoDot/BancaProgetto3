global class  BatchOpportunityInCompletamento implements Database.Batchable<sObject>,Database.AllowsCallouts{  
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('BatchOpportunityInCompletamento.start --- init');
        System.debug('BatchOpportunityInCompletamento.start --- Start');
        //cdo dite
        
        System.debug('query ' + Database.getQueryLocator('Select id,StageName,Is_Suspended__c, AccountId from Opportunity where Opp_5_1__c=\'Test\''));
        
        return Database.getQueryLocator('Select id,StageName,Is_Suspended__c, AccountId from Opportunity where CreatedBy.Profile.Name=\'Migrazione\' And StageName=\'Completamento Documenti\'  And Resultati_Pef_Flusso__c = null And Numero_Pratica__c <> null And Opp_5_1__c= \'Test\' ');
        
    }
    
    global void execute(Database.BatchableContext BC,  List<Opportunity> oppList){
        System.debug('BatchOpportunityInCompletamento.execute --- Start scope'+oppList);
        System.debug('BatchOpportunityInCompletamento.execute --- Start scope'+oppList.size());
     
        List<Opportunity> toBeProcessed = [Select id, Numero_Pratica__c,AccountId, Doc_Mail_User__c from Opportunity where Id in : oppList];
       
        system.debug('OpportunityController.createInquiry - Start toBeProcessed' +toBeProcessed);
        List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
        
        
        String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        serializeCredential = JSON.serialize(elevaCredentials, true);
        
        System.debug('Eleva Credential flusso 5.1 ' + serializeCredential);
        
        Utils_Constants constants = new Utils_Constants();
        
        String userMail;
        Map<Id, Map<String, List<Id>>> oppMapFinal = new Map<Id, Map<String, List<Id>>>();    
        Map<Id, List<Id>> mapAccount = new Map<Id, List<Id>>();        
        Map<Id, List<Id>> mapQuote = new Map<Id, List<Id>>();        
        Map<Id, List<Id>> mapContact1 = new Map<Id, List<Id>>();        
        Map<Id, List<Id>> mapContact2 = new Map<Id, List<Id>>();        
        
        Set<Id> IdOpp = new Set<Id>();
        Set<Id> IdAccount = new Set<Id>();
        Set<Id> idCointestazione = new Set<Id>();
        
        for(Opportunity opp : toBeProcessed){
            IdOpp.add(opp.Id);
            IdAccount.add(opp.AccountId);            
        }
        System.debug('IdAccount'+IdAccount);
        
        System.debug('IdAccount'+IdAccount);
        
        for(Opportunity o : [Select Id, (Select Id from Quotes where Status<>'Annullata' ) from Opportunity where Id IN : IdOpp ]){
            List<Id> IdQuote = new List<Id>();
            for(Quote q : o.Quotes){
                IdQuote.add(q.Id);
            }
            mapQuote.put(o.Id,IdQuote);
        }
        
        List<Garanzia__c> listGaranzia = [Select Id,Opportunit__c,Cointestazione__c,(Select Id,Persona_Fisica__r.NDG__c,Persona_Fisica__r.Id,Persona_Giuridica__r.Id from Fidejussioni__r) from Garanzia__c where  Opportunit__c IN :IdOpp   and Tipo_di_Garanzia__c ='Fidejussione' and Linea_di_Credito__r.Status <>'Annullata'  ];
        Set<Id> CointestazioneIdList = new Set<Id>();
        for(Garanzia__c  n : listGaranzia){
            if(n.Cointestazione__c !=null){
                CointestazioneIdList.add(n.Cointestazione__c);
            }
        }
        System.debug('CointestazioneIdList' +CointestazioneIdList);
        
        List<Cointestazione__c> ListCoinstazioneFull =[Select id, (Select Id, Name, Persona_Fisica__r.Id,Persona_Fisica__r.NDG__c,Persona_Giuridica__r.Id from Fidejussioni__r) from Cointestazione__c where Id IN : CointestazioneIdList];
        Map<Id, List<Fidejussione__c>> MapCointestazione = new Map<Id, List<Fidejussione__c>>();
        
        for(Cointestazione__c k : ListCoinstazioneFull){
            List<Fidejussione__c> nono = new List<Fidejussione__c>();
            nono = k.Fidejussioni__r;
            MapCointestazione.put(k.Id, nono);
        }
        System.debug('MapCointestazione' + MapCointestazione);
        
        
        for(Opportunity oppi :toBeProcessed ){
            Boolean blockOpp = false;
            Set<Id> amon = new Set<Id>();
            list<Id> test = new List<Id>();
            Set<Id> conts = new Set<Id>();
            List<Id> accs = new List<Id>();
            for(Contact c : [Select Id, AccountId, NDG__C from Contact where AccountId IN : IdAccount ]){
                
                if(oppi.AccountId == c.AccountId) { 
                    conts.add(c.Id);
                    test.add(c.Id);
                }
            }
            system.debug('conts'+conts); 
            accs.add(oppi.accountID);
            for(Garanzia__c var :  listGaranzia){
                if(var.Opportunit__c == oppi.Id)
                {
                    if(var.Cointestazione__c == null){
                        if(var.Fidejussioni__r.size() ==0){
                            blockOpp= true;                        
                        }
                        for(Fidejussione__c var2 : var.Fidejussioni__r){
                            if(var2.Persona_Fisica__r.Id != null){
                                conts.add(var2.Persona_Fisica__r.Id);}
                            if(var2.Persona_Giuridica__r.Id != null){
                                accs.add(var2.Persona_Giuridica__r.Id);}
                        }
                    }
                    else {
                        for(Fidejussione__c nos : MapCointestazione.get(var.Cointestazione__c)) {
                            amon.add(nos.Persona_Fisica__r.Id);
                            if(nos.Persona_Fisica__r.Id != null){
                                conts.add(nos.Persona_Fisica__r.Id);
                            }
                            if(nos.Persona_Giuridica__r.Id != null){
                                accs.add(nos.Persona_Giuridica__r.Id);
                            }
                        }
                        idCointestazione.add(var.Cointestazione__c);
                    }
                }
            }
            
            Set<Id> l=new Set<Id>();
            l.addAll(conts);
            list<Id> kot = new list<id>();
            kot.addAll(l);
            
            
            
            Set<Id> a=new Set<Id>();
            a.addAll(accs);
            list<Id> kotA = new list<id>();
            kotA.addAll(a);
            
            mapContact1.put(oppi.Id,test);
            mapContact2.put(oppi.Id,kot);
            // mapAccount.put(oppi.Id, accs);
            mapAccount.put(oppi.Id, kotA);
            System.debug('blockOpp'+blockOpp);
            if(blockOpp == true){
               
                   oppi.AddError('Non si può avanzare la opportunità se alla garanzia di tipo fidejussione non è associata almeno un fidejussore.');
               
            }
        }
        
        System.debug('idCointestazione' +idCointestazione);
        System.debug('mapQuote' +mapQuote);
        System.debug('mapContact1' +mapContact1);
        System.debug('mapContact2' +mapContact2);
        System.debug('mapAccount' +mapAccount);
        System.debug('mapCointestazione'+mapCointestazione);
        
        
        
        for(Opportunity op : toBeProcessed){
            if(metadata[0].Status__c == 'Active'){
                
                ElevaRestApiController.inquiry2(op.Id,op.AccountId,mapQuote.get(op.Id),mapContact2.get(op.Id),mapAccount.get(op.Id),op.Doc_Mail_User__c, serializeCredential);
                
            }}
        
        system.debug('OpportunityController.createInquiry - End');
        
    }
    
    global void finish(Database.BatchableContext BC){
         System.debug('BatchOpportunityInCompletamento.finish --- Start');
        System.debug('BatchOpportunityInCompletamento.finish --- End');
        
        
    }
}