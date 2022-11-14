@isTest
public class FlowErrorLogAfterCreateTest {
    /*
     * Error log creation triggers email to users setup in Apex Exception Email 
     * for Silient Error logs
     */
    @isTest
    private static void testEmailSendForSilentError() {
        Error_Log__c error1 = ErrorLogTestUtils.createErrorLog('Apex Trigger',true);
        error1.Apex_Class_Flow_Name__c = 'Test Trigger';
        error1.Error_Message__c = 'TestMessage1';
        
        Error_Log__c error2 = ErrorLogTestUtils.createErrorLog('Flow',false);
        error2.Apex_Class_Flow_Name__c = 'Test Flow';
        error2.Error_Message__c = 'TestMessage2';
        
        Test.startTest();
            insert new List<Error_Log__c>{
               error1,
               error2
            };
        Test.stopTest();
        //Emails are not sent in Unit Tests, so nothing is asserted.
    }
}