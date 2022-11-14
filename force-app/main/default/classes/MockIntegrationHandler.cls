public virtual class MockIntegrationHandler implements IIntegrationHandler {
  public static boolean executedAuthenticate { get; set; }
  public static boolean executedExecute { get; set; }
  public static boolean executedFinalize { get; set; }
  public static boolean shouldFailSome { get; set; }
  public static boolean shouldFailAll { get; set; }

  public MockIntegrationHandler() {
    executedAuthenticate = false;
    executedExecute = false;
    executedFinalize = false;
    shouldFailSome = false;
    shouldFailAll = false;
  }

  public object authenticate(
    Integration_Queue__c request,
    IIntegrationEngineUtilities utilities
  ) {
    executedAuthenticate = true;
    return request;
  }

  public object execute(
    object token,
    Integration_Queue__c request,
    IIntegrationEngineUtilities utilities
  ) {
    if (
      shouldFailAll ||
      (shouldFailSome && Math.mod(Datetime.now().millisecond(), 3) == 0)
    ) {
      throw new IntegrationEngineUtilities.IntegrationRequestException(
        'Some error'
      );
    } else {
      executedExecute = true;
    }

    return request;
  }

  public void finalize(
    object results,
    Integration_Queue__c request,
    IIntegrationEngineUtilities utilities
  ) {
    executedFinalize = true;
    System.debug(results);
  }
}