/**
 * An apex class that updates portal user details.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private boolean isEdit = false;

    public User getUser() {

        system.debug('MyProfilePageController getUser - Start');
        system.debug('return - user: ' + user);

        return user;
    }

    public MyProfilePageController() {
        system.debug('MyProfilePageController  - Start');
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        system.debug('user: ' + user );
        
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
        system.debug('MyProfilePageController  - End');
    }

    public Boolean getIsEdit() {
        system.debug('MyProfilePageController getIsEdit - Start');
        system.debug('Return isEdit: ' + isEdit);
        system.debug('MyProfilePageController getIsEdit - End');
        return isEdit;
    }

    public void edit() {
        system.debug('MyProfilePageController edit - Start');
        system.debug('MyProfilePageController edit - End');
        isEdit=true;
    }

    public void save() {
        try {
            system.debug('MyProfilePageController save - Start');
            update user;
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
        system.debug('MyProfilePageController save - End');
    }

    public PageReference changePassword() {
        system.debug('MyProfilePageController changePassword - Start');
        system.debug('return: Page.ChangePassword');
        system.debug('MyProfilePageController changePassword - End');
        return Page.ChangePassword;
    }

    public void cancel() {
        
        system.debug('MyProfilePageController cancel - Start');

        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        
        system.debug('user: ' + user);
        system.debug('MyProfilePageController cancel - End');
    }    
}