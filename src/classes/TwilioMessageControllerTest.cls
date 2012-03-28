//@IsTest (SeeAllData=true)
/*
 * Twilio Message Controller Test
 */
@isTest
private class TwilioMessageControllerTest {

    static User testUser;
    
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
	        Lead testLead = new Lead( FirstName = 'TestLead', LastName = 'TwilioApp', Company = 'TwilioTest', Phone = '(415) 867-5309', MobilePhone = '(415) 555-1212');
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
	        Contact testContact = new Contact( FirstName = 'TestContact', LastName = 'TestContact', AccountId = testAccount.id, Phone = '(415) 333-4444', MobilePhone = '(415) 111-2222', OtherPhone = '(415) 999-8888');
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
			//controller.onSend();
        }
    }
    
    // Test the exceptions
    static TestMethod void TestExceptions() {
    	System.runAs( testUser) {
    		Test.startTest();
			PageReference pageRef = Page.TwilioMessage;
			Test.setCurrentPage( pageRef);
			TwilioMessageController controller = new TwilioMessageController();
    		
    		System.assert( ApexPages.hasMessages() == true, 'Apex Pages should have an error message saying that it could not determine what type of record to look for');
    		
    		pageRef.getParameters().put( 'whoType', 'Contact');
    		controller = new TwilioMessageController();
    		System.assert( ApexPages.hasMessages() == true, 'Apex Pages should have an error message saying that it could not find the record');
    		
	        Account testAccount = new Account( Name = 'TestAccount2');
	        insert testAccount;
	        Contact testContact = new Contact( FirstName = 'TestContact2', LastName = 'TestContact2', AccountId = testAccount.id, Phone = '(415) 333-4444', MobilePhone = '(415) 111-2222', OtherPhone = '(415) 999-8888');
	        insert testContact;
    		
    		pageRef.getParameters().put( 'whoId', testContact.Id);
    		controller = new TwilioMessageController();

			controller.onSend();
    		System.assert( ApexPages.hasMessages() == true, 'Apex Pages should have an error message saying that it needs phone numbers to send the message to');
			
			controller.contactMobile = true;
			controller.onSend();
    		System.assert( ApexPages.hasMessages() == true, 'Apex Pages should have an error message saying that it needs a message to send');

			controller.messageBody = 'This is a message body';
			controller.onSend();
    		System.assert( ApexPages.hasMessages() == true, 'Apex Pages should have a message saying the message was sent');
							
	    }
    }
}