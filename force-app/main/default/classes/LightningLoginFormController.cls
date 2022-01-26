global class LightningLoginFormController {

    public LightningLoginFormController() {
        
    }

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            System.debug('LightningLoginFormController login --Start username: '+username+' password: '+password+' startUrl: '+startUrl);
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            System.debug('LightningLoginFormController login --End');
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        System.debug('LightningLoginFormController getIsUsernamePasswordEnabled --Start');
        System.debug('LightningLoginFormController getIsUsernamePasswordEnabled --End');
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        System.debug('LightningLoginFormController getIsSelfRegistrationEnabled --Start');
        System.debug('LightningLoginFormController getIsSelfRegistrationEnabled --End');
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        System.debug('LightningLoginFormController getSelfRegistrationUrl --Start');
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        System.debug('LightningLoginFormController getSelfRegistrationUrl --End');
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        System.debug('LightningLoginFormController getForgotPasswordUrl --Start');
        System.debug('LightningLoginFormController getForgotPasswordUrl --End');
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        System.debug('LightningLoginFormController getAuthConfig --Start');
        System.debug('LightningLoginFormController getAuthConfig --End');
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            System.debug('LightningLoginFormController setExperienceId --Start expId: '+expId);
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            System.debug('LightningLoginFormController setExperienceId --End');
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }   
}