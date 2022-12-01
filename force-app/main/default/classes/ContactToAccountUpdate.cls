/**
 * @description       : Contains apex logic that updates parent accounts from contacts
 * @author            : Adam Dirks
 * @last modified on  : 12-01-2022
 * @last modified by  : Adam Dirks
**/
public without sharing class ContactToAccountUpdate {

    /**
    * @description Updates Total_Contacts__c on the account if a contact is changed to active or an active cotnact is deleted
    * @author Adam Dirks | 11-30-2022 
    * @param contacts List of contacts. Either the new version of an updated contact or a list of deleted contacts
    * @param oldContactsMap Id to old contact map. Populated for an update trigger, otherwise null
    **/
    public static void updateAccountTotalContacts(List<Contact> contacts, Map<Id, Contact> oldContactsMap){

        //Create a map to store the account ids and the amount to change Total_Contacts__c by
        Map<Id, Integer> acctIdToInteger = new Map<Id, Integer>();

        //Loop through contacts
        for(Contact con : contacts){
            //Grab the old contact, if oldContactsMap is null oldContact is assigned to null
            Contact oldContact = oldContactsMap?.get(con.Id);

            //If the contact is changed to active
            if(con.AccountId != null && con.Active__c && oldContact?.Active__c != true){
                //If the map contains the account id already, assign tempInt to the map value, otherwise assign 0
                Integer tempInt = acctIdToInteger.containsKey(con.AccountId) ? acctIdToInteger.get(con.AccountId) : 0;
                //If this is a delete trigger, subtract 1 from the tempInt, otherwise add 1
                tempInt += Trigger.isDelete ? -1 : 1;
                //Reassign the tempInt back to the accountId in the map
                acctIdToInteger.put(con.AccountId, tempInt);
            }
        }

        //If the map is empty end the method since there's nothing to update
        if(acctIdToInteger.isEmpty()) {
            return;
        }

        //Query the accounts we're going to update so we can adjust the current value of Total_Contacts__c
        List<Account> queriedAccts = [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :acctIdToInteger.keySet()];

        //Loop through the queried accounts
        for(Account acct : queriedAccts){
            //Update the Total_Contacts__c based on it's associated integer in the map
            acct.Total_Contacts__c += acctIdToInteger.get(acct.Id);
        }

        //Double check that there are accounts to update
        if(!queriedAccts.isEmpty()){
            //Update the accounts
            update queriedAccts;
        }
    }
}