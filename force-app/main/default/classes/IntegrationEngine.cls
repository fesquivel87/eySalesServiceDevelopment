public with sharing class IntegrationEngine {
  IIntegrationEngineUtilities utilities;

  public IntegrationEngine(IIntegrationEngineUtilities utilities) {
    this.utilities = utilities;
  }

  public Id runNow(Integration_Queue__c integrationQueue) {
    if (utilities.IsOverQueueableJobsLimit()) {
      utilities.LogMessage(
        'Maximimum queueable limit reached. Inserting request to be picked up by the batch integration job'
      );
      return Queue(integrationQueue);
    }

    try {
      Integration_Engine_Mapping__mdt handlerMapping = utilities.GetIntegrationHandlerMapping(
        integrationQueue.Type__c
      );

      IIntegrationHandler handler = utilities.BuildIntegrationHandler(
        handlerMapping,
        integrationQueue.Type__c
      );

      if (handler == null) {
        utilities.LogError(
          string.format(
            'Unable to instantiate integration handler for type: {0}',
            new List<string>{ integrationQueue.Type__c }
          )
        );
        return null;
      }

      IntegrationEngineQueueableWorker worker = new IntegrationEngineQueueableWorker(
        integrationQueue,
        handler,
        utilities,
        handlerMapping
      );

      return System.enqueueJob(worker);
    } catch (Exception ex) {
      utilities.LogError('Failed to execute outbound request', ex);
    }

    return null;
  }

  public Id queue(Integration_Queue__c integrationQueue) {
    Database.SaveResult result = utilities.insertRecords(
      new List<Integration_Queue__c>{ integrationQueue }
    )[0];

    if (result.isSuccess()) {
      return result.getId();
    } else {
      List<IntegrationEngineUtilities.DMLExceptionDetails> errorDetails = new List<IntegrationEngineUtilities.DMLExceptionDetails>();
      for (Database.Error error : result.getErrors()) {
        errorDetails.add(
          new IntegrationEngineUtilities.DMLExceptionDetails(error)
        );
      }

      utilities.LogError(JSON.serialize(errorDetails));
      return null;
    }
  }
}