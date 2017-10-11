trigger UpdateObjectEventTrigger on UpdateObjectEvent__e (after insert) {
    System.debug(' UpdateObjectEventTrigger ' );
    
    for (UpdateObjectEvent__e event : Trigger.New) {
        System.debug(' : ' + event.RecordId__c + ' ' + event.ObjectName__c );
    }
    
}