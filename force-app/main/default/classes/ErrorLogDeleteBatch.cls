public class ErrorLogDeleteBatch implements Database.Batchable<sObject> {

    private Integer errorLogDaysLimit;
    private Boolean emptyRecycleBin;
	@testVisible
    private static List<Error_Log_Event__e> errorLogs = new List<Error_Log_Event__e>();
    @testVisible
    private static Boolean forceError = false;

	public ErrorLogDeleteBatch(Integer logKeepLimit,Boolean recycleRecords) {
        this.errorLogDaysLimit=logKeepLimit;
        emptyRecycleBin=recycleRecords;
		
    }
    
	public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Error_Log__c
            WHERE CreatedDate <: DateTime.now().addDays(this.errorLogDaysLimit * -1)
        ]);
	}
    
   	public void execute(Database.BatchableContext context, List<sObject> scope) {
       	//Added to force error in Test Class
		if(Test.isRunningTest() && forceError && !scope.isEmpty()){
            delete scope;
        }

        Database.DeleteResult[] drList = Database.delete(scope, false); 
                
        //Added to force error in Test Class
        if(Test.isRunningTest() && forceError && !scope.isEmpty()){
            undelete scope;
        }
        
        if(emptyRecycleBin) {
            database.emptyRecycleBin(scope);
        }

        List<Error_Log_Event__e> logsToPublish = new List<Error_Log_Event__e>();
        for(Database.DeleteResult deleteResult : drList){
            if(!deleteResult.isSuccess()){
                List<string> errorDetails = new List<string>();
                errorDetails.add('Failed to delete Error Log record');
                for(Database.Error error : deleteResult.getErrors()){
                    errorDetails.add('The following error occurred.');
                    errorDetails.add(string.Format('{0}: {1}', new List<string> {error.getStatusCode().name(), error.getMessage()}));
                    errorDetails.add(string.Format('Fields that affected this error: {0}', new List<string> { string.Join(error.getFields(), ', ') }));
                }
         
                Error_Log_Event__e resultErrorLog = ErrorLog.logError(
                    ErrorLog.ErrorLocation.BatchJob, string.join(errorDetails, '\n'),
                    'ErrorLogDeleteBatch', true, false);

                logsToPublish.add(resultErrorLog);
                errorLogs.add(resultErrorLog);
            }
        }

        if (logsToPublish.size() > 0) {
            ErrorLog.publishErrorLogEvents(logsToPublish);
        }
	}
    
    public void finish(Database.BatchableContext context) {}

}