@IsTest
public class Test_IntegrationEngineBatch {
  @TestSetup
  public static void setup() {
    List<Integration_Queue__c> queuedRecords = new List<Integration_Queue__c>();

    for (integer i = 0; i < 60; i++) {
      queuedRecords.add(new Integration_Queue__c(Type__c = 'Default'));
    }

    insert queuedRecords;
  }

  @IsTest
  public static void testIntegrationEngineBatchUpdateOnSuccess() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = true
    );

    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineBatch batchService = new IntegrationEngineBatch(utilities);

    Test.startTest();
    Database.executeBatch(batchService);
    Test.stopTest();

    List<Integration_Queue__c> records = [
      SELECT Id, Type__c, Status__c, Batch_Job__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(
      60,
      records.size(),
      'Did not return the expected number of records'
    );

    for (Integration_Queue__c record : records) {
      System.AssertEquals(
        'Success',
        record.Status__c,
        'Status should have been success'
      );

      System.AssertNotEquals(
        null,
        record.Batch_Job__c,
        'Batch job id should be set'
      );
    }
  }

  @IsTest
  public static void testIntegrationEngineBatchDeleteOnSuccess() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = false
    );

    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineBatch batchService = new IntegrationEngineBatch(utilities);

    Test.startTest();
    Database.executeBatch(batchService);
    Test.stopTest();

    List<Integration_Queue__c> records = [
      SELECT Id, Type__c, Status__c
      FROM Integration_Queue__c
    ];

    System.AssertEquals(
      0,
      records.size(),
      'Should not have returned any records'
    );
  }

  @IsTest
  public static void testIntegrationEngineBatchHandleFailuresRetry() {
    List<Integration_Queue__c> preRecords = [
      SELECT Id, Type__c, Status__c
      FROM Integration_Queue__c
    ];

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationFailureHandler',
      Maximum_Retries__c = 1,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = false
    );

    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineBatch batchService = new IntegrationEngineBatch(utilities);

    Test.startTest();
    Database.executeBatch(batchService);
    Test.stopTest();

    List<Integration_Queue__c> records = [
      SELECT Id, Type__c, Status__c, Attempts__c
      FROM Integration_Queue__c
    ];

    System.AssertNotEquals(
      preRecords.size(),
      records.size(),
      'Some records should have succeeded and therefore would have been removed'
    );

    for (Integration_Queue__c record : records) {
      System.AssertEquals(
        'Retry',
        record.Status__c,
        'Status should have been Retry'
      );

      System.AssertEquals(1, record.Attempts__c, 'Attempts should have been 1');
    }
  }

  @IsTest
  public static void testIntegrationEngineBatchHandleFailuresFailed() {
    List<Integration_Queue__c> preRecords = [
      SELECT Id, Type__c, Status__c
      FROM Integration_Queue__c
    ];

    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();
    Integration_Engine_Mapping__mdt mapping = new Integration_Engine_Mapping__mdt(
      Active__c = true,
      Handler_Class__c = 'MockIntegrationFailureHandler',
      Maximum_Retries__c = 0,
      Type__c = 'Default',
      DeveloperName = 'TestHandler',
      Retain__c = false
    );

    utilities.requestMapping.put('Default', mapping);

    IntegrationEngineBatch batchService = new IntegrationEngineBatch(utilities);

    Test.startTest();
    Database.executeBatch(batchService);
    Test.stopTest();

    List<Integration_Queue__c> records = [
      SELECT Id, Type__c, Status__c, Attempts__c
      FROM Integration_Queue__c
    ];

    System.AssertNotEquals(
      preRecords.size(),
      records.size(),
      'Some records should have succeeded and therefore would have been removed'
    );

    for (Integration_Queue__c record : records) {
      System.AssertEquals(
        'Failed',
        record.Status__c,
        'Status should have been Failed'
      );

      System.AssertEquals(1, record.Attempts__c, 'Attempts should have been 1');
    }
  }
}