public class EmailToCaseRoutingBatch implements Database.Stateful,Database.Batchable<Case> {
    public List<Case> dtos ;
    List <String> group1 = new List<String>{'benestare', 'messa in quota', 'erogazione', 'liquidazione'};
        List <String> group2 = new List<String>{'richiesta integrazione', ' liberatoria', 'conteggio estintivo'};
            List <String> group3 = new List<String>{'notific', ' richiesta integrazione', 'evidenza', 'comunicazione estinzione'};
                List <String> group4 = new List<String>{'integrazione notifica', 'richiesta documentazione'};
                    List <String> group5 = new List<String>{'annullamento', 'respingimento'};
                        List <String> group6 = new List<String>{'richiesta integrazione doc', 'estinzione', 'integrazione con liquidazione'};
                            List <String> group7 = new List<String>{'messa in quota', 'liberatoria', 'rimborso rata'};
                                List <String> group8 = new List<String>{'stato', 'sinistro', 'decesso', 'morte', 'licenziamento', 'cessazione', 'sospensione', 'dimissioni', 'riduzione rata'};
                                    List <String> group9 = new List<String>{'tabulato', 'distinta versamento', 'elenco versamenti', 'mortdettaglio ratee', 'elenchi debitorie', 'tabulato contabile'}; 
                                        List <String> group10 = new List<String>{'annullamento', 'respingimento', 'copia contratto', 'reclamo', 'indagine', 'DIAZ', 'ZENITH', 'rimborso', 'segnalazione', 'CR', 'banche dati'};   
                                            List <String> group11 = new List<String>{'allegat', 'respingimento', 'ministerial', 'certificato stipendio', 'stipendiale', 'attestazione servizio', 'allegato B'};   
                                                public CQSTechnicalAssigment__c priority0 ;
    public List<CQSTechnicalAssigment__c> listofconfigs; 
    public List<Group> grpList;
    Map<String,Group> mapGroup = new Map<String,Group>();
    List<Case> caseListPec = new List<Case>();
    List<Case> caseListAttach = new List<Case>();
    
    private CQSTechnicalAssigment__c config(String status,String subject,String description){ 
        
        CQSTechnicalAssigment__c returnObj;
        for(CQSTechnicalAssigment__c prd : listofconfigs){
            if(status==prd.CQSStatus_Pratica__c){
                List<String> str = prd.KeyWordGroup__c.split(',');
                if(listMethod(subject,str)==true){
                    returnObj = prd;
                    break;
                    
                }else if(listMethod(description,str)==true){
                    returnObj = prd;
                    break;
                }
            }             
        } 
        if(returnObj==null){
            returnObj = priority0;
        }
        return returnObj;
    }
    
    public EmailToCaseRoutingBatch(){
        priority0 = [SELECT id,Priority__c, CQSStatus_Pratica__c, CaseOwner__c, CQSTipologia__c, KeyWordGroup__c from CQSTechnicalAssigment__c  Where Priority__c =0][0];
        listofconfigs = [SELECT id,Priority__c, CQSStatus_Pratica__c, CaseOwner__c, CQSTipologia__c, KeyWordGroup__c from CQSTechnicalAssigment__c  Where Priority__c >0 order by Priority__c asc]; 
        grpList = [SELECT Id,Name,DeveloperName FROM Group where type = 'queue'];
        for(Group g : grpList){
            mapGroup.put(g.developername,g);
            
        }
    }
    
