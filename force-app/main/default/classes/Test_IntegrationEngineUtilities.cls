@IsTest
public class Test_IntegrationEngineUtilities {
  @IsTest
  public static void testIntegrationEngineUtilitiesBuildIntegrationHandlerNullMapping() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      IIntegrationHandler handler = utilities.BuildIntegrationHandler(
        null,
        'sometype'
      );
      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.AssertEquals(
        'Unable to find handler mapping for specified type: sometype',
        ex.getMessage(),
        'Error message does not match'
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
  public static void testIntegrationEngineUtilitiesBuildIntegrationHandlerInactiveMapping() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
        Active__c = false,
        Handler_Class__c = '',
        Maximum_Retries__c = 0,
        Type__c = 'sometype',
        DeveloperName = 'TestHandler'
      );

      IIntegrationHandler handler = utilities.BuildIntegrationHandler(
        mapping,
        'sometype'
      );
      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.AssertEquals(
        string.format(
          'Handler configuration found, but integration is inactive. Type: {0}. Inactive Handler: {1}',
          new List<string>{ 'sometype', 'TestHandler' }
        ),
        ex.getMessage(),
        'Error message does not match'
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
  public static void testIntegrationEngineUtilitiesBuildIntegrationHandlerValidMappingInstantiateFail() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
        Active__c = true,
        Handler_Class__c = '',
        Maximum_Retries__c = 0,
        Type__c = 'sometype',
        DeveloperName = 'TestHandler'
      );

      IIntegrationHandler handler = utilities.BuildIntegrationHandler(
        mapping,
        'sometype'
      );
      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.AssertEquals(
        string.format(
          'Error instantiating integration handler: {0}',
          new List<string>{ 'TestHandler' }
        ),
        ex.getMessage(),
        'Error message does not match'
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
  public static void testIntegrationEngineUtilitiesBuildIntegrationHandler() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
        Active__c = true,
        Handler_Class__c = 'MockIntegrationHandler',
        Maximum_Retries__c = 0,
        Type__c = 'sometype',
        DeveloperName = 'TestHandler'
      );

