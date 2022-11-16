public with sharing class AccountUpdate {
    public static void updateWebSite(List<Account> acc){
        for (Account acc2 : acc) {
            acc2.Website = 'eysalesforce.com.mx'
        }
    }

}
