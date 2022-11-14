public class TriggerUtilities implements ITriggerUtilities {

    public System.TriggerOperation evaluateOperation() {
        return Trigger.OperationType;
    } 

    public List<SObject> evaluateTriggerNew() {
        return Trigger.New;
    }

    public Map<Id, SObject> evaluateTriggerNewMap() {
        return Trigger.NewMap;
    }

    public Map<Id, SObject> evaluateTriggerOldMap() {
        return Trigger.OldMap;
    }

    public String getSObjectType() {
        if (Trigger.new != null) {
            return Trigger.new[0].getSObjectType().getDescribe().getName();
        } else if (Trigger.old != null) {
            return Trigger.old[0].getSObjectType().getDescribe().getName();
        }
        
        return null;
    }

    public void logMessage(string message) {
        //Do something
    }

    // Log errors within this method to a customer error logging framework or the debug console
    public void logError(string triggerName, string action, Exception ex){
        string message = String.format('{0} failed on {1} with {2}', new List<String> { triggerName, action, JSON.serialize(new SerializedError(ex), true) });        
    }

    public List<Trigger_Setting__mdt> getTriggerSettings(string objectType){
        return [SELECT Id, MasterLabel, SObject__c, Maximum_Loop_Count__c, Allow_Bypass__c FROM Trigger_Setting__mdt WHERE SObject__c = :objectType];        
    }

    public List<Trigger_Handler__mdt> getTriggerHandlers(Id triggerSettingId)
    {
        return [SELECT Id, MasterLabel, Handler_Class__c, Execution_Order__c FROM Trigger_Handler__mdt WHERE Active__c = true AND Trigger_Setting__c = :triggerSettingId];
    }

    public List<Trigger_Handler_Bypass__mdt> getTriggerHandlerBypasses(Id triggerSettingId) {
        DateTime currentTime = System.now();
        List<Trigger_Handler_Bypass__mdt> bypassList = [SELECT Id, MasterLabel, Trigger_Handler__c, User_Name__c, Bypass_Start__c, Bypass_End__c FROM Trigger_Handler_Bypass__mdt WHERE Bypass_End__c = NULL AND Trigger_Handler__r.Trigger_Setting__c = :triggerSettingId];
        bypassList.addAll([SELECT Id, MasterLabel, Trigger_Handler__c, User_Name__c, Bypass_Start__c, Bypass_End__c FROM Trigger_Handler_Bypass__mdt WHERE Bypass_End__c > :currentTime AND Trigger_Handler__r.Trigger_Setting__c = :triggerSettingId]);
        return bypassList;
    }

    public List<Trigger_Shared_Query__mdt> getTriggerSharedDataQueries(Id triggerSettingId) {
        return [SELECT Id, DeveloperName, MasterLabel, SOQL__c from Trigger_Shared_Query__mdt WHERE Trigger_Setting__c = :triggerSettingId];
    }    
    
    public class SerializedError {
        public string type { get;set;}
        public string message { get;set;}
        public string stackTrace { get;set;}

        public SerializedError(Exception ex){
            message = ex.getMessage();
            stackTrace = ex.getStackTraceString();
            type = ex.getTypeName();
        }
    }
}