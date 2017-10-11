List<UpdateObjectEvent__e> events = new List<UpdateObjectEvent__e>();
UpdateObjectEvent__e event = new UpdateObjectEvent__e(objectName__c='Account', recordId__c='1234');
events.add( event );
List<Database.SaveResult> results = EventBus.publish(events);
if( results != null && results.size() > 0 ) {
    for (Database.SaveResult sr : results) {
        if (sr.isSuccess()) {
            System.debug('Successfully published event. '  + results.size() );
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }
    }
} else {
    System.debug(' Noting is published. ');
}
