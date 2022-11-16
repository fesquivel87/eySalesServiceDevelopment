trigger AccountUpdateTrigger on Account (before insert) {
    List<Account> accToUpdate = Trigger.new;
    AccountUpdate.updateWebSite(accToUpdate);
}