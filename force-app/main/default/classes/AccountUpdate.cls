public with sharing class AccountUpdate {
    //Primer commit para lanzar por Jenkins
    public static void updateWebSite(List<Account> acc){
        for (Account acc2 : acc) {
            acc2.Website = 'ey-salesforce.com';
            
        }
    }

}
