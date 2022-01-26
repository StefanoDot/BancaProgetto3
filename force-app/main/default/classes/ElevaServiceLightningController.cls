public with sharing class ElevaServiceLightningController {
    @AuraEnabled
    public static Utils.FidejussoreResponse aggiornaMoreScore(Id recordId, String ricezioni,  String morescore,  String errorericezioni) {
        Utils.FidejussoreResponse response=new Utils.FidejussoreResponse ();
        
        
                Utils_Constants costanti = new Utils_Constants();

        String RecordTypeSi;
           List<RecordType> RecOpp = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE DeveloperName = :costanti.RECORD_TYPE_BUSINESS AND SobjectType = 'Account'];
        RecordTypeSi = RecOpp.get(0).Id; 
        
        response.responseMessage='';
        System.debug('ricezioni' +ricezioni);
                System.debug('morescore' +morescore);
        System.debug('errorericezioni' +errorericezioni);
         String serializeCredential;
        ElevaCredentials__mdt elevaCredentials = [SELECT DeveloperName,endpoint__c,root__c,x_api_key__c,x_app_language__c,x_caller_id__c,x_channel__c,x_hmac__c FROM ElevaCredentials__mdt WHERE DeveloperName = 'ElevaMoon'];
        serializeCredential = JSON.serialize(elevaCredentials, true);
        
        System.debug('Eleva Credential flusso 1.1 ' + serializeCredential);
        
        
        
        list<Account> acc=[select id, Codice_Fiscale__c,MoreScore__c,Data_Aggiornamento_MoreScore__c,CodiceKoOplon__c,Anagrafica_Id_Oplon__c,userMail__c, Ricezione_Dati_Oplon__c, updateOplonUserEmail__c from account where id=: recordId];

        
        response= ElevaRestApiController.getMoreScore1(acc[0].Codice_Fiscale__c, acc[0].Id,acc[0].userMail__c,acc[0].Anagrafica_Id_Oplon__c); 
        system.debug('eleva'+response);
        
        
            System.debug('Jena fut ketu 11111111111111');
         list<Account> acc1=[select id, Codice_Fiscale__c,MoreScore__c,Data_Aggiornamento_MoreScore__c,CodiceKoOplon__c,Anagrafica_Id_Oplon__c,userMail__c, Ricezione_Dati_Oplon__c, Errore_Ricezione_Dati_Oplon__c, updateOplonUserEmail__c from account where id=: recordId];
   
            System.debug('acc1[0].MoreScore__c' +acc1[0].MoreScore__c);
            System.debug('acc1[0].Ricezione_Dati_Oplon__c' +acc1[0].Ricezione_Dati_Oplon__c);
            System.debug('acc1[0].Errore_Ricezione_Dati_Oplon__c' +acc1[0].Errore_Ricezione_Dati_Oplon__c);
                    
            
            if(response.ok== true && morescore == acc1[0].MoreScore__c  && (ricezioni=='Ko Full' && acc1[0].Ricezione_Dati_Oplon__c == 'Ok Light' ) || (ricezioni=='Ok Full' && acc1[0].Ricezione_Dati_Oplon__c == 'Ok Light') || (ricezioni=='Ok Full' && acc1[0].Ricezione_Dati_Oplon__c == 'Ko Light') || (ricezioni=='Ok Full' && acc1[0].Ricezione_Dati_Oplon__c == 'Ko Full')){
                            System.debug('Jena fut ketu 55555');

                  
            ElevaRestApiController.getAnagraphicDetailsTrigger(acc1[0].Codice_Fiscale__c, acc1[0].Id, acc1[0].userMail__c,serializeCredential, acc1[0].updateOplonUserEmail__c,acc1[0].Anagrafica_Id_Oplon__c	);

        }

            if((morescore == acc1[0].MoreScore__c && ricezioni=='Ok Full' && morescore <>'C'&& morescore <> 'D') && response.ok==true  || (morescore == acc1[0].MoreScore__c && ricezioni=='Ok Full'  && errorericezioni=='Modefinance Analysis Create Budget KO'  &&  morescore <>'C'&& morescore <> 'D' && response.ok==false ))
            {
                
               System.debug('Jena fut ketu 33333333333');

                Account updateAcc = new Account();
                updateAcc.Id= acc1[0].Id;
                updateAcc.Ricezione_Dati_Oplon__c ='Ok Full';
                updateAcc.RecordTypeId=RecordTypeSi;
                
               
 AccountsController.bypasstrigger=true;
        system.debug('updateAcc ' + updateAcc);
        update updateAcc;
        AccountsController.bypasstrigger=false;
            }
            
        
        
      response.responseMessage= response.responseMessage + ' ' + '\n Contattare il Sales Support';

        system.debug('responsiii'+response);


        return response;
    }
    
    
    @AuraEnabled
    public static Utils.FidejussoreResponse moreScore(Id recordId) {  
        system.debug('start');
        Utils.FidejussoreResponse response=new Utils.FidejussoreResponse ();
        response.responseMessage='';
       
        List<Account> acc = [select id, Data_Aggiornamento_MoreScore__c, Ricezione_Dati_Oplon__c, MoreScore__c, Errore_Ricezione_Dati_Oplon__c from Account where id=: recordId];
         response.Ricezioni=acc[0].Ricezione_Dati_Oplon__c;
        response.Morescore = acc[0].MoreScore__c;
       response.ErroreRicezioni=acc[0].Errore_Ricezione_Dati_Oplon__c;
        
        
        List<String> profileIds = new List<String>();
  
        Boolean isNotAdmin=false;
        String aggiornaNull;
        for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name ='Amministratore del sistema']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        if(!profileIds.contains(currentProfileId)){
            isNotAdmin=true;
        }
        if(acc[0].Data_Aggiornamento_MoreScore__c<>null){
            aggiornaNull=acc[0].Data_Aggiornamento_MoreScore__c.format();
        }
        date aggiorna = acc[0].Data_Aggiornamento_MoreScore__c; 
        Integer scMonth;
        date current = date.today();
        integer currMonth;
        if (aggiorna<>null){
            scMonth = aggiorna.month();
            system.debug(scMonth);
            currMonth= current.month();
        }
        if(acc[0].Ricezione_Dati_Oplon__c<>'Ok Full' && (acc[0].MoreScore__c!='C' && acc[0].MoreScore__c!='D')&&isNotAdmin){
            system.debug('kushti ok full');
            response.ok=false;
         if(acc[0].Ricezione_Dati_Oplon__c=='Ok Light')
            response.responseMessage='Hai già richiesto l\'aggiornamento del Morescore. Attendi qualche minuto e ricarica la pagina per visualizzare i dati aggiornati.';
                else{
           response.responseMessage='Non puoi Aggiornare il MoreScore';
  
                }        
        }
        else{
            system.debug('kushti true');
            response.ok=true;
             if(aggiornaNull==null){
              response.responseMessage='Stai richiedendo l\'aggiornamento del MoreScore';
            }
            else{
         
            response.responseMessage='Stai richiedendo l\'aggiornamento del MoreScore. Il MoreScore attuale é '+'&nbsp'+aggiornaNull;
            }
            if(scMonth==currMonth&&aggiorna<>null){
                response.responseMessage= response.responseMessage+' che risulta già aggiornato il giorno del mese corrente.';
            }
            
        }
        
        
        
        system.debug('O EGLEVISA, KETE E KAM BERE PER ARSYE TE TRUPIT TIM, MOS MA HIQ!');
      
        return response; 
    }
}