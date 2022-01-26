public class PreDueDiligenceCreditiCondizioni {
    public static void EsitoPropostaPricingPositivo(List<Opportunity> newOppList){
         System.debug('Method entered');
        //per te thirrur ne opp controller nese ndyshon vlera e Esito proposta pricing
        Boolean pass = false;
        
            List<String> profileIds = new List<String>();
            //Comento da Indrit per Demo CF
            for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Fiscal Partner' OR Name = 'System Administrator']){
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
                 if(opp.Importo_del_Credito__c == null || opp.UfficioTerritorialeAE__c == null || opp.Tempo_di_Incasso_Stimato__c == null || opp.Pratica_complessa__c == null){
                pass = true;
            
                System.debug('Pass' + pass);
            }
            
            if(pass){
                trigger.newmap.get(opp.id).addError('Per procedere alla fase successiva occorre compilare i campi: Valore lordo del credito, Pratica complessa, UfficioTerritorialeAE, Tempo di Incasso stimato !  Solo il fiscal partner puo avanzare alla fase successiva');
            }
        }
    }
    
   /* public static void FieldEsitoPropostaPricing(List<Opportunity> newOppList){ 
         System.debug('Method entered');
        //nese ndryshon stage ne Preanalisi e pricing
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'Commerciale Factoring Crediti Fiscali' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
             pass = true;
        }
                if(opp.Tipo_Linea_di_Credito__c == 'Crediti Fiscali' && opp.Esito_Proposta_Pricing__c <> 'Esito positivo' || opp.Obbligo_Delega_Cassetto_Fiscale__c == false ){
                    pass = true;
                    System.debug('Pass' + pass);
                }
                if(pass){
                    trigger.newmap.get(opp.id).addError('Non è possibile avanzare l\'opportunità, il campo Esito Proposta Pricing non è valorizata o ha esito negativo!');
                }
            
        }
    }*/
    public static void EsitoPropostaPricingNegativo(List<Opportunity> newOppList){
        // nese ndryshon stage ne chiusa persa
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        
        for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Partner'OR Name = 'Commerciale Factoring Crediti Fiscali' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
             pass = true;
        }
                if (opp.Esito_Proposta_Pricing__c <> 'Esito negativo') {
                    pass = true;
                }
                
                if(pass){
                    trigger.newmap.get(opp.id).addError('Per passare in chiusa devi compilare il campo Esito Proposta Pricing con negativo!');
                }
            
        }
    }
    public static void notificationsStagePreDueDiligence(List<Opportunity>oppList){
        for(Opportunity opp : oppList)  { 
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Opportunity_in_Pre_Due_Diligence']; 
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle( opp.name + ' è in fase '+ opp.StageName);
            notification.setBody('L\'Opportunita è in fase '+ opp.StageName );
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(opp.id);
            
            List<String> profIds = new List<String>();
            for(User u : [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' OR Name ='Fiscal Partner']){
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
            
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where Name = 'Notifica User per opportunity cambio stage'];
            String subject = emailTemplate.Subject;
			subject = subject.replace('{!Opportunity.StageName}', opp.StageName);
            String htmlBody = emailTemplate.htmlValue;
            htmlBody = htmlBody.replace('{!User.Name}', UserInfo.getName());
            htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
			htmlBody = htmlBody.replace('{!Opportunity.StageName}', opp.StageName);
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
            if(profIds.contains(currentUserId)){
                String mMail = UserInfo.getUserEmail();
                System.debug('Mail' + mMail);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> sendTo = new List<String>();
               // sendTo.add(mMail);
                sendTo.add('enxhisa.bici@dunegroup.it');
                mail.setToAddresses(sendTo);
                mail.setReplyTo('noreply@salesforce.com'); 
                mail.setTemplateID(emailTemplate.Id);
            	mail.setTargetObjectId(currentUserId);
                
                mail.setSaveAsActivity(false);
                mail.setSubject(subject);
				mail.setHtmlBody(htmlBody);
                mails.add(mail);
                
                Messaging.sendEmail(mails);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
                
                if (results[0].success)  {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
            }
        }
    }
}