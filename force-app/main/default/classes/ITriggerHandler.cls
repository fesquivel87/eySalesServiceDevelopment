public interface ITriggerHandler
{
	void doBeforeInsert(List<SObject> newItems);
	void doBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
	void doBeforeDelete(Map<Id, SObject> oldItems);
    void doAfterInsert(Map<Id, SObject> newItems);
	void doAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
	void doAfterDelete(Map<Id, SObject> oldItems);
	void doAfterUndelete(Map<Id, SObject> oldItems);

	void setSharedData(Map<string, List<SObject>> data);
}