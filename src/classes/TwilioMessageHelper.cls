/*
 * TwilioMessageHelper 
 * Send Voice calls or SMS messages
 */
public class TwilioMessageHelper {
	
	// TODO: Move these hardcoded values to the TwilioConfig__c custom setting (or another one)
	private static final String FROM_PHONE = '+14159444108';		// This must be one of your Twilio numbers
	private static final String SITE_URL = 'http://twiliocon-developer-edition.na12.force.com/';
    
    // Send Voice Message
    @future(callout=true)
    public static void sendVoiceCall( ID whoId, Set<String> phones, ID taskId) {
        TwilioConfig__c tConfig = TwilioConfig__c.getValues( 'Settings');
        String account = String.valueOf( tConfig.AccountSid__c);
        String token = String.valueOf( tConfig.AuthToken__c);
        
        TwilioRestClient client = new TwilioRestClient(account, token);
        
        // For each phone
        for ( String ph : phones ) {
            // Call out to Twilio here (max 10)
			Map<String,String> params = new Map<String,String> {
		        'To'   => ph,
		        'From' => FROM_PHONE,
        		'Url' => SITE_URL+ 'TwilioMessageVoice?taskId=' + taskId
    		};
    
    		System.debug( 'DEBUG:::Twilio Request Parameters ' + params);
			TwilioRestResponse resp = client.request( 'https://api.twilio.com/2010-04-01/Accounts/' + account + '/Calls', 'POST', params);
			System.debug( 'DEBUG:::Twilio Response ' + resp);
        }
    }

    // Send SMS Message
    @future( callout=true)
    public static void sendSMSMessage( ID whoId, Set<String> phones, String messageBody) {
        TwilioConfig__c tConfig = TwilioConfig__c.getValues( 'Settings');
        String account = String.valueOf( tConfig.AccountSid__c);
        String token = String.valueOf( tConfig.AuthToken__c);
        
        TwilioRestClient client = new TwilioRestClient(account, token);
        
        // For each phone
        for ( String ph : phones ) {
            // Call out to Twilio here (max 10)
            Map<String,String> params = new Map<String,String> {
                'To'   => ph,
                'From' => FROM_PHONE,
                'Body' => messageBody
            };

            TwilioSMS sms = client.getAccount().getSMSMessages().create(params);
        }
        
    }

}