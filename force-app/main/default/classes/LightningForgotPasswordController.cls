global class LightningForgotPasswordController {

    public LightningForgotPasswordController() {

    }

    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            System.debug('LightningForgotPasswordController forgotPassword --Start username: '+username+' checkEmailUrl: '+checkEmailUrl);
            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            aura.redirect(checkEmailRef);
            System.debug('LightningForgotPasswordController forgotPassword --End');
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {    
        // Return null if there is no error, else it will return the error message 
        try {
            System.debug('LightningForgotPasswordController setExperienceId --Start expId: '+expId);
            if (expId != null) {
                Site.setExperienceId(expId);               
            }
            System.debug('LightningForgotPasswordController setExperienceId --End');
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    } 
}