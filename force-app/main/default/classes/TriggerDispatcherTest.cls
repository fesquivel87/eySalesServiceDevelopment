@isTest
public class TriggerDispatcherTest {

    private static Integer s_num = 1;

    private static string getFakeId(Schema.SobjectType sot) {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
    }

    @TestSetup
    public static void setup(){
        Profile sysAdmin = [select id from Profile WHere Name = 'System Administrator' LIMIT 1];
        User newUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john@doe.com',
            Username = 'john.doe.test@doe.com',
            Alias = 'JDoe',
            ProfileId = sysAdmin.Id,
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'America/Chicago', 
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessBeforeInsert() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;

        performSuccessfulTest(utilities, 'Before Insert');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionBeforeInsert() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;

        performExceptionTest(utilities, 'Throw BeforeInsert Exception');
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessBeforeUpdate() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_UPDATE;

        performSuccessfulTest(utilities, 'Before Update');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionBeforeUpdate() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_UPDATE;

        performExceptionTest(utilities, 'Throw BeforeUpdate Exception');
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessBeforeDelete() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_DELETE;

        performSuccessfulTest(utilities, 'Before Delete');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionBeforeDelete() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_DELETE;

        performExceptionTest(utilities, 'Throw BeforeDelete Exception');
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessAfterInsert() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_INSERT;

        performSuccessfulTest(utilities, 'After Insert');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionAfterInsert() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_INSERT;

        performExceptionTest(utilities, 'Throw AfterInsert Exception');
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessAfterUpdate() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_UPDATE;

        performSuccessfulTest(utilities, 'After Update');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionAfterUpdate() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_UPDATE;

        performExceptionTest(utilities, 'Throw AfterUpdate Exception');
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessAfterDelete() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_DELETE;

        performSuccessfulTest(utilities, 'After Delete');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionAfterDelete() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_DELETE;

        performExceptionTest(utilities, 'Throw AfterDelete Exception');
    }

    @isTest
    public static void Test_TriggerDispatcher_SuccessAfterUndelete() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_UNDELETE;

