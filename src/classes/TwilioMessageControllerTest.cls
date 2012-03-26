//@IsTest (SeeAllData=true)
@isTest
private class TwilioMessageControllerTest {

    static User testUser;
    static Lead testLead;
    static Contact testContact;
    
    static {
    	
        Profile p = [select Id from Profile where Name = 'System Administrator' limit 1];
        testUser = new User( profileId = p.id, Username = 'TestUser@TwilioApp.com', Email = 'TestUser@TwilioApp.com',
                           Alias = 'Twilio', FirstName = 'TestUser', LastName = 'TwilipApp', emailencodingkey='UTF-8',
                           languagelocalekey='en_US', timezonesidkey='America/Los_Angeles', localesidkey='en_US');
        insert testUser;

		// The Custom Setting
		TwilioConfig__c tConfig = new TwilioConfig__c();
		tConfig.Name = 'Settings';
		tConfig.ForceSiteUrl__c = 'http://developer.test-twilio.com/';
		tConfig.DefaultFrom__c = '+141512345678';
		tConfig.AuthToken__c = 'thisismytestauthtokenfromtwiliox';
		tConfig.AccountSid__c = 'ACTESTACCOUNTSID000000000000000000';  // Must be 34 Characters Long
		insert tConfig;
		        
    }
    
    // Test using a Lead
    static TestMethod void LeadVoiceMessageTest() {
        System.runAs( testUser) {
	        testLead = new Lead( FirstName = 'TestLead', LastName = 'TwilioApp', Company = 'TwilioTest', Phone = '(415) 867-5309', MobilePhone = '(415) 555-1212');
	        insert testLead;

			Test.startTest();
			PageReference pageRef = Page.TwilioMessage;
			Test.setCurrentPage( pageRef);
			pageRef.getParameters().put( 'whoId', testLead.Id);
			pageREf.getParameters().put( 'whoType', 'Lead');
			TwilioMessageController controller = new TwilioMessageController();
			
			controller.onClear();	// Courtesy, for coverage
			
			controller.leadMobile = true;
			controller.messageBody = 'This is the Message Body';
			controller.onSend();
			
        }
    }

    // Test using a Contact
    static TestMethod void ContactMessageTest() {
        System.runAs( testUser) {
	        
	        Account testAccount = new Account( Name = 'TestAccount');
	        insert testAccount;
	        testContact = new Contact( FirstName = 'TestContact', LastName = 'TestContact', AccountId = testAccount.id, Phone = '(415) 333-4444', MobilePhone = '(415) 111-2222', OtherPhone = '(415) 999-8888');
	        insert testContact;

			Test.startTest();
			PageReference pageRef = Page.TwilioMessage;
			Test.setCurrentPage( pageRef);
			pageRef.getParameters().put( 'whoId', testContact.Id);
			pageREf.getParameters().put( 'whoType', 'Contact');
			TwilioMessageController controller = new TwilioMessageController();
			
			controller.contactMobile = true;
			controller.messageType = 'SMS';
			controller.messageBody = 'This is the SMS Message Body';
			controller.onSend();
        }
    }
}