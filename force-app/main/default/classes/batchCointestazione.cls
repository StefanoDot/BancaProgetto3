global class  batchCointestazione implements Database.Batchable<sObject>,Database.AllowsCallouts{  
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('batchCointestazione.start --- Start');
        //cdo dite
        
        System.debug('query ' + Database.getQueryLocator('Select id from Cointestazione__c where NDG__c=\'newndg\' and Cointestazione_ID_Oplon__c=null'));
        
        return Database.getQueryLocator('Select id from Cointestazione__c where NDG__c=\'newndg\' and Cointestazione_ID_Oplon__c=null');
        
    }
    
    global void execute(Database.BatchableContext BC,  List<Cointestazione__c> cointList){
        System.debug('batchCointestazione.execute --- Start scope'+cointList);
        System.debug('batchCointestazione.execute --- Start scope'+cointList.size());
     
       List<Switch__mdt> metadata= [Select Id, DeveloperName, Status__c from Switch__mdt where DeveloperName='NDG_Eleva'];
          List<Id> contactIdList = new List<Id>();
        List<Id> accountIdList = new List<Id>();
        
        List<String> subjectIdList = new List<String>();
        List<Cointestazione__c> coint = [Select id,Tipo_di_Cointestazione__c from Cointestazione__c where id in:cointList];
        String defaultUserMail1 ='';
        List<Default_User__mdt> defaultUser1 = new List<Default_User__mdt>();
         defaultUser1=[select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, username__c  from Default_User__mdt where DeveloperName ='Integration_Default_Dot_Email'];
        if(defaultUser1.size()==1){
            defaultUserMail1=defaultUser1[0].username__c;
        }  
         Id user = userInfo.getUserId();
        System.debug('user ' + user);
        List<User> userMail = [Select id, ManagerId, Email, Manager.Email from User where Id =: user];
        
        String Email ;
        if(userMail[0].ManagerId <>null){
            System.debug('kushti i menxhaerit');
            
            if(userMail[0].Manager.Email.ContainsIgnoreCase('dunegroup.it')){
                Email= defaultUserMail1;  
            }else {
                Email=userMail[0]. Manager.Email;   
            }      
        }else {
            
            if(userMail[0].Email.ContainsIgnoreCase('dunegroup.it')){
                Email= defaultUserMail1;  
            }else {
                Email=userMail[0].Email;
            }
        }
        system.debug('email ' + Email);
             for(Fidejussione__c  a : [Select Id ,Cointestazione__r.Tipo_di_Cointestazione__c, Cointestazione__c,Persona_Giuridica__c, Persona_Fisica__c ,PersonaFisicaOplon__c,   Persona_Fisica__r.NDG__c, NDG__c from Fidejussione__c  where Cointestazione__c in : cointList]){
            
            if( a.Cointestazione__r.Tipo_di_Cointestazione__c =='Contact'){
                contactIdList.add(a.Persona_Fisica__c);
            }
            if( a.Cointestazione__r.Tipo_di_Cointestazione__c =='Account'){
                accountIdList.add(a.Persona_Giuridica__c);
            }
            subjectIdList.add(a.NDG__c);
            
        }
            if(metadata.size()==1){
            if(metadata[0].Status__c == 'Active'){
                if(coint[0].Tipo_di_Cointestazione__c== 'Contact'  && !contactIdList.isEmpty() && !subjectIdList.isEmpty()){
                   ElevaRestApiController.cointestazioneOnCedacriCallout(coint[0].Id,contactIdList, subjectIdList,Email,'contact');
                    
                }
                else if(coint[0].Tipo_di_Cointestazione__c== 'Account' && !accountIdList.isEmpty() && !subjectIdList.isEmpty() ){
                  ElevaRestApiController.cointestazioneOnCedacriCallout(coint[0].Id,accountIdList, subjectIdList,Email,'account');
                    
                }
            }
           }

        System.debug('batchCointestazione.execute --- End');
        
    }
    
    global void finish(Database.BatchableContext BC){
         System.debug('batchCointestazione.finish --- Start');
        System.debug('batchCointestazione.finish --- End');
        
        
    }
}