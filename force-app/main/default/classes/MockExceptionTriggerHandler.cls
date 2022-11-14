public with sharing class MockExceptionTriggerHandler extends TriggerHandlerBase {
    
    public override void doBeforeInsert(List<SObject> newItems) {
        throw new MockTriggerHandlerException('Throw BeforeInsert Exception');
    }

    public override void doBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        throw new MockTriggerHandlerException('Throw BeforeUpdate Exception');
    }

    public override void doBeforeDelete(Map<Id, SObject> oldItems) {
        throw new MockTriggerHandlerException('Throw BeforeDelete Exception');
    }

    public override void doAfterInsert(Map<Id, SObject> newItems) {
        throw new MockTriggerHandlerException('Throw AfterInsert Exception');
    }

    public override void doAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        throw new MockTriggerHandlerException('Throw AfterUpdate Exception');
    }

    public override void doAfterDelete(Map<Id, SObject> oldItems) {
        throw new MockTriggerHandlerException('Throw AfterDelete Exception');
    }

    public override void doAfterUndelete(Map<Id, SObject> oldItems) {
        throw new MockTriggerHandlerException('Throw AfterUndelete Exception');
    }

    public class MockTriggerHandlerException extends Exception {}
}