public class DueDiligenceStageCrediti {
    public static void notificationsStageDueDiligence(List<Opportunity>oppList){
        for(Opportunity opp : oppList)  { 
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Opportunity_in_Due_Diligence_Crediti']; 
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle( opp.name + ' è in fase '+ opp.StageName);
            notification.setBody('L\'Opportunita è in fase '+ opp.StageName );
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
    
    public static void CondizionePassaggioInCompletamentoDocumenti(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        //Comento da Indrit per Demo CF
        for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'Resp BU factoring CF' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
            pass=true;
        }
           if(opp.Verifica_Report_Finale_Studio_Dominici__c <> 'Esito Positivo'){
                    pass = true;
                }
                if(pass){
                    trigger.newmap.get(opp.id).addError('Per procedere alla fase successiva occorre che il Responsabile BU abbia restituito Esito Positivo nel campo Verifica Report Finale!');
                }
        }
    }

       public static void CheckCompletamentoVerificaReportFinale(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        //Comento da Indrit per Demo CF
        for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'Resp BU factoring CF' OR Name = 'System Administrator']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
            pass=true;
        }
        //modifed by stefano porcari 19/07/2021
           if(opp.Esito_Due_Diligence__c != 'Positivo' && opp.Esito_Due_Diligence__c != 'Red Flags Risolti'){
                    pass = true;
                }
                if(pass){
                    trigger.newmap.get(opp.id).addError('Per poter valorizzare Verifica Report Finale è necessario che il Fiscal partner abbia restituito Esito Due Diligence con Esito Positivo o che il Responsabile BU abbia restituito Red Flags Risolti!');
                }
        }
    }
    public static void chiusaLostDueDiligence(List<Opportunity> newOppList){
        Boolean pass = false;
        for(Opportunity opp: newOppList){
        List<String> profileIds = new List<String>();
        for(Profile pr : [SELECT Id FROM Profile WHERE Name ='Resp BU factoring CF' OR Name = 'System Administrator' OR Name = 'Integrator']){
            profileIds.add(pr.Id);
        }
        String currentProfileId = UserInfo.getProfileId();
        System.debug('currentProfileId' +currentProfileId);
        if(!profileIds.contains(currentProfileId)){
            System.debug('entra qui 2');
             pass = true;
        }
               /* if ( opp.Verifica_Report_Finale_Studio_Dominici__c <> 'Esito Negativo') {
                    System.debug('entra qui 3');
                    pass = true;
                }*/
                if(pass){
                    trigger.newmap.get(opp.id).addError('Solo il Resp BU CF può passare l\'opportunità in chiusa!');
                }
        }
    }

        public static void EsitoDueDiligenceRedFlagsConditions(List<Opportunity> newOppList){
            Boolean pass = false;
            for(Opportunity opp: newOppList){
            List<String> profileIds = new List<String>();
            //Comento da Indrit per Demo CF
            for(Profile pr : [SELECT Id FROM Profile WHERE Name = 'Fiscal Partner' OR Name = 'System Administrator']){
                profileIds.add(pr.Id);
            }
            String currentProfileId = UserInfo.getProfileId();
            System.debug('currentProfileId' +currentProfileId);
            if(!profileIds.contains(currentProfileId)){
                pass=true;
            }
               if(opp.Esito_Due_Diligence__c == 'Red Flags Risolti'){
                        pass = true;
                    }
                    if(pass){
                        trigger.newmap.get(opp.id).addError('Questo profilo non ha i permessi per compilare il campo con questo valore!');
                    }
            }
        }
    }