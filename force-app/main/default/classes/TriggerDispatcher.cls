public without sharing class TriggerDispatcher {

    public TriggerDispatcher(ITriggerUtilities utilities) {
        this.utilities = utilities;        
        this.getTriggerSettings();
        this.setMaxLoopCount(this.triggerSettings);
        this.getTriggerHandlers();
        this.getTriggerBypassUsers();
        this.getTriggerSharedQueriesData();
    }

    public static Map<Id, LoopCount> loopCountMap;

    static {
        loopCountMap = new Map<Id, LoopCount>();
    }

    private ITriggerUtilities utilities;

    @testVisible
    private Trigger_Setting__mdt triggerSettings;

    @testVisible
    private List<Trigger_Shared_Query__mdt> sharedQueries;
    
    @testVisible
    private Map<string, List<SObject>> sharedQueryData;

    @testVisible
    private List<Trigger_Handler__mdt> triggerHandlers;

    @testVisible
    private Map<Id, Set<string>> triggerHandlerBypasses;
    
    // Call this method from your trigger, passing in an instance of a trigger logicHandler which implements ITriggerHandler.
    // This method will fire the appropriate methods on the logicHandler depending on the trigger context.
    public void run() {
        try
        {   
            this.addToLoopCount(this.triggerSettings);

            string username = UserInfo.getUsername();

            for(Trigger_Handler__mdt handler : this.triggerHandlers) {
                ITriggerHandler triggerHandler;

                if(shouldBypass(handler, username)) {
                    continue;
                }

                try {
                    triggerHandler = (ITriggerHandler)Type.forName(handler.Handler_Class__c).newInstance();
                    triggerHandler.setSharedData(this.sharedQueryData);
                } catch (NullPointerException e) {
                    utilities.logError(this.triggerSettings.MasterLabel, String.format('Error instantiating trigger handler: {0}', new List<object> { handler.Handler_Class__c }), e);
                } catch (Exception e) {
                    utilities.logError(this.triggerSettings.MasterLabel, utilities.evaluateOperation().name(), e);
                    continue;
                }

                switch on utilities.evaluateOperation() {
                    when BEFORE_INSERT {
                        triggerHandler.doBeforeInsert(utilities.evaluateTriggerNew());
                    }
                    when BEFORE_UPDATE {
                        triggerHandler.doBeforeUpdate(utilities.evaluateTriggerNewMap(), utilities.evaluateTriggerOldMap());
                    }
                    when BEFORE_DELETE {
                        triggerHandler.doBeforeDelete(utilities.evaluateTriggerOldMap());
                    }
                    when AFTER_INSERT {
                        triggerHandler.doAfterInsert(utilities.evaluateTriggerNewMap());
                    }
                    when AFTER_UPDATE {
                        triggerHandler.doAfterUpdate(utilities.evaluateTriggerNewMap(), utilities.evaluateTriggerOldMap());
                    }
                    when AFTER_DELETE {    
                        triggerHandler.doAfterDelete(utilities.evaluateTriggerOldMap());
                    }
                    when AFTER_UNDELETE {
                        triggerHandler.doAfterUndelete(utilities.evaluateTriggerOldMap());
                    }
                }
            }
        } catch (TriggerDispatcherException ex) {
            utilities.logError(this.triggerSettings.MasterLabel, utilities.evaluateOperation().name(), ex);
            throw ex;
        }
        finally{
            this.clearMaxLoopCount(this.triggerSettings);
        }
    }

    private void getTriggerSettings(){
        string objectName = utilities.getSObjectType();
        List<Trigger_Setting__mdt> settings = utilities.getTriggerSettings(objectName);
        if(settings.isEmpty()){
            utilities.logMessage(String.format('Could not find trigger settings for {0} object', new List<string> {objectName}));
        } else {
            this.triggerSettings = settings[0];
        }
    }

    private void getTriggerHandlers()
    {
        this.triggerHandlers = utilities.getTriggerHandlers(this.triggerSettings?.Id);

        if(this.triggerHandlers.isEmpty()){
            utilities.logMessage(String.format('Could not find any active trigger handlers for {0} object', new List<string> {utilities.getSObjectType()}));
        }
    }

    private void getTriggerBypassUsers() {
        if(this.triggerSettings == null) {
            return;
        }

        this.triggerHandlerBypasses = new Map<Id, Set<string>>();

        if(!this.triggerSettings.Allow_Bypass__c) {
            return;
        }

        for(Trigger_Handler_Bypass__mdt bypass : utilities.getTriggerHandlerBypasses(this.triggerSettings.Id)) {
            if(!this.triggerHandlerBypasses.containsKey(bypass.Trigger_Handler__c)) {
                this.triggerHandlerBypasses.put(bypass.Trigger_Handler__c, new Set<string>());
            }

            this.triggerHandlerBypasses.get(bypass.Trigger_Handler__c).add(bypass.User_Name__c);
        }
    }

    private void getTriggerSharedQueriesData() {
        if(this.triggerSettings == null) {
            return;
        }

        this.sharedQueries = utilities.getTriggerSharedDataQueries(this.triggerSettings.Id);
        this.sharedQueryData = new Map<string, List<SObject>>();

        if(!this.sharedQueries.isEmpty()) {
            for(Trigger_Shared_Query__mdt query : this.sharedQueries) {
                this.sharedQueryData.put(query.DeveloperName, Database.query(query.SOQL__c));
            }
        }
    }

    private boolean shouldBypass(Trigger_Handler__mdt triggerHandler, string username) {
        return (this.triggerHandlerBypasses.containsKey(triggerHandler.Id) && this.triggerHandlerBypasses.get(triggerHandler.Id).contains(username));
    }

    private void setMaxLoopCount(Trigger_Setting__mdt triggerSetting) {
        if(triggerSetting == null){
            return;
        }

        this.setMaxLoopCount(triggerSetting.Id, triggerSetting.Maximum_Loop_Count__c);
    }

    private void setMaxLoopCount(Id settingId, decimal max){
        if (!TriggerDispatcher.loopCountMap.containsKey(settingId)) {
            TriggerDispatcher.loopCountMap.put(settingId, new LoopCount(max));
        } else {
            TriggerDispatcher.loopCountMap.get(settingId).setMax(max);
        }
    }

    @testVisible
    private void addToLoopCount(Trigger_Setting__mdt triggerSetting) {
        if(triggerSetting == null){
            return;
        }

        if (TriggerDispatcher.loopCountMap.containsKey(triggerSetting.Id)) {
            Boolean exceeded = TriggerDispatcher.loopCountMap.get(triggerSetting.Id).increment();
            if (exceeded) {
                decimal max = TriggerDispatcher.loopCountMap.get(triggerSetting.Id).max;
                throw new TriggerDispatcherException(
                    String.format('Maximum loop count of {0} reached in {1}', new List<string> { String.valueOf(max), triggerSetting.MasterLabel })
                );
            }
        }
    }

    private void clearMaxLoopCount(Trigger_Setting__mdt triggerSetting) {
        if(triggerSetting == null){
            return;
        }

        this.setMaxLoopCount(triggerSetting.Id, -1);
    }

    public class TriggerDispatcherException extends Exception {}

    public class LoopCount {
        public decimal max;
        public Integer count;

        public LoopCount(decimal max) {
            this.setMax(max);
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if (this.getMax() < 0) {
                return false;
            }
            if (this.getCount() > this.getMax()) {
                return true;
            }
            return false;
        }

        public decimal getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(decimal max) {
            this.max = max;
        }
    }
}