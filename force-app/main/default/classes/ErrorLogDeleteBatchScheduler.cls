public class ErrorLogDeleteBatchScheduler implements Schedulable  {
    
    public void execute(SchedulableContext SC) {
        Error_Log_Deletion_Batch_Settings__c batchSettings = Error_Log_Deletion_Batch_Settings__c.getInstance();
        Double batchSize = batchSettings.Batch_Size__c;
        Integer batchSizeIntegerValue = Integer.valueOf(batchSize);
        
        Double logKeepDays = batchSettings.Days_To_Keep_Logs__c;
        Integer logKeepDaysIntegerValue = Integer.valueOf(logKeepDays);
        
        Boolean deleteFromRecycleBin = batchSettings.Delete_From_Recycle_Bin__c;
        
        ErrorLogDeleteBatch batchApex = new ErrorLogDeleteBatch(logKeepDaysIntegerValue, deleteFromRecycleBin);
        Database.executeBatch(batchApex, batchSizeIntegerValue); 
    }

}