    public Iterable<Case> start(Database.BatchableContext bc) {
        
        // collect the batches of records or objects to be passed to execute
        return this.dtos;
        
    }
    public void execute(Database.BatchableContext bc, List<Case> records){
        
        String emailSubject = 'POSTA CERTIFICATA';
        Group grp = [SELECT Id FROM Group Where Name = 'CQS Admin e Supervisor'];
        Group grpchild = [SELECT Id FROM Group Where Name = 'CQS Risposte PEC'];
        List<Case> caseList = new List<Case>();
        List<String> productCodes = new List<String>(); 
        List<String> fiscalCodes = new List<String>(); 
        List<CQSProdotto__c> listofProduct = new List<CQSProdotto__c>(); 
        List<CQSCliente__c  > listofCliente = new List<CQSCliente__c  >();
        Map<String,String> caseFiscalCodes = new Map<String,String>();
        Map<String,String> caseProductNames = new Map<String,String>();
        Map<String,CQSProdotto__c> productMap = new Map<String,CQSProdotto__c>();
        Map<String,CQSCliente__c> clienteMap = new Map<String,CQSCliente__c>();
        Map<Integer,CQSTechnicalAssigment__c> configObject = new Map<Integer,CQSTechnicalAssigment__c>(); 
        //List<case> cases = [select id,subject from case];
        Map<String,String> results = new Map<String,String>();
        String mapValue = '';
        List<Id> result = new List<Id>(); 
        CaseUtils files = new CaseUtils();
        List<String> toRemoveList = new List<String>{'FWD:','RE:','FW:','I:','CONSEGNA:','ACCETTAZIONE:','RICEVUTA PROTOCOLLO - ','POSTA CERTIFICATA:'};
		
        
        for (Case cs : this.dtos) {
            //trim prefixes from case subject
            String trimmedSubject = cs.Subject;
            for(String str : toRemoveList) {
                String regExp = '(?i)('+str+')';
                trimmedSubject = trimmedSubject.replaceAll(regExp, '');
            }
                       
            system.debug('trimmedSubject:' + trimmedSubject);
            
            if(cs.Origin=='Posta elettronica'){
                if((cs.Subject != null && cs.Subject.toUppercase().Contains('CONSEGNA:'))||
                   (cs.Subject != null && cs.Subject.toUppercase().Contains('ACCETTAZIONE:'))||
                   (cs.Subject != null && cs.Subject.toUppercase().Contains('RICEVUTA PROTOCOLLO - '))){
                       
                   cs.OwnerId = grpchild.id;
                   cs.Origin = 'PEC';
                   cs.Status = 'Inoltrato';
                   cs.Subject = trimmedSubject;  
                   caseListPec.add(cs);
                       
                   }else{
                       
                      // caseList.add(cs);
                   
                
                if(cs.Subject != null && cs.Subject.Contains(emailSubject)){
                    cs.Origin='PEC';
                    cs.Priority='Alta';
                    caseListAttach.add(cs);
                    
                }else{
                    //cs.Origin='Posta Elettronica';
                    cs.Priority='Media';
                }
                cs.Subject = trimmedSubject;
                
                
                String fiscalCode='';
                if(cs.Subject != null){
                    fiscalCode = getValidSixteenNumber(cs.Subject);
                    
                }                
                if(fiscalCode==null||fiscalCode==''){
                    if(cs.Origin != null && cs.Origin=='PEC'){
                        if(results.get(cs.id)!= null){
                            mapValue =results.get(cs.id);
                            fiscalCode =getValidSixteenNumber(mapValue);
                            system.debug('fabio' + fiscalCode);
                        }
                    }else{
                        fiscalCode = getValidSixteenNumber(cs.Description);
                        system.debug(LoggingLevel.INFO, 'omg4');
                    }
                } 
                if(fiscalCode!=null&&fiscalCode!=''){                   
                    caseFiscalCodes.put(cs.Id,fiscalCode);
                    fiscalCodes.add(fiscalCode);
                    system.debug(LoggingLevel.INFO, 'omg3');	
                    
                }
                
                String pruductName='';
                
                if(cs.Subject != null){
                    pruductName = getValidEightNumber(cs.Subject);
                    
                }                
                if(pruductName==null||pruductName==''){
                    if(cs.Origin != null && cs.Origin=='PEC'){
                        if(results.get(cs.id)!= null){    
                            mapValue =results.get(cs.id);
                            pruductName =getValidEightNumber(mapValue);
                        }
                    }else{
                        pruductName = getValidEightNumber(cs.Description);
                        system.debug(LoggingLevel.INFO, 'omg4');
                    }
                } 
                if(pruductName!=null&&pruductName!=''){
                    caseProductNames.put(cs.Id,pruductName);
                    productCodes.add(pruductName);
                    system.debug(LoggingLevel.INFO, 'omg3');	
                }
            
            caseList.add(cs);
                       }
                
           }
        }
        
        List<Case> resultC = files.getAllChildCasesObj(caseListPec);
        results = files.getAllChildAttachments(caseListAttach);
        System.debug('******:' + resultC);
        for(Case c : this.dtos){
            for(Case b : resultC){
                if(c.id == b.id){
                    c.parentid = b.parentid;
                }
            }
        }       
        system.debug(LoggingLevel.INFO, 'omg');	
        if(productCodes.size()>0){
            listofProduct = [SELECT Id,Name,CQSCliente__c,CQSStatus_Pratica__c FROM CQSProdotto__c Where Name In: productCodes];
            for(CQSProdotto__c prd : listofProduct){
                productMap.put(prd.Name,prd);
            } 
            system.debug(LoggingLevel.INFO, 'omg2');	
        }
        if(fiscalCodes.size()>0){
            listofCliente = [SELECT CQSEmail__c, CQSTelefono_1__c, CQSTelefono_2__c, CQSCodice_Cliente__c,
                             CQSCognome_Cliente__c, CQSNome_Cliente__c, CQSCodice_Fiscale__c, CQSData_di_Nascita_Cliente__c,
                             CQSNDG_Cliente__c, CQSProvincia_Residenza_Cliente__c, CQSQualifica_Cliente__c, Id FROM CQSCliente__c where CQSCodice_Fiscale__c IN: fiscalCodes];
            for(CQSCliente__c fisc : listofCliente){
                clienteMap.put(fisc.CQSCodice_Fiscale__c,fisc);
            } 
            system.debug(LoggingLevel.INFO, 'omg2');	
        }
        for(Case cs : caseList){
            //cs.isAdminQueue__c = true;
            system.debug('********' + caseProductNames.get(cs.Id));
            cs.Status = 'Inoltrato';
            
            if(caseFiscalCodes.get(cs.Id) != null){
                String csFiscalCliente = caseFiscalCodes.get(cs.Id);
                if(csFiscalCliente != null && clienteMap.get(csFiscalCliente)!=null){
                    cs.CQSCliente__c= clienteMap.get(csFiscalCliente).ID;
                }
            }
            if(caseProductNames.get(cs.Id) != null){
                String csProduct = caseProductNames.get(cs.Id);
                if(csProduct != null && productMap.get(csProduct)!=null){
                    CQSProdotto__c prdObj = productMap.get(csProduct);
                    cs.CQSProdotto__c = prdObj.Id;
                    if(cs.CQSCliente__c==null){
                        cs.CQSCliente__c  = prdObj.CQSCliente__c;
                    }
                    
                    CQSTechnicalAssigment__c res = config(prdObj.CQSStatus_Pratica__c,cs.Subject,cs.Description);
                    
                    if(res.CQSTipologia__c != null){
                        cs.CQSTipologia__c = res.CQSTipologia__c;    
                    }
                    else{
                        cs.CQSTipologia__c = priority0.CQSTipologia__c;
                    }
                    Group gr = mapGroup.get(res.CaseOwner__c);
                    if(gr != null){
                        cs.ownerId = gr.id;
                        system.debug('Fabio1 '+cs.ownerId);
                    }
                    else{
                        cs.ownerId = mapGroup.get(priority0.CaseOwner__c).id;
                        cs.Status  = 'Da assegnare';
                        system.debug('Fabio2 '+cs.ownerId);
                    }
                }else{ 
                    cs.CQSTipologia__c = priority0.CQSTipologia__c;
                    cs.ownerId = mapGroup.get(priority0.CaseOwner__c).id;
                    cs.Status  = 'Da assegnare';
                    /////// we assign the value inside record with priority 0
                }
            }else{
                cs.CQSTipologia__c = priority0.CQSTipologia__c;
                cs.ownerId = mapGroup.get(priority0.CaseOwner__c).id;
                cs.Status  = 'Da assegnare';
                //////////  we assign the value inside record with priority 0
            }
            
        } 
    } 
    
