public interface IIntegrationEngineUtilities {
  IIntegrationHandler buildIntegrationHandler(
    Integration_Engine_Mapping__mdt handlerMapping,
    string type
  );

  Integration_Engine_Mapping__mdt getIntegrationHandlerMapping(string type);

  HttpResponse performRequest(
    string method,
    string endpoint,
    string certificateName,
    Map<string, string> headers,
    blob body
  );

  HttpResponse performRequest(
    string method,
    string endpoint,
    Map<string, string> headers,
    blob body
  );

  HttpResponse executeRequest(HttpRequest request);

  void logMessage(string message);

  void logError(string message);

  void logError(string message, Exception ex);

  boolean isOverQueueableJobsLimit();

  void captureFailure(
    Integration_Engine_Mapping__mdt handlerMapping,
    Integration_Queue__c request,
    Exception ex
  );

  boolean handleRequest(
    Integration_Engine_Mapping__mdt handlerMapping,
    Integration_Queue__c request
  );

  List<Database.SaveResult> updateRecords(List<Integration_Queue__c> toUpdate);
  List<Database.SaveResult> insertRecords(List<Integration_Queue__c> toInsert);
  List<Database.DeleteResult> deleteRecords(
    List<Integration_Queue__c> toDelete
  );
}