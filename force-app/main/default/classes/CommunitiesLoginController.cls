/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        system.debug('CommunitiesLoginController forwardToAuthPage - Start');
    	String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        system.debug('CommunitiesLoginController forwardToAuthPage - End');
        system.debug('return: '+ Network.forwardToAuthPage(startUrl, displayType));
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}