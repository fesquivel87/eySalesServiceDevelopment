public virtual class IntegrationEngineBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
  protected IIntegrationEngineUtilities utilities;
  List<Integration_Queue__c> toUpdate;
  List<Integration_Queue__c> toDelete;

  public IntegrationEngineBatch(IIntegrationEngineUtilities utilities) {
    this.utilities = utilities;
    toUpdate = new List<Integration_Queue__c>();
    toDelete = new List<Integration_Queue__c>();
  }

  public virtual Database.QueryLocator start(Database.BatchableContext bc) {
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
        WHERE Status__c NOT IN ('Success', 'Failed')
        ORDER BY Submitted__c
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<Integration_Queue__c> scope
  ) {
    for (Integration_Queue__c request : scope) {
      boolean shouldDelete = false;
      request.Batch_Job__c = BC.getJobId();

      Integration_Engine_Mapping__mdt handlerMapping = utilities.GetIntegrationHandlerMapping(
        request.Type__c
      );

      try {
        shouldDelete = utilities.handleRequest(handlerMapping, request);
      } catch (Exception ex) {
        utilities.captureFailure(handlerMapping, request, ex);
      }

      if (shouldDelete) {
        toDelete.add(request);
      } else {
        toUpdate.add(request);
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (!toUpdate.isEmpty()) {
      utilities.updateRecords(toUpdate);
    }

    if (!toDelete.isEmpty()) {
      utilities.deleteRecords(toDelete);
    }
  }
}