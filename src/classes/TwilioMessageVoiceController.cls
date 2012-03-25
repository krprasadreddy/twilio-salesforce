public with sharing class TwilioMessageVoiceController {

    public String message { get; set; }
    
    public TwilioMessageVoiceController() {
        String taskId = ApexPages.currentPage().getParameters().get( 'taskId');
        message = [select Description 
                     from Task 
                    where Id = :taskId].Description;
    }
}