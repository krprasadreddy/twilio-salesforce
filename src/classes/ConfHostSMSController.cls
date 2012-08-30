/*
 * ConfHostSMSController
 *
 * SMS message to host
 *   "get" in body retrieves the welcome message.
 *   "put/set" in body with message sets the message.
 *   "who" shows the active callers.
 *   "off" plays the message then hangs up.
 *   "on" plays the message then puts the user on hold.
 *   "help/?" shows options
 */
public class ConfHostSMSController {

    // Attributes
    public String body { get; set; }
    public String to { get; set; }
    public String cmd { get; set; }
    public String msg { get; set; }
    public String responseBody { get; set; }
    
    // For debugging
    public String getAllParams() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String output = 'All Page Parameters<br/>';
        for ( String s : params.keySet() ) {
            output += s + ' => ' + params.get( s) + '<br/>';
        }
        System.debug( output);
        return output;
    }
    
    // Was the Constructor, but does DML, so...
    public PageReference init() {
        to = ApexPages.currentPage().getParameters().get( 'To');
        body = ApexPages.currentPage().getParameters().get( 'Body');

        parseBody();
        processCommand();
        return null;
    }
    
    // Parse out the 
    private void parseBody() {
        if ( body == null ) {
            System.debug( 'No command sent. Default to \'help\'');
            cmd = 'help';
        } else if ( body.indexOf( ' ') > 0 ) {
            cmd = body.substring( 0, body.indexOf( ' '));
            msg = body.substring( body.indexOf( ' ') +1);
        } else {
            cmd = body;
        }
        
        System.debug( 'Command [' + cmd + '] and Message [' + msg + ']' );
    }

    // Process Command
    private void processCommand() {
        // Get Conference Bridge
        Conference_Bridge__c bridge;
        try {
            bridge = [select Id, Name, Welcome_Message__c
                        from Conference_Bridge__c
                       where Host_Number__c = :to];
        } catch ( Exception e) {
            responseBody = 'Exception [' + e.getMessage() + ']';
            return;
        }
        
        // Which command?
        if ( cmd == 'get') {
            responseBody = 'Welcome Message is * ' + bridge.Welcome_Message__c + ' *';
        } else if ( cmd == 'put' || cmd == 'set') {
            if ( msg != null && msg.length() > 0 ) {
                bridge.Welcome_Message__c = msg;
                update bridge;
                responseBody = 'Welcome message updated';
            } else {
                cmd = 'help';
            }
        } else if ( cmd == 'who') {
            responseBody = getActiveCallers();
        } else if ( cmd == 'off') {
            bridge.Hangup_After_Message__c = true;
            update bridge;
            responseBody = 'Conference bridge has been turned off';
        } else if ( cmd == 'on') {
            bridge.Hangup_After_Message__c = false;
            update bridge;
            responseBody = 'Conference bridge has been turned on';
        } else if ( cmd == 'help' || cmd == '?') {
            responseBody = 'Usage:\n';
            responseBody+= 'get - Get Welcome Message\n';
            responseBody+= 'put msg - Put Welcome Message\n';
            responseBody+= 'who - Show Active Callers\n';
            responseBody+= 'off - Disable Conference\n';
            responseBody+= 'on - Enable Conference';
        }

    }

    // First choice is to show the Contact First Name, Next would be the caller name lookup, and finally just the phone number
    private String getActiveCallers() {
        List<String> callers = new List<String>();
        for ( Twilio_Call__c tc : [select Contact__c, Contact__r.FirstName, CallerName__c, Caller__c
                                     from Twilio_Call__c
                                    where CallStatus__c != 'Completed']) {
            if ( tc.Contact__c != null ) {
                callers.add( tc.Contact__r.FirstName);
            } else if ( tc.CallerName__c != null ) {
                callers.add( tc.CallerName__c);
            } else {
                callers.add( tc.Caller__c);
            }
        }

        String response = 'Callers: ';
        if ( callers.size() == 0 ) {
            response += 'None';
        }
        
        for ( Integer i = 0 ; i < callers.size() ; ) {
            response += callers[i++];
            if ( i < callers.size() ) {
                response += ', ';
            }
        }
        response += '.';

        return response;
        
    }

}