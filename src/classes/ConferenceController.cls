/*
 * Class: ConferenceController
 */
public with sharing class ConferenceController {

    // Pull the conference name from the URL
    public String getConferenceName() {
        String confName = ApexPages.currentPage().getParameters().get('confName');
        if ( confName == null || confName.length() == 0 ) {
            confName = 'Unknown';
        }
        return confName;
    }

}