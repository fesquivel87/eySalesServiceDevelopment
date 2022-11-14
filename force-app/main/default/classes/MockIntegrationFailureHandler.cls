public class MockIntegrationFailureHandler extends MockIntegrationHandler {
  public MockIntegrationFailureHandler() {
    super();
    shouldFailSome = true;
  }

  public class MockIntegrationAllFailureHandler extends MockIntegrationHandler {
    public MockIntegrationAllFailureHandler() {
      super();
      shouldFailAll = true;
    }
  }
}