    public static string getValidEightNumber(String value){
        String text= '';
        String res = '';
        if(value != null){
            text = value.replaceAll('[^\\d]', ' ');
            //system.debug(str.split(' '));
            List<String> str = text.split(' ');
            For(String s : str){
                if(s.length() > 0 && s.length() <=8){
                    System.debug('FIND s:'+s);
                    res = s;
                    break;
                }
            }
        }
        return res;
    }
    
    private static string getValidSixteenNumber(String text){
        String value= '';
        String res = '';
        if(text != null){
            
            //system.debug(str.split(' '));
            value =  text.replaceAll('\n', ' ');
            List<String> str = value.split(' ');
            
            For(String s : str){
                if(s.length()== 16){
                    Pattern alphanumericOf16Pattern = Pattern.compile('^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$');
                    Matcher sMatcher16 = alphanumericOf16Pattern.matcher(s);
                    if(sMatcher16.find() == true) {
                        System.debug('FIND s:'+s);
                        res = s;
                        break;
                        
                    }
                }
            }
        }
        return res;
    }
    private static Boolean listMethod(String test, List <String> words){
        String stringWork = test != null ? test.tolowerCase() : '';
        boolean res = false;
        //List <String> group1 = new List<String>{'benestare', 'messa in quota', 'erogazione', 'liquidazione'};
        if(stringWork != null && stringWork != ''){
            For(String t : words){
                if(t != null && stringWork.Contains(t.tolowerCase())){
                    res = true;
                    break;
                }else{
                    res = false;
                }
                
            }
        }
        return res;
    }
    
    /*public string getAllChildAttachments(Id caseID){
list<Id> liChildDocumentIds = new List<Id>();
for(ContentDocumentLink cdl :  [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: caseID]){
liChildDocumentIds.add(cdl.ContentDocumentId);
}
ContentVersion bodytext = [SELECT Id, Title, ContentSize, Description, FileExtension,
FileType, IsLatest, VersionData FROM ContentVersion WHERE ContentDocumentId IN: liChildDocumentIds];
String s = bodytext.VersionData.tostring();
s = EncodingUtil.base64Decode(EncodingUtil.base64Encode(bodytext.VersionData)).toString();
return s;
}*/
    
    public void finish(Database.BatchableContext bc){
        update this.dtos;
    }
}