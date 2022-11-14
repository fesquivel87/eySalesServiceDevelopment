public abstract class TriggerHandlerBase implements ITriggerHandler {
    public Map<string, List<SObject>> SharedData;

    public virtual void doBeforeInsert(List<SObject> newItems) { return; }
	public virtual void doBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { return; }
	public virtual void doBeforeDelete(Map<Id, SObject> oldItems) { return; }
    public virtual void doAfterInsert(Map<Id, SObject> newItems) { return; }
	public virtual void doAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { return; }
	public virtual void doAfterDelete(Map<Id, SObject> oldItems) { return; }
	public virtual void doAfterUndelete(Map<Id, SObject> oldItems) { return; }

    public virtual void setSharedData(Map<string, List<SObject>> data) {
        this.SharedData = data;
    }
}