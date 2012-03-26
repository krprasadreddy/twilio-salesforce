/*
 * TwilioMessageVoiceController.cls 
 * This is the controller for the Sites page that serves up the TwiML for Voice Calls 
 */
public with sharing class TwilioMessageVoiceController {

    public String message { get; set; }
    
    public TwilioMessageVoiceController() {
        String taskId = ApexPages.currentPage().getParameters().get( 'taskId');
        message = [select Description 
                     from Task 
                    where Id = :taskId].Description;
    }
}