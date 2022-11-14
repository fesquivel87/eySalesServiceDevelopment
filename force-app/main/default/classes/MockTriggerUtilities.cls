public with sharing class MockTriggerUtilities implements ITriggerUtilities {
    
    // Flags used by test classes to be able to fully test methods in a mocked format
    public string triggerObject;
    public List<SObject> triggerNew = new List<SObject>();
    public Map<Id, SObject> triggerNewMap = new Map<Id, SObject>();
    public Map<Id, SObject> triggerOldMap = new Map<Id, SObject>();
    public List<Trigger_Setting__mdt> triggerSettings = new List<Trigger_Setting__mdt>();
    public List<Trigger_Handler__mdt> triggerHandlers = new List<Trigger_Handler__mdt>();
    public List<Trigger_Handler_Bypass__mdt> triggerHandlerBypasses = new List<Trigger_Handler_Bypass__mdt>();
    public List<Trigger_Shared_Query__mdt> triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt>();
    public System.TriggerOperation triggerOperation;
    
    public List<SObject> evaluateTriggerNew() {
        return triggerNew;
    }

    public Map<Id, SObject> evaluateTriggerNewMap() {
        return triggerNewMap;
    }

    public Map<Id, SObject> evaluateTriggerOldMap() {
        return triggerOldMap;
    }

    public String getSObjectType() {
        return triggerObject;
    }

    public void logMessage(string message){
        System.debug(message);
        throw new TriggerDispatcher.TriggerDispatcherException(message);
    }

    // Log errors within this method to a customer error logging framework or the debug console
    public void logError(string triggerName, string action, Exception ex){
        System.debug(ex);
        System.debug(ex.getStackTraceString());
        throw ex;
    }

    public List<Trigger_Setting__mdt> getTriggerSettings(string objectType){
        return triggerSettings;
    }

    public List<Trigger_Handler__mdt> getTriggerHandlers(Id triggerSettingId)
    {
        List<Trigger_Handler__mdt> toReturn = new List<Trigger_Handler__mdt>();

        for(Trigger_Handler__mdt handler : triggerHandlers){
            if(handler.Active__c) {
                toReturn.add(handler);
            }
        }

        return toReturn;
    }

    public List<Trigger_Handler_Bypass__mdt> getTriggerHandlerBypasses(Id triggerSettingId) {
        return triggerHandlerBypasses;
    }

    public List<Trigger_Shared_Query__mdt> getTriggerSharedDataQueries(Id triggerSettingId) {
        return triggerSharedDataQueries;
    }    

    public System.TriggerOperation evaluateOperation() {
        return triggerOperation;
    }
}