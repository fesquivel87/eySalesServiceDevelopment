global without sharing class IntegrationEngineService extends IntegrationEngineBatch implements Schedulable, Database.AllowsCallouts, Database.Stateful {
  boolean fullRetry;
  Id cronTriggerId;
  integer minutesBetweenRetries;

  public IntegrationEngineService(
    IIntegrationEngineUtilities utilities,
    integer minutesBetweenRetries
  ) {
    super(utilities);
    this.fullRetry = false;
    this.minutesBetweenRetries = minutesBetweenRetries;
  }

  public IntegrationEngineService(
    IIntegrationEngineUtilities utilities,
    boolean fullRetry,
    integer minutesBetweenRetries
  ) {
    super(utilities);
    this.fullRetry = fullRetry;
    this.minutesBetweenRetries = minutesBetweenRetries;
  }

  public void scheduleBatchJob() {
    ScheduleBatchJob(false);
  }

  public void scheduleBatchJob(boolean fullRetry) {
    if (fullRetry) {
      Database.executeBatch(
        new IntegrationEngineService(utilities, true, 0),
        Limits.getLimitCallouts()
      );
    } else {
      string namePrefix = 'Integration Engine Service ';
      if (Test.isRunningTest()) {
        namePrefix += '- Unit Test -';
      }

      for (integer i = 0; i < (60 / minutesBetweenRetries); i++) {
        system.schedule(
          namePrefix + (i + 1),
          '0 ' +
          i * minutesBetweenRetries +
          ' * ? * *',
          new IntegrationEngineService(utilities, false, minutesBetweenRetries)
        );
      }
    }
  }

  global void execute(SchedulableContext sc) {
    if (sc != null) {
      cronTriggerId = sc.getTriggerId();
    }

    // Each batch assumes that each Integration Queue will kick off a two callouts - Authenticate & Execute.
    Database.executeBatch(this, (Limits.getLimitCallouts() / 2));
  }

  public override Database.QueryLocator start(Database.BatchableContext bc) {
    if (fullRetry == true) {
      return super.start(bc);
    } else {
      DateTime startTime;
      if (cronTriggerId != null) {
        // PreviousFireTime will be when this job started.
        startTime = [
          SELECT PreviousFireTime
          FROM CronTrigger
          WHERE Id = :cronTriggerId
        ]
        .PreviousFireTime;
      }

      if (startTime == null) {
        startTime = system.now();
      }

      return Database.getQueryLocator(
        [
          SELECT
            Id,
            Attempts__c,
            Batch_Job__c,
            Error_Message__c,
            Record_Id__c,
            Request__c,
            Response__c,
            Status__c,
            Submitted__c,
            Type__c
          FROM Integration_Queue__c
          WHERE
            Status__c NOT IN ('Success', 'Failed')
            AND Submitted__c < :startTime.addMinutes(-1 * minutesBetweenRetries)
            AND Submitted__c >= :startTime.addMinutes(
              -2 * minutesBetweenRetries
            )
          ORDER BY Submitted__c
        ]
      );
    }
  }
}