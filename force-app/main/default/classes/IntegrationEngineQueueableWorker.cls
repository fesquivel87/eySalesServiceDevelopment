public with sharing class IntegrationEngineQueueableWorker implements Queueable, Database.AllowsCallouts {
  private Integration_Queue__c outboundRequest;
  private IIntegrationHandler handler;
  private IIntegrationEngineUtilities utilities;
  private Integration_Engine_Mapping__mdt handlerMapping;

  public IntegrationEngineQueueableWorker(
    Integration_Queue__c outboundRequest,
    IIntegrationHandler handler,
    IIntegrationEngineUtilities utilities,
    Integration_Engine_Mapping__mdt handlerMapping
  ) {
    this.outboundRequest = outboundRequest;
    this.handler = handler;
    this.utilities = utilities;
    this.handlerMapping = handlerMapping;
  }

  public void execute(QueueableContext context) {
    boolean shouldInsert = false;

    Integration_Engine_Mapping__mdt handlerMapping = utilities.GetIntegrationHandlerMapping(
      outboundRequest.Type__c
    );

    try {
      shouldInsert = !utilities.handleRequest(handlerMapping, outboundRequest);
    } catch (Exception ex) {
      shouldInsert = true;
      utilities.captureFailure(handlerMapping, outboundRequest, ex);
    }

    if (shouldInsert) {
      utilities.insertRecords(
        new List<Integration_Queue__c>{ outboundRequest }
      );
    }
  }
}