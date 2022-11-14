public with sharing class MockIntegrationUtilities extends IntegrationEngineUtilities {
  public boolean isOver { get; set; }

  public MockIntegrationUtilities() {
    isOver = false;
  }

  public override boolean isOverQueueableJobsLimit() {
    return isOver;
  }

  public override void logError(string message, Exception ex) {
    System.debug(message);
  }

  public override void logError(string message) {
    System.debug(message);
  }
}