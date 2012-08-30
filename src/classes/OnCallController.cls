public class OnCallController {

    public List<User> getOnCallUsers() {
        String groupName = ApexPages.currentPage().getParameters().get( 'groupName');
        
        return [select Id, FirstName, Username, MobilePhone
                                    from User 
                                   where IsActive = true 
                                     and MobilePhone != null
                                     and id in (
                                    select UserOrGroupId
                                      from GroupMember
                                     where group.name = :groupName)];
    }
}