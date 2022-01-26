public class PreAnalisingePricingStageCrediti {
    public static void checkCampoNoteEsitoNegativo(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        //Comento da Indrit per Demo CF
        /*for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Fiscal Partner' OR Name = 'System Administrator' OR Name = 'Responsabile BU Factoring']){
            profileIds.add(pr.Id);
        }*/
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        
        /*if(!profileIds.contains(currentProfileId)){
             pass = true;
        }*/
                if(opp.StageName == 'Pre-Analisi e Pricing' || opp.Note_Esito_Negativo_Due_Diligence__c == null){
                    pass = true;
                   
                }
                if(pass){
                    System.debug('Kalon apo jo testi Opportunity ' + opp);
                    trigger.newmap.get(opp.id).addError('Per restituire "Negativo" occorre esprimere una motivazione nel campo Note Esito Negativo!');
                    
                }
        }
    }
    public static void checkCampoNoteEsitoRedFlags(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        //Comento da Indrit per Demo CF
        /*for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Fiscal Partner' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }*/
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        /*if(!profileIds.contains(currentProfileId)){
        pass = true;
        }*/
            if(opp.StageName == 'Pre-Analisi e Pricing' || opp.Note_sospensive_Due_Diligence__c == null){
                    pass = true;
                }
                if(pass){
                    trigger.newmap.get(opp.id).addError('Per restituire "Red Flags" occorre esprimere una motivazione nel campo Note Esito Red Flags!');
                }
        }
    }
    //Ask Rocco if it's needed
    public static void checkCampoEsitoValutazioneRedFlags(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();

        for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Responsabile BU Factoring' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
             pass = true;
        }
            
                if(opp.StageName == 'Pre-Analisi e Pricing' || opp.Note_Desospensione__c == null){
                    pass = true;
                }
                if(pass){
                    trigger.newmap.get(opp.id).addError('Il campo Esito Valutazione Red Flags è compilato solo da Responsabile BU!');
                }
        }
    }
    public static void checkCampoEsitoDueDiligencePositivoDaRedFlags(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        //Comento da Indrit per Demo CF
        /*for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Fiscal Partner' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }*/
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        
       
        /*if(!profileIds.contains(currentProfileId)){
                  pass = true;
        }*/
                if(opp.StageName == 'Pre-Analisi e Pricing' || opp.Note_Desospensione__c == null){
                    pass = true;
                }
                if(pass){
                    trigger.newmap.get(opp.id).addError('Per passare da "Red Flags" a "Red Flags Risolti" occorre esprimere una motivazione nel campo Esito valutazione Red Flags!');
                }
        }
    }

    public static void FieldEsitoPropostaPricing(List<Opportunity> newOppList){
        System.debug('Method entered');
       //per te thirrur ne opp controller nese ndyshon vlera e Esito proposta pricing
       Boolean pass = false;
       
           List<String> profileIds = new List<String>();
           //Comento da Indrit per Demo CF
           for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Commerciale factoring CF' OR Name = 'System Administrator']){
               profileIds.add(pr.Id);
                System.debug('profileIds ' + profileIds);
           }
           String currentProfileId = UserInfo.getProfileId();
           System.debug('currentProfileId' +currentProfileId);
           if(!profileIds.contains(currentProfileId) ){
               pass = true;
           } 
       for(Opportunity opp: newOppList){
           system.debug('he m ti'+newOppList);
                if(opp.Pricing__c == null){
               pass = true;
           
               System.debug('Pass' + pass);
           }
           
           if(pass){
               trigger.newmap.get(opp.id).addError('Per restituire Esito proposta Pricing è necessario prima valorizzare la % Prezzo target!');
           }
       }
   }
    public static void checkPassareStageInDueDiligence(List<Opportunity> newOppList){
        System.debug('Check passare due diligence');
        Boolean pass = false;
        for(Opportunity opp: newOppList){
            List<String> profileIds = new List<String>();
            //Comento da Indrit per Demo CF
           for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Commerciale factoring CF' OR Name = 'Fiscal Partner' OR Name = 'System Administrator']){
                profileIds.add(pr.Id);
            }
            String currentProfileId = UserInfo.getProfileId();
            System.debug('currentProfileId' +currentProfileId);
            
            if(!profileIds.contains(currentProfileId)) {
                pass = true;
            }
               if(opp.Esito_Proposta_Pricing__c <> 'Esito positivo' || opp.Procedura_delega_Agenzia_delle_Entrate__c == false){
                pass = true;
            }
            if(pass){
                trigger.newmap.get(opp.id).addError('Per procedere alla fase successiva occorre che il Commerciale Factoring CF abbia restituito Esito Positivo nel campo Esito proposta Pricing e aver flaggato Flag Delega Ag. Entrate per Fatt. Elett.');
            }
        }
    }
    public static void checkPassareStageInChiusaPersaDaPreAnalising(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
            List<String> profileIds = new List<String>();
            for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Commerciale factoring CF' OR Name = 'System Administrator' OR Name = 'Integrator']){
                profileIds.add(pr.Id);
            }
            String currentProfileId = UserInfo.getProfileId();
            System.debug('currentProfileId' +currentProfileId);
            if(!profileIds.contains(currentProfileId)){
                pass = true;
            } 
           /* if(opp.Esito_Due_Diligence__c <> 'Negativo'){
                pass = true;
            }*/
            if(pass){
                trigger.newmap.get(opp.id).addError('Solo il Commerciale Factoring CF può passare l\'opportunità in chiusa!');
            }
        }
    }
    public static void notifyUser(List<Opportunity>oppList){
        
  for(Opportunity opp : oppList)  { 
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Pratica_in_Positivo_con_punti_di_attenzione_e_o_red_flags'];
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Pratica ' + opp.name + ' ha l\'esito Due Diligence in Red Flags');
            notification.setBody('Pratica ' + opp.name + ' ha l\'esito Due Diligence in Red Flags');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(opp.id);
            
            List<String> profIds = new List<String>();
            for(User u : [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' OR Name ='Responsabile BU Factoring']){
                profIds.add(u.Id);
                System.debug('Profile' + profIds);
            }
            
            Set<String> recipientsIds = new Set <String>();
            String currentUserId = UserInfo.getUserId();
            System.debug('ID' + currentUserId);
            if(profIds.contains(currentUserId)){
                recipientsIds.add(currentUserId);
                System.debug('RecipientList'  + recipientsIds );
           }
            
            try {
                notification.send(recipientsIds);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
    }
    }
}