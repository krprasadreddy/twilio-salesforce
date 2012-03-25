/*
 * TwilioMessageController
 */
public with sharing class TwilioMessageController {

	// The who
    public String whoType { get; set; }
    public String whoId { get; set; }
    
    // The what
    public String messageType { get; set; }
    public String messageBody { get; set; }
    public Set<String> sendToPhones { get; set; }

	// Lead and Phone Flags
    public Lead lead { get; set; }
    public Boolean leadPhone { get; set; }
    public Boolean leadMobile { get; set; }
    
    // Contact and Phone Flags
    public Contact contact { get; set; }
    public Boolean contactPhone { get; set; }
    public Boolean contactMobile { get; set; }
    public Boolean contactHome { get; set; }
    public Boolean contactOther { get; set; }

	// Constructor - figures out who and initializes the what
    public TwilioMessageController() {
        
        // Get the page parameters.  Who Type and the Who Id (yes, I could check for '00Q' and '003', but, come on...)
        try {
            whoType = ApexPages.currentPage().getParameters().get( 'whoType');
            whoId = ApexPages.currentPage().getParameters().get( 'whoId');
            if ( whoType == 'Lead' ) {
                lead = [select Id, Name, Phone, MobilePhone 
                          from Lead
                         where Id = :whoId];
            } else if ( whoType == 'Contact' ) {
                contact = [select Id, Name, Phone, MobilePhone, HomePhone, OtherPhone
                             from Contact
                            where Id = :whoId];
            } else {
                ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Could not determine the type of record to contact'));
            }                
        } catch ( Exception e) {
            ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Failed to set the contact information.  ERROR: ' + e.getMessage()));
        }

		// Init
        initialize();
    }
    
	//  Set the defaults
    private void initialize() {
        messageType = 'Voice';
        messageBody = '';
        
        leadPhone = false;
        leadMobile = false;
        
        contactPhone = false;
        contactMobile = false;
        contactHome = false;
        contactOther = false;
        
        sendToPhones = new Set<String>();
    }

	// Build the set of Phones to send the message to
	private void buildPhoneSet() {
        sendToPhones = new Set<String>();

		if ( leadPhone ) { sendToPhones.add( lead.Phone); }		
		if ( leadMobile ) { sendToPhones.add( lead.MobilePhone); }
		
		if ( contactPhone) { sendToPhones.add( contact.Phone); }
		if ( contactMobile) { sendToPhones.add( contact.MobilePhone); }
		if ( contactHome) { sendToPhones.add( contact.HomePhone); }
		if ( contactOther) { sendToPhones.add( contact.OtherPhone); }
	}

	// Clear/Reset
    public PageReference onClear() {
        initialize();
        return null;
    }

	// Send the Message
    public PageReference onSend() {
    	
    	buildPhoneSet();

		// Make sure there are phone numbers 
		if ( sendToPhones.size() == 0 ) {
			ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'No phone numbers selected.  No message sent.'));
			return null;
		}
		
		// Make sure the message body has something in it
		if ( messageBody.length() == 0 ) {
			ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Message is empty.  No message sent.'));
			return null;
		}

        // Create the call record and add it to the list
        Task t = new Task();
        t.whoId = whoId;
        t.Subject = 'Twilio ' + messageType + ' Message Sent to ' + sendToPhones;
        t.ActivityDate = Date.today();
        t.Status = 'Completed';
        t.Description = messageBody;

        // Insert task here
        insert t;

		// Check the type of message, then send.    	
    	if ( messageType == 'Voice') {
    		TwilioMessageHelper.sendVoiceCall( whoId, sendToPhones, t.id);
    	} else {
			TwilioMessageHelper.sendSMSMessage( whoId, sendToPhones, messageBody);
    	}
    	
    	ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Twilio ' + messageType + ' Message has been sent.'));
    	
        return null;
    }

}