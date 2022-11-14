@isTest
public class FlowErrorLogEventAfterPublishTest {
    
    @isTest
    private static void testErrogLogEventErrorInsert(){
        List<Error_Log_Event__e> errorEvents = new List<Error_Log_Event__e>();
		errorEvents.add(new Error_Log_Event__e(Apex_Class_Flow_Name__c = 'ApexTriggerTest',
            Error_Location__c = 'Apex Trigger', Error_Message__c = 'TestMessage',
            Silent_Error__c = true)); 

        errorEvents.add(new Error_Log_Event__e(Apex_Class_Flow_Name__c = 'ApexTriggerTest',
            Error_Location__c = 'Apex Trigger', Error_Message__c = 'TestMessage',
            Silent_Error__c = true));

        errorEvents.add(new Error_Log_Event__e(Apex_Class_Flow_Name__c = 'ApexTriggerTest',
            Error_Location__c = 'Apex Trigger', Error_Message__c = 'TestMessage',
            Silent_Error__c = true));
        
 		Test.startTest();
			EventBus.publish(errorEvents);
        Test.stopTest();
        
        List<Error_Log__c> log = [SELECT Id,
                                      Apex_Class_Flow_Name__c,
                                      Error_Message__c,
                                      Silent_Error__c,
                                      Error_Location__c
                          		FROM Error_Log__c];
        
        System.assertEquals(3, log.size(),'Should Have Generated an Error Log');
        for(Error_Log__c logDetail:log) {
            System.assertEquals('ApexTriggerTest', logDetail.Apex_Class_Flow_Name__c);
            System.assertEquals('Apex Trigger', logDetail.Error_Location__c);
            System.assertEquals('TestMessage', logDetail.Error_Message__c);
            System.assertEquals(true, logDetail.Silent_Error__c);  
        }       
    }
}