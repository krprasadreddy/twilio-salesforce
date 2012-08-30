global abstract class ConferenceHelper {

    // Only allow calls within the business hours
    public static Boolean inBusinessHours() {
        Boolean withinBusinessHours = false;
        
  		try {
	        BusinessHours bh = [select SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, 
	                                   TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, 
	                                   ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, 
	                                   SaturdayStartTime, SaturdayEndTime
	                              from BusinessHours
	                             where Name = 'Twilio Calls'];
	        
	        String dayOfWeek = Datetime.now().format( 'EEEEEEEEEE' );
	        System.debug( 'Day of Week is ' + dayOfWeek);
	        
	        Time timeNow = Datetime.now().time();
	        System.debug( 'Time now is ' + timeNow);
	        
	        Time dtStart = (Time)bh.get( dayOfWeek + 'StartTime');
	        Time dtEnd = (Time)bh.get( dayOfWeek + 'EndTime');
	        System.debug( 'Business Hours for ' + dayOfWeek + ' are from ' + dtStart + ' to ' + dtEnd); 
	        
	        // Now check it
	        if ( timeNow >= dtStart && timeNow <= dtEnd ) {
	            System.debug( 'Time ' + timeNow + ' is within Business Hours');
	            withinBusinessHours = true;
	        }
  		} catch ( Exception e) {
  			System.debug( 'Exception in ConferenceHelper.inBusinessHours: ' + e.getMessage());
  		}
        
        return withinBusinessHours;
    }
}