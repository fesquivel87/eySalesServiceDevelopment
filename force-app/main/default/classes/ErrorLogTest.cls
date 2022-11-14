@isTest
private class ErrorLogTest {

    @isTest
    private static void test_ErrorLog_MissingText() {
        ErrorLog.ErrorLocation location = ErrorLog.ErrorLocation.ApexTrigger;
        string message = null;
        string apexClass = 'TestClass';
        Boolean silent = false;

        Test.startTest();
            Error_Log_Event__e logResult = ErrorLog.logError(location, message, apexClass, silent, true);
            // This method must be called before Test.stopTest since limits will reset
            assertOnePlatformEventPublishCalled();
        Test.stopTest();

        System.assertNotEquals(null, logResult, 'Event was not able to be queued');
        assertPlatformEventLogged(logResult, 'Apex Trigger', ErrorLog.defaultText, apexClass, silent);
    }

    @isTest
    private static void test_ErrorLog_TooLongText() {
        ErrorLog.ErrorLocation location = ErrorLog.ErrorLocation.BatchJob;
        string apexClass = 'TestClass';
        string message = '012345789012345789012345789012345789012345789';
        Boolean silent = true;

        Test.startTest();
            ErrorLog.maxErrorMessageSize = 25;
            Error_Log_Event__e logResult = ErrorLog.logError(location, message, apexClass, silent, true);
            // This method must be called before Test.stopTest since limits will reset
            assertOnePlatformEventPublishCalled();
        Test.stopTest();

        System.assertNotEquals(null, logResult, 'Event was not able to be queued');
        assertPlatformEventLogged(logResult, 'Batch Job', message.left(25), apexClass, silent);
    }

    @isTest
    private static void test_ErrorLog_SuccessfulLog() {
        ErrorLog.ErrorLocation location = ErrorLog.ErrorLocation.Flow;
        string message = 'Some Error Message';
        string apexClass = 'TestClass';
        Boolean silent = false;

        Test.startTest();
            Error_Log_Event__e logResult = ErrorLog.logError(location, message, apexClass, silent, true);
            // This method must be called before Test.stopTest since limits will reset
            assertOnePlatformEventPublishCalled();
        Test.stopTest();

        System.assertNotEquals(null, logResult, 'Event was not able to be queued');
        assertPlatformEventLogged(logResult, 'Flow', message, apexClass, silent);
    }

    @isTest
    private static void test_ErrorLog_FailedLog() {
        ErrorLog.ErrorLocation location = ErrorLog.ErrorLocation.BatchJob;
        string message = 'Some Error Message';
        string apexClass = 'TestClass';
        Boolean silent = true;

        Test.startTest();
            ErrorLog.forceError = true;
            Error_Log_Event__e logResult = ErrorLog.logError(location, message, apexClass, silent, true);
            // This method must be called before Test.stopTest since limits will reset
            assertPlatformEventsPublishCalled(0);
        Test.stopTest();

        System.assertEquals(null, logResult, 'Event should not have been queued');
    }

    @isTest
    private static void test_ErrorLog_DoNotPublish() {
        ErrorLog.ErrorLocation location = ErrorLog.ErrorLocation.BatchJob;
        string apexClass = 'TestClass';
        string message = 'Test';
        Boolean silent = true;

        Test.startTest();
            Error_Log_Event__e logResult = ErrorLog.logError(location, message, apexClass, silent, false);
            // This method must be called before Test.stopTest since limits will reset
            assertPlatformEventsPublishCalled(0);
        Test.stopTest();

        System.assertNotEquals(null, logResult, 'Event was not able to be created');
        assertPlatformEventLogged(logResult, 'Batch Job', message, apexClass, silent);
    }

    @isTest
    private static void Test_ErrorLog_PublishErrorLogEvents() {
        List<Error_Log_Event__e> logEvents = new List<Error_Log_Event__e>();
        integer eventsToPublish = 5;

        for (integer i = 0; i < eventsToPublish; i++) {
            logEvents.add(ErrorLog.logError(ErrorLog.ErrorLocation.ApexTrigger, 'Test', 'TestClass', false, false));
        }

        // Sanity check that no logs have been published
        assertPlatformEventsPublishCalled(0);

        Test.startTest();
            ErrorLog.publishErrorLogEvents(logEvents);
            // This method must be called before Test.stopTest since limits will reset
            assertOnePlatformEventPublishCalled();
        Test.stopTest();
    }

    @isTest
    private static void Test_ErrorLog_PublishErrorLog_Error() {
        List<Error_Log_Event__e> logEvents = new List<Error_Log_Event__e>();
        integer eventsToPublish = 5;

        for (integer i = 0; i < eventsToPublish; i++) {
            logEvents.add(ErrorLog.logError(ErrorLog.ErrorLocation.ApexTrigger, 'Test', 'TestClass', false, false));
        }

        // Sanity check that no logs have been published
        assertPlatformEventsPublishCalled(0);

        Test.startTest();
            ErrorLog.ForceError = true;
            ErrorLog.publishErrorLogEvents(logEvents);
            // This method must be called before Test.stopTest since limits will reset
            assertPlatformEventsPublishCalled(0);
        Test.stopTest();
    }

    private static void assertPlatformEventLogged(Error_Log_Event__e log, string location, string message, string apexClass, Boolean silent) {
        System.assertEquals(location, log.Error_Location__c, 'Location does not match expected');
        System.assertEquals(message, log.Error_Message__c, 'Messsage does not match expected');
        System.assertEquals(apexClass, log.Apex_Class_Flow_Name__c, 'Apex Class does not match expected');
        System.assertEquals(silent, log.Silent_Error__c, 'Silent Error does not match expected');
    }

    private static void assertOnePlatformEventPublishCalled() {
        assertPlatformEventsPublishCalled(1);
    }

    private static void assertPlatformEventsPublishCalled(integer numberOfPublishCalls) {
        system.assertEquals(numberOfPublishCalls, Limits.getPublishImmediateDML(), 
            string.format('Expected {0} Events to be published, but {1} were.', 
                new List<Object> {numberOfPublishCalls, Limits.getPublishImmediateDML()}));
    }
}