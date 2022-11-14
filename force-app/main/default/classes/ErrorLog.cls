public inherited sharing class ErrorLog {

    public enum ErrorLocation { ApexTrigger, Flow, BatchJob}

    @testVisible
    private static integer maxErrorMessageSize = Error_Log_Event__e.Error_Message__c.getDescribe().getLength();

    @testVisible
    private static final string defaultText = 'UNKNOWN';

    @testVisible
    private static Boolean forceError = false;

    private static final Map<ErrorLog.ErrorLocation, string> locationValues = new Map<ErrorLog.ErrorLocation, string> {
        ErrorLocation.ApexTrigger => 'Apex Trigger',
        ErrorLocation.Flow => 'Flow',
        ErrorLocation.BatchJob => 'Batch Job'
    };

    public static Error_Log_Event__e logError(ErrorLog.ErrorLocation location, string message, string apexClass, Boolean silentError, boolean publish) {
        try {

            if(Test.isRunningTest() && forceError) {
                throw new IllegalArgumentException('Forced error message');
            }

            if(message == null) {
                message = defaultText;
            }

            string truncatedMessage = message?.length() > maxErrorMessageSize
                ? message.left(maxErrorMessageSize)
                : message;

            Error_Log_Event__e log = new Error_Log_Event__e(
                Apex_Class_Flow_Name__c = apexClass,
                Error_Location__c = locationValues.get(location),
                Error_Message__c = truncatedMessage,
                Silent_Error__c = silentError
            );

            if (publish) {
                Eventbus.publish(log);
            }
            return log;
        } catch (Exception ex) {
            System.debug(JSON.serialize(ex));
            return null;
        }
    }

    public static void publishErrorLogEvents(List<Error_Log_Event__e> logs) {
        try {
            if(Test.isRunningTest() && forceError) {
                throw new IllegalArgumentException('Forced error message');
            }

            Eventbus.publish(logs);

        } catch (Exception ex) {
            System.debug(JSON.serialize(ex));
            return;
        }
    }
}