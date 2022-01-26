/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        system.debug('SiteLoginController PageReference - Start');
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        system.debug('Return: ' + Site.login(username, password, startUrl));
        system.debug('SiteLoginController PageReference - End');
        return Site.login(username, password, startUrl);
    }
    
   	global SiteLoginController () {}
}