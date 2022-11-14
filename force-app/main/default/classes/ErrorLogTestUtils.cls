@isTest
public class ErrorLogTestUtils {
    public static Error_Log_Deletion_Batch_Settings__c getError_Log_Deletion_Batch_Settings() {
        Error_Log_Deletion_Batch_Settings__c customSetting = Error_Log_Deletion_Batch_Settings__c.getInstance();
        customSetting.Batch_Size__c = 200;
        customSetting.Days_To_Keep_Logs__c = 60;
        return customSetting;
    }

    public static Error_Log__c createErrorLog(String location,Boolean isSilent) {
        return new Error_Log__c(
            Error_Location__c = location,
            Silent_Error__c = isSilent
        );
    }
}