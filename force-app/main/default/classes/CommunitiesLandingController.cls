/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        system.debug('CommunitiesLandingController forwardToStartPage -Start');
        system.debug('CommunitiesLandingController forwardToStartPage -End');
        system.debug('return: '+ Network.communitiesLanding());
        return Network.communitiesLanding();
        
    }
    
    public CommunitiesLandingController() {}
}