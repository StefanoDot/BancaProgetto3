public class CompletamentoDocumentiCrediti {
    public static void notificationsStageCompletamentoDocumenti(List<Opportunity>oppList){
        System.debug('Method');
        for(Opportunity opp : oppList)  { 
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Opportunity_In_Completamento_Documenti_Crediti']; 
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle( opp.name + ' risulta nello stage ' + opp.StageName);
            notification.setBody('L\' opportunity risulta nello stage ' + opp.StageName);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(opp.id);
           
            
            List<String> profIds = new List<String>();
            for(User u : [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' OR Profile.Name = 'Sales Support']){
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
            
            EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where Name = 'Banca Progetto - Notifica Fiscal Partner fase pre-due diligence'];
            String subject = emailTemplate.Subject;
			subject = subject.replace('{!Opportunity.StageName}', opp.StageName);
            String htmlBody = emailTemplate.htmlValue;
            htmlBody = htmlBody.replace('{!User.Name}', UserInfo.getName());
            htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
			htmlBody = htmlBody.replace('{!Opportunity.StageName}', opp.StageName);
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
            if(profIds.contains(currentUserId)){
                String mMail = UserInfo.getUserEmail();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> sendTo = new List<String>();
                sendTo.add(mMail);
                //sendTo.add('enxhisa.bici@dunegroup.it');
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