        performSuccessfulTest(utilities, 'After Undelete');
    }

    @isTest
    public static void Test_TriggerDispatcher_ExceptionAfterUndelete() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.AFTER_UNDELETE;

        performExceptionTest(utilities, 'Throw AfterUndelete Exception');
    }

    private static void performSuccessfulTest(MockTriggerUtilities utilities, string expectedMessage) {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);
        
        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            DeveloperName = 'UserQueryName',
            MasterLabel = 'UserQueryLabel',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        Trigger_Handler_Bypass__mdt triggerHandlerBypass = new Trigger_Handler_Bypass__mdt (
            Trigger_Handler__c = settingId,
            User_Name__c = 'john.doe.test@doe.com'
        );

        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        
        utilities.triggerHandlerBypasses = new List<Trigger_Handler_Bypass__mdt> { triggerHandlerBypass };

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        List<User> users = [SELECT Email FROM User];

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();

                System.assertEquals(expectedMessage, MockTriggerHandler.ActionPerformed, 'Did not perform correct action');
                SYstem.assert(dispatcher.sharedQueryData.containsKey('UserQueryName'), 'Should have had query data');
                System.assertEquals(users.size(), dispatcher.sharedQueryData.get('UserQueryName').size(), 'Did not have expected record count');
            } catch (Exception ex) {
                System.assert(false, 'Should not have thrown exception');
            }
        Test.stopTest();
    }

    private static void performExceptionTest(MockTriggerUtilities utilities, string message) {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);
        
        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockExceptionTriggerHandler',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();
                System.assert(false, 'Should have thrown exception');
            } catch (MockExceptionTriggerHandler.MockTriggerHandlerException ex) {
                System.assert(true, 'Should have thrown exception');
                System.assertEquals(message, ex.getMessage(), 'Unexpected message');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_MaxLoopException() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account',
            Maximum_Loop_Count__c = 3,
            MasterLabel = 'MockTrigger'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);

                //Increment to 1
                dispatcher.addToLoopCount(triggerSetting);

                //Increment to 2
                dispatcher.addToLoopCount(triggerSetting);

                //Increment to 3 -- this is the max. Running should cause an exception
                dispatcher.addToLoopCount(triggerSetting);

                dispatcher.run();

                System.assert(false, 'Should have thrown exception');
            } catch (TriggerDispatcher.TriggerDispatcherException ex) {
                System.assert(true, 'Should have thrown exception');
                System.assertEquals(String.format('Maximum loop count of {0} reached in {1}', new List<string> { String.valueOf(triggerSetting.Maximum_Loop_Count__c), triggerSetting.MasterLabel }), ex.getMessage(), 'Unexpected message');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_MaxLoopException_Ignore() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account',
            Maximum_Loop_Count__c = -1,
            MasterLabel = 'MockTrigger'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);

                //Increment to 1
                dispatcher.addToLoopCount(triggerSetting);

                //Increment to 2
                dispatcher.addToLoopCount(triggerSetting);

                //Increment to 3 -- this is the max. Running should cause an exception
                dispatcher.addToLoopCount(triggerSetting);

                dispatcher.run();

                System.assertEquals('Before Insert', MockTriggerHandler.ActionPerformed, 'Wrong Action Performed');
            } catch (TriggerDispatcher.TriggerDispatcherException ex) {
                System.assert(false, 'Should not have thrown exception');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_ExceptionClassDoesntExist() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account',
            Maximum_Loop_Count__c = 3,
            MasterLabel = 'MockTrigger'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandlerFake',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();

                System.assert(false, 'Should have thrown exception');
            } catch (NullPointerException ex) {
                System.assert(true, 'Should have thrown exception');
            } catch(Exception ex) {
                System.assert(false, 'Wrong Exception Type Thrown');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_ExceptionCannotInstantiateHandler() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account',
            Maximum_Loop_Count__c = 3,
            MasterLabel = 'MockTrigger'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler.InstantiateExceptionMockTriggerHandler',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();

                System.assert(false, 'Should have thrown exception');
            } catch (MockExceptionTriggerHandler.MockTriggerHandlerException ex) {
                System.assert(true, 'Should have thrown exception');
            } catch(Exception ex) {
                System.assert(false, 'Wrong Exception Type Thrown');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_NoTriggerSettingsForObject() {
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt>();
        utilities.triggerHandlers = new List<Trigger_Handler__mdt>();
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt>();

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();
                System.assert(false, 'Should have thrown exception');
            } catch (TriggerDispatcher.TriggerDispatcherException ex) {
                System.assertEquals(ex.getMessage(), 'Could not find trigger settings for Account object', 'Messages do not match');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_NoTriggerHandlersForObject() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account'
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt>();

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();
                System.assert(false, 'Should have thrown exception');
            } catch (TriggerDispatcher.TriggerDispatcherException ex) {
                System.assertEquals(ex.getMessage(), 'Could not find any active trigger handlers for Account object', 'Messages do not match');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_NoActiveTriggerHandlersForObject() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = false,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler',
            Trigger_Setting__c = settingId
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();
                System.assert(false, 'Should have thrown exception');
            } catch (TriggerDispatcher.TriggerDispatcherException ex) {
                System.assertEquals(ex.getMessage(), 'Could not find any active trigger handlers for Account object', 'Messages do not match');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_DoNotAllowTriggerBypass() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = false,
            SObject__c = 'Account'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler',
            Trigger_Setting__c = settingId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );
        
        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;

        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };        

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                dispatcher.run();

                System.assertEquals('Before Insert', MockTriggerHandler.ActionPerformed, 'Wrong Action Performed');
            } catch (Exception ex) {
                System.assert(false, 'Should not have thrown exception');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_HandleTriggerBypass() {
        string settingId = getFakeId(Trigger_Setting__mdt.SobjectType);
        string handlerId = getFakeId(Trigger_Handler__mdt.SobjectType);

        Trigger_Setting__mdt triggerSetting = new Trigger_Setting__mdt (
            Id = settingId,
            Allow_Bypass__c = true,
            SObject__c = 'Account'
        );

        Trigger_Handler__mdt triggerHandler = new Trigger_Handler__mdt (
            Active__c = true,
            Execution_Order__c = 0,
            Handler_Class__c = 'MockTriggerHandler',
            Trigger_Setting__c = settingId,
            Id = handlerId
        );

        Trigger_Shared_Query__mdt sharedDataQuery = new Trigger_Shared_Query__mdt (
            MasterLabel = 'UserQuery',
            SOQL__c = 'SELECT Email FROM User',
            Trigger_Setting__c = settingId
        );

        Trigger_Handler_Bypass__mdt triggerHandlerBypass = new Trigger_Handler_Bypass__mdt (
            Trigger_Handler__c = handlerId,
            User_Name__c = 'john.doe.test@doe.com'
        );

        MockTriggerUtilities utilities = new MockTriggerUtilities();
        utilities.triggerOperation = System.TriggerOperation.BEFORE_INSERT;
        utilities.triggerSettings = new List<Trigger_Setting__mdt> { triggerSetting };
        utilities.triggerHandlers = new List<Trigger_Handler__mdt> { triggerHandler };
        utilities.triggerSharedDataQueries = new List<Trigger_Shared_Query__mdt> { sharedDataQuery };  
        utilities.triggerHandlerBypasses = new List<Trigger_Handler_Bypass__mdt> { triggerHandlerBypass };

        utilities.triggerNew = new List<Account>();
        utilities.triggerNewMap = new Map<Id, Account>();
        utilities.triggerOldMap = new Map<Id, Account>();

        utilities.triggerObject = 'Account';

        User runningUser = [SELECT Id from User where Username =: triggerHandlerBypass.User_Name__c LIMIT 1];

        Test.startTest();
            try {
                System.RunAs(runningUser) {
                    TriggerDispatcher dispatcher = new TriggerDispatcher(utilities);
                    dispatcher.run();
                }

                System.assertEquals(null, MockTriggerHandler.ActionPerformed, 'Should have been bypassed');
            } catch (Exception ex) {
                System.assert(false, 'Should not have thrown exception');
            }
        Test.stopTest();
    }

    @isTest
    private static void Test_TriggerDispatcher_UseNonMockTriggerUtilities() {
        Test.startTest();
            try {
                TriggerDispatcher dispatcher = new TriggerDispatcher(new TriggerUtilities());
                dispatcher.run();
            } catch (Exception ex) {
                System.assert(false, 'Should not have thrown exception');
            }
        Test.stopTest();
    }
}