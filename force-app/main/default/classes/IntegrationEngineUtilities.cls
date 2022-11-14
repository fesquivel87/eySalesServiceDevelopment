public virtual class IntegrationEngineUtilities implements IIntegrationEngineUtilities, Database.AllowsCallouts {
  public Map<string, Integration_Engine_Mapping__mdt> requestMapping {
    get;
    set;
  }

  public IntegrationEngineUtilities() {
    requestMapping = new Map<string, Integration_Engine_Mapping__mdt>();
    requestMapping.putAll(Integration_Engine_Mapping__mdt.getAll());
  }

  public IIntegrationHandler buildIntegrationHandler(
    Integration_Engine_Mapping__mdt handlerMapping,
    string type
  ) {
    if (handlerMapping == null) {
      logError(
        string.format(
          'Unable to find handler mapping for specified type: {0}',
          new List<string>{ type }
        )
      );
      return null;
    }

    if (handlerMapping.Active__c == false) {
      logError(
        string.format(
          'Handler configuration found, but integration is inactive. Type: {0}. Inactive Handler: {1}',
          new List<string>{ type, handlerMapping.DeveloperName }
        )
      );
      return null;
    }

    return getIntegrationHandler(handlerMapping);
  }

  public HttpResponse performRequest(
    string method,
    string endpoint,
    string certificateName,
    Map<string, string> headers,
    blob body
  ) {
    HttpRequest request = buildRequest(method, endpoint, headers, body);
    if (certificateName != null) {
      request.setClientCertificateName(certificateName);
    }
    return executeRequest(request);
  }

  public HttpResponse performRequest(
    string method,
    string endpoint,
    Map<string, string> headers,
    blob body
  ) {
    return executeRequest(buildRequest(method, endpoint, headers, body));
  }

  @testVisible
  private HttpRequest buildRequest(
    string method,
    string endpoint,
    Map<string, string> headers,
    blob body
  ) {
    if (headers == null) {
      headers = new Map<string, string>();
    }

    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint);
    request.setMethod(method);

    for (string headerKey : headers.keySet()) {
      request.setHeader(headerKey, headers.get(headerKey));
    }

    if (body != null) {
      request.setBodyAsBlob(body);
    }

    return request;
  }

  public virtual HttpResponse executeRequest(HttpRequest request) {
    try {
      return new Http().send(request);
    } catch (Exception ex) {
      throw new IntegrationRequestException(ex);
    }
  }

  public virtual void logMessage(string message) {
    System.debug(message);
  }

  public virtual void logError(string message, Exception ex) {
    throw new IntegrationRequestException(message, ex);
  }

  public virtual void logError(string message) {
    throw new IntegrationRequestException(message);
  }

  public virtual boolean isOverQueueableJobsLimit() {
    return Limits.getQueueableJobs() == Limits.getLimitQueueableJobs();
  }

  public Integration_Engine_Mapping__mdt getIntegrationHandlerMapping(
    string type
  ) {
    for (Integration_Engine_Mapping__mdt mapping : requestMapping.values()) {
      if (mapping.Type__c == type) {
        return mapping;
      }
    }

    return null;
  }

  private IIntegrationHandler getIntegrationHandler(
    Integration_Engine_Mapping__mdt handlerMapping
  ) {
    IIntegrationHandler handler = null;

    try {
      handler = (IIntegrationHandler) Type.forName(
          handlerMapping.Handler_Class__c
        )
        .newInstance();
    } catch (NullPointerException e) {
      logError(
        string.format(
          'Error instantiating integration handler: {0}',
          new List<string>{ handlerMapping.DeveloperName }
        ),
        e
      );
    } catch (Exception e) {
      logError(
        string.format(
          'Unexpected error when instantiating integration handler: {0}',
          new List<string>{ handlerMapping.DeveloperName }
        ),
        e
      );
    }

    return handler;
  }

  public virtual void captureFailure(
    Integration_Engine_Mapping__mdt handlerMapping,
    Integration_Queue__c request,
    Exception ex
  ) {
    request.Error_Message__c = ex.getMessage();
    request.Status__c = handlerMapping.Maximum_Retries__c == null ||
      request.Attempts__c > handlerMapping.Maximum_Retries__c
      ? 'Failed'
      : 'Retry';
  }

  public virtual boolean handleRequest(
    Integration_Engine_Mapping__mdt handlerMapping,
    Integration_Queue__c request
  ) {
    try {
      IIntegrationHandler handler = buildIntegrationHandler(
        handlerMapping,
        request.Type__c
      );

      if (request.Attempts__c == null) {
        request.Attempts__c = 1;
      } else {
        request.Attempts__c++;
      }

      object token = handler.authenticate(request, this);
      object results = handler.execute(token, request, this);
      handler.finalize(results, request, this);

      request.Status__c = 'Success';

      return !handlerMapping.Retain__c;
    } catch (Exception ex) {
      captureFailure(handlerMapping, request, ex);
      return false;
    }
  }

  public virtual List<Database.SaveResult> updateRecords(
    List<Integration_Queue__c> toUpdate
  ) {
    Database.DmlOptions options = new Database.DmlOptions();
    options.allowFieldTruncation = true;
    options.optAllOrNone = false;

    return Database.Update(toUpdate, options);
  }

  public virtual List<Database.SaveResult> insertRecords(
    List<Integration_Queue__c> toInsert
  ) {
    Database.DmlOptions options = new Database.DmlOptions();
    options.allowFieldTruncation = true;
    options.optAllOrNone = false;

    return Database.Insert(toInsert, options);
  }

  public List<Database.DeleteResult> deleteRecords(
    List<Integration_Queue__c> toDelete
  ) {
    return Database.Delete(toDelete, false);
  }

  public class IntegrationRequestException extends Exception {
  }

  public class DMLExceptionDetails {
    public string message { get; set; }
    public System.StatusCode statusCode { get; set; }
    public string[] fields { get; set; }

    public DMLExceptionDetails(Database.Error error) {
      message = error.getMessage();
      statusCode = error.getStatusCode();
      fields = error.getFields();
    }
  }
}