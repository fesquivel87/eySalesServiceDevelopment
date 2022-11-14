@IsTest
public class Test_IntegrationEngineQueueableWorker {
  @IsTest
  public static void testIntegrationEngineQueueableWorkerSuccess() {
    MockIntegrationHandler handler = new MockIntegrationHandler();
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedAuthenticate,
      'ExecutedAuthenticate should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedExecute,
      'ExecutedExecute should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedFinalize,
      'ExecutedFinalize should start as false'
    );

    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = false
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineQueueableWorker worker = new IntegrationEngineQueueableWorker(
      integrationQueue,
      handler,
      utilities,
      mapping
    );

    Test.StartTest();
    System.enqueueJob(worker);
    Test.StopTest();

    System.Assert(
      MockIntegrationHandler.executedAuthenticate,
      'ExecutedAuthenticate should be true'
    );
    System.Assert(
      MockIntegrationHandler.executedExecute,
      'ExecutedExecute should be true'
    );
    System.Assert(
      MockIntegrationHandler.executedFinalize,
      'ExecutedFinalize should be true'
    );

    List<Integration_Queue__c> afterExecution = [
      SELECT Id, Status__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(
      0,
      afterExecution.size(),
      'Should not have saved any records'
    );
  }

  @IsTest
  public static void testIntegrationEngineQueueableWorkerSuccessRetain() {
    MockIntegrationHandler handler = new MockIntegrationHandler();
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedAuthenticate,
      'ExecutedAuthenticate should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedExecute,
      'ExecutedExecute should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedFinalize,
      'ExecutedFinalize should start as false'
    );

    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = true
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineQueueableWorker worker = new IntegrationEngineQueueableWorker(
      integrationQueue,
      handler,
      utilities,
      mapping
    );

    Test.StartTest();
    System.enqueueJob(worker);
    Test.StopTest();

    List<Integration_Queue__c> afterExecution = [
      SELECT Id, Status__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(1, afterExecution.size(), 'Should have saved 1 record');
    System.AssertEquals(
      'Success',
      afterExecution[0].Status__c,
      'Should have been successful'
    );
  }

  @IsTest
  public static void testIntegrationEngineQueueableWorkerRetry() {
    MockIntegrationHandler handler = new MockIntegrationHandler();
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedAuthenticate,
      'ExecutedAuthenticate should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedExecute,
      'ExecutedExecute should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedFinalize,
      'ExecutedFinalize should start as false'
    );

    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationFailureHandler.MockIntegrationAllFailureHandler',
      Maximum_Retries__c = 1,
      Type__c = 'Default',
      DeveloperName = 'TestHandler'
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineQueueableWorker worker = new IntegrationEngineQueueableWorker(
      integrationQueue,
      handler,
      utilities,
      mapping
    );

    Test.StartTest();
    System.enqueueJob(worker);
    Test.StopTest();

    List<Integration_Queue__c> afterExecution = [
      SELECT Id, Status__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(1, afterExecution.size(), 'Should have saved 1 record');
    System.AssertEquals(
      'Retry',
      afterExecution[0].Status__c,
      'Should have been Retry'
    );
  }

  @IsTest
  public static void testIntegrationEngineQueueableWorkerFailed() {
    MockIntegrationHandler handler = new MockIntegrationHandler();
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedAuthenticate,
      'ExecutedAuthenticate should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedExecute,
      'ExecutedExecute should start as false'
    );
    System.AssertEquals(
      false,
      MockIntegrationHandler.executedFinalize,
      'ExecutedFinalize should start as false'
    );

    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationFailureHandler.MockIntegrationAllFailureHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler'
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineQueueableWorker worker = new IntegrationEngineQueueableWorker(
      integrationQueue,
      handler,
      utilities,
      mapping
    );

    Test.StartTest();
    System.enqueueJob(worker);
    Test.StopTest();

    List<Integration_Queue__c> afterExecution = [
      SELECT Id, Status__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(1, afterExecution.size(), 'Should have saved 1 record');
    System.AssertEquals(
      'Failed',
      afterExecution[0].Status__c,
      'Should have been Failed'
    );
  }
}