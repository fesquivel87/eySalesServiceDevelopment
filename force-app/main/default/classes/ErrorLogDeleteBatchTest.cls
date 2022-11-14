@isTest
public class ErrorLogDeleteBatchTest {
    private static Integer logCount = 40;
    private static Integer logDaysLimit = 10;
    private static DateTime createdDateBefore = DateTime.now().addDays((logDaysLimit+1) * -1);
    private static DateTime createdDateAfter = DateTime.now();

    @testSetup
    public static void testSetupMethod(){
        
        Error_Log_Deletion_Batch_Settings__c settings = ErrorLogTestUtils.getError_Log_Deletion_Batch_Settings();
        settings.Days_To_Keep_Logs__c = logDaysLimit;
        settings.Delete_From_Recycle_Bin__c = true;
        upsert settings;
        
        List<Error_Log__c> logs = new List<Error_Log__c>();
        for(Integer i = 0; i<logCount; i++) {
            if (Math.mod(i, 2) == 0) {
            	Error_Log__c logRecord = ErrorLogTestUtils.createErrorLog('Batch Job', false);
                logs.add(logRecord);
            }
            else {
                Error_Log__c logRecord = ErrorLogTestUtils.createErrorLog('Flow', false);
                logs.add(logRecord);
            }
            
        }
        
        insert logs;
        
        for(Error_Log__c log:logs) {
            if(log.Error_Location__c == 'Batch Job'){
                Test.setCreatedDate(log.Id, createdDateBefore);
            }
            else if (log.Error_Location__c == 'Flow') {
                Test.setCreatedDate(log.Id, createdDateAfter);
            }
        }
        
    }
    
    @isTest
    private static void verifyErrorLogDeletionScheduler(){
      	       
        Test.startTest();
        	ErrorLogDeleteBatchScheduler scheduler =new ErrorLogDeleteBatchScheduler();
        	scheduler.execute(null);
        Test.stopTest();

        List<Error_Log__c> logs = [SELECT Id, Error_Location__c
                                   FROM Error_Log__c];
        
        System.assertEquals(logCount/2, logs.size(),
            'Error log records created before Log Days Limit should get deleted');

        for(Error_Log__c log:logs) {
        	System.assertEquals('Flow', log.Error_Location__c, 
                'Error log records at Location Batch Job should get deleted');   
        }  
    }
    
    @isTest
    private static void verifyErrorLogDeletionBatchForceError(){
        Test.startTest();
        	ErrorLogDeleteBatchScheduler scheduler =new ErrorLogDeleteBatchScheduler();
        	ErrorLogDeleteBatch.forceError = true;
        	scheduler.execute(null);
        Test.stopTest();
        
        List<Error_Log__c> logs = [Select Id,Error_Location__c from Error_Log__c];
        
        System.assertEquals(logCount+logCount/2, logs.size(),
            'Error log records created before Log Days Limit should not get deleted on force error');

        System.assertEquals(logCount/2, ErrorLogDeleteBatch.errorLogs.size(),
            'Should create error log when force error is true') ;
    }
    
    @isTest
    private static void verifyErrorLogDeletionBatchWithNoRecords(){
      	List<Error_Log__c> logs = [Select Id,Error_Location__c from Error_Log__c];
        delete logs;
        
        Test.startTest();
        	ErrorLogDeleteBatch batchApex = new ErrorLogDeleteBatch(logDaysLimit,true);
        	Database.executeBatch(batchApex);
        Test.stopTest();
		
        System.assertEquals(0, ErrorLogDeleteBatch.errorLogs.size(),
            'Should not generate any error when no records are present for deletion') ;
    }
}