      IIntegrationHandler handler = utilities.BuildIntegrationHandler(
        mapping,
        'sometype'
      );
      System.AssertNotEquals(null, handler, 'Handler should not be null');
      System.Assert(
        handler instanceof MockIntegrationHandler,
        'Handler is not of the expected type'
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
  public static void testIntegrationEngineUtilitiesExecuteRequestFailure() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Test.setMock(HttpCalloutMock.class, new TestCalloutMock());
      HttpResponse response = utilities.ExecuteRequest(null);
      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.Assert(true, 'Should have thrown an exception');
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
  public static void testIntegrationEngineUtilitiesPerformRequestWithoutCert() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Test.setMock(HttpCalloutMock.class, new TestCalloutMock());
      HttpResponse response = utilities.PerformRequest(
        'GET',
        'https://jsonplaceholder.typicode.com/posts/',
        null,
        null
      );
      System.AssertEquals(
        'OK',
        response.getStatus(),
        'Should have been successful'
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
  public static void testIntegrationEngineUtilitiesPerformRequestWithCert() {
    try {
      Map<string, string> headers = new Map<string, string>();
      headers.put('Authorization', 'SomeToken');

      Blob body = Blob.valueOf('Some Body');

      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Test.setMock(HttpCalloutMock.class, new TestCalloutMock());
      HttpResponse response = utilities.PerformRequest(
        'POST',
        'https://jsonplaceholder.typicode.com/posts/',
        null,
        headers,
        body
      );
      System.AssertEquals(
        'OK',
        response.getStatus(),
        'Should have been successful'
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
  public static void testIntegrationEngineUtilitiesLogMessage() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      utilities.LogMessage('Some Message');
      System.Assert(true, 'Should not have thrown exception');
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
  public static void testIntegrationEngineUtilitiesLogErrorWithoutException() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      utilities.LogError('Some Error');

      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.AssertEquals(
        'Some Error',
        ex.getMessage(),
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
  public static void testIntegrationEngineUtilitiesLogErrorWithException() {
    try {
      IIntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      utilities.LogError(
        'Some Error',
        new IntegrationEngineUtilities.IntegrationRequestException(
          'Some Inner Error'
        )
      );

      System.Assert(false, 'Should have thrown exception');
    } catch (IntegrationEngineUtilities.IntegrationRequestException ex) {
      System.AssertEquals(
        'Some Error',
        ex.getMessage(),
        'Error message does not match'
      );
      System.AssertNotEquals(
        null,
        ex.getCause(),
        'Inner exception should be set'
      );
      System.AssertEquals(
        'Some Inner Error',
        ex.getCause().getMessage(),
        'Inner error message does not match'
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
  public static void testIntegrationEngineUtilitiesGetIntegrationHandlerMappingNoMatch() {
    try {
      IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
        Active__c = false,
        Handler_Class__c = '',
        Maximum_Retries__c = 0,
        Type__c = 'sometype',
        DeveloperName = 'TestHandler'
      );

      utilities.requestMapping.put('sometype', mapping);

      Integration_Engine_Mapping__mdt handlerMapping = utilities.GetIntegrationHandlerMapping(
        'sometype2'
      );
      System.AssertEquals(
        null,
        handlerMapping,
        'Response should have been null'
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
  public static void testIntegrationEngineUtilitiesGetIntegrationHandlerMapping() {
    try {
      IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
      Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
        Active__c = false,
        Handler_Class__c = '',
        Maximum_Retries__c = 0,
        Type__c = 'sometype',
        DeveloperName = 'TestHandler'
      );

      utilities.requestMapping.put('sometype', mapping);

      Integration_Engine_Mapping__mdt handlerMapping = utilities.GetIntegrationHandlerMapping(
        'sometype'
      );
      System.AssertEquals(mapping, handlerMapping, 'Response was not correct');
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
  public static void testIntegrationEngineUtilitiesDMLException() {
    Account acct = new Account();
    Database.SaveResult result = Database.Insert(acct, false);
    System.AssertEquals(
      false,
      result.isSuccess(),
      'Should have errored due to missing name'
    );

    List<Database.Error> errors = result.getErrors();

    IntegrationEngineUtilities.DMLExceptionDetails details = new IntegrationEngineUtilities.DMLExceptionDetails(
      errors[0]
    );

    System.AssertEquals(
      errors[0].getMessage(),
      details.message,
      'Message did not match'
    );
    System.AssertEquals(
      errors[0].getStatusCode(),
      details.statusCode,
      'Status did not match'
    );
    System.AssertEquals(
      errors[0].getFields().size(),
      details.fields.size(),
      'Number of fields did not match'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesInsert() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    List<Integration_Queue__c> toBeQueued = new List<Integration_Queue__c>{
      new Integration_Queue__c(Type__c = 'Default'),
      new Integration_Queue__c(Type__c = 'Default')
    };

    List<Database.SaveResult> response = utilities.insertRecords(toBeQueued);
    System.AssertEquals(2, response.size(), 'Response count did not match');
    System.Assert(response[0].isSuccess(), 'Response 1 failed');
    System.Assert(response[1].isSuccess(), 'Response 2 failed');
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesInsertFailure() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    List<Integration_Queue__c> toBeQueued = new List<Integration_Queue__c>{
      new Integration_Queue__c(Type__c = 'Default'),
      new Integration_Queue__c(Type__c = 'SomeBogusType')
    };

    List<Database.SaveResult> response = utilities.insertRecords(toBeQueued);
    System.AssertEquals(2, response.size(), 'Response count did not match');
    System.Assert(response[0].isSuccess(), 'Response 1 failed');
    System.Assert(!response[1].isSuccess(), 'Response 2 should have failed');
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesUpdate() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    List<Integration_Queue__c> toBeQueued = new List<Integration_Queue__c>{
      new Integration_Queue__c(Type__c = 'Default'),
      new Integration_Queue__c(Type__c = 'Default')
    };

    insert toBeQueued;

    Test.StartTest();
    toBeQueued[0].Status__c = 'Success';
    toBeQueued[1].Status__c = 'Retry';
    List<Database.SaveResult> results = utilities.updateRecords(toBeQueued);
    Test.StopTest();

    System.AssertEquals(2, results.size(), 'Response count did not match');
    System.Assert(results[0].isSuccess(), 'Response 1 failed');
    System.Assert(results[1].isSuccess(), 'Response 2 failed');

    Map<Id, Integration_Queue__c> postUpdate = new Map<Id, Integration_Queue__c>(
      [SELECT Id, Type__c, Status__c FROM Integration_Queue__c]
    );
    System.AssertEquals(
      'Success',
      postUpdate.get(toBeQueued[0].Id).Status__c,
      'Status for #1 do not match'
    );
    System.AssertEquals(
      'Retry',
      postUpdate.get(toBeQueued[1].Id).Status__c,
      'Status for #2 do not match'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesUpdateFailure() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    List<Integration_Queue__c> toBeQueued = new List<Integration_Queue__c>{
      new Integration_Queue__c(Type__c = 'Default'),
      new Integration_Queue__c(Type__c = 'Default')
    };

    insert toBeQueued;

    Test.StartTest();
    toBeQueued[0].Status__c = 'Success';
    toBeQueued[1].Status__c = 'Retry';
    toBeQueued[1].Type__c = 'Bogus';
    List<Database.SaveResult> results = utilities.updateRecords(toBeQueued);
    Test.StopTest();

    System.AssertEquals(2, results.size(), 'Response count did not match');
    System.Assert(results[0].isSuccess(), 'Response 1 failed');
    System.Assert(!results[1].isSuccess(), 'Response 2 should have failed');

    Map<Id, Integration_Queue__c> postUpdate = new Map<Id, Integration_Queue__c>(
      [SELECT Id, Type__c, Status__c FROM Integration_Queue__c]
    );
    System.AssertEquals(
      'Success',
      postUpdate.get(toBeQueued[0].Id).Status__c,
      'Status for #1 do not match'
    );
    System.AssertEquals(
      'New',
      postUpdate.get(toBeQueued[1].Id).Status__c,
      'Status for #2 do not match'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesDelete() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    List<Integration_Queue__c> toBeQueued = new List<Integration_Queue__c>{
      new Integration_Queue__c(Type__c = 'Default'),
      new Integration_Queue__c(Type__c = 'Default')
    };

    insert toBeQueued;

    Test.StartTest();
    List<Database.DeleteResult> results = utilities.deleteRecords(toBeQueued);
    Test.StopTest();

    System.AssertEquals(2, results.size(), 'Response count did not match');
    System.Assert(results[0].isSuccess(), 'Response 1 failed');
    System.Assert(results[1].isSuccess(), 'Response 2 failed');

    List<Integration_Queue__c> postDelete = [
      SELECT Id, Type__c, Status__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(
      0,
      postDelete.size(),
      'Should not have returned records'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesHandleRequest() {
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

    Test.StartTest();
    boolean response = utilities.handleRequest(mapping, integrationQueue);
    Test.StopTest();

    System.Assert(!response, 'Should have been marked to retain');
    System.AssertEquals(
      'Success',
      integrationQueue.Status__c,
      'Should have been successful'
    );
    System.AssertEquals(
      1,
      integrationQueue.Attempts__c,
      'Should have been 1 attempt'
    );
    System.AssertEquals(
      null,
      integrationQueue.Error_Message__c,
      'Error Message should be blank'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesHandleRequestFailure() {
    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationFailureHandler.MockIntegrationAllFailureHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = true
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    Test.StartTest();
    boolean response = utilities.handleRequest(mapping, integrationQueue);
    Test.StopTest();

    System.Assert(!response, 'Should have been marked to retain');
    System.AssertEquals(
      'Failed',
      integrationQueue.Status__c,
      'Should have been Failed'
    );
    System.AssertEquals(
      1,
      integrationQueue.Attempts__c,
      'Should have been 1 attempt'
    );
    System.AssertNotEquals(
      null,
      integrationQueue.Error_Message__c,
      'Error Message should be set'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesHandleRequestRetry() {
    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationFailureHandler.MockIntegrationAllFailureHandler',
      Maximum_Retries__c = 1,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = true
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    Test.StartTest();
    boolean response = utilities.handleRequest(mapping, integrationQueue);
    Test.StopTest();

    System.Assert(!response, 'Should have been marked to retain');
    System.AssertEquals(
      'Retry',
      integrationQueue.Status__c,
      'Should have been Failed'
    );
    System.AssertEquals(
      1,
      integrationQueue.Attempts__c,
      'Should have been 1 attempt'
    );
    System.AssertNotEquals(
      null,
      integrationQueue.Error_Message__c,
      'Error Message should be set'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesCaptureFailureRetry() {
    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default'
    );

    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 1,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = true
    );

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    IntegrationEngineUtilities.IntegrationRequestException integrationException = new IntegrationEngineUtilities.IntegrationRequestException(
      'Some Retry Error'
    );

    Test.StartTest();
    utilities.captureFailure(mapping, integrationQueue, integrationException);
    Test.StopTest();

    System.AssertEquals(
      'Retry',
      integrationQueue.Status__c,
      'Should have been Failed'
    );
    System.AssertEquals(
      'Some Retry Error',
      integrationQueue.Error_Message__c,
      'Error message does not match'
    );
  }

  @IsTest
  public static void testIntegrationEngineUtilitiesCaptureFailureFailed() {
    Integration_Queue__c integrationQueue = new Integration_Queue__c(
      Type__c = 'Default',
      Attempts__c = 1
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

    IntegrationEngineUtilities.IntegrationRequestException integrationException = new IntegrationEngineUtilities.IntegrationRequestException(
      'Some Error'
    );

    Test.StartTest();
    utilities.captureFailure(mapping, integrationQueue, integrationException);
    Test.StopTest();

    System.AssertEquals(
      'Failed',
      integrationQueue.Status__c,
      'Should have been Failed'
    );
    System.AssertEquals(
      'Some Error',
      integrationQueue.Error_Message__c,
      'Error message does not match'
    );
  }

  public class TestCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatus('OK');
      res.setStatusCode(200);
      res.setBody('GREAT SCOTT');
      return res;
    }
  }
}