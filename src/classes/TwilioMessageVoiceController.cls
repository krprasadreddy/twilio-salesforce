/*
 * TwilioMessageVoiceController.cls 
 * This is the controller for the Sites page that serves up the TwiML for Voice Calls 
 */
public with sharing class TwilioMessageVoiceController {

    public String message { get; set; }
    
    public TwilioMessageVoiceController() {
        String taskId = ApexPages.currentPage().getParameters().get( 'taskId');
        try {
	        message = [select Description 
	                     from Task 
	                    where Id = :taskId].Description;
        } catch ( Exception e) {
        	message = 'Could not get message associated with this request.';
        }
    }
}