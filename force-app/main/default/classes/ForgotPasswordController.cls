/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
		System.debug('ForgotPasswordController forgotPassword --Start ');
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  
			System.debug('ForgotPasswordController forgotPassword --End ');  			
  			return pr;
		  }
		System.debug('ForgotPasswordController forgotPassword --End ');  
  		return null;
  	}
}