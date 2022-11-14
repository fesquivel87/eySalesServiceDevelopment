@IsTest
public class Test_IntegrationEngine {
  @IsTest
  public static void testIntegrationEngineQueue() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    IntegrationEngine engine = new IntegrationEngine(utilities);

    Integration_Queue__c toBeQueued = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Id response = engine.queue(toBeQueued);
    System.Assert(response != null, 'Response should not be null');
  }

  @IsTest
  public static void testIntegrationEngineQueueFailure() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    IntegrationEngine engine = new IntegrationEngine(utilities);

    Integration_Queue__c toBeQueued = new Integration_Queue__c(
      Type__c = 'SomeBogusType'
    );
    try {
      Id response = engine.queue(toBeQueued);
      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.Assert(
        ex.getMessage().indexOf('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') > -1,
        'Error message does not match'
      );
      System.AssertEquals(
        null,
        ex.getCause(),
        'Inner exception should be empty'
      );
    } catch (Exception ex) {
      System.Assert(
        false,
        string.Format(
          'Test threw unexpected error: {0}',
          new List<string>{ ex.getMessage() }
        )
      );
    }
  }

  @IsTest
  public static void testIntegrationEngineQueueFailureReturnNull() {
    MockIntegrationUtilities utilities = new MockIntegrationUtilities();
    IntegrationEngine engine = new IntegrationEngine(utilities);

    Integration_Queue__c toBeQueued = new Integration_Queue__c(
      Type__c = 'SomeBogusType'
    );

    Id response = engine.queue(toBeQueued);
    System.AssertEquals(null, response, 'Should have been a null Id');
  }

  @IsTest
  public static void testIntegrationEngineRunNow() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler'
    );

    utilities.requestMapping.put('Default', mapping);
    IntegrationEngine engine = new IntegrationEngine(utilities);

    Integration_Queue__c toBeQueued = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Id response = engine.runNow(toBeQueued);
    System.AssertEquals(
      response.getSObjectType().getDescribe().getName(),
      AsyncApexJob.getSObjectType().getDescribe().getName(),
      'Should have been an AsyncApexJob'
    );
  }

  @IsTest
  public static void testIntegrationEngineRunNowTooMany() {
    MockIntegrationUtilities utilities = new MockIntegrationUtilities();
    utilities.isOver = true;

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler'
    );

    utilities.requestMapping.put('Default', mapping);
    IntegrationEngine engine = new IntegrationEngine(utilities);

    Integration_Queue__c toBeQueued = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Id response = engine.runNow(toBeQueued);

    System.AssertEquals(
      response.getSObjectType().getDescribe().getName(),
      toBeQueued.getSObjectType().getDescribe().getName(),
      'Should have been an Integration Queue record'
    );
  }

  @IsTest
  public static void testIntegrationEngineRunNowHandlerCreationFailure() {
    MockIntegrationUtilities utilities = new MockIntegrationUtilities();
    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler2',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler'
    );

    utilities.requestMapping.put('Default', mapping);
    IntegrationEngine engine = new IntegrationEngine(utilities);

    Integration_Queue__c toBeQueued = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Id response = engine.runNow(toBeQueued);
    System.AssertEquals(null, response, 'Should have been a null response');
  }
}