@isTest
public class AccountUpdateTest {
    @IsTest
    static void validateAccountUpdate(){
        List<Account> b = new Account(Name = 'Demo10');
        System.debug('Website before inserting new Account: ' b.Website)
        Test.startTest();
        // Insert a new Account
        insert b;
        /*System.runAs(contextuser){
            
        }*/
        Test.stopTest();
        b = [SELECT Website FROM Account WHERE Id =: b.Id];
        System.debug('Website after trigger fired: ' + b.Website);
        System.assertEquals('eysalesforce.com.mx', b.Website);
    }

    }
}
