/*
 * TCall 
 * Twilio Call - Renamed because the Twilio - Salesforce library uses it
 * This calls saves the call info into the Twilio_Call__c object based on the page parameters.
 */
public class TCall {

    public String called { get; set; }
    public String caller { get; set; } 
    public String callDuration { get; set; }
    public String callStatus { get; set; }
    
    public TCall() {
        System.debug( 'TCall Initialized');
        Map<String,String> callMap = ApexPages.currentPage().getParameters();
        called = callMap.get( 'Called');
        caller = callMap.get( 'Caller');
        callDuration = callMap.get( 'CallDuration');
        callStatus = callMap.get( 'CallStatus');
    }

    // Save the call to the custom object
    @future
    public static void saveCall( Map<String,String> callMap ) {
        try {
            String msg = 'Call Details';
            for ( String k : callMap.keySet() ) {
                msg += '\n' + k + ' => ' + callMap.get(k);
            }
            
            Twilio_Call__c theCall = new Twilio_Call__c();
            
            // Start or end of call?
            if ( callMap.get( 'CallStatus') != null && callMap.get( 'CallStatus') == 'completed') {
                theCall = [select Id from Twilio_Call__c where CallSid__c = :callMap.get( 'CallSid')];
            }
            
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Twilio_Call__c.fields.getMap();
            for ( String fieldName : fieldMap.keySet()) {
                // If it's a custom field
                if ( fieldMap.get( fieldName).getDescribe().isCustom()) {
                    if ( !fieldMap.get( fieldName).getDescribe().isCalculated()) {
                        // Cut off the last 3 characters
                        String fieldLabel = fieldMap.get( fieldName).getDescribe().getLabel();
                        
                        // Get the value, if there is one
                        String fieldValue = callMap.get( fieldLabel);
                        if ( fieldValue != null ) {
                            theCall.put( fieldName, callMap.get( fieldLabel));
                        }
                    }
                }
            }

            // Now get the conference bridge number
            // Important to get this after the mapping fiasco above
            System.debug( 'Trying to get Conference Bridge Info');
            try {
                theCall.Conference_Bridge__c = [select Id from Conference_Bridge__c where Twilio_Number__c = :callMap.get( 'Called')].Id;
                System.debug( 'theCall Conf Bridge Id is ' + theCall.Conference_Bridge__c);
            } catch ( Exception e) {
                System.debug( 'Exception caught trying to find conference bridge number: ' + e.getMessage());
            }

            upsert theCall;
            
            String callDetails = 'Call Details\n';
            for ( String k : callMap.keySet()) {
                callDetails += k + ' => ' + callMap.get( k) + '\n';
            }
            insert new Twilio_Call_Detail__c( Twilio_Call__c = theCall.id, Details__c = callDetails);            
        } catch ( Exception e) {
        	System.debug( 'Failed to save call in Twilio_Call__c object.  Exception: ' + e.getMessage());
        }
    }

}