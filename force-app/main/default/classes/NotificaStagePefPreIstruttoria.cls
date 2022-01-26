public class NotificaStagePefPreIstruttoria {
 public static void notificationsPefPreIstrError(List<Opportunity>oppList){
        for(Opportunity opp : oppList)  { 
            EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where Name = 'Notifica Owner - Errore in inquiry'];
            String subject = emailTemplate.Subject;
            subject = subject.replace('{!Opportunity.StageName}', opp.StageName);
            String htmlBody = emailTemplate.htmlValue;
            htmlBody = htmlBody.replace('{!User.Name}', UserInfo.getName());
            htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
            htmlBody = htmlBody.replace('{!Opportunity.StageName}', opp.StageName);
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
                String mMail = UserInfo.getUserEmail();
                System.debug('Mail' + mMail);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> sendTo = new List<String>();
                //sendTo.add(mMail);
                sendTo.add('salesforce@bancaprogetto.it');
                mail.setToAddresses(sendTo);
                mail.setReplyTo('noreply@salesforce.com'); 
                mail.setTemplateID(emailTemplate.Id);
               // mail.setTargetObjectId(currentUserId);
                
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