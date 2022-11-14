@IsTest
public with sharing class Test_IntegrationEngineService {
  @IsTest
  public static void testIntegrationEngineService_scheduleNonFullRetry() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    Test.startTest();
    new IntegrationEngineService(utilities, 10).scheduleBatchJob();
    Test.stopTest();

    List<CronTrigger> cronTriggers = [
      SELECT Id
      FROM CronTrigger
      WHERE CronJobDetail.Name LIKE 'Integration Engine Service - Unit Test -%'
    ];

    system.assertEquals(6, cronTriggers.size());
  }

  @IsTest
  public static void testIntegrationEngineService_scheduleFullRetry() {
    IntegrationEngineUtilities utilities = new IntegrationEngineUtilities();

    Test.startTest();
    new IntegrationEngineService(utilities, 10).scheduleBatchJob(true);
    Test.stopTest();

    List<CronTrigger> cronTriggers = [
      SELECT Id
      FROM CronTrigger
      WHERE CronJobDetail.Name LIKE 'Integration Engine Service - Unit Test -%'
    ];

    system.assertEquals(0, cronTriggers.size());
  }
}