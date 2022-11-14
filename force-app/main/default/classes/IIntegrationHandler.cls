public interface IIntegrationHandler {
  object authenticate(
    Integration_Queue__c request,
    IIntegrationEngineUtilities utilities
  );

  object execute(
    object token,
    Integration_Queue__c request,
    IIntegrationEngineUtilities utilities
  );

  void finalize(
    object results,
    Integration_Queue__c request,
    IIntegrationEngineUtilities utilities
  );
}