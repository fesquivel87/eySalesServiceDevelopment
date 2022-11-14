public with sharing class MockTriggerHandler extends TriggerHandlerBase {

    public static string ActionPerformed;

    public override void doBeforeInsert(List<SObject> newItems) {
        ActionPerformed = 'Before Insert';
    }

    public override void doBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ActionPerformed = 'Before Update';
    }

    public override void doBeforeDelete(Map<Id, SObject> oldItems) {
        ActionPerformed = 'Before Delete';
    }

    public override void doAfterInsert(Map<Id, SObject> newItems) {
        ActionPerformed = 'After Insert';
    }

    public override void doAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ActionPerformed = 'After Update';
    }

    public override void doAfterDelete(Map<Id, SObject> oldItems) {
        ActionPerformed = 'After Delete';
    }

    public override void doAfterUndelete(Map<Id, SObject> oldItems) {
        ActionPerformed = 'After Undelete';
    }

    public class BlankMockTriggerHandler extends TriggerHandlerBase {

    }

    public class InstantiateExceptionMockTriggerHandler extends TriggerHandlerBase {
        
        public InstantiateExceptionMockTriggerHandler() {
            throw new MockExceptionTriggerHandler.MockTriggerHandlerException('Boom');
        }
    }
}