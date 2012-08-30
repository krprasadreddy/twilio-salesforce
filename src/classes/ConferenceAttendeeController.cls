/*
 * Conference Attendee Controller 
 *   Used by: ConferenceAttendee (Advanced)
 */
public with sharing class ConferenceAttendeeController {

    // The conference Bridge
    private Conference_Bridge__c bridge; 
    
    public String getCallAction() {
        System.debug( 'Executing getCallAction()');

        // If the call is outside business hours
        if ( !ConferenceHelper.inBusinessHours()) {
            String twiml = '';
            twiml += '<Response>';
            twiml += '<Say>This call is outside business hours.  Good bye.</Say>';
            twiml += '<Hangup/>';
            twiml += '</Response>';
            return twiml;
        }

        // No Bridge info?
        if ( bridge == null ) {
            String twiml = '';
            twiml += '<Response>';
            twiml += '<Say>Could not find conference information.  Good bye.</Say>';
            twiml += '<Hangup/>';
            twiml += '</Response>';
            return twiml;
        }       

        // If the bridge checks out
        if ( bridge.Hangup_After_Message__c == true ) {
            String twiml = '';
            twiml += '<Response>';
            twiml += '<Say>' + bridge.Welcome_Message__c + '</Say>';
            twiml += '<Hangup/>';
            twiml += '</Response>';
            System.debug( 'Hangup TwiML is ' + twiml);
            System.debug( 'Hangup after saying ' + bridge.Welcome_Message__c);
            return twiml;
        }

        // Build the conference TwiML
        TwilioConfig__c tConfig = TwilioConfig__c.getValues( 'Settings');
        String siteUrl = String.valueOf( tConfig.ForceSiteUrl__c);

        String twiml = '';
        twiml += '<Response>';
        twiml += '<Say>' + bridge.Welcome_Message__c + '</Say>';
        twiml += '<Dial>';
        twiml += '<Conference startConferenceOnEnter="false" waitUrl="' + siteUrl + 'ScrumCallHold"';
        twiml += '>' + bridge.Bridge_Name__c + '</Conference>"';
        twiml += '</Dial>';
        twiml += '</Response>';
        System.debug( 'Conference TwiML is ' + twiml);

        return twiml;
    }
    
    public ConferenceAttendeeController() {
        System.debug( 'Executing the ScrumCallController()');
        String dialedNumber = ApexPages.currentPage().getParameters().get( 'Called');
        
        try {
            System.debug( 'Executing SOQL to get Conference Bridge Record');
            bridge = [select Bridge_Name__c, Welcome_Message__c, Hangup_After_Message__c
                        from Conference_Bridge__c
                       where Twilio_Number__c = :dialedNumber];
        } catch ( Exception e) {
            System.debug( 'Exception caught trying to get Conference Bridge: ' + e.getMessage());
            bridge = null;
        }

    }

    // Init, because Constructors cannot do DML
    public PageReference init() {

        // Save off the call 
        TCall.saveCall( ApexPages.currentPage().getParameters());
            
        return null;
    }

}