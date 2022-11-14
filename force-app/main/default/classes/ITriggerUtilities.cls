public interface ITriggerUtilities
{
    System.TriggerOperation evaluateOperation();    
    List<SObject> evaluateTriggerNew();
    Map<Id, SObject> evaluateTriggerNewMap();
    Map<Id, SObject> evaluateTriggerOldMap();
    String getSObjectType();
    void logMessage(string message);
    void logError(string triggerName, string action, Exception ex);
    List<Trigger_Setting__mdt> getTriggerSettings(string objectType);
    List<Trigger_Handler__mdt> getTriggerHandlers(Id triggerSettingId);
    List<Trigger_Handler_Bypass__mdt> getTriggerHandlerBypasses(Id triggerSettingId);
    List<Trigger_Shared_Query__mdt> getTriggerSharedDataQueries(Id triggerSettingId);
}